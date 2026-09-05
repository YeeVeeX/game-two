#!/usr/bin/env python
"""tools/normalize_ldtk.py -- re-canonicalise an LDtk project file (WB-T6, S0).

The builders (tools/build_*.py) pin authoring/pilot.ldtk to ONE byte
format and refuse anything else (tools/build_tower_floor.py:83-88):

    (json.dumps(doc, indent=2, ensure_ascii=False) + "\\n")
        .replace("\\n", "\\r\\n").encode("utf-8")

Every LDtk GUI save rewrites the whole file in LDtk's own style (tabs +
LF), so a GUI session breaks that pin on the first Ctrl+S. This script
parses and re-dumps: the VALUES are untouched by construction (it
re-serialises, it never edits), only the bytes move. It is the first
step of the AfterSave command (tools/ldtk_aftersave.py) and a suite
check (test/tools/normalize_ldtk_test.rb).

Modes:
    normalize <file>          rewrite in place; prints "normalized <file>"
                              or "already canonical <file>"; exit 0
    --check <file>            exit 0 if canonical, 1 with a one-line reason
    --semantic-diff <a> <b>   exit 0 if the two parse to equal documents,
                              1 with the differing JSON paths otherwise

Laws: bytes in, bytes out (read_bytes/write_bytes) -- Windows Python's
text stdout/files write "\\r\\n" for "\\n" and would corrupt the pin
(recorded trap 2026-09-02). Stdlib only. Unreadable/invalid input is a
NAMED refusal with exit 2, never a silent pass.
"""

import json
import sys
from pathlib import Path

MAX_DIFF_PATHS = 50


def canonical_bytes(doc):
    """The builders' pin, verbatim (tools/build_tower_floor.py:85)."""
    return (json.dumps(doc, indent=2, ensure_ascii=False) + "\n").replace("\n", "\r\n").encode("utf-8")


def load(path):
    """-> (raw bytes, parsed doc). Raises on unreadable/invalid input."""
    raw = Path(path).read_bytes()
    return raw, json.loads(raw.decode("utf-8-sig"))


def check(path):
    """-> None if canonical, else a one-line reason."""
    raw, doc = load(path)
    formatted = canonical_bytes(doc)
    if formatted == raw:
        return None
    return describe_drift(raw, formatted)


def describe_drift(raw, formatted):
    # A raw TAB byte can only be indentation: json.loads (strict) has already
    # rejected any unescaped control character inside a string value.
    if raw.startswith(b"\xef\xbb\xbf"):
        return "UTF-8 BOM present (the pin has none)"
    if b"\t" in raw and b"\t" not in formatted:
        return "tab-indented (LDtk's own writer style; the pin is 2-space + CRLF)"
    if b"\r\n" not in raw:
        return "LF line endings (the pin is CRLF)"
    if raw.replace(b"\r\n", b"\n") == formatted.replace(b"\r\n", b"\n"):
        return "line-ending drift only (mixed or bare CR/LF; the pin is CRLF throughout)"
    if len(raw) != len(formatted):
        return f"byte length {len(raw)} != canonical {len(formatted)} (whitespace/separator drift)"
    return "byte drift from json.dumps(indent=2)+CRLF (same length, different bytes)"


def normalize(path):
    """Rewrite in place. -> True if bytes changed, False if already canonical."""
    raw, doc = load(path)
    formatted = canonical_bytes(doc)
    if formatted == raw:
        return False
    Path(path).write_bytes(formatted)
    return True


def scalar_equal(a, b):
    """Strict scalar equality: bool never equals int (Python's 1 == True
    would hide a `1` -> `true` rewrite); int and float compare by value
    (1 vs 1.0 is formatting, not semantics)."""
    if isinstance(a, bool) or isinstance(b, bool):
        return type(a) is type(b) and a == b
    if isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return a == b
    return type(a) is type(b) and a == b


def diff_paths(a, b, prefix="$", out=None):
    """Collect JSON paths where a and b differ (recursive, order-sensitive
    for arrays -- LDtk arrays are ordered data; deterministic key order)."""
    if out is None:
        out = []
    if len(out) > MAX_DIFF_PATHS:
        return out
    if isinstance(a, dict) and isinstance(b, dict):
        for k in list(a.keys()) + [k for k in b.keys() if k not in a]:
            if k not in a:
                out.append(f"{prefix}.{k}: only in B")
            elif k not in b:
                out.append(f"{prefix}.{k}: only in A")
            else:
                diff_paths(a[k], b[k], f"{prefix}.{k}", out)
    elif isinstance(a, list) and isinstance(b, list):
        if len(a) != len(b):
            out.append(f"{prefix}: array length {len(a)} != {len(b)}")
        for i, (x, y) in enumerate(zip(a, b)):
            diff_paths(x, y, f"{prefix}[{i}]", out)
    elif isinstance(a, (dict, list)) or isinstance(b, (dict, list)) or not scalar_equal(a, b):
        # ensure_ascii=True on purpose: this line goes to a Windows console
        # (cp1252 by default) -- raw non-ASCII would raise UnicodeEncodeError.
        out.append(f"{prefix}: {json.dumps(a)[:60]} != {json.dumps(b)[:60]}")
    return out


def semantic_diff(path_a, path_b):
    """-> [] if parsed-equal (strict scalars, ordered arrays), else the
    differing paths (capped at MAX_DIFF_PATHS + 1)."""
    _, a = load(path_a)
    _, b = load(path_b)
    return diff_paths(a, b)


def main(argv):
    # Console safety: paths/reasons may carry non-ASCII; never die printing a report.
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(errors="backslashreplace")
    usage = ("usage: python tools/normalize_ldtk.py normalize <file> | --check <file> | "
             "--semantic-diff <a> <b>")
    try:
        if len(argv) == 3 and argv[1] == "normalize":
            changed = normalize(argv[2])
            print(("normalized " if changed else "already canonical ") + argv[2])
            return 0
        if len(argv) == 3 and argv[1] == "--check":
            reason = check(argv[2])
            if reason is None:
                print("canonical " + argv[2])
                return 0
            print(f"NOT CANONICAL {argv[2]}: {reason} -- run: python tools/normalize_ldtk.py normalize {argv[2]}")
            return 1
        if len(argv) == 4 and argv[1] == "--semantic-diff":
            paths = semantic_diff(argv[2], argv[3])
            if not paths:
                print(f"semantically equal: {argv[2]} == {argv[3]}")
                return 0
            shown = paths[:MAX_DIFF_PATHS]
            print(f"SEMANTIC DIFF {argv[2]} vs {argv[3]}: {len(paths)}{'+' if len(paths) > MAX_DIFF_PATHS else ''} differing path(s)")
            for p in shown:
                print("  " + p)
            if len(paths) > MAX_DIFF_PATHS:
                print("  ...")
            return 1
    except (OSError, UnicodeDecodeError, json.JSONDecodeError) as e:
        print(f"NORMALIZE REFUSED: {e}")
        return 2
    print(usage)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
