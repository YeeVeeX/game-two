"""Human-biased vision critique of capture frames via Bedrock (Rule 2, stage 2).

Adapted from the Foreman pipeline's vision drill-down (workspace/foreman):
same converse_stream + image-blocks + retry pattern, stripped of the
meeting-specific stages. The critic is an INDEPENDENT eye — a vision model
prompted as a veteran Tibia player and game-feel designer — so the dev of
record isn't grading their own frames.

Usage:
  python harness/vision_critic.py captures/world_loop [--reel captures/critic_reel]

Writes critique JSON + markdown to drafts/_vision-critique-<timestamp>.md.
AWS: profile voice-dev, us-east-1, bedrock-runtime (us.-prefixed model ids
are correct on this API — the bare-id rule is Mantle-transport-only).
"""

from __future__ import annotations

import json
import re
import sys
import time
from datetime import datetime
from pathlib import Path

import boto3
from botocore.config import Config as BotoConfig
from botocore.exceptions import ConnectionError as BotoConnectionError
from botocore.exceptions import ReadTimeoutError

# Windows may expose a legacy CP1252 console even though verdict/log data is
# UTF-8. Model prose can contain arrows or other glyphs; printing must never
# turn a valid verdict into a gate infrastructure failure.
for stream in (sys.stdout, sys.stderr):
    reconfigure = getattr(stream, "reconfigure", None)
    if reconfigure:
        reconfigure(encoding="utf-8", errors="replace")

PROFILE = "voice-dev"
REGION = "us-east-1"
MODEL = "us.anthropic.claude-fable-5"
MAX_IMAGES = 20  # Bedrock converse cap per request
_ATTEMPTS = 3

PERSONA = """You are two people in one review:
1. A 35-year-old Tibia veteran (played since 7.x) who knows exactly how grid
   movement, attack exhaust, telegraphs, and chokepoint combat should FEEL.
2. A senior game-feel designer (Vlambeer/Nuclear Throne school) who critiques
   readability, juice, and moment-to-moment clarity from static frames.

You are looking at capture frames from "game-two": a 2D top-down action RPG
built as a Ruby+Gosu rebuild of a pygame project called Kethral. Flat-rect
placeholder art is a DELIBERATE choice (feel first, art later) — do not ask
for sprites; critique what the rectangles communicate. 32px tiles. Player is
ember orange, enemies (husks) pale bone, telegraph flashes yellow, attacks
show as white tiles, gates are gold, town is warm brown, dungeon is cold blue.

Be a human, biased, opinionated playtester. Say what feels wrong and what a
player would FEEL, not what is technically correct. Rank problems by how much
they hurt the experience. Praise only what earns it."""


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


def load_frames(directory: Path) -> list[tuple[str, bytes]]:
    frames = sorted(directory.glob("frame_*.png"))
    if not frames:
        sys.exit(f"no frame_*.png in {directory}")
    if len(frames) > MAX_IMAGES:
        step = len(frames) / MAX_IMAGES
        frames = [frames[int(i * step)] for i in range(MAX_IMAGES)]
    return [(f.name, f.read_bytes()) for f in frames]


def image_blocks(frames: list[tuple[str, bytes]]) -> list[dict]:
    blocks: list[dict] = []
    for name, data in frames:
        blocks.append({"text": f"[{name}]"})
        blocks.append({"image": {"format": "png", "source": {"bytes": data}}})
    return blocks


KEY_MOMENTS_PROMPT = """These frames are KEY MOMENTS from one deterministic play loop, in order:
spawn in town -> walk east -> gate into the dungeon (Threketh) -> husk fight
(telegraph, player swing arc, kill) -> dodge -> death by husks -> YOU DIED
veil -> respawn back in town.

Critique as JSON only:
{
  "first_impressions": "what a player feels in the first 10 seconds",
  "readability": [{"issue": "...", "severity": "high|medium|low", "frame": "frame name", "fix": "..."}],
  "tibia_feel": [{"gap": "what a Tibia veteran would miss or find wrong", "severity": "...", "fix": "..."}],
  "juice": [{"issue": "...", "severity": "...", "fix": "..."}],
  "what_works": ["..."],
  "top_3_changes": ["the three changes that would most improve how this FEELS, in priority order"]
}"""

REEL_PROMPT = """These frames are a DENSE MOTION REEL — consecutive captures a few frames apart
during walking and combat, so you can read the movement cadence, tween
spacing, attack arc timing, and telegraph swell between frames.

Critique the MOTION as JSON only:
{
  "cadence_read": "how the tile-stepping rhythm reads from the frame spacing",
  "combat_motion": [{"issue": "...", "severity": "high|medium|low", "fix": "..."}],
  "animation_gaps": [{"gap": "where motion fails to communicate state", "severity": "...", "fix": "..."}],
  "top_3_changes": ["..."]
}"""


VERDICT_PROMPT_TEMPLATE = """These frames are capture output from a deterministic replay.
Evaluate ONLY the checklist below against what is actually visible. You are a gate,
not an advisor: a check passes only if the frames clearly demonstrate it.

Checklist:
{checks}

Respond with JSON only, no prose outside it:
{{
  "checks": [{{"id": "...", "pass": true, "why": "one sentence"}}],
  "verdict": "PASS" or "FAIL"
}}
"verdict" MUST be "FAIL" if any check has "pass": false.
STRICT OUTPUT RULES (malformed JSON voids the verdict): each "why" is ONE short
sentence, maximum 20 words, containing NO double quotes, NO apostrophes, and NO
frame-name lists longer than two frames. Each check id appears EXACTLY once."""


def extract_json(text: str) -> dict:
    m = re.search(r"\{.*\}", text, re.DOTALL)
    if not m:
        raise ValueError(f"no JSON object in model output: {text[:200]!r}")
    return json.loads(m.group(0))


def run_verdict(captures_dir: Path, checks_path: Path) -> int:
    checks = json.loads(checks_path.read_text(encoding="utf-8"))["checks"]
    listing = "\n".join(f"- [{c['id']}] {c['check']}" for c in checks)
    prompt = VERDICT_PROMPT_TEMPLATE.format(checks=listing)
    client = _client()
    frames = load_frames(captures_dir)
    print(f"gate verdict on {len(frames)} frames from {captures_dir} ...")
    expected_ids = {c["id"] for c in checks}
    # 4 verdict attempts: a Bedrock stream can end early mid-JSON with no
    # exception (three truncations observed 2026-08-12), so unusable output
    # is retried like a throttle, never trusted.
    for attempt in (1, 2, 3, 4):
        text = converse(client, image_blocks(frames) + [{"text": prompt}])
        try:
            result = extract_json(text)
            # The model's output is trusted only if it covers the checklist
            # exactly — all([]) is True, so an empty/partial checks array
            # would otherwise false-PASS the gate.
            returned_ids = {c.get("id") for c in result.get("checks", [])}
            if returned_ids != expected_ids:
                raise ValueError(
                    f"checklist coverage mismatch: missing={sorted(expected_ids - returned_ids)} "
                    f"unknown={sorted(returned_ids - expected_ids)}"
                )
            break
        except (ValueError, json.JSONDecodeError) as exc:
            if attempt == 4:
                print(f"GATE INFRA ERROR: unusable verdict: {exc}", file=sys.stderr)
                return 2
            time.sleep(15)
    log = Path("drafts") / "_gate-verdicts.log"
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    with log.open("a", encoding="utf-8") as fh:
        fh.write(f"\n=== {stamp} {captures_dir} ===\n{json.dumps(result, indent=2)}\n")
    for c in result.get("checks", []):
        mark = "PASS" if c.get("pass") else "FAIL"
        print(f"  [{mark}] {c.get('id')}: {c.get('why', '')}")
    if result.get("verdict") == "PASS" and all(c.get("pass") for c in result.get("checks", [])):
        print("GATE vision: PASS")
        return 0
    print("GATE vision: FAIL (see above; full verdict in drafts/_gate-verdicts.log)", file=sys.stderr)
    return 1


def main() -> None:
    args = sys.argv[1:]
    if not args:
        sys.exit("usage: python harness/vision_critic.py <captures_dir> [--reel <dir>] | --verdict <dir> --checks <checks.json>")
    if args[0] == "--verdict":
        captures_dir = Path(args[1])
        checks_path = Path(args[args.index("--checks") + 1]) if "--checks" in args else Path("harness/gate_checks.json")
        sys.exit(run_verdict(captures_dir, checks_path))
    key_dir = Path(args[0])
    reel_dir = Path(args[args.index("--reel") + 1]) if "--reel" in args else None

    client = _client()
    out_parts: list[str] = []

    frames = load_frames(key_dir)
    print(f"critiquing {len(frames)} key-moment frames from {key_dir} ...")
    text = converse(client, image_blocks(frames) + [{"text": KEY_MOMENTS_PROMPT}])
    out_parts.append("## Key moments critique\n\n```json\n" + text + "\n```")

    if reel_dir:
        reel = load_frames(reel_dir)
        print(f"critiquing {len(reel)} motion-reel frames from {reel_dir} ...")
        text = converse(client, image_blocks(reel) + [{"text": REEL_PROMPT}])
        out_parts.append("## Motion reel critique\n\n```json\n" + text + "\n```")

    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    out = Path("drafts") / f"_vision-critique-{stamp}.md"
    header = (
        f"# Vision critique ({stamp})\n\nModel: {MODEL} on bedrock-runtime "
        f"({PROFILE}/{REGION}). Persona: Tibia veteran + game-feel designer.\n"
        f"Sources: {key_dir}" + (f", {reel_dir}" if reel_dir else "") + "\n"
    )
    out.write_text(header + "\n" + "\n\n".join(out_parts), encoding="utf-8")
    print(f"wrote {out}")


if __name__ == "__main__":
    main()
