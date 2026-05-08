---
name: ticket-breakdown
description: "Break down PRDs into executable Jira development tickets, create a Jira Epic, associate all tickets to that Epic, and append the created ticket links back to the source Confluence PRD. Use when the user asks to break down a PRD into tickets, convert requirements to dev tasks, create Jira tickets from a PRD, split a spec into front-end and back-end work, create an Epic with child tickets, or says things like 'break this PRD into tickets', 'create dev tickets from this spec', 'split this into FE and BE tasks', 'convert requirements to Jira issues'. Also trigger when the user has a Confluence PRD link and wants development-ready Jira tickets."
version: 0.2.0
user-invocable: true
argument-hint: "<confluence-prd-url> <jira-project-key> [design-url]"
---

# Ticket Breakdown Assistant

Read PRDs from Confluence, break the Requirements section into executable development tickets, create the tickets in Jira, link them under a newly created Epic, and write a ticket index back to the bottom of the PRD.

## Arguments

- `$CONFLUENCE_URL`: Link to the Confluence requirements document
- `$JIRA_PROJECT_KEY`: Jira project key where the Epic and tickets should be created
- `$EPIC_SUMMARY`: Epic title / summary (optional; derive from PRD title if missing)
- `$DESIGN`: Link to the design draft (optional)
- `$CONTEXT`: Additional assumptions or context (optional)
- `$DRY_RUN`: If true, produce the breakdown plan only and do not create Jira issues or update Confluence

## Goals

- Convert PRD requirements into clear, actionable tickets
- Ensure each ticket has a well-defined User Story and Acceptance Criteria
- Split work cleanly between front-end and back-end
- Create one Jira Epic for the PRD implementation
- Create all Jira tickets and associate them to the Epic
- Append a "Development Tickets" section to the bottom of the Confluence PRD with links to the created Epic and tickets
- Maintain consistent format, tone, labels, and traceability for efficient implementation

## Required inputs before Jira writes

Before creating anything in Jira, confirm or infer:

1. **Confluence PRD URL** — required.
2. **Jira project key** — required. If missing, ask the user.
3. **Epic summary** — derive from PRD title if missing, but show it in the plan before writing.
4. **Issue type names** — discover from Jira metadata; do not assume `Epic`, `Story`, or `Task` exists in every project.
5. **Epic association field** — discover from Jira field metadata; do not guess custom field IDs.
6. **Target PRD update policy** — default is to append/update a bottom section named `Development Tickets`.

Always require an explicit user approval after presenting the planned Epic and tickets. The user's initial request to "create tickets" is not approval. If project key, permissions, issue types, or Epic-link field are ambiguous, stop and ask before presenting the approval plan.

## Atlassian MCP tools to use

Use the Atlassian MCP tools for all Jira and Confluence operations:

| Need | Tool |
|---|---|
| Resolve cloud/site | `getAccessibleAtlassianResources` if the hostname cannot be used directly as `cloudId` |
| Read PRD | `getConfluencePage` |
| Update PRD | `updateConfluencePage` |
| Check project issue types | `getJiraProjectIssueTypesMetadata` |
| Check fields for Epic / Story / Task | `getJiraIssueTypeMetaWithFields` |
| Search for duplicate existing Epic | `searchJiraIssuesUsingJql` |
| Create Epic and tickets | `createJiraIssue` |
| Patch parent / Epic-link / labels if needed | `editJiraIssue` |
| Link dependencies between tickets | `createIssueLink` |

Always inspect Jira issue type and field metadata before creating tickets. Jira projects differ: some use `Story`, some use `Task`; Epic association may be `parent`, `Epic Link`, or another custom field.

## Process

### Step 1 — Read PRD and extract requirements

- Read the entire PRD from Confluence
- Identify all functional requirements and their priorities
- Group requirements into sensible deliverables
- Determine which work is front-end, back-end, or shared (API/Contract)
- Preserve traceability to the PRD by recording section / FR IDs for every planned ticket
- Extract design links, rollout constraints, dependencies, open questions, and known out-of-scope items

### Step 2 — Plan the ticket breakdown

For each deliverable:

- Create separate **Front-end** and **Back-end** tickets when both are needed.
- Create a shared **API/Contract** ticket when FE and BE need to agree on request/response, field mapping, permissions, events, or error behavior.
- Create a **QA/Test** ticket only if the PRD includes a large matrix, migration, high-risk release, or explicit test ownership.
- Avoid tiny tickets that simply mirror every FR row. Group by implementable deliverable.

Before writing to Jira, produce a user-facing creation plan:

```markdown
Epic:
- [Epic Summary]

Tickets:
1. [Front-end] - ...
   Source: FR-A1, FR-A2
   Depends on: API/Contract ticket
2. [Back-end] - ...
   Source: FR-A1, FR-A3
3. [API/Contract] - ...
   Source: FR-A1, §8 Analytics
```

The plan must include:

- Epic summary, issue type, project key, and description outline
- Every ticket summary, issue type, source FR / section, dependencies, and whether it is Front-end, Back-end, API/Contract, or QA/Test
- The intended Epic association method discovered from metadata, if already known
- The PRD update section that will be appended or replaced after Jira creation
- Whether any design areas should be mapped to ticket-specific screenshots. If static design images are needed, load the internal `prd-design-assets` skill after Jira creation so each crop can be named with the final ticket key.

If `$DRY_RUN` is true, stop here and return the plan.

### Approval gate — required before Jira writes

After presenting the creation plan, stop and ask the user to confirm. Do not call `createJiraIssue`, `editJiraIssue`, `createIssueLink`, or `updateConfluencePage` until the user explicitly confirms.

Accepted confirmations include:

- "approved, create them"
- "proceed with Jira creation"
- "confirmed, start creating the Jira issues"
- "yes, create the Epic and tickets"

Not accepted:

- The user's initial request
- Ambiguous reactions like "looks good" if they do not clearly authorize Jira writes
- Confirmation of only the Epic or only some tickets, unless the user clearly scopes what should be created

If the user changes the plan, revise the plan and ask for confirmation again.

### Step 3 — Discover Jira project metadata

1. Use `getJiraProjectIssueTypesMetadata` for `$JIRA_PROJECT_KEY`.
2. Identify the best issue type names:
   - Epic: prefer `Epic`; otherwise use the project-specific Epic-like type.
   - Child tickets: prefer `Story`; fallback to `Task`.
3. Use `getJiraIssueTypeMetaWithFields` for Epic and child issue types.
4. Find required fields and allowed values.
5. Find how child issues should be associated with an Epic:
   - Prefer a standard parent/Epic field exposed in metadata.
   - If a project has a custom `Epic Link` field, use its exact custom field ID from metadata.
   - If neither is available, create child tickets normally, then use `createIssueLink` with `Relates` to connect each child to the Epic and report that this is a fallback, not a true Epic hierarchy.

### Step 4 — Create the Epic

Create one Epic using `createJiraIssue`.

Recommended Epic summary:

```text
[ROVO] [Epic] - {Theme / Capability Name}
```

Epic description should use this format:

```markdown
**Epic User Story:**
As a [type of user - who]
I want [large business goal / capability - what]
So that [business value - why]

---

**Business Objective:**
[Why this Epic matters and what outcome it supports.]

---

**Scope Summary:**
- [Capability / theme covered by this Epic]
- [Important constraints or rollout boundaries]
- [Out of scope, if relevant]

---

**Breakdown Guidance:**
- Break this Epic into several independent User Stories that follow INVEST where possible.
- Do not force full Given / When / Then acceptance criteria at Epic level. Capture only high-level success signals, constraints, and links.
- User Stories under the same Epic may be delivered in different Sprints based on priority.
```

Epic description should also include:

- PRD link
- Links to design, if available
- Ticket breakdown strategy

Before creating a new Epic, search for possible duplicates with JQL:

```text
project = {PROJECT_KEY} AND issuetype = Epic AND summary ~ "{feature name}" ORDER BY created DESC
```

If a likely duplicate exists, ask whether to reuse it or create a new one.

### Step 5 — Create child tickets and associate them to the Epic

For each planned ticket:

1. Create the issue with `createJiraIssue`.
2. Put the Epic association in `additional_fields` when metadata identifies a parent/Epic field.
3. If the API does not accept Epic association during creation, create the issue first, then call `editJiraIssue` to set the parent/Epic field.
4. Use `createIssueLink` for ticket dependencies:
   - API/Contract blocks Front-end and Back-end tickets.
   - Back-end blocks Front-end only when the UI cannot proceed without implemented backend behavior.
   - QA/Test is blocked by all implementation tickets.
5. Labels should include:
   - `prd-breakdown`
   - normalized feature slug
   - optional PRD phase / platform labels if source PRD provides them

Never silently drop a ticket that failed to create. Return a partial-success summary and list the failed item with the tool error.

### Step 6 — Append ticket links back to the PRD

After all Jira writes succeed, update the source Confluence page with `updateConfluencePage`.

Add or replace a bottom section named:

```markdown
## Development Tickets
```

If the section already exists, replace only that section instead of appending a duplicate.

Recommended section:

```markdown
## Development Tickets

> Generated by `ticket-breakdown` on {{YYYY-MM-DD}}.

| Type | Ticket | Summary | Source requirements |
|---|---|---|---|
| Epic | [{{EPIC_KEY}}]({{EPIC_URL}}) | {{Epic summary}} | Whole PRD |
| Front-end | [{{KEY}}]({{URL}}) | {{Summary}} | FR-A1, FR-A2 |
| Back-end | [{{KEY}}]({{URL}}) | {{Summary}} | FR-A1 |
| API/Contract | [{{KEY}}]({{URL}}) | {{Summary}} | FR-A1, §8 |

**Notes**
- All child tickets are associated to Epic [{{EPIC_KEY}}]({{EPIC_URL}}).
- API/Contract tickets should be agreed before dependent FE/BE implementation starts.
```

For Confluence updates, preserve the existing page title, parent, and space. Use `versionMessage`: `Add development ticket links from PRD breakdown`.

### Step 6.5 — Add ticket-specific design assets when needed

If the PRD has a Figma design link and the user asks for images, cropped screenshots, or design references per ticket, load the internal `prd-design-assets` skill.

Use it to:

- Export the relevant Figma section or frame through the Figma API.
- Crop the design into focused regions mapped to the created Jira keys.
- Publish the cropped images to the configured asset URL.
- Insert the cropped image under the matching PRD Design subsection or into each Jira ticket's `Design` / `Additional Information` field when appropriate.

Do not use one full-length screenshot for multiple tickets if focused crops can be produced. Each image should explain the specific UI area owned by that ticket.

### Step 7 — Return final summary

Return:

- Epic key and URL
- Count of created tickets by type
- Confluence PRD URL updated
- Any fallback behavior, such as dependency links used because Epic hierarchy field was unavailable
- Any failed ticket creations or fields that need manual correction

## Ticket Template

```markdown
Title: [ROVO] [Front-end / Back-end] - [Feature Name]

---

**User Story:**
As a [type of user - who]
I want [some goal / action - what]
So that [some reason / business value - why]

---

**Additional Information:**
- [Specific rule, constraint, data condition, permission, file type, size limit, or known assumption]

---

**Acceptance Criteria:**
1. Given [a situation / precondition]
   When [something happens / user action]
   Then [expected result]
2. Given [a boundary or exception situation]
   When [something happens]
   Then [expected result or error message]

---

**Design:** [link]
**PRD:** [Confluence PRD link]
**Epic:** [Epic link]
**Dependencies:** [dependent tickets]
**Source Requirements:** [FR IDs / PRD sections]
```

### User Story Format

```
As a [type of user - who]
I want [some goal - what]
So that [some reason - why]
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

## Language Requirements

- Use clear, concise, and technical language suitable for software development teams
- Maintain a formal and collaborative tone in all responses
- Ensure descriptions are unambiguous and implementation-oriented

## Safety and quality rules

- Do not create Jira issues without a confirmed Jira project key.
- Do not guess Jira custom field IDs; read metadata first.
- Do not create duplicate Epics if a likely existing Epic is found; ask whether to reuse it.
- Do not update Confluence until Jira issue creation has completed, unless the user asks for a draft-only update.
- Do not overwrite unrelated PRD content. Only append or replace the `Development Tickets` section.
- If a PRD requirement is ambiguous, still create a ticket only when the ambiguity can be captured as an open question inside the ticket. Otherwise ask the user first.
