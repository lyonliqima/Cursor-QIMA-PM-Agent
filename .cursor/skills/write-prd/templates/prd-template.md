# PRD Template — QIMA Standard (Draft Version)

Extracted from `qima-prd-writing-guide` and adapted for the `write-prd` skill. Length budget: no more than 250 body lines or 6 Confluence pages. Technical implementation detail belongs in Appendix or Tech Design.

---

## How to Use This Template

Replace these placeholders:

- `{{FIELD}}` — single-value placeholder.
- `{{LIST:item-kind}}` — repeat this row or bullet once per item.
- `Open question — <text>` — unresolved item surfaced in Checkpoint A.
- `<!-- IMG:filename.png -->` — optional Figma image marker for Phase 4.

Voice rules:

- PM voice. No repo names, service names, API paths, field names, commits, branches, PRs, or implementation jargon.
- At most 3 Jira ticket references in the whole document, all in Section 1 or Appendix.
- Stakeholders should be named people with direct ownership or decision responsibility, not repo lists, inferred business SME rows, or broad team rows.
- If technical detail is required, link to Tech Design or move it to Appendix.

Formatting:

- Use Markdown headings and pipe tables for drafting and Confluence publishing by default. Do not force table width through ADF from this template.
- Keep paragraphs to 3 lines or fewer.
- Use inline links: `[label](url)`.
- Do not use HTML tables, inline CSS, decorative callouts, or gradient headings.

If a section truly has no content, keep the heading and write:

> Not applicable for this release — reason: {{REASON}}.

---

## Template Body

```markdown
# 1. Overview

| Field | Content |
| --- | --- |
| **Document Owner** | {{PM_NAME}} ({{TITLE}}) |
| **Date** | {{YYYY-MM-DD}} |
| **Version** | v0.1 (Draft — {{what is pending}}) |
| **Target System** | {{myQIMA / QIMAlabs / QSP / etc.}} |
| **Phase** | {{e.g. Phase 1 — Online inspection report rebuild}} |
| **Related Materials** | {{up to 6 links: Tech Design / Figma / main UX research / Prototype / Epic}} |

One paragraph (3-5 sentences): what is being built, for whom, and why now.

---

# 2. Background & Objective

## 2.1 Business Problem / Opportunity

Three bold-lead-in paragraphs grounded in verified context. Do not add visible `Source:` lines in the PRD body.

1. **{{Pain 1 short label}}**: {{evidence + 1-line implication}}
2. **{{Pain 2 short label}}**: {{evidence + 1-line implication}}
3. **{{Pain 3 short label}}**: {{evidence + 1-line implication}}

## 2.2 Primary Objective

Write 2-4 plain sentences describing the concrete business goal for this PRD.

Rules:
- Use only goals that are confirmed by source material or by the PM.
- Do not invent North Star metrics, leading proxies, percentages, timelines, or adoption targets.
- If a measurable target is confirmed, mention it once in simple language; otherwise keep the objective qualitative and certain.

## 2.3 Why Now

3-4 bullets covering design readiness, data signals, dependency timing, or competitive context.

---

# 3. Stakeholders

| Role | Name | Responsibility |
| --- | --- | --- |
| Product Owner | {{PM}} | {{1 line}} |
| Engineering Lead | {{Eng Lead}} | {{1 line}} |
| Design Lead | {{Designer}} | {{1 line}} |
| QA Lead | {{QA}} | {{1 line}} |

Rules:
- No more than 6 rows.
- Do not add `Business Owner`, `Business SME`, or `Business / Product Sponsor` by default, even if a source mentions a business name. Include a business-side row only when the PM explicitly asks for that person to appear in Section 3.
- Do not add generic rows like `Delivery Team`, `Backend Support`, `Frontend Support`, or team-only names such as `Titan / SP team`.
- Do not list repos or services per person.

---

# 4. User Stories / Use Cases

## 4.1 Target Users & Personas

| Persona | Description (1 line) | Action in flow (1 line) |
| --- | --- | --- |

No more than 5 personas.

## 4.2 User Stories

No more than 7 stories. Format:

> **US-N**: As a **{role}**, I want to {action}, so that {value}.

Coverage rule:
- Include concrete user actions from meeting notes and PM walkthroughs, not only high-level personas. If a source says users must generate, edit online, confirm, merge, preview, enable/disable, or review a specific section, represent that action in a user story unless it is clearly out of scope.

---

# 5. Requirements

**Priority definitions**:

- **P0** = required for MVP and v1 launch.
- **P1** = fast follow, usually within one sprint after v1.
- **P2** = architecture reserve or future scope.

## 5.1 Functional Requirements and Priority

No more than 12 rows total.

| ID | Function | Priority | Description / Notes |
| --- | --- | --- | --- |
| **FR-1** | {{1-line function name}} | P0 | {{no more than 2 sentences describing what users see or can do; do not describe APIs or fields}} |

If FRs naturally group into 2-3 modules, use sub-headings such as `### 5.1.1 Module A — {name}` and keep each module table to 6 rows or fewer.

Business-rule coverage:
- Meeting-note rules that change user-visible behavior must appear in the relevant FR row, not only in a Jira appendix. Examples: independent display rules, order-level enable/disable, no-duplicate output, fallback values, overwrite warnings, and section merge behavior.
- Ticket lists prove source coverage; they do not replace product requirements.

## 5.2 Out of Scope

| Item | Reason |
| --- | --- |

No more than 8 rows. Each row is one deferred or excluded item plus the reason.

---

# 6. Design

> All Section 6 frame links must be scoped to the Figma section [{{section-name}}]({{section-URL}}) provided during Phase 0 intake. Search frames only inside this section, never globally.

## 6.1 Page 1 — {{name}}

No more than 3 sentences.

> **Figma frame**: [{{page-1-name}}]({{full Figma URL with ?node-id=<frame-id>}})

{{full Figma URL on its own line for the Figma for Confluence plugin}}

Rule: each Section 6.x page must include the text deep link and the same bare URL on its own line. If the node ID cannot be resolved inside the provided section, write `> **Figma frame**: TBD — not in section; ask design lead` and add it to Section 11.1.

## 6.2 Page 2 — {{name}}

Repeat per page. Keep to 4 pages or fewer.

## 6.3 Key Interaction Specs

| Element | Interaction | Behavior |
| --- | --- | --- |

No more than 10 rows.

## 6.4 Edge Cases

No more than 8 bold-lead-in items, each one sentence or fewer.

1. **{{label}}**: {{behavior}}

---

# 7. Acceptance Criteria (Optional — keep if PM wants explicit pass/fail)

No more than 1 AC per FR. Format:

> **AC-N (FR-X: {{label}})**
> - Given {{precondition}}
> - When {{action}}
> - Then {{observable result}}

AC coverage rule:
- If an FR note contains a behavior-changing condition such as "must still show", "can enable/disable", "do not duplicate", "fallback to X", or "warn before overwrite", add a matching AC that makes the behavior testable.

---

# 8. Analytics & Tracking

## 8.1 Events to Track

| Event | Trigger | Key business fields |
| --- | --- | --- |

No more than 12 rows.

## 8.2 Success Metrics

**Leading (within 30 days)**:

- **{{metric}}**: {{target with number, e.g. >= 60%}}
- No more than 4 items

**Lagging (within 3 months)**:

- **{{metric}}**: {{target}}
- No more than 3 items

## 8.3 Measurement Method

No more than 4 sentences: data source, dashboard owner, and review cadence.

---

# 9. Dependencies & Risks (Optional — keep when project complexity requires it)

## 9.1 Dependencies

| Dependency | Description (1 line) | Owner |
| --- | --- | --- |

No more than 8 rows. Use bucket names such as Frontend, Backend, Mail, Legal, BI, or Platform; do not list repos.

## 9.2 Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
| --- | --- | --- | --- |

No more than 6 rows. Probability uses High / Medium / Low.

---

# 10. Rollout & Release Plan

## 10.1 Phasing

**Phase A — {{name}}**

- Target: {{whom}}
- Scope: {{FR list, by ID}}
- Estimate: {{honest estimate or "pending dev estimate"}}

Repeat for Phase B and C when needed.

## 10.2 Beta / Pilot Plan

No more than 5 numbered steps from internal dogfood to GA.

## 10.3 Release Gates

3 gates with named signers:

1. **Tech Gate** ({{Eng Lead}} + {{QA Lead}}): {{exit criterion with number}}
2. **Business Gate** ({{Sponsor}}): {{exit criterion}}
3. **Data Gate** ({{PM}} + {{BI}}): {{exit criterion}}

---

# 11. Open Questions & Next Steps (Optional — usually keep)

## 11.1 Open Questions

| # | Question | Owner to answer | Blocks v1? |
| --- | --- | --- | --- |
| Q1 | {{question}} | {{name}} | {{No, but affects ...}} or **Yes — {{reason}}** |

No more than 6 rows. The blocker column only allows the two shapes above.

## 11.2 Next Steps

| Step | Owner | When |
| --- | --- | --- |

No more than 6 rows.

---

## Appendix A — Source-of-Truth Links (Only If Requested)

Include this appendix only when the PM explicitly asks for source links in the formal PRD. Otherwise keep the source ledger as an internal working note.

| Type | Source | Link |
| --- | --- | --- |

---

## Appendix B — Decision Log (Optional)

No more than 6 rows. Capture the main decisions where Option A was considered and Option B was chosen.

| Decision | Option A | Option B | Chosen | Reasoning | Reopen trigger |
| --- | --- | --- | --- | --- | --- |

---

## Appendix C — For Engineering Reference (Optional — only if PM explicitly wants it)

Default: do not write this section. If the PRD contains route, field, service-name, or implementation details that the PM wants to preserve, move them here and keep the main body in business language.

In most cases, write: `See [Tech Design]({{link}})` instead of copying technical detail into the PRD.

---

_Document complete. {{1-sentence next action by document owner}}_
```

---

## Notes for the Agent

1. Hard length cap: no more than 250 body lines. If exceeded, cut Sections 5, 6, and 7 first.
2. Voice gate: before publishing, scan against `voice-and-register.md`.
3. Never invent citations. Unsupported claims become Open Questions in Section 11.1.
4. IMG markers must match filenames exactly if used.
5. Default: drop Section 7 and Appendix C unless the PM explicitly wants them.
