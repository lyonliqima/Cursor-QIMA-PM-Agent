---
name: codebase-understanding
description: Produce a deep local codebase research report for a QIMA feature, module, or system area before PRD drafting — repo map, architecture stages, team ownership, key APIs, cross-system data flows, business fields, field-source logic, acceptance-criteria inputs, related Tech Designs and Jira tickets. Use when a PM says "create a codebase report", "深入看看代码库", "trace this feature across the stack", "what's the codebase for X", or invokes /codebase-understanding. Also runs from write-prd Phase 1.1 for product/software PRDs. Does NOT modify code; saves markdown reports locally.
version: 0.2.0
user-invocable: true
argument-hint: "[feature name or module]"
---

# Code base understanding

A focused workflow that turns a feature / module name into a deep local codebase research report for PRD preparation — pitched at a PM who needs to know which repos, teams, services, APIs, business fields, data rules, and related docs are involved before writing requirements.

Modeled after existing manual QIMA Interactive Report codebase-brief documents.

## Core principle

**The output is PRD research support, not a Tech Design.** PMs use it to:
- Know which team to talk to
- Know which Tech Design / PRD already exists
- Know which Jira epic / stories cover it
- Know whether a feature spans QSP / QIMAone / QIMAlabs / cross-system
- Know which service catalogs / endpoints to bookmark
- Know which business fields exist, where they come from, and what user-visible rules they imply
- Convert code facts into PRD-ready requirements and acceptance criteria

Do not write implementation specs or tell engineers how to build; that remains Tech Design's job. But unlike a slim repo map, this report should go deep enough to prevent the PRD from inventing product behavior that conflicts with the codebase.

**Depth target**: for PRD-prep mode, expect 500-900 lines if the feature is cross-system. Keep the writing structured and PM-readable; raw code snippets should be rare and only used as evidence.

## Use modes

**Standalone**: PM runs `/codebase-understanding [feature]` to get a local codebase report before PRD work.

**Inside write-prd (Phase 1.1 required for product/software PRDs)**: The main skill invokes this unless the PM explicitly confirms the PRD is non-software / no-codebase. The report paths are linked from the PRD's Section 1 related-materials row. The report is NOT pasted into the PRD body (per voice-and-register rules).

## Mandatory preparation

Before any work, confirm you have:

1. **Feature / module name** — the canonical name (e.g., "Interactive Report", "Audit Renew", "Package Charge Management"). If unclear, ask via `AskUserQuestion`.
2. **Output location** — default to the PRD working folder `_prd-run/codebase-reports/` when invoked by `write-prd`; otherwise save to the user's provided docs folder or Desktop.
3. **Scope** — full feature, single module, or single repo? Default = full feature.
4. **Freshness policy** — if an existing report is found, reuse only if it is fresh (see Phase A0).

If feature name is missing, ASK first.

---

## Workflow — 5 phases

### Phase A0 · Existing-report freshness check (≤ 2 min)

Before scanning, search the likely local locations:

- current working folder / PRD input folder
- `{input-folder}/_prd-run/codebase-reports/`
- Desktop
- meeting-notes folder if the user supplied one

Look for:

- `*codebase*{feature-slug}*.md`
- `*{feature-slug}*Codebase*.md`
- `*{feature-slug}*PRD_Ready*.md`
- prior manual notes such as `功能代码梳理.md` / `codebase-briefs/*.md`

Reuse only if ALL are true:

- report age is ≤ 14 days;
- feature scope matches the current PRD scope;
- no newer Jira / Confluence / Figma seeds were provided;
- user did not ask to refresh / "深入研究" / "重新看看代码".

If stale, explicitly mark it as stale in the new report's source ledger and regenerate. If fresh, still scan for obvious new seeds and produce a short "freshness checked" note.

### Phase A · Anchor identification (≤ 2 min)

1. **Generate keyword variants** using the patterns in `write-prd/references/keyword-expansion.md` — English names, localized names, code names, Jira labels, and team mentions.
2. **Confirm scope with user** if needed (single ad-hoc card via `AskUserQuestion`):
   - Whole feature vs single module?
   - Include cross-system links (QSP ↔ QIMAone ↔ QIMAlabs) or scope to one platform?
3. **Don't loop**: ≥ 3 variants found OR user confirms — proceed.

### Phase B · Deep parallel discovery (5 min, dispatch Subagents)

Dispatch all relevant scanners in one message. Each scanner returns a structured brief with evidence links and file paths. For cross-system features, keep the scan focused: spend up to 5 minutes on discovery, then proceed with the best evidence found and mark gaps explicitly.

| Source | Tool | What to extract |
|---|---|---|
| Confluence | `searchConfluenceUsingCql` | Pages titled "Tech Design" / "PRD" / "architecture" / "design" matching feature variants |
| QSP repos | `qcp__init_qcp` + Read on `Repos.md`, then Explore / GitHub / local repo reads on top hits | Repo list, hot files, per-repo role, entrypoints, DTOs, mappers, services |
| Jira | `searchJiraIssuesUsingJql` | Epic(s) + top 5 stories + recent bugs + labels |
| Service catalog | invoke `find-service-details` skill or `find-service-endpoint` skill per repo | Service URLs (Dev/PP/Prod), swagger, key APIs |
| Team mapping | invoke `find-right-team` skill | Owning team + TL per repo |
| Code history (optional) | invoke `code-trace-skills` skill | Recent commits / authors for hot-zone files (only if PM asked for ownership trace) |

Required code scan dimensions for PRD-prep mode:

- **Entry points**: routes, pages, controllers, public APIs, consumers, scheduled jobs.
- **Data flow**: front-end → API gateway/public API → service → mapper → upstream systems → storage/cache.
- **Business fields**: user-visible fields, labels, enums, result statuses, decision states.
- **Field source logic**: where each field comes from, fallback rules, stale/cache rules, cross-system differences.
- **Computation / mapping rules**: AQL, pass/fail, totals, grouping, visibility, permissions, share/read-only modes.
- **Evidence chain**: photos, attachments, comments, defects, tests, measurements.
- **Risks for PRD**: fields that can be missing, legacy/new data differences, ambiguous terminology.

If `qcp__init_qcp` is unavailable in current session, fall back to: a Confluence CQL search for `"asiainspection" AND <feature>` + the SP repo inventory pages on Confluence.

### Phase C · Synthesis (inline)

Merge briefs into the expanded report template (see `references/output-template.md`). For each section:
- If we have evidence, write the row + cite link
- If we have nothing, write *"Not found in scan — possibly N/A or out of QSP repos.md inventory"*
- Never fabricate. If a service / repo / API is not in any source, say so.
- Translate code facts into PRD implications:
  - field -> business meaning
  - mapper/service rule -> user-visible behavior
  - missing/fallback rule -> PRD risk or AC
  - result computation -> "front-end must not recalculate" boundary

### Phase D · Output

1. Save full report to `{output-root}/_prd-run/codebase-reports/{feature-slug}-codebase-report-{YYYYMMDD}.md`
2. Save PRD-ready summary to `{output-root}/_prd-run/codebase-reports/{feature-slug}-prd-ready-field-guide-{YYYYMMDD}.md`
3. If invoked outside a source folder, save to Desktop:
   - `~/Desktop/{Feature}_Codebase_Understanding_Report.md`
   - `~/Desktop/{Feature}_PRD_Ready_Field_Guide.md`
4. **Copy to user's Cowork mounted folder** if available (e.g., `~/Cowork/<folder>/codebase-{feature-slug}.md`)
5. If an older report was found, keep it; never overwrite unless the user explicitly asks. Create a dated fresh file.
6. If updating a long-running PRD folder, add a one-line pointer from the newest report to any PRD-ready guide.
7. **Return to user**:
   - 5-bullet summary (one bullet per: lifecycle stage, repo count, team count, key Tech Design link, biggest gap)
   - local file paths
   - whether this was reused or freshly regenerated
8. **If invoked by write-prd**: also return a single short link line suitable for the PRD Section 1 related-materials row, e.g. *"[Codebase report — {Feature}]({local-path})"*. The PM decides whether to paste it.

---

## Voice rules — different from main write-prd

The main `voice-and-register.md` bans repo names / service names / API paths in the PRD body. **This skill is the exception** — repo names, service names, API paths ARE the deliverable's substance, so they belong in the brief.

But still:
- **Sections 1, 2.1–2.3, 8, 9, 10**: PM voice (1-line descriptions, no code)
- **Sections 3, 4, 5, 6, 7**: tabular reference — repo / service / API names allowed
- **No commit hashes** in the brief body. If a commit trace is needed, link to the `code-trace-skills` output instead.
- For PRD-prep mode, do not enforce the old 300-line cap. Use structure, not artificial brevity. If the report exceeds ~900 lines, move detailed evidence into an appendix.

---

## Output template

See `references/output-template.md` for the canonical layout. Briefly:

```
# Code base understanding — {Feature}
> Date · Generated by

## 0. Preface (about 3 lines)
## 1. What {Feature} is (one-line positioning + cross-system view)
## 2. Feature inventory
   2.1 Live / currently running
   2.2 In development / planned
   2.3 Core feature modules
   2.4 Non-functional characteristics
## 3. Technical architecture (repo view)
   3.1 Front-end (table)
   3.2 Back-end (table)
   3.3 Cross-system data flows (up to 2)
## 4. Team ownership (table)
## 5. Core APIs / entry points (up to 10 rows)
## 6. Related PRDs / Tech Design documents (up to 8 rows)
## 7. Related Jira (up to 6 rows)
## 8. Business field dictionary and logic
## 9. PRD-ready implications and AC seeds
## 10. PM quick navigation
## 11. Important caveats
## 12. Candidate next steps
```

## PRD-ready field guide output

When invoked by `write-prd`, also create a shorter companion file named:

`{feature-slug}-prd-ready-field-guide-{YYYYMMDD}.md`

Use this structure:

```markdown
# {{FEATURE_NAME}} PRD-ready field guide

## 0. How to use this guide
## 1. Product positioning for the PRD
## 2. Business terms and field口径
## 3. Module-by-module requirement notes
## 4. Acceptance Criteria seeds
## 5. Design-review pitfalls
## 6. Engineering alignment boundaries
## 7. P0 / P1 / P2 requirement opportunities
## 8. PRD-ready snippets
```

Rules:

- Keep this guide product-readable; hide repo/service details unless needed for traceability.
- Convert technical fields into business terms.
- Include directly reusable AC bullets.
- State what must NOT be recalculated by front-end.
- Mention stale/fallback/legacy-data caveats in product language.

---

## Decision rules

### When to ask vs proceed

ASK when: feature name unclear · scope ambiguous · user wants ownership trace (commit history) which costs time.

PROCEED (and flag) when: minor ambiguity in module name · alias choice (use canonical name + list variants in §1).

### Stop conditions

- Report reaches the expanded template with enough evidence for PRD drafting, OR
- Phase B time budget exceeded (5 minutes) and the user did not ask for deeper scan, OR
- User says "stop, brief what you have"

In all cases: never fabricate.

---

## Safety gates

- **No code modification.** This skill reads only.
- **No git commit / push.** If `code-trace-skills` is invoked, it must be in read-only mode.
- **Confirm output location** before writing if user has a non-default mounted folder.
- **Do not overwrite old reports** unless explicitly requested; create dated fresh reports when stale.

---

## Inputs & outputs

**Inputs**: feature / module name; (optional) scope hints; (optional) related Confluence pages as seeds.

**Outputs**:
- full codebase report markdown (primary)
- PRD-ready field guide markdown (when invoked by write-prd or when useful for PRD drafting)
- `computer://` link returned to user
- 5-bullet summary in chat
- (if invoked by write-prd) single short link line for the PRD Section 1 related-materials row

---

## References

- `references/output-template.md` — exact 10-section layout
- `write-prd/references/keyword-expansion.md` — variant generation patterns

---

## Related skills

- `write-prd` — main PRD orchestrator; invokes this skill in Phase 1.1 for product/software PRDs unless explicitly skipped
- `find-right-team` — bundled team-to-project map; called by Phase B
- `find-service-details` — per-service inspection; called by Phase B
- `find-service-endpoint` — per-service URL lookup; called by Phase B
- `code-trace-skills` — commit / Jira ticket trace; optional Phase B sub-call
- `find-jira-skill` — Jira ticket links; helper

---

## Non-goals

- This skill does NOT write Tech Design docs (engineers do)
- This skill does NOT modify code or commit
- This skill does NOT generate Jira tickets
- This skill does NOT replace the main PRD skill — it complements
- This skill does NOT replace `ticket-breakdown`, but it MAY produce field dictionaries and AC seeds for PRD preparation
