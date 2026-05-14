---
name: write-ticket
description: "Create a single Jira development ticket from a design draft (Figma URL) and a brief requirement description. Embeds design screenshots into the ticket body, writes structured User Story + Acceptance Criteria + design-state tables following the ticket-breakdown standard. Use when the user says 'create a ticket', 'write a ticket', '新建一个 ticket', '帮我建个 ticket', provides a Figma URL and wants a Jira issue, or asks to turn a design into a backlog item."
version: 0.1.0
user-invocable: true
argument-hint: "<figma-url> <jira-project-key> [summary]"
---

# Write Ticket

Create a single, well-structured Jira development ticket from a Figma design URL and a brief requirement description. Automatically embeds cropped design screenshots into the ticket body.

## Arguments

- `$FIGMA_URL`: One or more Figma design URLs (comma-separated if multiple states/views). Required.
- `$JIRA_PROJECT_KEY`: Target Jira project key (e.g., `SP`). Required.
- `$SUMMARY`: Ticket summary / title. Optional — derive from the design if missing, but confirm with user before creating.
- `$DESCRIPTION`: Brief requirement description from user. Optional — infer from design context.
- `$ISSUE_TYPE`: Issue type name. Default `Story`; override if user specifies.
- `$DRY_RUN`: If true, produce the ticket draft only and do not create in Jira.

## Goals

- Turn a Figma design + brief description into a single buildable Jira ticket
- Embed design screenshots directly in the ticket body (not just links)
- Follow the Design-State Ticket Standard from ticket-breakdown (state tables, action logic)
- Include structured User Story, Acceptance Criteria, and design references

## Required inputs before Jira writes

Before creating anything in Jira, confirm or infer:

1. **Figma URL** — required. Must contain `fileKey` and `node-id`.
2. **Jira project key** — required. Ask the user if missing.
3. **Ticket summary** — derive from design context if missing, but show in the draft before writing.
4. **Issue type** — discover from Jira metadata; do not assume types exist.
5. **Requirement description** — the user's brief explanation of what the feature does.

Always require an explicit user approval after presenting the planned ticket. The user's initial request to "create a ticket" is not approval.

## Atlassian MCP tools to use

| Need | Tool |
|---|---|
| Resolve cloud/site | `getAccessibleAtlassianResources` |
| Check project issue types | `getVisibleJiraProjects` or `getJiraProjectIssueTypesMetadata` |
| Create ticket | `createJiraIssue` |
| Add comment / image link | `addCommentToJiraIssue` |
| Transition ticket | `transitionJiraIssue` (if user wants to set status) |

## Figma tools to use

| Need | Tool |
|---|---|
| Get design context + code | `get_design_context` |
| Get metadata (node tree) | `get_metadata` |

## Process

### Step 1 — Parse Figma URLs and fetch design context

For each Figma URL provided:

1. Extract `fileKey` from `figma.com/design/<fileKey>/...`.
2. Convert node-id from dash form to colon form (`15230-124568` → `15230:124568`).
3. Call `get_design_context` with `fileKey` and `nodeId`.
4. Analyze the returned code, styles, and component descriptions to understand the UI.

### Step 2 — Analyze design and extract requirement details

From the design context, identify:

- UI elements, labels, text content
- Interactive components (buttons, toggles, dropdowns)
- States (default, editing, loading, error, empty)
- Layout structure and visual hierarchy
- Color tokens and typography

Cross-reference with the user's description to fill any gaps.

### Step 3 — Plan the ticket draft

Produce a user-facing draft before writing to Jira:

```markdown
**Project**: SP
**Issue Type**: Story
**Summary**: Add "Show test item on result summary" toggle when "No result table needed"

**User Story:**
As a [user role]
I want [action / feature]
So that [value]

**Design States:**
| State | Description | Screenshot |
|---|---|---|
| View mode | ... | [Figma link] |
| Edit mode | ... | [Figma link] |

**Acceptance Criteria:**
1. Given ... When ... Then ...
2. Given ... When ... Then ...

**Design:** [Figma URL]
```

If `$DRY_RUN` is true, stop here and return the draft.

### Approval gate — required before Jira writes

After presenting the draft, stop and ask the user to confirm. Do not call `createJiraIssue` until the user explicitly confirms.

### Step 4 — Export Figma screenshots

Use `fetch-figma.sh` to export design frames as PNG:

```bash
bash "$HOME/.cursor/skills/write-prd/scripts/fetch-figma.sh" <FILE_KEY> /tmp/<ticket-slug>-design "<NODE_IDS>" 2
```

- `FILE_KEY` — from Figma URL
- Comma-separated node IDs for each design state
- Scale 2 for high-resolution
- Token read from `~/.config/figma-token`

If multiple design states are present (e.g., view mode and edit mode), export each as a separate PNG.

If `fetch-figma.sh` is unavailable or fails, fall back to embedding the Figma URL as a clickable link in the ticket body. Do NOT fail the entire ticket creation due to image export failure.

### Step 5 — Publish screenshots to stable URL

Use the dedicated asset repo:

```bash
# Copy exported PNGs to the asset repo
cp /tmp/<ticket-slug>-design/*.png <asset-repo>/assets/<feature-slug>/figma/

# Commit and push
cd <asset-repo> && git add . && git commit -m "Add <feature> design screenshots" && git push
```

Default asset repo: `lyonliqima/prd-assets` (if exists).

Stable URL pattern:
```
https://raw.githubusercontent.com/lyonliqima/prd-assets/main/assets/<feature-slug>/figma/<filename>.png
```

If the asset repo is unavailable, embed images via Figma MCP asset URLs (expire after 7 days) and note the expiration in the ticket.

### Step 6 — Create the Jira ticket

Use `createJiraIssue` with `contentFormat: "markdown"`.

Ticket body template:

```markdown
## User Story

As a [type of user]
I want [some goal]
So that [some reason]

---

## Design / States

| Action / State | Screenshot | Details / Expected behavior |
|---|---|---|
| Default (view mode) | ![view mode](<image-url>) | [description of what user sees] |
| Edit mode | ![edit mode](<image-url>) | [description of editing interaction] |
| After save | ![saved](<image-url>) | [description of saved state] |

> **Figma frame**: [Design name](<figma-url-with-node-id>)

---

## Acceptance Criteria

1. Given [precondition]
   When [action]
   Then [expected result]
2. Given [boundary / edge case]
   When [action]
   Then [expected result]

---

## Additional Information

- [Constraints, dependencies, technical notes]
```

For design-state tickets with multiple UI states, use the **state table** pattern (from ticket-breakdown Design-State Ticket Standard):

- Table columns: `Action / State`, `Screenshot or Figma frame`, `Details / Expected behavior`
- Each row explains: what triggers the state, which buttons/actions are enabled/disabled, what changes
- If button behavior changes, include a **Button / Action Logic** matrix

### Step 7 — Return result

Return:

- Ticket key and URL (e.g., `SP-33798 — https://qima.atlassian.net/browse/SP-33798`)
- Brief summary of what was created
- Any fallback behavior (e.g., "Figma link used instead of screenshot due to export failure")

## Ticket Quality Standards

This section is the **authoritative source** for ticket writing standards. Other skills (e.g., `ticket-breakdown`) reference this section instead of duplicating it.

### User Story Format

```
As a [type of user - who]
I want [some goal / action - what]
So that [some reason / business value - why]
```

User Stories must be clear enough to fit in one Sprint and should follow INVEST:

- **Independent**
- **Negotiable**
- **Valuable**
- **Estimable**
- **Small**
- **Testable**

An issue may contain **multiple User Stories** only when they are tightly related and still small enough for one Sprint. Otherwise, split them into separate tickets.

### Acceptance Criteria Guidelines

- Each item must clearly determine **Pass / Fail**
- Use **Given / When / Then** for every scenario
- Include the **main success flow** and at least one **boundary / exception** scenario when relevant
- Use **specific values** — avoid vague descriptions
- 2 to 4 acceptance criteria are usually enough for a User Story; QA can expand detailed test coverage separately

### Design-State Ticket Standard

When the source PRD, Figma, or prior Jira ticket shows multiple UI / document / workflow states, the ticket must describe every important state directly in the Jira body. Do not rely on a Figma screenshot alone.

Use the style of [SP-33537](https://qima.atlassian.net/browse/SP-33537) as the reference:

- Start with the Figma link and, when useful, a short **Current design** / **Expected design** comparison.
- Add an **Expected design / state table** before the User Story when the design has multiple visible states.
- Table columns should be: `Action / State`, `Screenshot or Figma frame`, `Details / Expected behavior`.
- Each row must explain:
  - what triggers the state;
  - which buttons / actions become enabled or disabled;
  - which file, report, language, status, or section appears;
  - whether the state changes immediately or waits for a generated output;
  - what default selection or follow-up action is expected.
- If the ticket changes button behavior, include a **Button / Action Logic** matrix with columns like `Button`, `Applies to`, `Enabled when`, `Disabled when`, `Click behavior`.
- If a button changes label after an action, state the exact transition, e.g. `Send report` -> `Resend report`.
- If one action affects another language / row / file, state the cascade explicitly.
- Keep the language operational and direct. Mixed English product terms with concise Chinese notes are acceptable when the source ticket / team uses them, but the logic must be unambiguous.

For design-state tickets, replace the generic 2-4 AC limit with enough state coverage to make the ticket buildable. Prefer one compact state table plus one action logic table over many repetitive Given / When / Then items.

### Language Requirements

- Use clear, concise, and technical language suitable for software development teams
- Maintain a formal and collaborative tone in all responses
- Ensure descriptions are unambiguous and implementation-oriented
- For UI state / design-driven tickets, use practical PM language: describe what appears, what is enabled, what is disabled, what changes after click, and what the default behavior is. Avoid generic phrases like "improve user experience" or "update the UI accordingly"

## Image Handling Strategies

In order of preference:

1. **Figma REST API → PNG → GitHub raw URL** (stable, offline-readable)
2. **Figma MCP asset URLs** (expires after 7 days, quick fallback)
3. **Bare Figma URL** (always works as clickable link, no inline image)

## Safety Rules

- Do not create Jira issues without a confirmed project key
- Do not guess Jira custom field IDs; read metadata first
- Always get user approval before creating the ticket
- If image export fails, proceed with Figma links only — do not block ticket creation
- Preserve the user's exact wording when they provide specific requirement descriptions
