# Format Conventions — Strict Spec

Canonical example: Confluence 4609409051, *Sample weighing and labeling function*. Every formatting decision in this skill defers to that PRD's structure, translated here into English-only rules.

This file is authoritative for Phase 4 drafting and Phase 4.7 review. `prd-critique` must flag deviations as findings.

> Length and voice override: these conventions define document shape. For length and tone, `voice-and-register.md` is binding.

---

## 1. Section Grammar

### 1.1 Heading Level

| Markdown | Used for | Tag |
|---|---|---|
| `#` | Top-level sections 1-11 and appendices | none in published PRD |
| `##` | Same as `#` when published as a sub-page; choose one style and stay consistent | none |
| `###` | First-level subsection, such as `2.1`, `5.1`, `9.2` | none |
| `####` | Second-level subsection or module split, such as `5.1.1 Module A — Preparation` | none |

### 1.2 Heading Text Format

```markdown
# 1. Overview
## 2. Background & Objective
### 2.1 Business Problem / Opportunity
#### 5.1.1 Module A — Preparation
## Appendix A — Existing Tool Rules
```

Rules:

- Top-level sections use: number + dot + space + English title. Do not include template-only tags like `(Mandatory)` in the published PRD.
- Subsection numbering uses `2.1`, `2.2`, `5.1.1`; never roman numerals.
- Module/page titles use an em dash with single spaces around it.
- Appendices use `Appendix A`, `Appendix B`; never `Appendix 1`.

### 1.3 Exact 11 Sections

```markdown
1. Overview
2. Background & Objective
   2.1 Business Problem / Opportunity
   2.2 Primary Objective
   2.3 Why Now
3. Stakeholders
4. User Stories / Use Cases
   4.1 Target Users & Personas
   4.2 User Stories
5. Requirements
   5.1 Functional Requirements and Priority
       5.1.1 Module A — {name}
       5.1.2 Module B — {name}
       5.1.3 Cross-cutting / Platform (only if needed)
   5.2 Out of Scope
6. Design
   6.1 Page 1 — {name}
   6.2 Page 2 — {name}
   6.3 Key Interaction Specs
   6.4 Edge Cases
7. Acceptance Criteria
8. Analytics & Tracking
   8.1 Events to Track
   8.2 Success Metrics
   8.3 Measurement Method
9. Dependencies & Risks
   9.1 Dependencies
   9.2 Risks & Mitigations
10. Rollout & Release Plan
    10.1 Phasing
    10.2 Beta / Pilot Plan
    10.3 Release Gates
11. Open Questions & Next Steps
    11.1 Open Questions
    11.2 Next Steps

Appendix A — {name}
Appendix B — {name}
```

If a section is intentionally omitted, explain the reason in the drafting notes or open questions, not in the section title.

---

## 2. Required Tables

Use the exact column headers and order shown below.

| Section | Table | Columns |
|---|---|---|
| 1 | Overview meta | `Field` · `Content` |
| 3 | Stakeholders | `Role` · `Name` · `Responsibility` |
| 4.1 | Personas | `Persona` · `Description` · `Action in flow` |
| 5.1.x | Functional Requirements | `ID` · `Function` · `Priority` · `Description / Notes` |
| 5.2 | Out of Scope | `Item` · `Reason` |
| 6.3 | Key Interaction Specs | `Element` · `Interaction` · `Behavior` |
| 8.1 | Events to Track | `Event` · `Trigger` · `Key business fields` |
| 9.1 | Dependencies | `Dependency` · `Description` · `Owner` |
| 9.2 | Risks & Mitigations | `Risk` · `Impact` · `Probability` · `Mitigation` |
| 11.1 | Open Questions | `#` · `Question` · `Owner to answer` · `Blocks v1?` |
| 11.2 | Next Steps | `Step` · `Owner` · `When` |

Per-table rules:

- Section 1 Overview meta must include: `Document Owner`, `Date`, `Version`, `Target System`, `Phase`, `Related Materials`.
- Section 5.1.x FR table: `ID` uses bold `**FR-A1**`; `Priority` uses plain `P0`, `P1`, `P2`.
- Section 5.1 priority block is placed immediately above the first FR subsection.
- Section 9.2 `Probability` uses `High`, `Medium`, or `Low`.
- Section 11.1 `Blocks v1?` uses `Yes — {reason}` or `No, but affects {impact}`. No bare yes/no.
- In the markdown draft, all tables use markdown pipe syntax. Never use HTML tables in the draft.
- In the Confluence draft page, every PRD table must occupy the full page width. Markdown-to-Confluence conversion does not preserve table width and commonly renders narrow default tables, so use `contentFormat: "adf"` when publishing table-heavy PRDs.
- For every ADF `table` node, preserve existing attrs and set/override `width: 1800`, `layout: "center"`, and `displayMode: "fixed"`. If ADF publishing is unavailable, tell the PM the table width cannot be guaranteed instead of claiming the page is full-width.
- Empty cells use `TBD`.

Priority block:

```markdown
**Priority definitions**:

* **P0** = required for MVP and v1 launch.
* **P1** = fast follow, usually within one sprint after v1.
* **P2** = architecture reserve or future scope.
```

---

## 3. Inline Formatting

### 3.1 Bold Lead-In Labels

Lists where each item makes a distinct point start with a bold 2-6 word label followed by a colon:

```markdown
1. **Data fragmentation**: The current workflow requires manual reconciliation across systems.
2. **Limited scalability**: The current tool supports one team but cannot scale to additional labs.
3. **Audit risk**: Manual handoff makes it harder to prove source-of-truth consistency.
```

This pattern is required for Section 2.1 problem list, Section 6.4 Edge Cases, and Section 10.3 Release Gates.

### 3.2 ID Conventions

| Item | Format | Example |
|---|---|---|
| Functional requirement | `**FR-{module-letter}{n}**` | `**FR-A1**` |
| User story | `**US-{n}**` | `**US-1**` |
| Acceptance criterion | `**AC-{n} (FR-X: {feature label})**` | `**AC-1 (FR-A5: Merge included relationships)**` |
| Open question | `Q{n}` | `Q1` |

IDs are bolded only at definition site.

### 3.3 Code-Style Identifiers

Wrap in backticks only when a developer would copy the value verbatim:

- DB columns or config fields
- analytics event names
- exact string examples

Do not backtick PRD-internal terms, product names, or generic English words.

### 3.4 User Story Syntax

```markdown
**US-N**: As a **{role}**, I want to {action / capability}, so that {value}.
```

### 3.5 Acceptance Criterion Syntax

```markdown
**AC-N (FR-X: {feature label})**

* Given {precondition}
* When {action}
* Then {observable result with named field or threshold}
```

### 3.6 Metrics Split

```markdown
**Leading (within 30 days)**:

* **{metric name}**: {target with operator and number}

**Lagging (within 3 months)**:

* **{metric name}**: {target}
```

### 3.7 Phasing

Each phase uses this order:

```markdown
**Phase A — Preparation**

* Target: {whom}
* Scope: {FR list}
* Dependency: {prereqs, optional}
* Estimate: {honest estimate or "pending dev estimate"}
```

### 3.8 Release Gates

Numbered list, at least 3 gates with distinct signers:

```markdown
1. **Tech Gate** (Dev + QA): {specific exit criteria with threshold}
2. **Business Gate** ({named SME / business owner}): {exit criteria}
3. **Data Gate** ({PM + BI owner}): {exit criteria}
```

---

## 4. Language Policy

All skill instructions and generated template content must be English. Product names, system names, repo names, and exact source titles may retain their original spelling if they are proper nouns or source-of-truth labels.

---

## 5. Punctuation and Typography

| Rule | Right | Wrong |
|---|---|---|
| Clean section title | `# 1. Overview` | `# 1. Overview (Mandatory)` |
| Module separator | `Module A — Preparation` | `Module A: Preparation` |
| Optional-section reason | Explain in drafting notes or open questions | Put `(Optional)` in a heading |
| Label colon | `**Success criteria**: reduce manual work` | mixed punctuation |
| Numeric ranges | `2-3 sprints` | ambiguous prose |
| Comparison operators | `>= 95%`, `<= 30 minutes` | vague targets |
| Arrow notation | `->` | inconsistent symbols |
| Italic closing line | `_Document complete. Next action..._` | `**Document complete**` |

---

## 6. Section 1 Overview Meta-Table

```markdown
| Field | Content |
| --- | --- |
| **Document Owner** | {Name} ({Title}) |
| **Date** | YYYY-MM-DD |
| **Version** | v0.1 (Draft — {what is pending}) |
| **Target System** | {QIMAlabs / QIMAone / etc.} |
| **Phase** | {program phase} |
| **Related Materials** | {meeting names and doc links, semicolon-separated} |
```

Rules:

- Six rows, in this order.
- Field names bolded.
- Date is ISO `YYYY-MM-DD`.
- Version includes the status.

---

## 7. Section 11.1 Open Questions

```markdown
| # | Question | Owner to answer | Blocks v1? |
| --- | --- | --- | --- |
| Q1 | {question} | {name(s)} | No, but affects {impact} |
| Q2 | {question} | {name(s)} | **Yes — resolve before dev kickoff** |
```

Allowed blocker-column shapes:

- `No, but affects {downstream impact}`
- `**Yes — {when/who must resolve}**`

No bare `Yes` or `No`.

---

## 8. Footer and Marginalia

The canonical PRD ends with one italic line:

```markdown
_Document complete. {Concrete next action by document owner}._
```

Use horizontal rules between top-level sections and before appendices. Avoid horizontal rules between subsections inside a section.

---

## 9. Validation Checklist

Before sign-off, `prd-critique` verifies:

- [ ] All 11 sections present in canonical order with exact titles.
- [ ] Section 1 meta-table has all 6 required rows.
- [ ] Published headings are clean and do not include `Mandatory` / `Optional` tags.
- [ ] Every FR ID uses `**FR-{letter}{n}**`.
- [ ] Priority block appears above Section 5.1.
- [ ] Section 5.2 Out of Scope items have non-empty reasons.
- [ ] Section 6.3 Interaction table exists whenever Section 6 has UI.
- [ ] Section 6.4 Edge Cases has at least 5 bold-lead-in items.
- [ ] Section 8.1 events use dotted snake_case when implementation event names are needed.
- [ ] Section 8.2 is split into Leading and Lagging blocks.
- [ ] Section 9.2 risks table has all 4 columns and High / Medium / Low probability values.
- [ ] Section 10.3 has at least 3 gates with distinct signers.
- [ ] Section 11.1 uses the allowed blocker-column shapes.
- [ ] Footer is italic and names a concrete next action.
- [ ] Code identifiers are backticked only when appropriate.

Any failure is a finding. Format violations are at minimum Medium priority; structural omissions are High.

---

## 10. Anti-Patterns

- HTML tables, nested tables, or merged cells.
- Translating canonical column headers inconsistently between drafts.
- Adding `Mandatory` / `Optional` tags to published headings.
- Hyphen instead of em dash in module/page titles.
- Bare Yes/No in Open Questions.
- Missing priority block above Section 5.1.
- FR table without module split when there are 8 or more FRs.
- Section 6 with prose only and no Interaction Specs table.
- Inventing new section titles or numbering, such as Section 12.
- Section 1 meta-table missing `Related Materials`.
