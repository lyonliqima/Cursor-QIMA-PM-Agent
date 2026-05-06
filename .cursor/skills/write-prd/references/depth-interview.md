# Depth Interview — pre-draft questioning protocol

The job of Phase 2.5 is to pre-empt shallow PRD content **before** the draft is written. Modeled after Claude Design's iterative discovery loop (many short rounds, one focus per round), not a one-shot questionnaire.

The skill MUST run this before Phase 3 outline. The synthesis output from Phase 2 is the input — it tells you which PRD sections would be thin if you drafted today.

---

## Operating principles

1. **One topic per round, max 3 questions per AskUserQuestion card.** A wall of 15 questions = user gives shallow answers to all 15. A focused round of 3 = user thinks. Multi-round, not multi-question-per-card.
2. **Branch on user's answer.** If user says "we haven't decided", that's a separate follow-up — don't push for invented numbers.
3. **Stop when the section can be drafted at "good PRD" depth, not "complete" depth.** Different bar.
4. **Cap: 7 rounds total across all sections.** Short PRDs DO need depth — short ≠ shallow. If still thin after 7, draft with explicit ⚠️ TBD markers; don't loop forever, but don't bail at 3 either.
5. **Never auto-answer. Never infer.** If the synthesis didn't surface it from a source, ask. If you find yourself writing "presumably X" or "likely Y" in §2, that's a question, not a sentence.
6. **All 18 triggers active by default.** Run any round whose trigger has fired. The priority order below tells you WHICH round to run first; not WHICH rounds to skip. If a section is thin on a long-tail trigger and you don't have round budget left, leave a ⚠️ marker — don't fabricate.

**Default mindset: ASK.** When choosing whether to spend a round on a borderline section, lean toward asking. The user can skip a card; they can't unread a fabricated claim.

---

## Shallow-content detection — where PRDs go thin

Run this self-audit on the synthesis output. For each section, if the answer to the trigger question is **no**, that section needs an interview round.

| Section | Shallowness trigger (if YES → ask) | Standard the section must reach |
|---|---|---|
| **§2 Background** | Can you list ≥ 3 distinct, independently defensible reasons why this matters? | Each reason is a sentence + concrete evidence (a failure mode, a workaround, a stat). Not "improves efficiency". |
| **§2 Objective** | Is the v1 success criterion falsifiable in one sentence? | E.g. "HZ chemistry team fully migrated, legacy tool retired" — not "improved adoption". |
| **§3 Stakeholders** | Are there ≥ 2 named SMEs (not roles) with explicit responsibility for the domain logic? | Real names, not "the design team". |
| **§4 Personas** | Does each persona have a concrete action in the flow? | "BD lead → scans QR → picks BD version → triggers ShortName match" — not "uses the system". |
| **§5.1 FR table** | Does each P0 FR answer: (a) what's the current state? (b) what changes? (c) what data structure / schema? | Without (c), config FRs are vapor. |
| **§5.1 FR table** | Does the table distinguish P0 / P1 / P2, with a written rule for what each means? | "P0 = blocks v1 launch" — not just labels. |
| **§5.2 OOS** | Does each OOS bullet have a reason or reopen trigger? | Bare "out of scope: X" fails. |
| **§5.2 OOS** | Is each OOS row attributed to a decision-maker / meeting? | Pattern 8 — provenance. |
| **§6 Design** | Are key interactions specified as a table (element / trigger / behavior)? | Prose-only design = ambiguity. |
| **§6 Design** | Are edge cases enumerated (≥ 5 listed)? | Multi-version / unmatched / hardware disconnect / overflow / conflict. |
| **§7 AC** | Does each AC reference a named field or schema element? | "Given config replicate_count = 2..." — not "Given user is logged in". |
| **§8 Analytics** | Are events listed with key fields, not just names? | `weigh.weight_captured(order_id, shortname, source=balance/manual)` |
| **§8 Metrics** | Split into Leading vs Lagging with numbers? | Leading 30d / Lagging 90d, with thresholds. |
| **§9 Risks** | Does each risk have probability AND mitigation that's executable? | Probability column + "do X by date Y" — not "improve communication". |
| **§9 Dependencies** | Is each dep owned by a named person/team? | "TBD" is OK if explicit; "Dev" alone is not. |
| **§10 Rollout** | Are phases lettered/numbered with explicit dependencies between phases? | Phase B depends on Phase A complete + hardware spike done. |
| **§10 Release Gates** | ≥ 3 gates with distinct signers? | Tech / Business / Data — Pattern 6. |
| **§11 OQ** | Each OQ has answerer + "Blocks v1?" flag? | Pattern 7. |

---

## Round structure

Each round = one section topic + max 3 questions + structured options where possible.

### Round 0 (always run): scope sanity

Before any other round, confirm three anchors:

```
Q1. v1 scope sentence — please confirm or correct: "{auto-extracted from intake}"
Q2. v1 success criterion — what single observable outcome means v1 succeeded?
Q3. v1 explicitly out of scope — name 1-3 things that are tempting but won't ship.
```

If user can't answer Q2 in one sentence, the PRD will be unfocused. Loop on Q2 until you have a falsifiable sentence.

### Rounds 1–N: section-specific (run only if shallowness trigger fires)

Pick rounds in this priority order — earlier rounds compound into later ones:

1. **Background depth round** — 3 separate problems, each with evidence
2. **FR schema round** — for each P0 FR involving config/data, get field names
3. **OOS provenance round** — for each OOS, who decided + why
4. **Risk probability round** — assign H/M/L to each risk, name a mitigation owner
5. **Release gate round** — split into tech/business/data, name signers
6. **Edge case round** — 5+ named edge cases per major flow
7. **Open Question blocker round** — flag each OQ as blocking or not

Stop when sections can be drafted at "good" not just "complete" depth, OR when round budget hits 7.

---

## Question shapes (use these phrasings)

**For depth on Background (Round 1)**:

> "I have one defensible reason for this PRD: {reason from synthesis}. To match the bar of a strong PRD I need 2 more reasons that aren't restatements. Pick from below or write your own:
> □ Data isolation / no system-of-record
> □ Bus factor (single maintainer)
> □ Compliance / audit risk
> □ Downstream value blocked
> □ Scalability / multi-tenancy
> □ Other: _____"

**For FR schema (Round 2)**:

> "FR-{N} mentions a {config table / mapping / rule}. To avoid vapor, I need at least 2-3 field names. Smallest viable schema:
> - parent_X: ___
> - child_X: ___
> - scope: ___
> Or: 'use existing schema in {service Y}'"

**For OOS provenance (Round 3)**:

> "For each OOS item, one line: who decided + why. Free-text OK.
> - Item A: ___
> - Item B: ___
> - Item C: ___"

**For Risk probability (Round 4)**:

> "Rate each risk's probability (H/M/L) and name one mitigation step (max 1 sentence each):
> - Risk 1: ___ / ___
> - Risk 2: ___ / ___
> - Risk 3: ___ / ___"

**For Release Gates (Round 5)**:

> "For migration/integration PRDs we split release into 3 gates. Confirm or adjust signers:
> - Tech Gate signer: {default Dev + QA}
> - Business Gate signer: {default PO + lab manager}
> - Data Gate signer: {default PM + data owner}"

**For Open Questions blocking (Round 7)**:

> "Mark each OQ as Blocks v1 (yes/no). 'Yes' = must resolve before dev kickoff:
> - Q1 ___
> - Q2 ___
> ..."

---

## Stop conditions

Stop the depth interview when ANY of these is true:

- All shallowness triggers cleared for sections marked Mandatory in the QIMA template
- Round budget hit 7
- User says "stop asking, draft what you have" (record this in the open-questions section: *"Drafted with reduced depth interview at user request — sections marked ⚠️ TBD are not blocking the user, but should be reviewed before dev kickoff"*)

---

## Output of Phase 2.5

A `depth-interview-log.md` with:

- Round-by-round Q&A captured
- Per-section "depth status": ✓ ready / ⚠️ TBD / ✗ blocked
- A list of any answers that contradict the synthesis (these become AC verification points later)

This log becomes the input to Phase 3 outline + Phase 4 drafting. Drafting MUST cite this log when filling each section.

---

## Anti-patterns

- ❌ One AskUserQuestion card with 15 questions covering 5 sections → user fatigue, shallow answers
- ❌ Asking for invented numbers ("what's the target CSAT?") when no source supports it → fabrication risk
- ❌ Skipping Round 0 because intake "seemed clear" → 80% of bad PRDs trace back to a fuzzy v1 success criterion
- ❌ Looping a single section past 2 rounds → user is telling you they don't know; surface as Open Question with Blocks v1: yes
- ❌ Drafting any FR-table row before the FR schema round runs → the FR will be vapor
