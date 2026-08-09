"""Tibia gameplay video -> design analysis via the adapted Foreman pipeline.

Stages (all resumable, all local under drafts/_tibia-videos/):
  1. frames:  ffmpeg samples 1 frame every N seconds -> <id>_frames/
  2. dedup:   perceptual-hash dedup (Foreman frames.py pattern) -> keeps only
              frames where the screen actually changed
  3. analyze: batches of <=20 frames -> Bedrock vision (Fable) with a
              game-designer + Tibia-veteran persona, per-batch JSON notes
  4. synth:   one call merges all batch notes into a design brief

Usage: python harness/video_analyst.py <video_id> "<lens prompt>"
Output: drafts/_tibia-videos/<id>_analysis.md
"""

from __future__ import annotations

import io
import json
import subprocess
import sys
import time
from pathlib import Path

import boto3
import imagehash
from botocore.config import Config as BotoConfig
from botocore.exceptions import ConnectionError as BotoConnectionError
from botocore.exceptions import ReadTimeoutError
from PIL import Image

PROFILE = "voice-dev"
REGION = "us-east-1"
MODEL = "us.anthropic.claude-fable-5"
FRAME_EVERY_S = 2
PHASH_THRESHOLD = 6      # Foreman default: >6 bits difference = new frame
MAX_PER_BATCH = 20       # Bedrock converse image cap
MAX_BATCHES = 8          # spend tripwire per video
_ATTEMPTS = 3

BASE = Path("drafts/_tibia-videos")

PERSONA = """You are a senior game designer doing competitive analysis of Tibia
(CipSoft's 2D grid MMO) for a small action-RPG rebuild project. You are ALSO a
long-time Tibia player who knows the game's feel from thousands of hours.
You are watching gameplay footage as sampled frames (1 every ~2s, deduplicated).
Read the UI, the battle list, creature positions, player movement between
frames, and infer the moment-to-moment mechanics and decisions."""


def _client():
    session = boto3.Session(profile_name=PROFILE, region_name=REGION)
    return session.client("bedrock-runtime", config=BotoConfig(read_timeout=300))


def converse(client, content_blocks: list[dict], max_tokens: int = 8000) -> str:
    kwargs = {
        "modelId": MODEL,
        "messages": [{"role": "user", "content": content_blocks}],
        "system": [{"text": PERSONA}],
        "inferenceConfig": {"maxTokens": max_tokens},
    }
    for attempt in range(1, _ATTEMPTS + 1):
        try:
            resp = client.converse_stream(**kwargs)
            parts: list[str] = []
            for event in resp["stream"]:
                delta = event.get("contentBlockDelta", {}).get("delta", {})
                if "text" in delta:
                    parts.append(delta["text"])
            return "".join(parts).strip()
        except (client.exceptions.ThrottlingException, BotoConnectionError, ReadTimeoutError):
            if attempt == _ATTEMPTS:
                raise
            time.sleep(30)
    raise RuntimeError("unreachable")


def extract_frames(video_id: str) -> Path:
    video = BASE / f"{video_id}.mp4"
    out_dir = BASE / f"{video_id}_frames"
    if out_dir.exists() and any(out_dir.glob("*.jpg")):
        return out_dir
    out_dir.mkdir(exist_ok=True)
    subprocess.run(
        ["ffmpeg", "-i", str(video), "-vf", f"fps=1/{FRAME_EVERY_S}",
         "-q:v", "4", str(out_dir / "f%05d.jpg"), "-loglevel", "error"],
        check=True,
    )
    return out_dir


def dedup_frames(frames_dir: Path) -> list[Path]:
    files = sorted(frames_dir.glob("f*.jpg"))
    kept: list[Path] = []
    last_hash = None
    for f in files:
        h = imagehash.phash(Image.open(io.BytesIO(f.read_bytes())))
        if last_hash is None or (h - last_hash) > PHASH_THRESHOLD:
            kept.append(f)
            last_hash = h
    return kept


BATCH_PROMPT = """Frames {a}-{b} of {total} (chronological, ~{every}s apart, times shown per frame).

LENS: {lens}

Return JSON only:
{{
  "observed_mechanics": [{{"mechanic": "...", "evidence": "frame/time", "detail": "how it works, with any numbers you can read (cooldowns, damage, HP, speeds)"}}],
  "movement_notes": ["how the character/creatures move on the grid this segment"],
  "combat_cadence": ["attack timing, cooldown indicators, exhaust bars, rotation patterns you can see"],
  "positioning_play": ["chokepoints, blocking, kiting, formation — spatial decisions visible here"],
  "ui_reads": ["what the UI communicates and how (hotkeys, battle list, cooldown ring...)"],
  "designer_takeaways": ["what a small grid ARPG should copy or deliberately reject, based on THIS segment"]
}}"""

SYNTH_PROMPT = """Below are your own segment-by-segment analysis notes from one Tibia video
("{title}"). Merge them into ONE design brief for game-two (a Ruby 2D grid
action-RPG: 32px tiles, tile-stepped movement, one attack verb + dodge,
hitstop/shake feel layer, hub town + dungeon).

LENS: {lens}

Markdown, these sections:
# What this video teaches
## Core mechanics observed (with evidence)
## Combat cadence and cooldown model (be precise — this informs an attack-exhaust redesign)
## Movement and positioning doctrine
## What game-two should adopt (ranked, concrete)
## What game-two should reject (and why)

NOTES:
{notes}"""


def main() -> None:
    if len(sys.argv) < 3:
        sys.exit('usage: python harness/video_analyst.py <video_id> "<lens>"')
    video_id, lens = sys.argv[1], sys.argv[2]
    title = sys.argv[3] if len(sys.argv) > 3 else video_id

    frames_dir = extract_frames(video_id)
    kept = dedup_frames(frames_dir)
    print(f"{video_id}: {len(list(frames_dir.glob('f*.jpg')))} frames -> {len(kept)} after dedup")

    # Uniform thinning to the batch budget (Foreman dedup() tail behavior).
    budget = MAX_PER_BATCH * MAX_BATCHES
    if len(kept) > budget:
        step = len(kept) / budget
        kept = [kept[int(i * step)] for i in range(budget)]

    client = _client()
    notes: list[str] = []
    cache_dir = BASE / f"{video_id}_notes"
    cache_dir.mkdir(exist_ok=True)
    batches = [kept[i:i + MAX_PER_BATCH] for i in range(0, len(kept), MAX_PER_BATCH)]
    for bi, batch in enumerate(batches):
        cache = cache_dir / f"batch-{bi:02d}.json"
        if cache.exists():
            notes.append(cache.read_text(encoding="utf-8"))
            continue
        blocks: list[dict] = []
        for f in batch:
            t = int(f.stem[1:]) * FRAME_EVERY_S
            blocks.append({"text": f"[t={t // 60}:{t % 60:02d}]"})
            blocks.append({"image": {"format": "jpeg", "source": {"bytes": f.read_bytes()}}})
        blocks.append({"text": BATCH_PROMPT.format(
            a=bi * MAX_PER_BATCH + 1, b=bi * MAX_PER_BATCH + len(batch),
            total=len(kept), every=FRAME_EVERY_S, lens=lens)})
        print(f"  batch {bi + 1}/{len(batches)} ({len(batch)} frames)...")
        text = converse(client, blocks)
        cache.write_text(text, encoding="utf-8")
        notes.append(text)

    print("  synthesizing...")
    brief = converse(client, [{"text": SYNTH_PROMPT.format(
        title=title, lens=lens, notes="\n\n---\n\n".join(notes))}], max_tokens=16000)
    out = BASE / f"{video_id}_analysis.md"
    out.write_text(f"# Video analysis: {title} ({video_id})\n\nLens: {lens}\n\n{brief}\n",
                   encoding="utf-8")
    print(f"wrote {out}")


if __name__ == "__main__":
    main()
