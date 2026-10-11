#!/usr/bin/env python3
"""Fail if the guide's front matter tags and the plugin's keywords differ."""
import json
import re
import sys
from pathlib import Path

GUIDE = Path("sre-alerting-guidelines.md")
PLUGIN = Path("plugins/sre-alerting-guidelines/.claude-plugin/plugin.json")


def guide_tags():
    text = GUIDE.read_text(encoding="utf-8")
    front = re.match(r"---\n(.*?)\n---\n", text, re.S)
    if not front:
        sys.exit(f"{GUIDE}: no YAML front matter found")
    line = re.search(r"^tags:\s*(\[.*\])\s*$", front.group(1), re.M)
    if not line:
        sys.exit(f"{GUIDE}: front matter must have a single-line `tags: [...]` list")
    return json.loads(line.group(1))


def plugin_keywords():
    return json.loads(PLUGIN.read_text(encoding="utf-8"))["keywords"]


def main():
    tags, keywords = guide_tags(), plugin_keywords()
    only_tags = [t for t in tags if t not in keywords]
    only_keywords = [k for k in keywords if k not in tags]
    if only_tags or only_keywords:
        print(f"{GUIDE} tags and {PLUGIN} keywords have diverged:")
        for t in only_tags:
            print(f"  only in tags: {t}")
        for k in only_keywords:
            print(f"  only in keywords: {k}")
        print("Update both lists so they contain the same entries.")
        sys.exit(1)
    print(f"OK: {len(tags)} tags match plugin keywords.")


if __name__ == "__main__":
    main()
