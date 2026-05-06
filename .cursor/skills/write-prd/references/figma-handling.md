# Figma → Confluence image pipeline

QIMA Confluence has the **Figma for Confluence** plugin installed. The default render path is therefore **inline live Figma embeds via bare URL** — no PNG download, no attachment upload, no Chrome MCP needed.

This file specifies (a) how to **scope** the frame search to a user-provided section, (b) the **render contract** for the Figma for Confluence plugin, (c) **fallback paths** for static PNG when needed.

---

## A · Section-scoping rule（HARD GATE）

Every PRD that has §6 Design content MUST be anchored to **a single Figma section node-id** provided by the user upfront in Phase 0 intake. All frame lookups for §6.1–§6.4 are constrained to that section's subtree.

**Why**: A QIMA Figma file (e.g., `rISHYzh2BlJbfbXrOaSwB2`) typically contains 20+ pages — Marketing dashboards, AI workspace reviews, Currency, Audit Renewal, etc. — each with hundreds of frames. A naive `getNodeByIdAsync` against a known frame guess can land on a completely unrelated page (observed regression: searching for "Landing" picked up MAISA AI workspace frames). **Scoped search is a correctness requirement, not a perf optimisation.**

**Procedure**:

1. **In Phase 0 intake**: ASK for the Figma section URL. Example: `https://www.figma.com/design/<KEY>/<NAME>?node-id=10428-25076`. Record in `context-manifest.md` under `figma_section_url`.
2. **Validate**: extract the node-id from the URL, query `figma.getNodeByIdAsync(nodeId)`, confirm it is a `SECTION` or top-level `FRAME` (≥ 1000px wide). If it's not, ASK the user to re-paste a section-level link, not a small component.
3. **Drill DOWN, never sideways**: when looking for §6.x frames, traverse the section's subtree only. NEVER call `figma.root.children` — that returns the whole file.
4. **If the section truly contains a single long page** (e.g., 1171×4625 IR full page) and PRD §6 has multiple sub-sections (Workmanship / Checklist / Photos / CAP), use the section's named sub-frames inside `main panel` etc. Sub-frames may have anonymous names (`Frame 47871`); link to them anyway — Figma deep-link will scroll to the area.
5. **If a §6.x cannot be matched within the section**, write `> **Figma frame**: ⚠️ TBD — not in section <section-id>; ask design lead`. Add to §11.1 OQ. Don't fall back to file root.

**Reference snippet** (use_figma plugin API):

```js
// Find named frames inside a user-provided section
const root = await figma.getNodeByIdAsync(SECTION_ID);
const found = [];
const walk = (n, depth) => {
  if (depth > 5) return;
  if (n.id !== SECTION_ID && /workman|defect|checklist|measure|photo|cap|share|landing|fail|pass/i.test(n.name||'')) {
    found.push({ id: n.id, name: n.name, w: n.width, h: n.height, y: n.y });
  }
  if ('children' in n) for (const c of n.children) walk(c, depth + 1);
};
walk(root, 0);
```

---

## B · Render contract (Figma for Confluence plugin path) — DEFAULT

For every `## 6.x Page N`, body should contain:

```markdown
## 6.x Page N — {{name}}

≤ 3 sentences description.

> **Figma frame**: [{{name}}]({{full URL with ?node-id=...}})

{{full URL with ?node-id=... on its own line, no formatting}}
```

The bare URL on its own line is what the **Figma for Confluence** plugin (assumed installed) auto-detects to render an inline live frame embed. The text-link on the line above is a fallback for users whose plugin isn't loaded yet.

**Why both?**
- The text-link survives even if the plugin macro fails to render
- The bare URL is what the plugin pattern-matches (Confluence's auto-card detection picks it up and the Figma plugin's content interceptor swaps it for a Figma macro)

**Build the URL in this exact form**:

```
https://www.figma.com/design/<FILE_KEY>/<FILE_NAME>?node-id=<NODE_ID_DASH_FORM>
```

- `FILE_KEY` from the file URL
- `FILE_NAME` from the file URL (slugified, can keep query slugs)
- `NODE_ID_DASH_FORM`: replace `:` with `-` (e.g., `10380:17767` → `10380-17767`). Figma's deep-link normalises both, but `dash` form is the standard one Confluence pattern-matches.

**Confluence rendering** behaves as follows on save:
- Without Figma plugin: card appearance (small chip with thumbnail + title + click-to-open)
- With Figma plugin: full inline frame embed (interactive viewer, panning + zoom)

If the page is rendered with the small card only (plugin didn't auto-trigger), the user can click the URL inline in the editor → "/" menu → choose "Figma for Confluence" → paste the same URL → save. Then it renders as the macro embed.

---

## C · Static PNG fallback (Path A / Path B) — OPT-IN

When the team explicitly wants offline-readable screenshots in addition to live embeds (e.g., for stakeholder PDF exports), use one of these.

---

## Readiness check (run this FIRST)

Before choosing a path, verify:

| Check | How | If fails |
|---|---|---|
| Chrome MCP available | Try `tabs_create_mcp` with a test URL (or check tool list) | Path A unavailable → use Path B |
| User logged in to Confluence | `navigate` to `https://qima.atlassian.net` and `get_page_text`; look for a username / workspace name, not a login form | Ask user to log in, then retry — OR fall back to Path B |
| Chrome browser actually running | If `tabs_create_mcp` errors with "no browser" | Ask user to open Chrome, then retry |

Tell the user the outcome in one sentence, e.g. *"Chrome MCP ready, you're logged in as Lyon — I'll auto-upload 6 screenshots."*

---

## Path A — Chrome MCP auto-upload (default)

### Step 1 · Capture Figma screenshots

**Preferred: Figma REST API via `scripts/fetch-figma.sh`** (fast, one call for many nodes, no 20KB MCP truncation):

```bash
bash scripts/fetch-figma.sh <FILE_KEY> ~/Desktop/<feature-slug>-figma "10380:18214,10383:18532,..." 2
```

- `FILE_KEY` — from Figma URL `figma.com/design/<FILE_KEY>/...`
- Comma-separated node IDs (can mix any depth)
- Last arg is scale (1–4, default 2)
- Token read from `~/.config/figma-token` (already provisioned)
- Output: `<node-id-with-underscore>.png` in target dir; rename to kebab-case after

Caveats:
- Node IDs with colon must be URL-encoded (`fetch-figma.sh` does this)
- Scrollable frames get cropped to visible area — expand the frame in Figma first if needed
- URLs returned by Figma expire in 30 days, but the script downloads immediately
- Hidden / 0-opacity nodes return null — script logs `[skip]` and moves on

**Fallback: MCP `get_screenshot(frame_id)`** — use only when REST API unreachable or for single-shot preview. MCP truncates at 20KB so large frames fail; not suitable for batch.

After download, rename to kebab-case ASCII for Confluence compatibility:
```
~/Desktop/<feature-slug>-figma/<slug>-<short-description>.png
  e.g.  package-charge-checkout-flow.png
```

### Step 2 · Create the Confluence draft with markers + per-frame deep-links

Use Atlassian MCP `createConfluencePage`. **Every §6.x Page N section MUST contain both a Figma deep-link line AND an IMG marker:**

```markdown
## 6.1 Page 1 — Checkout flow

≤ 3 sentences description.

> **Figma frame**: [Checkout flow](https://www.figma.com/design/<FILE_KEY>/<NAME>?node-id=10380-18214)

<!-- IMG:checkout-flow.png -->
*Figure 1 — Checkout flow*
```

**Why both?**
- **Figma deep-link** — reviewer clicks once and lands in the exact frame, can leave Figma comments, can copy the frame into FigJam, etc. The file-root link forces them to re-find the frame and is unacceptable.
- **IMG marker** — bookmark for the upload step (Path A) or manual drop-in checklist (Path B). The screenshot appears inline in the PRD.

The deep-link survives even if Path B fallback fires; the screenshot may not. Both anchors are required.

**Format the deep-link line as a Confluence quote block** (`> **Figma frame**: …`) so it visually sits one notch below the section heading and one notch above the screenshot.

If you don't yet know the node-id for a page, write:
```markdown
> **Figma frame**: ⚠️ TBD — node-id needed; ask {{design-lead-name}}
```
…and add it to §11.1 Open Questions.

**Building the deep-link URL**:
```
https://www.figma.com/design/<FILE_KEY>/<FILE_NAME>?node-id=<NODE_ID_WITH_DASH>
```
- `FILE_KEY` is from the Figma URL `figma.com/design/<FILE_KEY>/...`
- `NODE_ID_WITH_DASH` is the colon-form node-id with `:` replaced by `-` (e.g., `10380:18214` → `10380-18214`)
- Dashes are required by Figma's deep-link format; colons in URLs break some clients

### Step 3 · Navigate to edit mode

```
tabs_create_mcp(url = <draft_page_url>?atlOrigin=edit)
   — the ?atlOrigin=edit hint opens the editor directly
```

Verify editor loaded: `get_page_text` should show the `<!-- IMG:... -->` markers inline.

### Step 4 · Upload each image, in order

For each PNG in the local folder:

1. `find` the exact marker text: `<!-- IMG:{filename} -->`
2. Click the position (or place the cursor there) — editor-specific, may need `javascript_tool` to set selection
3. `file_upload(path = ~/Desktop/<feature>-figma/{filename})` targeting the editor's file input
4. Wait 1–2 seconds for the image macro to render
5. `get_page_text` and confirm the marker is now replaced with an image reference (not the literal `<!-- IMG... -->` string anymore)
6. If still present, retry once; if still fails, note the filename for Path B fallback

### Step 5 · Save draft

Trigger save (usually ⌘+S or click the "Save" button). Do NOT publish.

### Step 6 · Verify

Use Atlassian MCP `getConfluencePage` to read back the final body. Assert every marker was replaced. If any weren't, add them to the Path B "needs manual upload" list and tell the user.

### Error handling

- **Upload dialog didn't open**: editor version may differ. Try keyboard shortcut `⌘+Shift+I` (insert image in Confluence Cloud editor) or the `/` slash-command menu
- **File rejected**: check file size < 100 MB (Confluence limit)
- **Macro didn't render**: Confluence editor has a known delay; wait 3s and re-read
- **Wrong page edited**: CRITICAL — abort immediately and check the tab URL

---

## Path B — Manual drag-in fallback

Use when Chrome MCP is unavailable, user is not logged in, or Path A had partial failures.

### Body format

Keep the `<!-- IMG:... -->` markers + caption as-is. They're human-readable instructions to the PM.

### Append a "📎 Design assets" section

At the bottom of the PRD, add:

```
## 📎 Design assets — manual drop-in required

The Chrome-based auto-upload was unavailable for this run. Please drop these files into the page at the matching markers:

| Marker in body | Local file |
|---|---|
| <!-- IMG:package-charge-checkout-flow.png --> | ~/Desktop/package-charge-figma/package-charge-checkout-flow.png |
| <!-- IMG:package-charge-error-state.png -->   | ~/Desktop/package-charge-figma/package-charge-error-state.png |

**To complete:**
1. Click "Edit" on this page
2. For each row, find the marker text and drag the local file to that spot
3. Delete the marker comment after the image loads
4. Publish
```

### Tell the user

After the skill finishes, the final message should say:
> *"Draft written. 6 Figma frames need manual drop-in — see the bottom of the page. Reason: [Chrome MCP not installed / not logged in / 2 uploads failed in Path A]."*

---

## Non-goals / explicit don'ts

- ❌ Do NOT try to use Atlassian REST API directly via `fetch` — connector doesn't expose attachment endpoints
- ❌ Do NOT request an API token from the user — we're explicitly staying MCP-only
- ❌ Do NOT upload to any page without verifying the tab URL matches the draft we created
- ❌ Do NOT use Chinese or spaces in filenames
- ❌ Do NOT publish the page automatically; always leave as draft for PM final review
