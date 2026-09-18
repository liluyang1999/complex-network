"""Offline source inventory checks using Python's standard library.

This is NOT a MATLAB parser, Code Analyzer, or runtime test. It checks names,
package references, relative documentation links and the preserved .mlx files.
Run: python tools/check_source.py
"""
from pathlib import Path
import hashlib
import re

ROOT = Path(__file__).resolve().parents[1]
HISTORICAL = {
    "self_test.mlx": "07d986efdad668e92fcc282b9d21b19cb639cb5a2e5c0612dc2462128beecf9d",
    "test_question2.mlx": "3c545d98c5f2c350f8a8bd7b08c6fc1803b2cd2305f2f31407d394898107143a",
    "test_question4.mlx": "d5b4b05de4b062bdda691aca002314dd6496c109bc8db7a64cd7d09284255c74",
    "test_question5.mlx": "24011fbeee6c0f1efb97beb4583602a65caa1e40098a7873ca1f3d76da1b3121",
    "test_question6.mlx": "636afd1a51e491f7b32d7c5c8e71fb6504a5107caca6c4f8bd61604239ec970e",
}


def main():
    errors = []
    sources = sorted(ROOT.rglob("*.m"))
    for source in sources:
        text = source.read_text(encoding="utf-8")
        first = next((line.strip() for line in text.splitlines() if line.strip() and not line.lstrip().startswith("%")), "")
        match = re.match(r"function\s+(?:(?:\[[^\]]+\]|\w+)\s*=\s*)?(\w+)", first)
        if not match or match.group(1) != source.stem:
            errors.append(f"{source.relative_to(ROOT)}: first function name mismatch")
        for helper in set(re.findall(r"\bcn\.(\w+)\s*\(", text)):
            if not (ROOT / "+cn" / f"{helper}.m").is_file():
                errors.append(f"{source.relative_to(ROOT)}: unresolved cn.{helper}")
        if not text.endswith("\n") or any(line.rstrip() != line for line in text.splitlines()):
            errors.append(f"{source.relative_to(ROOT)}: trailing whitespace or missing final newline")
    for document in ROOT.rglob("*.md"):
        for target in re.findall(r"\]\(([^)]+)\)", document.read_text(encoding="utf-8")):
            if "://" in target or target.startswith("#"):
                continue
            if not (document.parent / target.split("#")[0]).is_file():
                errors.append(f"{document.relative_to(ROOT)}: missing linked file {target}")
    for name, expected in HISTORICAL.items():
        if hashlib.sha256((ROOT / name).read_bytes()).hexdigest() != expected:
            errors.append(f"{name}: historical material changed")
    if errors:
        raise SystemExit("\n".join(errors))
    tests = (ROOT / "tests/test_network.m").read_text(encoding="utf-8")
    test_count = len(re.findall(r"^function test\w+\(testCase\)", tests, re.MULTILINE))
    print(f"SOURCE_INVENTORY_OK: {len(sources)} MATLAB files, {test_count} prepared test groups, 5 preserved .mlx files")
    print("MATLAB syntax analysis, runtime tests, plots and exports: NOT EXECUTED by this checker")


if __name__ == "__main__":
    main()
