# Business Background Mining

The job of Phase 1.5 is to answer the meta-questions a sharp engineer or new PM would ask about the domain BEFORE they read the FR table. Modeled after how top QIMA PMs use the Confluence comment area as a research scratchpad — see comments on Confluence page 4531159117 (Audit Renew) for the canonical example.

This phase is **not** about the user's intent or the FR set. It's about the **business semantics** of every domain concept the PRD will touch. Without it, the PRD reads like a feature spec; with it, the PRD reads like someone who understands the business.

---

## When this runs

Between Phase 1 (source scan) and Phase 2 (synthesis). The output `business-background.md` is consumed by:
- Phase 2 synthesis (informs gap detection)
- Phase 2.5 depth interview (informs which questions to ask)
- Phase 4 drafting (every §2 Background paragraph cites it)
- Phase 4.7 review (review-expert checks PRD claims against this file)

---

## Question generation heuristics

Generate **6–15 sharp meta-questions** by scanning the feature brief + Phase 1 source briefs for these triggers. **Default to ASKING.** A missing meta-question becomes a fabricated paragraph in §2 — the cost of one extra question is far less than the cost of one fabricated claim.

Output is a **working note**, NOT a deliverable section in the PRD body. The PM uses it to inform §2 prose and check assumptions; do NOT paste Q&A blocks into the published PRD. The PRD body still hits the ≤ 250-line cap regardless of how many meta-questions were answered upstream.

| Trigger in brief | Meta-question shape |
|---|---|
| A domain noun not self-evident from English (e.g. "Validity Date", "CAP", "ShortName", "Breakdown") | *"Why does {noun} exist? What does it semantically represent?"* |
| Two actors mentioned (buyer / supplier, BD / sampler, etc.) | *"Who initiates {object}? Who confirms? Who consumes downstream?"* |
| A state or status field | *"What is the lifecycle of {state}? What triggers transitions?"* |
| A threshold or rule (score ≥ 9, 12mo, 24mo) | *"What rule governs {threshold}? Where is it defined? Is it standard-driven or client-driven?"* |
| A workflow with variations (per lab, per client, per standard) | *"How does {process} differ across {dimension}? What's the canonical vs variant?"* |
| A removed/deprecated feature | *"Why was {removed feature} considered? Why not now?"* |
| A reminder, deadline, or expiration | *"What business risk does {deadline} mitigate? What happens if missed?"* |
| A categorization with "Other" | *"What scenarios fall under each option? What does 'Other' typically catch?"* |

**Stop generating** when no new trigger fires after re-scanning the brief. Don't pad — 5 sharp Qs is better than 15 vague ones.

---

## Procedure per question

For each generated Q, in parallel via Subagents:

1. **CQL search** Confluence: `text ~ "{noun}" AND space.key = "IT"` plus variants from `keyword-expansion.md`.
2. **Read top 3–5 hits** end-to-end.
3. **Cross-check**: if the brief mentions a UX flow doc or process page, follow that link first.
4. **Draft answer** in the format below — direct reason first, then evidence, then "what it means for this PRD".
5. **If no internal source answers it** → mark as `unresolved` and add to Phase 2.5 user-question batch (don't fabricate).

---

## Answer formats — pick the archetype that fits the question

Two archetypes from the Audit Renew comment thread. Use **A** by default; use **B** when the trigger is a categorization/enum/dropdown.

### Archetype A — Definition Q (Why X? / Who Y? / What lifecycle?)

```
### Q: {meta-question, verbatim}

**Direct reason** (1 sentence): {core answer — the *because*}

**Evidence**:
- {claim} — source: {Confluence page title} ({link or page ID})
- {claim} — source: ...

**Detail / mechanism** (optional, ≤ 150 words): {how the rule actually works — thresholds, lifecycles, edge cases}

**Implications**:
- For *this* PRD: {which FR / §section / decision this answer changes}
- For *future* product decisions (when applicable): {what other product surfaces this fact unblocks — pricing, churn analytics, segmentation, retirement candidates}
```

### Archetype B — Categorization unpacking (per-option semantics)

When a feature exposes a dropdown / enum / radio / "Other" bucket, do NOT just list the labels. For each option, surface what it means in the user's real world AND what business levers the data feeds.

```
### Q: What does each option in {dropdown / enum / category} actually mean?

For each option:

#### Option N: {label}

**User real scenarios** (3–5 concrete bullets — what the user is actually living through when they pick this):
- {scenario}
- {scenario}
- {scenario}

**Implications for business** (what data downstream teams can mine from this signal):
- {use case A — e.g. pricing strategy adjustment}
- {use case B — e.g. discount evaluation for key clients}
- {use case C — e.g. measuring loss share due to this reason}

**Source**: {if a doc enumerates the options, cite it; if user-supplied, mark `user-supplied — Round X`}
```

> **Why two formats**: Archetype A explains *why a thing exists*. Archetype B explains *what choosing each branch means semantically and operationally*. Confusing the two produces shallow content — Suki's Audit Renew thread keeps them clean (Comments 1 & 3 are A; Comment 2 is B).

**Example A (from Audit Renew comment 4556095497 — Definition Q archetype):**

> **Q: Why does the audit report have a "Validity Date"?**
>
> **Direct reason**: An audit report represents factory compliance at a point in time; compliance risk diminishes over time, so the report cannot represent "still compliant now" indefinitely.
>
> **Evidence**:
> - Validity period length is set by the audit standard or by the client (brand) — source: *Ux - Current Audit flow* (Confluence 1358201217)
> - Validity rules tied to score: ≥ 9 → 24 months, ≥ 8.5 & < 9 → 12 months, < 8.5 → requires Follow-Up Audit — source: same
>
> **Detail**: Some clients opt out of expiration entirely (treating the report as internal reference, not certificate). The validity field is therefore not just system metadata but a business rule controlling when re-audits are required.
>
> **Implications**:
> - For this PRD: §2 Background must explain why the reminder exists at all (compliance expires); FR-X must support both "client-set expiration" and "no expiration" cases; §5.2 OOS should call out "score < 8.5 follow-up flow" as separate.
> - For future product decisions: validity-tier data feeds future pricing-by-tier work and identifies which clients treat reports as internal-reference (a different value prop, possibly a different SKU).

**Example B (from Audit Renew comment 4557406216 — Categorization unpacking archetype):**

> **Q: What does each option in the "deferral reason" dropdown actually mean?**
>
> #### Option 1: Price too high / budget constraints
>
> **User real scenarios**:
> - This year's budget was cut; compliance/audit budget is insufficient
> - Management thinks the audit is "too expensive, not a priority"
> - User is comparing against other suppliers and finds QIMA relatively expensive
>
> **Implications for business**:
> - Adjusting pricing strategy for certain projects
> - Evaluating whether to offer key clients volume/bundle discounts
> - Determining the loss share attributable to price (vs other reasons)
>
> *(Repeat per option; "Other" gets a free-text bucket for future single-choice promotion)*

---

## Output

`business-background.md` in working directory:

```
# Business Background — {feature name}

Last updated: {date}
Coverage: N questions, M sources cited, K unresolved (forwarded to Phase 2.5)

---

## Domain Q&A

### Q1: Why does X exist?
{full block as above}

### Q2: Who initiates Y?
{...}

...

## Unresolved
- Q-N: {question} — no internal source found, queued for Phase 2.5 user batch
```

---

## Coverage bar

The phase passes when:
- ≥ 80% of generated Qs have answers backed by ≥ 1 cited source, OR
- All unresolved Qs are queued into Phase 2.5 (the depth-interview round 0 user-batch)

If a generated Q's answer requires only the user (not internal docs) → skip the search, route directly to Phase 2.5.

---

## Anti-patterns

- ❌ Skipping this phase when "the brief is clear" — the brief is what the PM wrote, not what the team needs to know
- ❌ Writing the Q&A from your own reasoning without citing sources — that's fabrication
- ❌ Generating Qs by templating the FR list — the questions should target the business semantics, not the features
- ❌ Stopping at "found a doc that mentions X" — read the doc; surface the actual rule
- ❌ More than 15 Qs in v1 — over-broad. Pick the 5–10 that genuinely block PRD drafting; defer the rest

---

## Why this works

A PRD authored without this step describes *what to build*. A PRD authored with this step explains *what the business object means and why it exists* — which is the difference between a feature spec and a product document. Top QIMA PRDs (SUKI portfolio, Audit Renew) consistently do this groundwork; the comment area on Audit Renew (page 4531159117) is the proof — Suki literally pasted her research notes into the comment thread before drafting.

---

## Canonical example — Audit Renew (Confluence 4531159117)

This page is the reference standard for Phase 1.5 output. Three comments in its footer thread, two distinct archetypes:

1. **Comment 4556095497 — Archetype A (Definition Q)**
   Two stacked Q&As in one comment:
   - *"Why does the audit report have a Validity Date?"* — direct reason → evidence (Ux Current Audit flow, page 1358201217) → mechanism (score thresholds: ≥9 → 24mo, ≥8.5 & <9 → 12mo, <8.5 → Follow-Up Audit) → implications.
   - *"Why is there a Follow-up Audit Due Date?"* — CAP (Corrective Action Plan) lifecycle → 2 internal docs cited (CAP page 526647410, Audits 2.0 page 1209827522) → distinguishes Follow-up Audit (on-site re-check) vs Desktop Review (document evidence review).

2. **Comment 4557406216 — Archetype B (Categorization unpacking)**
   Unpacks the 5-option deferral-reason dropdown (Price too high / Pending business decision / No longer required / No longer working with this supplier / Other). For each option: *user real scenarios* (3–5 bullets) + *implications for business* (forward-looking: pricing strategy, discount evaluation, loss-share measurement, churn-supplier marking, "Other" promotion to single-choice).

3. **Comment 4556390405 — Archetype A (Definition Q)**
   *"Who initiates the audit — buyer or supplier?"* — buyer-driven main scenario (4 cited sources: 1358201217 Ux flow, 4515495938 reminder PRD, 4390682638 Supplier Confirmation, plus the same Ux flow for branding) → supplier role is *confirm/cooperate* via Supplier Confirmation flow (no login, link + password) → why renewal reminders nonetheless go to suppliers as opt-in client setting (default No).

### Match this format exactly when authoring `business-background.md`

For **Archetype A** entries:
- Phrase as a meta-question (*Why X?* / *Who Y?* / *What lifecycle?*) — not a feature question
- Cite ≥ 1 internal Confluence page by name + ID
- Close with **Implications** split into *this PRD* + *future product decisions*
- Stay under ~250 words per Q (Suki's longest is ~300; brevity is the bar)

For **Archetype B** entries:
- One Q frames the categorization; each option gets its own block
- Per option: ≥ 3 *user real scenarios* (lived experience, not jargon) + ≥ 2 *implications for business* (downstream uses, not just "log this for analytics")
- "Other" must explicitly be flagged as a free-text bucket with promotion criteria ("if X recurs, upgrade to a single-choice option")

If your generated `business-background.md` doesn't read like Audit Renew's comment thread — Archetypes A and B in the right places — re-do it.
