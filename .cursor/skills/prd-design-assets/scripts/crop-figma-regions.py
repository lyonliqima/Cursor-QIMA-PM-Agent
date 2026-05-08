#!/usr/bin/env python3
"""Crop Figma-exported PNGs into PRD or ticket-specific regions."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any

from PIL import Image


def load_plan(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)
    if not isinstance(data, dict) or not data:
        raise ValueError("crop plan must be a non-empty JSON object")
    return data


def parse_box(entry: Any) -> tuple[float, float, float, float]:
    if not isinstance(entry, dict):
        raise ValueError("each crop entry must be an object")
    box = entry.get("box")
    if (
        not isinstance(box, list)
        or len(box) != 4
        or not all(isinstance(value, (int, float)) for value in box)
    ):
        raise ValueError("each crop entry requires box: [x, y, width, height]")
    x, y, width, height = box
    if width <= 0 or height <= 0:
        raise ValueError("crop width and height must be positive")
    return float(x), float(y), float(width), float(height)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Crop a Figma-exported PNG using a JSON crop plan."
    )
    parser.add_argument("--image", required=True, type=Path, help="Source PNG")
    parser.add_argument("--plan", required=True, type=Path, help="Crop plan JSON")
    parser.add_argument("--out-dir", required=True, type=Path, help="Output folder")
    parser.add_argument(
        "--scale",
        type=float,
        default=1.0,
        help="Figma export scale. Use 2 for a 2x export.",
    )
    args = parser.parse_args()

    if args.scale <= 0:
        raise ValueError("--scale must be positive")

    image = Image.open(args.image)
    plan = load_plan(args.plan)
    args.out_dir.mkdir(parents=True, exist_ok=True)

    for filename, entry in plan.items():
        x, y, width, height = parse_box(entry)
        left = round(x * args.scale)
        top = round(y * args.scale)
        right = round((x + width) * args.scale)
        bottom = round((y + height) * args.scale)

        if left < 0 or top < 0 or right > image.width or bottom > image.height:
            raise ValueError(
                f"{filename} crop box {(left, top, right, bottom)} exceeds "
                f"image bounds {(image.width, image.height)}"
            )

        output = args.out_dir / filename
        image.crop((left, top, right, bottom)).save(output, optimize=True)
        print(f"{filename}: {output.stat().st_size} bytes")


if __name__ == "__main__":
    main()
