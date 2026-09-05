#!/usr/bin/env python
"""tools/ldtk_aftersave.py -- the AfterSave driver LDtk runs on every Ctrl+S (WB-T6, S0/S2).

Registered in authoring/pilot.ldtk as
    customCommands: [{"command": "python ../tools/ldtk_aftersave.py ../authoring/pilot.ldtk",
                      "when": "AfterSave"}]
LDtk v1.5.3 splits that string on spaces and runs it with
ChildProcess.spawn(name, args, {cwd: <project directory>}) -- NO shell
(CommandRunner.hx:77-93): the first token must be an executable name on
the Windows PATH of the LDtk process (hence `python`, never a .cmd), and
cwd is authoring/ (hence the ../ paths). LDtk shows the output in a
runner window that auto-closes on exit 0 and STAYS OPEN on nonzero --
refusals are visible, clean saves are silent. Custom commands carry no
variables (upstream #965): the string is static by design.

Steps (each one prints; the first failure sets the exit code):
  1. normalize the project file (tools/normalize_ldtk.py) -- LDtk's
     writer style is re-canonicalised to the builders' byte pin
  2. run the importer into tmp/ldtk_out (NEVER data/zones -- D12 merge
     law): every NAMED refusal appears in the editor, not at `rake`
  3. lint the world graph as it WOULD be after the deliberate copy
     (data/zones overlaid by tmp/ldtk_out): tools/lint_world_graph.rb

Ruby: C:\\Ruby34-x64\\bin is prepended to PATH when it exists (the
game-two Ruby is not on Git Bash's PATH by default); otherwise PATH
must already resolve `ruby` -- a missing ruby is a NAMED refusal.

Manual run (what LDtk does), from the repo root:
    cd authoring && python ../tools/ldtk_aftersave.py ../authoring/pilot.ldtk
"""

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
sys.dont_write_bytecode = True  # never litter tools/ with __pycache__ on every Ctrl+S
sys.path.insert(0, str(HERE))
import normalize_ldtk  # noqa: E402  (sibling module, stdlib-only)

RUBY_DIR = r"C:\Ruby34-x64\bin"
IMPORT_OUT = "tmp/ldtk_out"
LINT = ROOT / "tools" / "lint_world_graph.rb"


def say(msg):
    print(f"[aftersave] {msg}")
    sys.stdout.flush()


def console_safe():
    # The LDtk runner window / cmd console is cp1252 by default on Windows;
    # a non-ASCII path or refusal text must never crash the report itself.
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(errors="backslashreplace")


def ruby_env():
    env = dict(os.environ)
    if Path(RUBY_DIR).is_dir():
        env["PATH"] = RUBY_DIR + os.pathsep + env.get("PATH", "")
    return env


def run_ruby(ruby, args, env, label):
    say(f"{label}: ruby {' '.join(args)}")
    rc = subprocess.run([ruby, *args], cwd=ROOT, env=env).returncode
    sys.stdout.flush()
    say(f"{label}: exit {rc}")
    return rc


def main(argv):
    console_safe()
    args = list(argv[1:])
    out_dir = IMPORT_OUT
    if len(args) == 3 and args[1] == "--out":
        out_dir = args[2]
        args = args[:1]
    if len(args) != 1:
        print("usage: python tools/ldtk_aftersave.py <project.ldtk> [--out <dir>]  (default --out tmp/ldtk_out)")
        return 2
    project = Path(args[0]).resolve()
    say(f"project {project}")
    failed = []

    # 1. normalize
    try:
        changed = normalize_ldtk.normalize(project)
        say("normalized (LDtk writer style -> builders' byte pin)" if changed else "already canonical")
    except (OSError, UnicodeDecodeError, json.JSONDecodeError) as e:
        say(f"NORMALIZE REFUSED: {e}")
        return 1

    # 2. importer
    env = ruby_env()
    ruby = shutil.which("ruby", path=env["PATH"])
    if not ruby:
        say(f"REFUSED: ruby not found on PATH (looked in {RUBY_DIR} first) -- install Ruby 3.4 "
            "or add its bin/ to the Windows PATH (docs/JUNIOR.md)")
        return 1
    Path(out_dir if os.path.isabs(out_dir) else ROOT / out_dir).mkdir(parents=True, exist_ok=True)
    rc = run_ruby(ruby, ["tools/import_ldtk.rb", str(project), "--sidecars", "authoring",
                         "--out", out_dir], env, "import")
    if rc != 0:
        failed.append("import")

    # 3. world-graph lint (data/zones overlaid by the fresh emission)
    if LINT.exists():
        if "import" in failed:
            say("lint: skipped (import refused -- fix that first)")
        else:
            rc = run_ruby(ruby, ["tools/lint_world_graph.rb", "--zones", "data/zones",
                                 "--overlay", out_dir], env, "lint")
            if rc != 0:
                failed.append("lint")
    else:
        say("lint: tools/lint_world_graph.rb not present, skipped")

    if failed:
        say(f"FAILED: {', '.join(failed)} -- the window stays open so you can read why")
        return 1
    say("ok")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
