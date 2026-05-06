---
name: design-critique
description: Upgrade design critique from surface-level UI inspection to full-link verification covering business rules, R&D implementation, and team historical practices. Pulls Confluence PRDs, scans front/back-end code, and references Jira history so every comment cites doc / code / ticket evidence. Outputs an HTML report with severity-grouped findings and clickable evidence links. Use when the user asks for a "business-aware critique", "evidence-based design review", "design critique", or supplies a Figma URL plus Confluence/repo context.
version: 0.1.0
user-invocable: true
argument-hint: "<figma-url> [confluence-page-id] [repo-path]"
---

## Purpose

Replace subjective "looks-fine" critique with verifiable findings. Every issue is backed by:
- a business rule (Confluence) — *should it work this way?*
- a code reference (repo file:line) — *can it work this way?*
- a historical decision (Jira / past PRD) — *did we already try this?*

## Inputs

| Param | Required | Source | Example |
|---|---|---|---|
| `figma-url` | yes | user message | `https://figma.com/design/.../?node-id=10494-28570` |
| `confluence-page-id` | recommended | user / inferred via CQL | `4609409051` |
| `repo-path` | recommended | user / inferred from CWD | `~/Desktop/Weighting-main` |
| `qsp-service-keyword` | optional | for backend lookup | `weighing`, `breakdown` |

If anything required is missing, stop and ask. Do not invent.

## Tool Availability Map

| Need | Tool |
|---|---|
| Figma node tree / screenshot | `mcp__*figma*__get_metadata`, `__get_screenshot`, `__get_design_context` |
| Confluence | `mcp__*atlassian*__getConfluencePage`, `__searchConfluenceUsingCql` |
| Jira | `mcp__*atlassian*__searchJiraIssuesUsingJql` |
| Backend service / endpoints | `qcp` MCP, skill `find-service-endpoint`, `find-service-details` |
| Frontend code | `Glob`, `Grep`, `Read` on `repo-path` |
| QIMA naming dictionary | `~/.claude/skills/.../keyword-expansion.md` (PRD agent) |

## Standardized Workflow (6 steps)

### Step 1 — Correlation & Matching

1. `get_metadata` on the Figma node → extract: page title, button labels, column headers, field names, status enum values.
2. Run those keywords through QIMA naming dictionary (expand acronyms).
3. CQL-search Confluence within the relevant space for those keywords.
4. JQL-search Jira for tickets whose summary/desc match.
5. Glob the local repo for component file names matching the page name.

**Output of step 1**: a `correlation.json` listing
```
{
  "figma": { "node": "...", "title": "...", "keywords": [...] },
  "confluence": [ { id, title, url } ],
  "jira": [ { key, summary, status } ],
  "frontend_files": [ "src/.../X.tsx" ],
  "backend_services": [ "qsp-weighing", ... ]
}
```

### Step 2 — Business Analysis

For each Confluence page from Step 1, fetch full content. Extract:
- core process (numbered steps, who does what)
- role / permission boundaries
- abnormal scenarios (edge cases, validation rules)
- compliance / out-of-scope items

Write into `business-spec.md` (internal note).

### Step 3 — Code Benchmarking

For each frontend file from Step 1:
- Read the file
- Map UI elements to actual props / state / API calls
- Note status enums, validation rules, hard-coded constants

For backend (via qcp / find-service-endpoint):
- Pull Swagger / endpoint contract
- Compare field names + types vs the design

Write into `code-evidence.md` with `file:line` citations.

### Step 4 — Practice Benchmarking

Pull the top 5 most relevant Jira tickets from Step 1:
- read description + last 5 comments
- look for "rolled back", "post-mortem", "lessons learned"

Pull team paradigm pages (search Confluence for `design system`, `interaction guidelines`).

Write into `historical-context.md`.

### Step 5 — Multi-Dimensional Review

**Voice rule** — write findings as a PM / designer, NOT as a code reviewer. **Output language: English.** Allowed vocabulary: button, label, copy, spacing, alignment, hierarchy, hover, click, empty state, loading state, error state, tooltip, modal, list, column, chip, badge, placeholder. Banned: component name, prop, state hook, file path, enum, API contract, "hardcoded", "config-driven", "useState", "endpoint". Code/Jira evidence is still cited in the evidence block (so the reader can drill in), but the **finding title and description must read naturally to a non-engineer**.

Five lenses — every finding must hit at least 2:

| Lens | Question | What to look at |
|---|---|---|
| Interaction flow | Can the user finish the task without confusion? Are loading / empty / error states designed? | Click-through path on the screenshot |
| Visual consistency | Does the same data point look the same across screens? Are colors / icons / chip styles aligned? | Compare regions across frames |
| Copy & language | Typos? Inconsistent capitalization? Mixed Chinese/English? Ambiguous labels? Term mismatch with PRD glossary? | Read every text node |
| Spacing & alignment | Crowded clusters? Misaligned columns? Inconsistent padding between similar cards? | Eyeball + ruler |
| Business correctness | Does the screen show the right field, in the right state, per PRD + historical Jira fixes? | Confluence § + Jira |

Severity: 🔴 Critical (blocks ship / violates PRD / breaks task flow) / 🟡 Moderate (visible inconsistency or known recurring issue) / 🟢 Minor (polish: typo, 2-4px misalignment, single-screen quirk).

### Step 6 — HTML Report

Render to a self-contained HTML file at `$TMPDIR/design-critique-<timestamp>.html`. Use the template at `reference/report-template.html`. Include:
- Header: design name, Figma link, generated timestamp
- Executive summary: counts by severity
- Findings list grouped by severity, then by section
- Each finding: title, dim badges, evidence links (Confluence URL / file:line / Jira key), recommendation
- Footer: data sources scanned (Confluence pages, files, Jira tickets)

Open the file path at the end. Do **not** dump the full HTML in chat — just the path + a one-paragraph summary.

## Evidence Citation Format

```
[FINDING] Title
├─ Severity:  🔴 Critical
├─ Dimensions: Business Rationality, R&D Implementability
├─ Evidence:
│   ├─ Confluence:  <url>#section
│   ├─ Code:        <repo>/src/.../File.tsx:42-58
│   ├─ Jira:        QSP-1234
│   └─ Figma:       node 10494:28570
└─ Recommendation: <one-sentence concrete action>
```

## Anti-Patterns (Reject These)

- Subjective "feels too crowded" with no metric (count items / measure spacing)
- Findings with zero evidence link
- Recommendations that conflict with PRD without flagging the conflict
- Re-stating PRD content as a finding (that's a summary, not a critique)

## When to Stop

- If Confluence access fails: ask user for the PRD content or skip business-rationality dim with explicit warning.
- If repo path missing: skip code-benchmarking dim with explicit warning.
- Never silently skip — call it out in the report's "Coverage" section.
