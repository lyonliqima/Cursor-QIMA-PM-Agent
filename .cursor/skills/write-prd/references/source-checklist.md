# Source checklist — 8 scanner specs

Phase 1 of the write-prd dispatches 8 parallel Subagents, one per source type. Each Subagent is a `subagent_type: Explore` instance. This file is the specification each scanner reads before running.

---

## Scanner contract — what every Subagent must do

**Inputs** (same for all scanners, passed in the prompt):

1. `keyword-map.md` content — canonical name + all variants in EN/ZH/code-name/acronym
2. Time window — default last 90 days; tighten if the feature is new, loosen for historical research
3. Feature scope one-liner — helps disambiguate noisy matches

**Output** (Subagent returns this structured block, ≤ 300 words):

```markdown
### Source: {{scanner_name}}

**Matches found**: {{N}} (reviewed top {{M}} by relevance)

**Key facts** (only assertions with strong support):
- {{fact}} — [ref: {{source_link_or_id}}]
- ...

**Decisions / agreements** (if any):
- {{who}} on {{when}}: {{decision}} — [ref: ...]

**Contradictions with other sources** (if seen):
- {{contradiction}} — [ref: ...]

**Open / unresolved in this source**:
- {{question}}

**Confidence**: High / Medium / Low
**Reason for confidence level**: {{one sentence}}
```

**Never** invent content. If a field is empty, write "None found" — do not pad.

---

## Scanner 1 · Outlook email

**Why it matters**: initial asks, executive alignment, stakeholder commitments, dates.

**Primary tool**: `mcp__986f78ae-...-outlook_email_search`

**Query strategy**:
1. First pass — search each EN variant from the keyword map, past 90 days
2. Second pass — search stakeholder names × feature canonical name
3. Third pass (only if first two are sparse) — search Jira epic key or Confluence page title

**What to extract**:
- **Decisions**: "we decided to X", "let's go with Y", "approved"
- **Commitments**: "we'll have it by …", "owner is …"
- **Constraints / red lines**: "must not …", "can't break …", "legal requires …"
- **Quotes from leadership** — preserve verbatim with sender + date
- **Attachments mentioned** — note filename + sender; flag for local-file scanner to try

**Skip**:
- Meeting invite noise unless it contains actual agenda content
- Newsletter / automated mail
- "+1" / "thanks" one-liners

**Failure modes**:
- *Too many matches*: tighten to stakeholder × topic; lower window to 30 days
- *No matches*: broaden to ZH variants; try acronym only
- *Auth error*: ask user to re-login to the Microsoft connector

---

## Scanner 2 · Teams chat / channels

**Why it matters**: real-time decisions, complaints, scope-change arguments, lightweight consensus.

**Primary tool**: `mcp__986f78ae-...-chat_message_search`

**Query strategy**:
1. Channel-scoped search first if the feature has a known channel (e.g., team-specific channel)
2. Then keyword-map variants across DMs + group chats
3. Stakeholder names × feature keyword

**What to extract**:
- **Informal decisions** ("let's just do X for v1")
- **Complaints / frustration** — strong signal of pain the PRD should address
- **Screenshot / link references** — collect URLs but don't open them (that's other scanners' job)
- **Timeline claims** ("we need this before Q2")

**Skip**:
- Emoji-only messages
- Pure coordination ("meeting at 3?")

**Failure modes**:
- *Channel not accessible*: note which channel was skipped, let user grant later
- *Chinese-heavy channel with poor EN keywords*: rerun with ZH variants only

---

## Scanner 3 · SharePoint / OneDrive

**Why it matters**: long-form docs, decks, research reports, meeting recordings (with transcripts).

**Primary tools**:
- `mcp__986f78ae-...-sharepoint_search` — content search across all sites
- `mcp__986f78ae-...-sharepoint_folder_search` — if a known folder path exists

**Query strategy**:
1. Keyword-map variants, filtered to doc types: `.pptx`, `.docx`, `.pdf`, `.mp4` (for transcripts)
2. Stakeholder names if the doc type hits suggest owned folders
3. Team name × feature keyword (teams often have dedicated site folders)

**What to extract**:
- **Filename + last-modified date + owner** — even if not opening content, this is signal
- **Top-of-doc summary / TL;DR** — if the doc has one
- **Slide titles** from decks — often contain the decision structure
- **Meeting dates** from transcript filenames

**Skip**:
- Backup / archived versions (`_old`, `_v1_backup`, etc.) — keep only newest
- Files older than 18 months unless historical context is requested

**Failure modes**:
- *Recording with no transcript*: note filename + date; flag as "needs user to provide transcript"
- *Access denied on a promising file*: record the title and ask user for access in Checkpoint A

---

## Scanner 4 · Confluence/Jira history

**Why it matters**: prior PRDs, Tech Designs, Jira Epics/Stories/Bugs, research docs, retrospective findings, decision logs, and historical scope changes.

**Primary tools**:
- `searchConfluenceUsingCql` for Confluence pages
- Jira search / issue read tools for Epics, Stories, Bugs, Tasks, linked issues, and recently updated tickets

**Query strategy**:

```
text ~ "<canonical>" OR text ~ "<variant_1>" OR text ~ "<variant_2>"
  AND type = page
  AND space in ("<team-specific space>", "PROJ", "SBP", "DA", "AIBB", ...)
  AND lastmodified > now("-90d")
  ORDER BY lastmodified DESC
```

Then:

1. Run a second Confluence query without the time filter for **anchor docs** (previous PRDs, strategy pages) — retrieval quality matters more than recency here.
2. Search Jira using the same keyword map plus page titles and Jira keys discovered from Confluence.
3. Follow links both ways: Confluence pages → Jira keys, Jira issues → Confluence/spec links.
4. Spend about 5 minutes total; stop and summarize rather than chasing every link.

**What to extract**:
- **Previous PRD / Tech Design for the same or adjacent feature** — flag as HIGH priority for the agent to read
- **Jira history** — Epics, Stories, Bugs, linked issues, recent updates, and unresolved tickets
- **Research findings** — competitive, user interviews, data analysis
- **Retrospective action items** relevant to this area
- **Architecture / decision records**
- **Timeline** — when scope or decisions changed
- **Conflicts** — old vs new terminology, old scope vs recent scope, Jira vs Confluence mismatch
- **PRD implications** — what should affect Background, Scope, Requirements, Risks, Rollout, or Open Questions

**Skip**:
- Personal spaces (space keys starting with `~`)
- "Copy of …" pages older than 6 months
- Similar-keyword Jira issues with no clear relation after summary/link review

**Failure modes**:
- *Too many matches across all spaces*: filter to owning-team space only first
- *CQL error on special characters*: escape or simplify
- *Too many Jira matches*: prefer recently updated Epics/Stories and issues linked from strong Confluence hits

---

## Scanner 5 · Figma design

**Why it matters**: current design state, frame-level annotations, component library references.

**Primary tools**:
- `mcp__b800ab12-...-get_metadata` — file structure, frame list
- `mcp__b800ab12-...-get_design_context` — per-frame content
- `mcp__b800ab12-...-get_screenshot` — visual capture (called in Phase 4, not Phase 1)

**Query strategy**:
1. User must provide Figma file URL(s) — do not attempt to auto-discover (no Figma search tool)
2. If no URL given, skip this scanner and note in output
3. `get_metadata` to enumerate frames, then `get_design_context` on frames whose names match the feature keyword

**What to extract**:
- **Frame inventory** — ID + name + last-modified
- **Annotations / sticky notes** written on the canvas (often contain design rationale)
- **Figma variables / design tokens** if the feature introduces new ones
- **Stated user flow** if there's a flow diagram

**Skip** (in Phase 1):
- Actual screenshots — defer to Phase 4 to avoid double work
- Draft / exploratory frames labeled `WIP` / `scratch` / `do not use`

**Failure modes**:
- *No Figma URL*: output "Not applicable — no Figma provided" with confidence High
- *File access denied*: ask user to grant Figma connector access

---

## Scanner 6 · QSP code repos

**Why it matters**: hard technical constraints, existing API contracts, data model limits, what's actually already built.

**Primary tools**:
- `mcp__qcp__search_inspection_orders` / `mcp__qcp__get_inspection_order_detail` — domain data lookups
- `mcp__qcp__git_check_out` — check out a specific repo
- Then `Explore` sub-subagent with `Read` / `Grep` on the checked-out repo

**Query strategy**:
1. Resolve target repos from the keyword map `code-repos` field + team-to-project map (see `find-right-team/teams.md`)
2. For each repo, check out latest `main` / `master`
3. Grep for feature keyword across source files
4. Read the top 3-5 most relevant files identified

**What to extract**:
- **API endpoints** the feature would touch (GET/POST paths + request/response shape)
- **Data model constraints** — required fields, uniqueness, foreign keys
- **Feature flags** already in place
- **TODO / FIXME** comments near relevant code — often hint at known limitations
- **Recent commits** touching this area (last 10) — signal of active work

**Skip**:
- Generated code (`*.gen.ts`, `node_modules/`, `target/`)
- Test fixtures unless they reveal required shape

**Failure modes**:
- *Repo too large to read fully*: read only the module directly named by the keyword
- *User lacks access*: note repo name in output; flag for Checkpoint A

---

## Scanner 7 · Notion

**Why it matters**: some teams use Notion for long-form specs, meeting notes, or personal drafts before promoting to Confluence.

**Primary tools**:
- `mcp__daeeeaa6-...-notion-search` — workspace-wide search
- `mcp__daeeeaa6-...-notion-fetch` — read a specific page by ID/URL

**Query strategy**:
1. `notion-search` with canonical keyword, then each variant
2. For any page with a matching title OR with > 3 keyword hits in body, `notion-fetch` to read

**What to extract**:
- **Specs or proposals** at any stage of maturity
- **Linked databases** containing feature-related rows
- **Comments / discussions** on pages (if the API exposes them)

**Skip**:
- Personal template pages
- Empty / abandoned drafts

**Failure modes**:
- *No workspace access*: output "Not applicable — Notion workspace not shared"; confidence High
- *Page has nested databases*: note existence but don't recursively traverse unless PM requests

---

## Scanner 8 · Local files (PPT / PDF / transcripts / screenshots)

**Why it matters**: the freshest materials the PM is literally working with right now.

**Primary tool**: `Read` (native)

**Query strategy**:
1. User provides a folder path OR a list of files in Phase 0
2. For each file, Read and extract key structure
3. For large files (> 50 pages for PDF), read first, last, and a sampled middle section; flag as partial read

**What to extract**:
- **Slide titles** from PPTs — the outline IS the argument
- **Section headings** from PDFs
- **Speaker identification** + key quotes from transcripts (if speaker-labeled)
- **Dates and figures** mentioned anywhere

**Skip**:
- Binary files that can't be read as text (raw video, encrypted zips)
- Files that are clearly templates (empty PPT with only placeholders)

**Failure modes**:
- *Transcript in Chinese without speaker labels*: extract verbatim quotes with no attribution
- *Scanned PDF (image-only)*: note file; ask user to provide OCR'd version
- *File path doesn't exist*: return error with the attempted path

---

## Orchestration notes for the main agent

### How to dispatch all 8 scanners

Send a **single message containing 8 Agent tool calls** (all `subagent_type: Explore`), each with:

- The scanner's spec from this file (copy-paste the relevant section)
- The shared inputs (keyword-map content, time window, scope one-liner)
- A reminder: *"Return the structured output block only. Do not narrate or explain your process."*

### Merging scanner outputs

After all 8 return:

1. **Dedupe** facts that appear in multiple sources (stronger signal — keep all refs)
2. **Flag contradictions** where sources disagree on a specific fact
3. **Rank gaps** — which template sections still have no source support
4. **Rate overall confidence** per PRD section based on how many independent sources support it

### What to do when a scanner fails

- **Do not retry more than once** — scanners fail because auth, permissions, or empty results; retrying rarely helps
- **Do not hide failures** — every failed scanner must appear in the source ledger with reason
- **Degrade gracefully** — a PRD with 6 out of 8 scanners is still valuable; just clearly marked

### Time budget

If Phase 1 exceeds **5 minutes wall-clock** total, stop remaining scanners and proceed to Phase 2 with what you have. Surface the timeout in the source ledger. PMs waiting 10 minutes staring at a loading spinner is worse than a slightly thinner PRD.

---

## Maintenance

This checklist is a living document. When a new MCP tool becomes available (e.g., if QIMA deploys a Linear MCP, a Jira native MCP different from Atlassian's, or a custom internal doc search), add a Scanner 9+ following the same structure. Remove scanners that become obsolete.

The order of scanners here is also the **default dispatch priority** — if time-budget-constrained, scanners 1-4 are the most load-bearing for PRD quality; 5-8 are frequently "not applicable" and cheap to skip.
