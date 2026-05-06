---
name: codebase-understanding
description: Produce a structured "code base understanding" brief for a QIMA feature, module, or system area — repo map, architecture stages, team ownership, key APIs, cross-system data flows, related Tech Designs and Jira tickets. Use when a PM says "create a codebase brief", "identify which repos, services, and teams this feature touches", "what's the codebase for X", "trace this feature across the stack", "give me an architecture brief", or invokes /codebase-understanding. Use standalone OR as opt-in Phase 1.X of write-prd when the PRD needs technical context. Does NOT modify code; produces a markdown brief saved to working folder.
version: 0.1.0
user-invocable: true
argument-hint: "[feature name or module]"
---

# Code base understanding

A focused workflow that turns a feature / module name into a structured "where does this live in QIMA's stack" brief — pitched at a PM who needs to know which repos, teams, services, APIs, and related docs are involved, without becoming a tech design.

Modeled after existing manual QIMA Interactive Report codebase-brief documents.

## Core principle

**The output is a navigation map, not a tech design.** PMs use it to:
- Know which team to talk to
- Know which Tech Design / PRD already exists
- Know which Jira epic / stories cover it
- Know whether a feature spans QSP / QIMAone / QIMAlabs / cross-system
- Know which service catalogs / endpoints to bookmark

Not to specify behavior, contracts, or implementation. That's Tech Design's job.

**Keep it ≤ 300 lines**. Anything that runs longer means we're writing a tech design — stop and link out.

## Use modes

**Standalone**: PM runs `/codebase-understanding [feature]` to get a quick map before any PRD work.

**Inside write-prd (Phase 1.X opt-in)**: If the PRD subject is technically novel or cross-system, the main skill's Phase 1 may invoke this to produce a brief; the brief's path is then linked from the PRD's Section 1 related-materials row. The brief is NOT pasted into the PRD body (per voice-and-register rules).

## Mandatory preparation

Before any work, confirm you have:

1. **Feature / module name** — the canonical name (e.g., "Interactive Report", "Audit Renew", "Package Charge Management"). If unclear, ask via `AskUserQuestion`.
2. **Output location** — default to working folder `/sessions/<session>/codebase-briefs/{feature-slug}.md`; copy to user's mounted Cowork folder if available.
3. **Scope** — full feature, single module, or single repo? Default = full feature.

If feature name is missing, ASK first.

---

## Workflow — 4 phases

### Phase A · Anchor identification (≤ 2 min)

1. **Generate keyword variants** using the patterns in `write-prd/references/keyword-expansion.md` — English names, localized names, code names, Jira labels, and team mentions.
2. **Confirm scope with user** if needed (single ad-hoc card via `AskUserQuestion`):
   - Whole feature vs single module?
   - Include cross-system links (QSP ↔ QIMAone ↔ QIMAlabs) or scope to one platform?
3. **Don't loop**: ≥ 3 variants found OR user confirms — proceed.

### Phase B · Parallel discovery (≤ 5 min, dispatch Subagents)

Dispatch all in one message. Each scanner returns a structured brief ≤ 300 words.

| Source | Tool | What to extract |
|---|---|---|
| Confluence | `searchConfluenceUsingCql` | Pages titled "Tech Design" / "PRD" / "architecture" / "design" matching feature variants |
| QSP repos | `qcp__init_qcp` + Read on `Repos.md`, then Explore on top hits | Repo list intersecting feature keywords; per-repo 1-line role |
| Jira | `searchJiraIssuesUsingJql` | Epic(s) + top 5 stories + recent bugs + labels |
| Service catalog | invoke `find-service-details` skill or `find-service-endpoint` skill per repo | Service URLs (Dev/PP/Prod), swagger, key APIs |
| Team mapping | invoke `find-right-team` skill | Owning team + TL per repo |
| Code history (optional) | invoke `code-trace-skills` skill | Recent commits / authors for hot-zone files (only if PM asked for ownership trace) |

If `qcp__init_qcp` is unavailable in current session, fall back to: a Confluence CQL search for `"asiainspection" AND <feature>` + the SP repo inventory pages on Confluence.

### Phase C · Synthesis (≤ 3 min, inline)

Merge briefs into the 10-section template (see `references/output-template.md`). For each section:
- If we have evidence, write the row + cite link
- If we have nothing, write *"Not found in scan — possibly N/A or out of QSP repos.md inventory"*
- Never fabricate. If a service / repo / API is not in any source, say so.

### Phase D · Output

1. Save brief to `/sessions/<session>/codebase-briefs/{feature-slug}.md`
2. **Copy to user's Cowork mounted folder** if available (e.g., `~/Cowork/<folder>/codebase-{feature-slug}.md`)
3. **Return to user**:
   - 5-bullet summary (one bullet per: lifecycle stage, repo count, team count, key Tech Design link, biggest gap)
   - `computer://` link to the file
4. **If invoked by write-prd**: also return a single short link line suitable for the PRD Section 1 related-materials row, e.g. *"[Code base brief — {Feature}]({computer://...})"*. The PM decides whether to paste it.

---

## Voice rules — different from main write-prd

The main `voice-and-register.md` bans repo names / service names / API paths in the PRD body. **This skill is the exception** — repo names, service names, API paths ARE the deliverable's substance, so they belong in the brief.

But still:
- **Sections 1, 2.1–2.3, 8, 9, 10**: PM voice (1-line descriptions, no code)
- **Sections 3, 4, 5, 6, 7**: tabular reference — repo / service / API names allowed
- **No commit hashes** in the brief body. If a commit trace is needed, link to the `code-trace-skills` output instead.
- **Length cap ≤ 300 lines.** If you blow past, prune section 5 (APIs) and section 7 (Jira) first.

---

## Output template (slim)

See `references/output-template.md` for the canonical 10-section layout. Briefly:

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
## 8. PM quick navigation (links to other skills)
## 9. Important caveats (architecture evolution / tech debt / caveats)
## 10. Candidate next steps (up to 3)
```

---

## Decision rules

### When to ask vs proceed

ASK when: feature name unclear · scope ambiguous · user wants ownership trace (commit history) which costs time.

PROCEED (and flag) when: minor ambiguity in module name · alias choice (use canonical name + list variants in §1).

### Stop conditions

- Brief reaches ≥ 8 of 10 sections with content + ≤ 300 lines, OR
- Phase B time budget exceeded (5 minutes), OR
- User says "stop, brief what you have"

In all cases: never fabricate.

---

## Safety gates

- **No code modification.** This skill reads only.
- **No git commit / push.** If `code-trace-skills` is invoked, it must be in read-only mode.
- **Confirm output location** before writing if user has a non-default mounted folder.

---

## Inputs & outputs

**Inputs**: feature / module name; (optional) scope hints; (optional) related Confluence pages as seeds.

**Outputs**:
- `codebase-briefs/{feature-slug}.md` (primary)
- `computer://` link returned to user
- 5-bullet summary in chat
- (if invoked by write-prd) single short link line for the PRD Section 1 related-materials row

---

## References

- `references/output-template.md` — exact 10-section layout
- `write-prd/references/keyword-expansion.md` — variant generation patterns

---

## Related skills

- `write-prd` — main PRD orchestrator; can invoke this skill as Phase 1.X opt-in
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
- This skill does NOT produce per-FR field-mapping tables (that's `ticket-breakdown`)
