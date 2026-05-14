# Human PRD Writing Style — QIMA PM Gate

This file turns the PRD samples from Suki Yuan, Matt Cai, Pierre Rioual, Eric Wang, and Bindu into writing rules. It is a hard gate for Phase 4: a PRD that sounds like a generic AI summary fails.

---

## 1. What "Human PM" Means

Write like a PM who has been in the alignment meetings:

- Start from the real situation, not a generic product ambition.
- Name the team, user group, source system, business owner, or decision-maker when known.
- State what was decided, what is deferred, and why.
- Use business language that can survive Confluence review by Ops, Design, PM, and Tech.
- Keep natural phrasing. Do not over-polish every sentence into the same structure.

The target style is concise, practical, and decision-oriented. It can be slightly plain. It must not feel like marketing copy or an AI-written executive summary.

---

## 2. Source-Inspired Writing Patterns

### Suki-style: structured requirement clarity

Use for QIMAlabs / LT / report / field-heavy PRDs.

- Prefer tables for field behavior, page areas, priorities, and milestones.
- Say exactly which page, section, status, field, or report output changes.
- Keep requirements operational: "The team should be able to upload..." is better than "Users will enjoy a streamlined experience."
- When scope is split by phase, show the phase in the requirement row, not only in Rollout.

### Matt-style: operational pain and explicit alignment

Use for workflow / sync / handoff PRDs.

- Open Background with today's manual work and who performs it.
- Tie each requirement to a specific operational pain: duplicate entry, manual copy/paste, unclear ownership, workload imbalance, missing source of truth.
- Mark "Owner", "To align with", and "Deferred" items clearly.
- If a rule is not aligned yet, do not hide it inside prose. Put it in Open Questions or Out of Scope with owner.

### Pierre-style: business adoption and stakeholder framing

Use for adoption, report experience, GTM, customer-facing change, and strategy PRDs.

- Explain why the change matters to adoption, customer behavior, communication, or business KPI.
- Include rollout communication, pilot audience, and success signal.
- Separate "what ships in v1" from "what supports the wider program".
- Avoid over-detailing engineering. The reader should understand the business path to adoption.

### Eric-style: delivery-aware product handoff

Use for frontend, myQIMA, interactive report, and delivery coordination PRDs.

- Make implementation ownership visible at team/role level, without repo names.
- Keep UX requirements tied to observable user actions and acceptance criteria.
- For frontend-heavy work, include design frame links, interaction specs, and responsive/empty/error states.
- Flag dependency and release risks early; do not bury them after the FR table.

### Bindu-style: process traceability and audit discipline

Use for audit, CAP, QIMAcert, compliance, and workflow-control PRDs.

- Show the end-to-end business process and the handoff between roles.
- Capture status definitions, responsibility boundaries, approvals, and audit trail expectations.
- Use stakeholder names and process owners where available.
- Risks should include operational adoption and training, not only system defects.

---

## 3. Decision-Quality Requirements

Before publish, verify these sections answer the real PM questions.

### Background

Must include:

- Current situation: what happens today and who does it.
- Pain point: what breaks, slows down, or creates risk.
- Impact: business, customer, operation, compliance, cost, adoption, or data-quality impact.
- Baseline: current volume, time, conversion, error rate, usage, or "TBD — source needed".
- Why now: stakeholder push, roadmap dependency, support pressure, KPI target, or upcoming rollout.

Fail: "This PRD aims to improve the user experience by making the process more efficient."

Pass: "Coordination currently assigns inspectors in IRP, then manually copies the assignment into QIMAOne product by product. This creates duplicate work and makes workload balancing hard to verify before report preparation."

### Scope

Must include:

- In-scope capability.
- Out-of-scope item.
- Reason for the boundary.
- Reopen / re-include trigger when useful.

Fail: "Mobile optimization is out of scope."

Pass: "Mobile optimization is out of scope for v1 because current usage is driven by internal desktop users. Reopen when client-facing usage exceeds the agreed adoption threshold or when GTM confirms mobile users are part of launch."

### Requirements

Each high-value FR should answer:

- Who uses it.
- What they need to do.
- What decision / output changes.
- What edge case matters.
- How the PM will know it works.

Avoid FRs that only describe UI components or backend behavior.

### Metrics

Every success metric needs:

- Baseline or source gap.
- Target.
- Measurement method.
- Owner.
- Review timing.

If there is no baseline, write "Baseline TBD — owner to confirm before launch" rather than inventing a number.

### Rollout

Include the human rollout work only when relevant and supported by source material or PM confirmation:

- Communication owner.
- Pilot / beta group.
- Training or SOP update.
- Reversible configuration or fallback.
- Release gate with named signer.

Do not invent rollout tasks, pilot groups, training plans, or signers just to make this section look complete. If not confirmed, ask the PM or mark the decision as TBD.

### Open Questions

Every open question must have:

- Owner to answer.
- Who they need to align with.
- Whether it blocks v1.
- Consequence if left unresolved.

---

## 4. AI-Smell Language to Remove

Delete or rewrite these patterns unless they are directly sourced:

- "seamless", "robust", "user-friendly", "enhanced", "optimized", "streamlined", "intuitive", "leverage", "empower", "holistic", "comprehensive solution".
- Paragraphs that start with "This feature aims to..." and never mention a concrete team, workflow, metric, or decision.
- Over-balanced sentences: "This will not only X but also Y, ensuring Z."
- Generic benefits: "improve efficiency", "reduce manual effort", "enhance visibility" without baseline or example.
- Fake certainty: "will significantly increase adoption" without a target and measurement method.
- Too-perfect structure: every bullet has the same length and grammar. Real PM docs vary by importance.

Preferred replacements:

- "Reduce manual copy/paste for Coordination users."
- "Make the report conclusion visible before detailed sections."
- "Record rejection reason so Sales/CS can stop follow-up reminders."
- "Keep Phase 1 internal-only until Finance confirms the invoice-line requirement."

---

## 5. Human Rewrite Rules

Apply these before the voice gate:

1. Replace abstract nouns with the real business object.
   - Weak: "improve data consistency"
   - Strong: "keep inspector assignment consistent between IRP and QIMAOne"

2. Replace generic users with real roles.
   - Weak: "users can review reports"
   - Strong: "buyers and QA managers can read the report conclusion before opening defect details"

3. Replace unsupported adjectives with evidence.
   - Weak: "faster workflow"
   - Strong: "remove the product-by-product copy step from Coordination's daily assignment flow"

4. Keep one useful imperfection when it improves authenticity.
   - It is acceptable to write "To align with: Alice Xie" or "Owner: Matt Cai" rather than forcing everything into polished prose.

5. Do not hide disagreement.
   - If stakeholders are not aligned, write the unresolved decision and owner. Do not smooth it into a vague "future consideration".

---

## 6. Final Gate

A PRD passes this gate only if:

- A PM can explain why the feature exists after reading Section 2.
- A designer can see which user/job/page/problem the requirement supports.
- A business stakeholder can see what is in v1 and what is deferred.
- A delivery lead can see the main dependencies and release gates without reading code.
- At least one sentence in Background or Scope could not have been written without QIMA-specific context.

If the answer is no, rewrite before Confluence publish.
