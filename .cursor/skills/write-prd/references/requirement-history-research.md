# Requirement History Research

Phase 1.2 creates a local Confluence/Jira history report before PRD drafting. Its job is to understand why the requirement exists, what has already been tried or decided, and which historical constraints still matter.

This is a working research deliverable. Link it from the PRD source ledger, but do not paste the full history into the PRD body.

---

## When this runs

Run in parallel with Phase 1.1 codebase research and the other Phase 1 scanners.

Default = RUN for every product/software PRD. Skip only when the PM explicitly confirms the work is not connected to an existing QIMA product/process/history.

Time budget: about 5 minutes. Stop when the budget is reached, then write the best-supported report and mark gaps.

---

## Inputs

Start with all available seeds:

- feature name and aliases
- user-provided Confluence page URLs
- user-provided Jira keys
- Figma names / screen titles
- meeting-note titles
- codebase report service names, module names, route names, and business terms
- Phase 0.5 keyword expansion results

If no seed exists beyond a feature name, generate 5-10 keyword variants before searching.

---

## Search plan

Dispatch parallel searches where tools allow it:

1. **Confluence broad search**
   - Search for feature keywords, legacy names, service names, and domain nouns.
   - Prefer PRDs, Tech Designs, solution designs, meeting notes, rollout notes, retrospectives, research pages, and architecture pages.
2. **Confluence link following**
   - From strong hits, follow linked pages and page mentions.
   - Check child pages and pages with similar titles when available.
3. **Jira broad search**
   - Search Epics, Stories, Bugs, Tasks, and recently updated issues using feature keywords and linked page titles.
   - Pull linked issues from the strongest Jira hits.
4. **Jira-to-Confluence cross-check**
   - For Jira tickets that mention specs, designs, Confluence links, release names, or bugs, follow those references.
5. **Confluence-to-Jira cross-check**
   - For pages that mention Jira keys, read the issue summary/status/comments enough to understand the decision or historical context.

Do not spend the entire budget on the first good result. The value comes from triangulating across sources.

---

## Weighting guidance

Weighting helps decide what to read first. It does not decide truth.

Use these signals:

| Signal | Weight impact | Notes |
|---|---:|---|
| Updated in last 90 days | High | Often reflects latest scope or current constraints. |
| Directly linked from user-provided page/ticket | High | Strong context match. |
| Explicit PRD / Tech Design / Solution Design | High | Usually contains decisions and rationale. |
| Jira Epic with many linked child issues | High | Often represents implementation scope. |
| Bug/support issue tied to this flow | Medium | Useful for pain points and edge cases. |
| Older page with original decision rationale | Medium | Still important when it explains why a rule exists. |
| Similar keyword only, no links | Low | Use as lead, not evidence. |
| Deprecated / archived / cancelled content | Low-to-medium | Useful for "what not to repeat"; label clearly. |

When a recent source conflicts with an older canonical source, record both and flag as a conflict. Do not silently prefer the recent source unless it explicitly supersedes the older one.

---

## What to extract

For each strong source, extract:

- What problem or requirement it describes.
- Who requested it and who owns it.
- What decision, constraint, or scope boundary it establishes.
- Whether it is current, historical, deprecated, or ambiguous.
- Related Jira keys / Confluence pages.
- Any measurable signal: NPS, usage, defect count, ticket count, SLA, rollout date, client impact.
- Product implication for the PRD: Background, Scope, FR, NFR, Risks, Rollout, Acceptance Criteria, or Open Questions.

Avoid copying long raw notes. Summarize the decision and cite the source.

---

## Output location

Save the report to:

`{work-folder}/_prd-run/history-reports/{feature-slug}-confluence-jira-history-{YYYYMMDD}.md`

If the user provided a Desktop or meeting-notes folder as source material, also save/copy a convenience copy there.

---

## Output template

```markdown
# {Feature Name} - Confluence/Jira History Report

Generated: {YYYY-MM-DD}
Scan budget: about 5 minutes
Feature slug: {feature-slug}
Freshness: {new report / refreshed because ... / reused because ...}

## 1. Executive Summary

- {1-3 bullets: what history matters most for this PRD}
- {latest known direction}
- {biggest unresolved historical question or conflict}

## 2. Search Seeds and Keywords

- User-provided seeds: {links / Jira keys / docs / names}
- Expanded keywords: {terms}
- Systems / services / modules used as search terms: {if any}

## 3. Weighted Source List

| Weight | Source | Type | Date / recency | Why it matters | Link |
|---|---|---|---|---|---|
| High / Medium / Low | {title or key} | Confluence / Jira | {updated/created date} | {1 sentence} | {URL} |

## 4. Timeline of Requirement History

| Time | Source | What happened | PRD relevance |
|---|---|---|---|
| {date/period} | {source} | {decision / change / issue} | {Background / Scope / FR / Risk / Open question} |

## 5. Related Confluence Pages

For each meaningful page:

### {Page title}

- Link: {URL}
- Status: {current / historical / deprecated / unclear}
- Key points:
  - {point}
- PRD implications:
  - {how this should affect the PRD}

## 6. Related Jira Issues

| Jira | Type/status | Recency | Key point | PRD implication |
|---|---|---|---|---|
| {KEY} | {Epic/Story/Bug + status} | {updated date} | {summary} | {Background / Scope / FR / Risk / Open question} |

## 7. Confirmed Facts

- {fact} — source: {source}

## 8. Conflicts and Ambiguities

- Conflict: {A says X, B says Y}
  - Sources: {links}
  - Why it matters for PRD: {impact}
  - Recommended question to PM: {question}

## 9. Gaps

- {gap}
  - Why it matters: {impact}
  - Suggested next search / owner: {next step}

## 10. PRD Implications

### Background
- {what history should be summarized in Background}

### Scope
- {in/out boundary from history}

### Requirements
- {requirement implication}

### Risks / Dependencies
- {risk or dependency}

### Rollout / Measurement
- {rollout or success-metric implication}

### Open Questions
- {questions to ask in Phase 2.5 / Checkpoint A}
```

---

## Quality bar

A good report lets the PRD writer answer:

- "Why now?"
- "What has already been decided?"
- "What should not be reopened without explicit PM choice?"
- "What recent changes may supersede older assumptions?"
- "Which Jira/Confluence evidence should be cited in Section 1?"

If the report only lists links, it failed. It must translate history into PRD implications.
