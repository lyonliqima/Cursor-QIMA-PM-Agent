---
name: write-prd
description: Orchestrate end-to-end PRD drafting for QIMA PMs. Before drafting, performs or refreshes local deep codebase and Confluence/Jira history reports for product features, then aggregates local files, Outlook, Teams, SharePoint/OneDrive, Confluence history, Figma, Notion, Jira, and QSP code context; runs business-background mining + multi-turn depth interview; enforces a PM-readable, non-technical PRD body; then writes a complete draft to Confluence. Use when a PM says "write a PRD", "draft a PRD", "create a requirements document", "run the PRD skill", or invokes /write-prd. Do NOT use for reviewing existing PRDs (use prd-critique) or breaking PRDs into tickets (use ticket-breakdown).
version: 0.4.2
user-invocable: true
argument-hint: "[feature name or brief description]"
---

# QIMA PM Skills

End-to-end orchestrator that turns scattered context into a Confluence PRD draft. The PM owns the thinking; this skill owns the legwork.

## Core principles

**Never fabricate.** Every claim must be traceable to a cited source or marked as "assumption — needs user confirmation".

**Ask thoroughly, write tightly.** Long interview → short PRD. **These are two different budgets — do not conflate them.** Phase 1.5 / 2.5 / Checkpoint A SHOULD ask many questions; Phase 4 drafting SHOULD compress aggressively. The user's time spent answering = quality saved later.

When deciding whether to ask a question, default to **ASK**. Three triggers fire a question:

1. **You're uncertain about a fact** (source ambiguous, two sources conflict, or no source at all)
2. **You find a detail meaningful** (a number, a constraint, a stakeholder name, a trade-off the PM is making implicitly) — flag it back to the PM so they can confirm or correct, even if it doesn't block drafting
3. **A section couldn't be drafted today without inventing** — that section's missing inputs are questions, not assumptions

If unsure whether to ask, ASK. Verbose interview is recoverable; PRD with fabricated detail is not.

**PM voice, not engineer voice.** PRDs are read by PMs, designers, business leads, and customer reps — not engineers. Technical detail belongs in the Tech Design page (linked from §1 meta-table), not in the PRD body. See `references/voice-and-register.md` — it is **enforced before publish**.

**Human PM writing, not AI summary.** The PRD should read like a QIMA PM wrote it after stakeholder alignment: concrete situation, named owner, explicit scope decision, measurable outcome, and a few useful imperfections of natural business writing. If a paragraph could fit any company or any product, rewrite it or delete it. See `references/human-prd-writing-style.md` — it is **enforced before publish**.

**Short by default.** Target the body to **≤ 250 lines / ≤ 6 pages of Confluence**. If the PM wants engineering-grade depth, run `ticket-breakdown` afterwards — do not bloat the PRD itself.

---

## Mandatory preparation

Before any work, confirm you have:

1. **Feature scope** — one-sentence description of what's being built
2. **Target Confluence location** — Space key + parent page URL (ask user if not given)
3. **Template** — default to `qima-prd-writing-guide`; confirm if user wants otherwise
4. **Primary objective** — the confirmed business goal this PRD serves, in plain language

If any of these four are missing, ASK the user first. Do not guess.

---

## Workflow — 7 phases, 2 checkpoints, 1 auto-loop

### Phase 0 · Input intake

Collect from the user (explicit or via the elicitation form):

- Background text or filled-in brief
- Local asset paths (PPTs, PDFs, meeting transcripts, screenshots, prototype URLs)
- **Figma section URL (REQUIRED if any §6 Design content is expected)** — the **specific section** containing the page-level frames (NOT the file root). Example: `https://www.figma.com/design/<KEY>/<NAME>?node-id=10428-25076`. Phase 4 will scope frame search to this section only — never search the whole file globally (that mis-resolves to unrelated pages: e.g., Marketing dashboards, MAISA AI panels, etc.). If user hasn't picked a section yet, ASK before drafting §6.
- Known stakeholders (PM peers, engineering lead, design lead)
- Known related Jira epics or Confluence pages (as seeds)
- Target Confluence Space + parent page
- Deadline / urgency (affects depth of source scan)

Output: `context-manifest.md` listing every input source — Figma section URL recorded in its own row.

### Phase 0.5 · Keyword expansion

QIMA features have **inconsistent naming**. Build a small keyword map (at least 2 English variants, at least 1 localized or legacy variant, code names if known) before scanning. See `references/keyword-expansion.md`.

Stop condition: ≥ 3 variant names found OR user confirms "these are all the names". Don't loop.

### Phase 1 · Parallel source scan

Dispatch all scanners in a single message (parallel Subagents). Every scanner uses the keyword map.

| Scanner | Tool | What to extract |
|---|---|---|
| Outlook | `outlook_email_search` | Emails, past 90 days |
| Teams | `chat_message_search` | Channels/DMs, decisions, asks |
| SharePoint | `sharepoint_search` | Related docs |
| Confluence / Jira history | Phase 1.2 below | Deep history report across related Confluence pages and Jira issues |
| Figma | `get_design_context` + `get_screenshot` | Designs |
| QSP code / architecture | `codebase-understanding` skill (Phase 1.1 below) | Deep codebase report, business fields, data flows, repo/service/API map |
| Notion | `notion-search` + `notion-fetch` | Linked Notion docs |
| Local files | `Read` | PPT/PDF/transcript |

Each Subagent returns a **structured brief (≤ 250 words)** with: key findings, direct quotes, source links.

### Phase 1.1 · Deep codebase research report (REQUIRED for product/software PRDs)

Before drafting any product/software PRD, run or refresh `codebase-understanding` for the feature. Default = RUN. Skip only when the PRD is explicitly non-software / non-system-facing and the PM confirms no codebase context is needed.

**Freshness check first**:

1. Search the working folder, user-provided docs folder, and Desktop for existing reports matching:
   - `*codebase*{{feature-slug}}*.md`
   - `*{{feature-slug}}*Codebase*.md`
   - `*{{feature-slug}}*PRD_Ready*.md`
2. Treat an existing report as stale if:
   - it is older than 14 days, OR
   - feature scope changed materially, OR
   - new Jira / Confluence / Figma seeds were provided after the report was created, OR
   - the PM says "重新研究", "深入看看代码", "refresh", "old", or similar.
3. If no fresh report exists, run `codebase-understanding` in **deep PRD-prep mode**. Use a focused 5-minute scan budget for codebase discovery, then proceed with the best evidence found and mark remaining gaps.

**Required local outputs**:

- Full codebase report: `{work-folder}/_prd-run/codebase-reports/{feature-slug}-codebase-report-{YYYYMMDD}.md`
- PRD-ready summary: `{work-folder}/_prd-run/codebase-reports/{feature-slug}-prd-ready-field-guide-{YYYYMMDD}.md`
- If the user gave a Desktop / meeting-notes folder as source material, also copy or save the files there for easy access.

**How to use the output**:

- Link both local reports from PRD Section 1 related materials / source ledger.
- Use the PRD-ready summary to shape Requirements and Acceptance Criteria.
- Do NOT paste repo names, route paths, Java/TS field paths, or mapper details into the PRD body unless the user explicitly requests a dev-ready spec. Keep technical details in the local report or appendix.

### Phase 1.2 · Confluence/Jira history research report (REQUIRED)

Run this in parallel with Phase 1.1 and the other Phase 1 scanners. The goal is to understand the requirement's history, not just find the newest page.

**Time budget**: about 5 minutes. When the budget is hit, stop deeper searching, summarize what was found, and mark gaps.

**Search targets**:

- Confluence PRDs, Tech Designs, design notes, rollout notes, retrospectives, meeting notes, research pages, and architecture pages.
- Jira Epics, Stories, Bugs, Tasks, linked issues, recently updated tickets, and tickets referenced from Confluence pages.

**Search strategy**:

1. Use the Phase 0.5 keyword map plus Jira keys and page titles found during the scan.
2. Search broadly first, then follow links from the strongest Confluence/Jira hits.
3. Extract history, not just current scope:
   - why the requirement exists;
   - previous attempts / legacy decisions;
   - known constraints and unresolved questions;
   - scope changes over time;
   - related bugs / support asks;
   - stakeholders and owning teams mentioned in docs;
   - old vs new terminology.
4. Weighting is for prioritization only, not proof:
   - recent content gets higher weight;
   - directly linked PRD/Tech Design/Jira gets higher weight;
   - older content still matters when it explains origin, constraints, or decisions that remain true.
5. If sources conflict, record the conflict instead of choosing silently.

**Required local output**:

- History report: `{work-folder}/_prd-run/history-reports/{feature-slug}-confluence-jira-history-{YYYYMMDD}.md`
- If the user gave a Desktop / meeting-notes folder as source material, also copy or save the file there for easy access.

**Report must include**:

- Executive summary of historical context.
- Weighted source list with recency and relevance notes.
- Timeline of major decisions / requirement changes.
- Related Confluence pages.
- Related Jira issues.
- Confirmed facts, conflicts, gaps, and open questions.
- PRD implications: what should influence Background, Scope, Requirements, Risks, Rollout, and Open Questions.

See `references/requirement-history-research.md`.

### Phase 1.5 · Business-background mining

Generate **6–15 meta-questions** about the domain concepts the PRD touches. For each: try to answer from sources first (1-sentence direct answer + cited source + ≤ 50 words mechanism). **Unanswered questions go to Phase 2.5 user batch — don't fabricate them.**

The bar is *lift the PRD above template-completeness*. Each meta-question should be one a sharp engineer or new PM would ask. Don't pad — but don't under-ask either; a missing meta-question becomes a fabricated paragraph in §2.

Output `business-background.md`. **Do NOT paste Q&A blocks into PRD body.** This file is fuel for §2 Background prose, not a section in the PRD itself.

See `references/business-background-mining.md`.

### Phase 2 · Synthesis & gap detection

Merge briefs. Produce: confirmed facts, conflicts, gaps, assumptions. Do NOT write PRD content yet.

### ◆ Checkpoint A · Multi-turn clarification

Use `AskUserQuestion`. Prioritize, but cover ALL relevant items — under-asking here is the #1 PRD-quality killer:

1. **Conflicts between sources** — every conflict that affects an FR / metric / scope decision (user must pick)
2. **Critical gaps** — every section that cannot be left blank without inventing (e.g., success metric numbers, owners, dates)
3. **Scope boundaries** — every "is X in or out?" the sources don't decide
4. **Implicit trade-offs** — when the PM has an implicit preference but no source mentions it (e.g., "you said keep 5-star landing — confirm this overrides the Ornella deletion email?")
5. **Stakeholder identities** — every name mentioned without a §3 row entry should be confirmed (who is this, what role, do they belong in §3?)
6. **Numbers without sources** — any quantitative claim (≥ 60%, ≥ 40%, 32 MD, 6,621 sessions) needs a source citation; if missing, ask

Per card: no more than 3 questions, single topic per card. Multi-card rounds are normal. Cap at **5 rounds**. Unresolved at round 5 -> "Open question" in Section 11 and move on.

If a question feels minor but you're truly uncertain, ASK ANYWAY — the cost of asking is small; the cost of fabricating a detail in the PRD is large.

### Phase 2.5 · Depth interview

The shallowness audit lives in `references/depth-interview.md` — **all 18 triggers active by default**, not just the priority five. Target one round per triggered section.

The point is to lift the PRD above template-completeness, not to interrogate the PM — but err toward asking. If the synthesis says "section X is thin", that section gets a round. **Don't skip rounds to save user time** — the user's time saved here re-appears as PRD weakness.

Round structure per `references/depth-interview.md`:
- Round 0 — scope sanity (always run)
- Then run rounds in priority order (Background → FR schema → OOS provenance → Risk probability → Release gates → Edge cases → OQ blockers → others)

**Stop conditions**: All triggered sections cleared, OR **round 7 hit (cap)**, OR user says "stop asking, draft what you have" (in which case log what's missing as TBD markers).

### Phase 3 · Outline generation

Produce the PRD outline only — section headings + one-line intent. Surface to user as a structured list. Mark sections as Strong / from-source / "open question".

### ◆ Checkpoint B · Outline approval

User confirms outline or redirects.

### Phase 4 · Draft body

1. **Delegate to `qima-prd-writing-guide`** for section prose.
2. **Length budget**: aim for ≤ 250 lines of markdown body, ≤ 6 Confluence pages. If you exceed, cut.
3. **Human PM style gate (REQUIRED before publish)**: scan the draft against `references/human-prd-writing-style.md`. Remove AI-smell language, generic benefit claims, symmetrical filler, and unsupported confidence. Make Background, Scope, Metrics, Rollout, and Open Questions decision-quality before publishing.
4. **Voice gate (REQUIRED before publish)**: scan the draft for the banned items in `references/voice-and-register.md` — Jira ticket lists, repo names, route paths, service names, internal field paths, snake_case event details. Move any survivors to **Appendix · For engineering reference** or strip outright.
5. **Figma deep-links + render**: every `## 6.x Page N` MUST carry:
   - a `> **Figma frame**: [name](URL?node-id=<frame>)` line — text-link form
   - **a bare Figma URL on its own line directly underneath** — Confluence's **Figma for Confluence** plugin (assumed installed in QIMA Confluence) auto-detects bare URLs and renders them as inline live frame embeds. Bare-URL-on-own-line is the simplest reliable trigger for the plugin macro.

   **Frame-search scope**: search **ONLY inside the user-provided Figma section** (recorded in Section 1 related materials + Phase 0 intake). NEVER search the whole file globally — Figma files have many unrelated pages (marketing dashboards, AI workspaces, etc.) and global search picks the wrong frame. If the user hasn't supplied a section node-id, ASK before drafting Section 6.

   If a node-id can't be resolved within the user-provided section, write `TBD — ask design lead` and add to Section 11 Open Questions; do NOT fall back to file root.

   Optional: also include an `<!-- IMG:filename.png -->` marker for static-PNG fallback (Path B manual drop-in) — only if the team explicitly wants offline-readable screenshots in addition to live embeds. Default = skip the IMG marker; live Figma embed is enough.

   **Static design assets / cropped screenshots**: when the user asks for images in the PRD, when Confluence needs URL-hosted screenshots, or when a long Figma page must be split into PRD-section-specific crops, load the internal `prd-design-assets` skill. Use it to export via Figma API, crop focused regions, publish stable image URLs, and insert the cropped screenshots next to the matching Design subsection. Do not insert one long screenshot when section-level crops are available.

   See `references/figma-handling.md` for the section-scoping algorithm and the Figma for Confluence rendering rule.
6. **No visible inline source footers**: do not add `Source:` lines under each section in the formal PRD body. Keep evidence in the internal source ledger, Section 1 Related Materials, or Appendix A only when the user explicitly wants a source appendix.
7. **Primary Objective style**: write Section 2.2 as 2-4 short, certain sentences. Avoid "North Star", "leading proxy", adoption targets, percentages, dates, or KPI language unless the source material or PM explicitly confirms them. If the objective is not confirmed, ask before drafting instead of inventing a polished metric.
8. **Meeting-note business-rule coverage**: when a meeting note, walkthrough, or PM explanation contains concrete user-visible behavior, promote it into the PRD body. Do not leave these rules only in the source ledger, ticket appendix, or broad summary.
   - customer-specific examples -> user stories or requirement notes when they change behavior
   - "must still show", "can enable/disable", "do not duplicate", "fallback to X", "warn before overwrite" -> FR notes plus matching AC
   - per-role actions such as generate, edit online, confirm, merge, preview, approve -> user stories or interaction specs
   - ticket lists -> appendix only; they prove coverage but do not replace business rules in Section 4/5/7
   If adding every detail would bloat the PRD, keep the prose short but preserve the behavior in the relevant US / FR / AC row.
9. **Codebase-report use**: convert codebase findings into product language:
   - code field -> business field
   - mapper logic -> user-visible rule
   - API/data-flow constraint -> dependency/risk
   - evidence path -> acceptance criterion
   Never paste raw implementation detail into the main PRD body.
10. **History-report use**: convert Confluence/Jira history into PRD context:
   - old decision -> background or scope rationale
   - recent Jira/Confluence update -> current direction or risk
   - conflict between sources -> open question
   - repeated bug/support ask -> pain point or acceptance criterion
   Never paste the full timeline into the PRD body; keep it in the local history report and cite the strongest sources.
11. **Decision-quality pass**: before review, verify the draft contains:
   - Background: current situation, pain point, business impact, and baseline if available.
   - Stakeholders: only named decision owners / leads / required reviewers; no generic sponsor, business SME, support, or delivery-team rows. Do not infer a business stakeholder from related materials; include one only when the PM explicitly asks for that person to appear in Section 3.
   - User Stories: cover concrete user actions from source material, not just generic personas.
   - Requirements: include the material business rules from meeting notes / tickets, especially exceptions, display rules, enable-disable rules, fallback behavior, and overwrite warnings.
   - Acceptance Criteria: add a matching AC for each behavior-changing rule introduced in an FR note.
   - Scope: in-scope / out-of-scope decisions with reasons, not just a feature list.
   - Metrics: baseline, target, measurement method, and owner; if missing, ask or mark TBD.
   - Rollout: communication / training / pilot / reversible configuration where relevant.
   - Open Questions: owner, target alignment party, and whether it blocks v1.

### Phase 4.5 · Depth-pass loop (OPTIONAL — only on explicit PM request)

The 6-dimension per-FR depth gate (`references/depth-gate-checklist.md`) drives engineering-grade detail: state machines, field-mapping tables, API contracts, edge case matrices. **This produces a 500+ line "spec" — useful for solo dev handoff, but bloats the PRD.**

Default = SKIP. Run only when:
- PM explicitly asks: *"make this dev-ready"* / *"deep version"* / *"include the data contract"*, OR
- There is no separate Tech Design page and dev is pulling from PRD directly.

Otherwise, leave per-FR detail to `ticket-breakdown` (the dedicated handoff skill).

### Phase 4.7 · Review-loop (REQUIRED)

After body draft, invoke the `prd-critique` skill. Loop until no High items or 3rd round. Apply fixes between rounds.

The reviewer's first pass also enforces `voice-and-register.md` and `human-prd-writing-style.md` — any technical-jargon survivor or AI-smell paragraph counts as a finding.

### Phase 5 · Write to Confluence

1. **Confirm target Space** with user (safety gate)
2. Create page with `createConfluencePage` — status: **draft**. Use `contentFormat: "markdown"` for PRD publishing by default. Do not force table width through ADF attrs (`width`, `layout`, or `displayMode`) from this skill; Confluence should render markdown pipe tables using its native page/table behavior.
3. Append only user-facing material:
   - **Open questions** (any unresolved)
   - Optional source appendix only if the PM explicitly asks for source links in the PRD
   Keep the full source ledger as a local/internal working note by default; do not publish it into the formal PRD.
4. Return URL + 3-bullet summary of what was written and what needs user attention.

---

## Decision rules

### When to ask vs proceed

ASK when: required field has no source · two sources contradict · scope unclear · target Confluence not specified.

PROCEED (and flag) when: minor ambiguity in non-critical section · stylistic phrasing only.

### When to use Subagent vs inline

Subagent (parallel): Phase 1 source scanning · heavy code-repo reads · single read > 5k tokens.

Inline: AskUserQuestion · PRD body writing · Confluence write.

---

## Safety gates

1. **Confluence write** — confirm Space + parent; default Draft.
2. **Figma upload via Chrome MCP** — verify Chrome MCP available + authenticated to `qima.atlassian.net` before uploading.
3. **Jira creation** — NOT this skill's job (use `ticket-breakdown`).
4. **Codebase report freshness** — for product/software PRDs, do not draft without either a fresh local codebase report or an explicit PM confirmation to skip.
5. **History report freshness** — do not draft without either a fresh Confluence/Jira history report or an explicit PM confirmation to skip.

NEVER:
- Write to a published Confluence page without explicit confirmation
- Auto-generate Jira tickets
- **Skip the human PM style gate, voice-gate, or review-loop**
- Improvise formatting — match `references/format-conventions.md`
- Exceed the length budget without an explicit user request to go deep
- Paste Phase 1.5 Q&A blocks into PRD body — they are working notes, not deliverable
- Treat stale codebase notes as current without checking age/scope
- Treat the newest Confluence/Jira page as the only truth without checking linked historical context

---

## Inputs & outputs

**Inputs**: feature brief · optional local assets / Figma URLs / Confluence-Jira seeds · target Confluence + confirmed primary objective.

**Outputs**:
- Confluence draft page URL (primary)
- Compact internal source ledger or optional source appendix when requested
- Open-questions list
- Local `context-manifest.md`
- Local deep codebase report + PRD-ready field guide for product/software PRDs
- Local Confluence/Jira history report for requirement background and prior decisions

---

## References

- `templates/prd-template.md` — QIMA PRD template (draft version)
- `references/voice-and-register.md` — **enforced** non-technical voice rules
- `references/human-prd-writing-style.md` — **enforced** human PM writing and decision-quality rules
- `references/format-conventions.md` — section structure + style guardrails
- `references/source-checklist.md` — Phase 1 source-type → MCP-tool mapping
- `references/keyword-expansion.md` — Phase 0.5 patterns
- `references/business-background-mining.md` — Phase 1.5 light Q&A guidance
- `references/requirement-history-research.md` — Phase 1.2 Confluence/Jira history report guidance
- `references/depth-interview.md` — Phase 2.5 5-trigger audit
- `references/depth-gate-checklist.md` — **OPTIONAL** dev-handoff template
- `references/prd-patterns-from-best.md` — patterns library; PMs pick what fits
- `references/figma-handling.md` — Figma → Confluence image pipeline

---

## Related skills

- `qima-prd-writing-guide` — Phase 4 prose
- `prd-critique` — Phase 4.7 review (auto-invoked)
- `codebase-understanding` — required before product/software PRDs unless explicitly skipped; produces local deep codebase report + PRD-ready field guide; link from Section 1, never paste raw technical detail in body
- `prd-design-assets` — internal helper for static Figma exports, cropped PRD-section images, and URL-hosted screenshots; use only from this skill or `ticket-breakdown`
- `ticket-breakdown` — AFTER PRD approval, produces engineering-grade ticket detail
- `test-case-generation` — AFTER PRD approval, produces test cases

---

## Non-goals

- This skill does NOT produce engineering-grade specs (use `ticket-breakdown`)
- This skill does NOT review existing PRDs
- This skill does NOT generate Jira tickets or test cases
- This skill does NOT make product decisions — it surfaces information and asks the user
- This skill does NOT write to production Confluence without confirmation
