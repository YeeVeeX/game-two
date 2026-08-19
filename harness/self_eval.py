"""Self-evaluation: OUR OWN gameplay clips -> quality critique (flywheel lane 2).

Adapted from video_analyst.py (Tibia competitive analysis) on 2026-08-19,
owner direction: evaluate whether the build reads as appealing / entertaining
/ fluid — and what to improve — using the SAME vision machinery.

Key difference vs video_analyst: the persona knows game-two's art is
DELIBERATE placeholder geometry (assets integration is a parked lane), so it
scores STRUCTURE (readability, juice, pacing, moment-to-moment loop) separately
from ASSET POLISH (recorded for the assets era, never conflated). Rubric
grounded in the verified KB shelf (game-research + uiux-design):
juice is a multiplier not base value; shake 0.1-0.3s / hitstop family numbers;
action readability & visual hierarchy; HEART visual-appeal axis kept separate.

Input: a frames dir from make_clip.sh (tmp/clip_*/video/*.png — lossless,
deterministic) or an mp4 (falls back to ffmpeg sampling like the Tibia lane).

Usage:
  python harness/self_eval.py tmp/clip_world_loop_<ts>/video "<focus, optional>"
Output:
  drafts/_self-eval/<clip_name>_critique.md (+ cached batch notes beside it)

Spend rails: MAX_BATCHES tripwire + per-batch cache (re-runs free). ~$2-5/clip.
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
SIM_FPS = 60             # sim frames per second (tick-locked)
PHASH_THRESHOLD = 6
MAX_PER_BATCH = 20
MAX_BATCHES = 8          # spend tripwire per clip
_ATTEMPTS = 3

OUT_BASE = Path("drafts/_self-eval")

PERSONA = """You are a senior game-feel critic and combat designer reviewing an
IN-DEVELOPMENT build of a 2D grid action-RPG (Ruby+Gosu, 32px tiles,
tile-stepped movement, possession-swap party of three, hub + dungeon zones).

CRITICAL CONTEXT: every sprite is a DELIBERATE placeholder (colored geometry,
generic ZONE/BOSS names) — the asset pipeline is a separate parked lane. Never
score the placeholder art itself. Score the STRUCTURE underneath it:
- ACTION READABILITY: can you tell what is happening — who hit whom, what
  killed you, where the threat is — from motion, layout and feedback alone?
- GAME FEEL / JUICE: hitstop, screen shake, knockback, flashes, death
  feedback. Juice multiplies a good core loop; it never replaces one.
- FLUIDITY / PACING: movement cadence, downtime vs pressure, fight rhythm,
  respawn/walk-back time. Note dead air and button-mash monotony.
- MOMENT-TO-MOMENT LOOP: is there visible decision-making (positioning,
  kiting, retreat, banking) or random-looking churn?
- ASSET-ERA LEVERAGE (separate list): what upgrades would multiply the
  existing structure most (animation frames, silhouettes, palettes, VFX).
You are watching sampled frames with timestamps. Evidence-cite every claim
(frame time). Unknown = say unknown, never guess."""

BATCH_PROMPT = """Frames {a}-{b} of {total} (chronological, sim-time stamps shown per frame).

FOCUS: {lens}

Return JSON only:
{{
  "readability": [{{"observation": "...", "evidence": "t=...", "severity": "good|minor|major"}}],
  "feel_juice": [{{"observation": "...", "evidence": "t=...", "severity": "good|minor|major"}}],
  "fluidity_pacing": [{{"observation": "...", "evidence": "t=...", "severity": "good|minor|major"}}],
  "loop_engagement": [{{"observation": "...", "evidence": "t=...", "severity": "good|minor|major"}}],
  "asset_leverage": ["upgrade that would multiply this segment most"],
  "standout_moments": ["anything that already reads as exciting/satisfying, with evidence"]
}}"""

SYNTH_PROMPT = """Below are your own segment notes from one deterministic gameplay clip
("{title}") of game-two. Merge them into ONE quality critique for the dev.

FOCUS: {lens}

Markdown, these sections, evidence-cited throughout:
# Clip critique: {title}
## Verdict in three lines (appealing? entertaining? fluid? — honest, structure-only)
## Scores (0-10 with one-line justification each): readability / feel-juice / fluidity-pacing / loop-engagement
## What already works (keep + amplify)
## Top issues (ranked, each with evidence + a concrete, small fix candidate)
## Asset-era leverage (separate — what better assets would multiply, ranked)
## What to re-check on the next clip (so fixes are verifiable against the same script)

NOTES:
{notes}"""


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


def collect_frames(source: Path) -> tuple[str, list[tuple[float, Path]]]:
    """Returns (clip_name, [(sim_seconds, png_path), ...]).

    Preferred: a make_clip.sh video dir of v_%06d.png dumps (VIDEO_EVERY
    spacing is recovered from the replay manifest dir name being absent —
    we derive time as index * every / SIM_FPS with every read from env or
    defaulting to 2, matching make_clip.sh).
    """
    every = int(json.loads((source.parent / "clip_meta.json").read_text())["every"]) \
        if (source.parent / "clip_meta.json").exists() else 2
    if source.is_dir():
        frames = sorted(source.glob("v_*.png"))
        name = source.parent.name
        return name, [(int(f.stem[2:]) * every / SIM_FPS, f) for f in frames]
    # mp4 fallback: sample like the Tibia lane
    out_dir = source.with_suffix("")
    out_dir.mkdir(exist_ok=True)
    if not any(out_dir.glob("f*.jpg")):
        subprocess.run(
            ["ffmpeg", "-i", str(source), "-vf", "fps=2",
             "-q:v", "4", str(out_dir / "f%05d.jpg"), "-loglevel", "error"],
            check=True,
        )
    frames = sorted(out_dir.glob("f*.jpg"))
    return source.stem, [((int(f.stem[1:]) - 1) / 2.0, f) for f in frames]


def dedup(frames: list[tuple[float, Path]]) -> list[tuple[float, Path]]:
    kept: list[tuple[float, Path]] = []
    last_hash = None
    for t, f in frames:
        h = imagehash.phash(Image.open(io.BytesIO(f.read_bytes())))
        if last_hash is None or (h - last_hash) > PHASH_THRESHOLD:
            kept.append((t, f))
            last_hash = h
    return kept


def to_jpeg_bytes(path: Path) -> bytes:
    if path.suffix == ".jpg":
        return path.read_bytes()
    buf = io.BytesIO()
    Image.open(path).convert("RGB").save(buf, "JPEG", quality=88)
    return buf.getvalue()


def main() -> None:
    if len(sys.argv) < 2:
        sys.exit('usage: python harness/self_eval.py <frames_dir|clip.mp4> ["<focus>"]')
    source = Path(sys.argv[1])
    lens = sys.argv[2] if len(sys.argv) > 2 else (
        "General quality pass: is this appealing, entertaining and fluid? "
        "What should we improve first?")

    name, frames = collect_frames(source)
    kept = dedup(frames)
    print(f"{name}: {len(frames)} frames -> {len(kept)} after dedup")

    budget = MAX_PER_BATCH * MAX_BATCHES
    if len(kept) > budget:
        step = len(kept) / budget
        kept = [kept[int(i * step)] for i in range(budget)]

    OUT_BASE.mkdir(exist_ok=True)
    cache_dir = OUT_BASE / f"{name}_notes"
    cache_dir.mkdir(exist_ok=True)

    client = _client()
    notes: list[str] = []
    batches = [kept[i:i + MAX_PER_BATCH] for i in range(0, len(kept), MAX_PER_BATCH)]
    for bi, batch in enumerate(batches):
        cache = cache_dir / f"batch-{bi:02d}.json"
        if cache.exists():
            notes.append(cache.read_text(encoding="utf-8"))
            continue
        blocks: list[dict] = []
        for t, f in batch:
            blocks.append({"text": f"[t={int(t) // 60}:{t % 60:05.2f}]"})
            blocks.append({"image": {"format": "jpeg", "source": {"bytes": to_jpeg_bytes(f)}}})
        blocks.append({"text": BATCH_PROMPT.format(
            a=bi * MAX_PER_BATCH + 1, b=bi * MAX_PER_BATCH + len(batch),
            total=len(kept), lens=lens)})
        print(f"  batch {bi + 1}/{len(batches)} ({len(batch)} frames)...")
        text = converse(client, blocks)
        cache.write_text(text, encoding="utf-8")
        notes.append(text)

    print("  synthesizing...")
    critique = converse(client, [{"text": SYNTH_PROMPT.format(
        title=name, lens=lens, notes="\n\n---\n\n".join(notes))}], max_tokens=16000)
    out = OUT_BASE / f"{name}_critique.md"
    out.write_text(f"# Self-eval: {name}\n\nFocus: {lens}\n\n{critique}\n",
                   encoding="utf-8")
    print(f"wrote {out}")


if __name__ == "__main__":
    main()
