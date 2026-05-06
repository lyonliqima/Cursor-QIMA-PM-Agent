#!/usr/bin/env bash
# Batch-download Figma nodes as PNG via REST API.
#
# Usage:
#   fetch-figma.sh <FILE_KEY> <OUT_DIR> <NODE_IDS> [SCALE]
#
#   FILE_KEY   — from Figma URL: figma.com/design/<FILE_KEY>/...
#   OUT_DIR    — where PNGs land (created if missing)
#   NODE_IDS   — comma-separated, e.g. "10380:18214,10383:18532"
#   SCALE      — 1 / 2 / 3 / 4 (default 2)
#
# Token: read from ~/.config/figma-token (chmod 600).
#
# Output files named <node-id-with-colon-replaced>.png

set -euo pipefail

TOKEN_FILE="${FIGMA_TOKEN_FILE:-$HOME/.config/figma-token}"
[[ -r "$TOKEN_FILE" ]] || { echo "missing $TOKEN_FILE" >&2; exit 1; }
TOKEN=$(tr -d '\n' < "$TOKEN_FILE")

FILE_KEY="${1:?FILE_KEY required}"
OUT_DIR="${2:?OUT_DIR required}"
IDS="${3:?NODE_IDS required}"
SCALE="${4:-2}"

mkdir -p "$OUT_DIR"

# URL-encode colons in ids for the query string
ENCODED_IDS="${IDS//:/%3A}"

echo "→ requesting image URLs from Figma (scale=$SCALE)…" >&2
resp=$(curl -sfH "X-FIGMA-TOKEN: $TOKEN" \
  "https://api.figma.com/v1/images/${FILE_KEY}?ids=${ENCODED_IDS}&format=png&scale=${SCALE}") \
  || { echo "figma api request failed" >&2; exit 2; }

# Extract {id: url} with python (jq not guaranteed)
python3 - "$resp" "$OUT_DIR" <<'PY'
import json, os, sys, urllib.request
resp, out_dir = sys.argv[1], sys.argv[2]
data = json.loads(resp)
if data.get('err'):
    sys.exit(f"figma error: {data['err']}")
imgs = data.get('images', {})
for nid, url in imgs.items():
    if not url:
        print(f"  [skip] {nid} — null (hidden or 0-opacity?)")
        continue
    fname = nid.replace(':', '_') + '.png'
    path = os.path.join(out_dir, fname)
    urllib.request.urlretrieve(url, path)
    print(f"  [ok]   {fname}")
print(f"→ {len(imgs)} node(s) → {out_dir}")
PY
