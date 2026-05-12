# Voice & Register — PRD Body Rules (Hard Gate)

The PRD audience is PMs, designers, business leads, and customer representatives, not engineers. Technical implementation belongs in the Tech Design document; the PRD should link to it instead of repeating it.

> This file is a hard gate: after Phase 4 drafting and before Phase 4.7 review, scan the body against this checklist. Move any remaining technical implementation detail to *Appendix · For engineering reference* or remove it. Also run the human writing gate in `human-prd-writing-style.md`. The `prd-critique` skill checks both again.

---

## 0. Length and Scope Limits

PRD body, excluding appendices:

- Target: no more than 250 markdown lines or 6 Confluence pages.
- Section 5.1 FR table: no more than 12 rows. More than 12 usually means the document is becoming a dev spec.
- Section 6 Edge Cases: no more than 8 items. Put overflow in Appendix only if truly needed.
- Section 11.1 Open Questions: no more than 6 rows. Each item should be one sentence.

If the PRD exceeds the limit, cut Sections 5, 6, and 7 first. Most bloat comes from copying Tech Design detail into those sections.

---

## 1. Content Banned from the PRD Body

| Banned content | Example | Rewrite as |
| --- | --- | --- |
| Microservice chains / repo names | `psi-web-cloud -> final-report-service-cloud -> aca-new` | "Inspection data moves from field capture to report assembly to online presentation." |
| Jira ticket stacks | "SP-32258 / SP-32257 / SP-32296 / SP-32308..." | At most 3 Jira references in the whole PRD, only in Section 1 meta-table or Appendix. |
| Code / component / function names | `V2Header`, `ReportPageV5`, `inspection-report.service` | "Top decision area", "report main page" |
| API / field paths | `keyIndicator.aqlLevel = "reference"` | "Workmanship results can be shown by product or by reference." |
| Operational implementation terms | route component swap, killswitch, ETag, CDN, immutable cache, snake_case event | Business-language behavior, rollout, or fallback description |
| DB / schema details | "Add `client_rating_feedback` field" | "Add rating feedback." |
| Commit / branch / PR references | `commit a3f29b on develop` | Remove from PRD body. |

---

## 2. Stakeholders

List only named people with direct ownership, decision responsibility, or required review responsibility. Do not list repo or service names in the Responsibility column. Do not infer a `Business SME`, `Business Owner`, or `Business / Product Sponsor` row from source material; include a business-side row only when the PM explicitly asks for that person to appear in Section 3.

| Role | Name | Responsibility |
| --- | --- | --- |
| Product Owner | Suki Yuan | Own PRD, scope, and acceptance readiness |
| Backend Lead | Hydie Chan (Titan TL) | Report service and gateway coordination |
| Frontend Lead | Eric Wang | Frontend implementation coordination |

Do not write: "Eric Wang — `aca-new` + `report-service-cloud` + `gateway-service-cloud`".

Do not add generic or team-only rows such as `Business SME`, `Business Owner`, `Business / Product Sponsor`, `Delivery Team`, `Backend Support`, `Frontend Support`, or `Titan / SP team` unless the PM explicitly asks for that row and provides a specific person and responsibility. If no PM-approved business-side row is given, omit it.

---

## 3. Dependencies

Describe dependency buckets without naming repos:

- Frontend: report presentation components
- Backend: conclusion aggregation and AI Summary fields
- Platform: tenant-level switch and operational configuration
- Mail: email templates, Phase 2
- Legal: AI disclaimer approval
- BI: tracking contract and dashboard

Specific service names, endpoints, function paths, and field contracts belong in Tech Design.

---

## 4. Section 1 Related Materials Row

Use at most 6 links, one line each: Tech Design, Figma, main UX audit, main memo, prototype, or Epic. Do not list 8-12 source links here, and do not append a visible source ledger unless the PM explicitly asks for one in the formal PRD.

---

## 5. If Technical Detail Must Be Preserved

Put it in **Appendix · For engineering reference**, separated from the body, or link directly to Tech Design:

> See [Tech Design — Smart Report] Confluence 4559699969.

If the PM wants dev-ready handoff, run the `ticket-breakdown` skill. Do not inflate the PRD body.

---

## 6. Allowed Exceptions

- Section 6 Design may reference Figma node IDs. Each Section 6.x page must include a Figma deep link containing `?node-id=...`; linking only to the file root is a review finding.
- Section 9.1 Dependencies may name broad buckets such as Backend, Frontend, Mail, Legal, BI, and Platform.
- Section 1 related materials may name one Tech Design link.
- Section 11.1 Open Questions may reference one Jira ticket if it is the tracking anchor for a decision.
- Established product names may remain: myQIMA, QIMAone, QIMAlabs, Smart Report, PSI, AQL, POM, CAP.

---

## 7. Review Quick Check

Search the PRD body and fix matches:

- [ ] `cloud` — often indicates a service name.
- [ ] `service` — often indicates a service name.
- [ ] `route` / `endpoint` / `payload` / `schema` / `JSON`
- [ ] `repo` / `commit` / `branch` / `PR` / `Lambda`
- [ ] `SP-` appears 4 or more times.
- [ ] Backticked code identifiers appear 6 or more times.
- [ ] `snake_case` / `camelCase` / `kebab-case`
- [ ] `killswitch` / `feature flag` / `ETag` / `CDN` / `lazy load`

Remove matching implementation detail from the body or move it to Appendix.

---

## 8. Human / AI-Smell Quick Check

Also search for generic AI wording and rewrite it into QIMA-specific business language:

- [ ] "seamless", "robust", "intuitive", "user-friendly", "enhanced", "optimized", "streamlined", "leverage", "empower"
- [ ] "This feature aims to..." followed by generic benefits
- [ ] "not only... but also..." unless this exact trade-off is sourced
- [ ] "improve efficiency" / "reduce manual effort" without saying whose work, what step, and what baseline
- [ ] Any paragraph with no QIMA-specific noun: role, team, system, workflow, metric, source, or decision

If a paragraph could be pasted into another company's PRD unchanged, rewrite it using `human-prd-writing-style.md` before review.
