---
name: prd-design-assets
description: Internal helper for PRD and Jira ticket workflows. Produces ticket-specific static design assets by exporting Figma nodes, cropping relevant regions, publishing images to a stable URL, and inserting links into Confluence PRDs or Jira ticket design references. Use only when invoked by write-prd or ticket-breakdown; do not expose as a user-facing slash skill.
version: 0.1.0
user-invocable: false
disable-model-invocation: true
argument-hint: "<figma-url-or-node-map> <prd-or-ticket-scope>"
---

# PRD Design Assets

Internal helper skill for design screenshots used by `write-prd` and `ticket-breakdown`.

This skill turns a Figma design into focused, ticket-specific visual references. It should not be offered to the user as a standalone workflow. Load it from another skill when the PRD or ticket output needs static images in addition to Figma links.

## When To Use

Use this skill from `write-prd` or `ticket-breakdown` when any of these are true:

- The user asks to insert design images into a PRD.
- A PRD Section 6 needs offline-readable screenshots in addition to live Figma links.
- Jira tickets need cropped design references for their specific scope.
- A Figma node is a long page or section, and only a sub-area is relevant to a PRD section or ticket.
- Confluence cannot upload attachments through the current MCP, so images must be hosted by a stable URL.

Do not use for normal live Figma embeds only. If a bare Figma URL is enough, follow `write-prd/references/figma-handling.md` instead.

## Required Inputs

- `figma_url`: Figma file URL with `fileKey` and section or frame `node-id`.
- `scope_map`: PRD sections or Jira tickets mapped to the design area they need.
- `asset_repo`: default to `lyonliqima/prd-assets` if it already exists; otherwise ask before creating a new public repo.
- `feature_slug`: lower-kebab-case folder name, e.g. `smart-report`.
- `confluence_page`: optional PRD page to update.
- `jira_tickets`: optional ticket keys to reference in captions.

## Workflow

### Step 1 — Resolve The Figma Source

1. Parse `fileKey` from `figma.com/design/<fileKey>/...`.
2. Convert URL node IDs from dash form to colon form when calling Figma APIs (`10428-25076` -> `10428:25076`).
3. If the source node is a section or large page, inspect the subtree and choose smaller frames when possible.
4. If the requested area is still a long frame, export the long frame once and crop it into focused regions.

Preferred export path:

```bash
# If working inside the shared PM Agent repo:
bash .cursor/skills/write-prd/scripts/fetch-figma.sh <FILE_KEY> <OUT_DIR> "<NODE_IDS>" 2

# If the skills are installed as personal Cursor skills:
bash "$HOME/.cursor/skills/write-prd/scripts/fetch-figma.sh" <FILE_KEY> <OUT_DIR> "<NODE_IDS>" 2
```

The script reads the Figma token from `~/.config/figma-token`.

### Step 2 — Build The Crop Plan

Create a crop plan before cutting images. Each crop must map to a PRD section or Jira ticket.

Use this structure:

```json
{
  "SP-12345-decision-frame.png": {
    "ticket": "SP-12345",
    "title": "Decision frame and first-screen conclusion",
    "source_node": "10380:17767",
    "box": [0, 0, 1171, 350],
    "units": "figma-frame-px"
  }
}
```

Crop rules:

- Prefer coordinates from Figma metadata (`x`, `y`, `width`, `height`) rather than visual guessing.
- Include enough context around the target area so developers can understand layout and hierarchy.
- Avoid full-page or long-scroll images unless the ticket is specifically about whole-page layout.
- Use one image per ticket or PRD subsection when possible.
- Filename must be ASCII lower-kebab-case and start with the ticket key when tied to a ticket.

### Step 3 — Crop Images

Use `scripts/crop-figma-regions.py` for repeatable crops:

```bash
# If working inside the shared PM Agent repo:
python .cursor/skills/prd-design-assets/scripts/crop-figma-regions.py \
  --image <exported-full-image.png> \
  --plan <crop-plan.json> \
  --out-dir <asset-repo>/assets/<feature_slug>/figma/crops \
  --scale 2

# If the skills are installed as personal Cursor skills:
python "$HOME/.cursor/skills/prd-design-assets/scripts/crop-figma-regions.py" \
  --image <exported-full-image.png> \
  --plan <crop-plan.json> \
  --out-dir <asset-repo>/assets/<feature_slug>/figma/crops \
  --scale 2
```

The `--scale` must match the Figma export scale. If the exported PNG is 2x the Figma frame size, use `--scale 2`.

Install the script dependency if needed:

```bash
python3 -m pip install -r .cursor/skills/prd-design-assets/requirements.txt
```

### Step 4 — Publish To A Stable URL

Use the dedicated asset repo unless the user instructs otherwise:

```text
https://raw.githubusercontent.com/lyonliqima/prd-assets/main/assets/<feature_slug>/figma/crops/<filename>.png
```

Before pushing:

- Check image sizes. Keep each image well below GitHub's 100 MB file limit.
- Prefer PNG for UI screenshots.
- Do not commit secrets, token files, or temporary API responses.

Commit message convention:

```text
Add <feature> cropped design screenshots.
```

Only commit/push when the user has asked for an asset-hosting workflow or the parent skill already has approval to update the PRD/tickets.

### Step 5 — Insert References

For PRDs, place images near the relevant Design subsection:

```markdown
### Ticket Design References

[**SP-12345**](https://qima.atlassian.net/browse/SP-12345) **— Decision frame and first-screen conclusion**  
Cropped from the top decision bar, report identity, key actions, and first-screen conclusion area.

![SP-12345 Decision frame](https://raw.githubusercontent.com/lyonliqima/prd-assets/main/assets/<feature>/figma/crops/sp-12345-decision-frame.png)
```

For Jira tickets, add the same raw image URL under the ticket's `Design` or `Additional Information` section. If the Jira editor does not render the image, include both the raw URL and the Figma frame URL.

## Quality Gate

Before updating Confluence or Jira, verify:

- Every generated crop maps to exactly one PRD section or ticket.
- No long screenshot is used where a focused crop exists.
- Captions explain what area was cropped and why it belongs to that ticket.
- Raw GitHub URLs are reachable.
- The PRD still preserves live Figma links for designers and cropped static images for PM/dev review.

## Failure Handling

- If Figma export fails, fall back to `get_design_context` / `get_screenshot` for small nodes only.
- If the node is too large, inspect child nodes and export smaller frames.
- If exact crop coordinates are ambiguous, ask the user or design lead instead of guessing.
- If GitHub upload is blocked, keep local paths and add a manual asset insertion checklist to the PRD.
