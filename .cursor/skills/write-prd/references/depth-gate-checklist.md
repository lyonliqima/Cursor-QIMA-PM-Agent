# Depth-Gate Checklist — per-FR template

> **⚠️ OPTIONAL — default = SKIP this whole phase.**
>
> This produces engineering-grade per-FR depth: state machines, field-mapping tables, API contracts, edge case matrices. **Running it bloats the PRD by 200–500 lines and pushes technical detail into a doc PMs / business stakeholders won't read.**
>
> Run only when:
> - PM explicitly asks: *"make this dev-ready"* / *"deep version"* / *"include the data contract"*, OR
> - There is no separate Tech Design page and dev is pulling from PRD directly.
>
> **Otherwise**: leave this for `ticket-breakdown` (the dedicated handoff skill). PRDs are for product alignment; ticket breakdowns are for dev handoff. Don't conflate them.
>
> If running: max 3 rounds per FR. Remaining gaps after round 3 → Section 11 Open Questions (do not fabricate). Detail below applies only when this phase is opted-in.

---



---

## D1 · State enumeration (7-state checklist)

| State | Must specify |
|---|---|
| Default | — |
| Loading | Skeleton vs spinner? After 3s show progress indicator? Optimistic UI? |
| Empty | First-time-user copy + CTA? Zero-data dashboard vs no-permission? |
| Error | What happened / why / what the user can do next. Catch-all vs per-feature isolation |
| Partial / Degraded | Slow network, stale cache, some fields missing |
| Permission denied | Role-restricted view, unverified account fallback |
| Session timeout | Mid-action timeout recovery, inconsistent state resolution |
| Offline | (If applicable) — queue local, sync on reconnect, read-only view |

**Pass criterion**: each applicable state has an explicit display spec (not "handle gracefully").

**For workflow FRs**: also enumerate **parallel state machines per entity** (Report / FP / Test / Order / etc.) with explicit transition triggers and side effects. See `prd-patterns-from-best.md` Pattern 1.

## D2 · Interaction micro-behavior

Per interactive element, specify:

- **Mouse/touch**: click, hover, focus, active, double-click, long-press
- **Keyboard**: tab order, Enter/Space behavior, Esc, arrow-key navigation (if list/table)
- **Form validation** (if input): timing — on change / on blur / on submit? Error display location — inline below field / summary top / toast?
- **Scroll / swipe**: if the component has virtualized / infinite lists, specify threshold and loading indicator

**Pass criterion**: a new FE engineer can implement all interactions without asking.

## D3 · Data field mapping (MOST COMMON GAP)

**Required table** per FR:

| UI element | Contract field path | Type | Source | Formatting / Copy rule | Special values |
|---|---|---|---|---|---|
| e.g. "Critical inspected count" | `keyIndicator.inspectionResultSummary.checkedCritical` | string (int) | Interactive Report contract (Confluence 3237249028) | Display as `Checked 132` | `null` -> hide row |
| "Order quantity" | `productDetails.generalInfo.QUANTITY` | string | QSP orderService | `"18 Pcs"` passthrough | `""` -> `"-"` placeholder |
| "AQL Level" | `keyIndicator.aqlLevel` | enum `product \| reference` | Interactive Report contract | When `reference` → use per-SKU breakdown | — |

**Coverage bar**: ≥ 80% of numbers / labels / mutable text on the Figma frame for this FR must appear in the table.

**For integration FRs (data crosses system boundaries)**: add a separate **cross-system handoff table** with columns: sender field path / receiver field path / type / required / release version / missing-value behavior. See `prd-patterns-from-best.md` Pattern 3.

**Anti-pattern triggers depth-pass immediately**:
- Prose says "sample total" without naming the backing field
- Two similar-looking concepts (e.g. "Total Inspected" vs Workmanship sample size) not distinguished with their separate field paths
- "Data from backend" without naming which service or contract

## D4 · Boundary conditions

For each list / text / numeric field, answer:

- **Long text**: truncation strategy (`...`, multi-line clamp, expand-on-click)? Character budget?
- **Count bounds**: max visible items before paging / "view more"? Min before fallback copy?
- **Empty**: per-section empty copy (not a global blank state)
- **Dedup**: when upstream returns duplicates, collapse or show all?
- **Extreme values**: 0, negative, very large (overflow the column)?

## D5 · Dependencies + API contract (4 must-answer)

**Depends-on list**:
- Upstream FRs that must exist first
- Services / data events the FR relies on
- Design tokens / shared components (if any)

**Must-answer API questions** (Aditya Agarwal's checklist):

1. **Null / empty payload** — if API returns a field with `null` or `{}`, what does UI do? Hide? Show placeholder? Collapse the section?
2. **Unknown error code** — if API returns an error code not explicitly handled, does the whole app crash, does a generic modal show, or is the error isolated to this FR?
3. **Timeout** — what's the timeout threshold, and what UI state fires when it's hit? (Retry? Fallback content? Disabled CTA?)
4. **Schema evolution** — if the backend adds a field (backward-compatible) or renames one (breaking), how does the FR degrade? Minimum version expected?

**Pass criterion**: all 4 answered, even if the answer is "follows global app pattern — see [link]".

## D6 · Scope boundary (positively stated)

End of every FR body must have an "Out of this FR" line listing what downstream might reasonably assume is included but isn't.

**Rationale**: Downstream consumers (AI agents in particular, but also new engineers) **cannot infer scope from omission**. Every boundary must be positively stated. This follows the AGENTS.md 2025 cross-vendor consensus (Google / OpenAI / Factory / Sourcegraph / Cursor).

**Each OOS bullet must carry either** (a) a positive **re-inclusion trigger** (the condition under which it returns to scope), or (b) ≥ 2 reasons it's deferred. Bare "out of scope: X" fails. See `prd-patterns-from-best.md` Pattern 4.

**Example** (FR-3 AI Summary):

> **Out of this FR**:
> - (a) the AI model itself — we reuse existing Summary service, no new prompt / fine-tune. *Reopen trigger*: summary quality complaints > 5%.
> - (b) multi-language output — English-only in Phase 1. *Reopen trigger*: DE/CN tier-1 client requests.
> - (c) editing or regenerating a summary from the UI — Phase 2 backlog.

## Acceptance Criteria format — Given / When / Then

At least one AC per FR. Format:

```
AC-<n> (FR-<m>) — Given <preconditions>, When <action>, Then <observable outcome referencing specific field / component>.
```

**Good example**:
> **AC-5.1 (FR-5)** — **Given** `keyIndicator.aqlLevel = reference`, **When** user opens Workmanship section, **Then** show per-SKU breakdown table sourced from `productReferenceWorkmanShipResult[]` with columns SKU / checked / found / max / severity, rows sorted by descending `foundMajor`.

**For algorithm / allocation / branching FRs**: prefer a **scenario matrix** over a single G/W/T — one row per edge case (happy path, boundary 0/max/+1, partial-eligibility, all-ineligible, asymmetry). See `prd-patterns-from-best.md` Pattern 2.

## Decision log (per material trade-off)

For any FR where alternatives were considered, append a § Decisions entry naming Option A / Option B (pros / cons), the chosen option WITH reasoning, and a **reopen trigger**. See `prd-patterns-from-best.md` Pattern 5. Material trade-offs resolved in Slack but not recorded in the PRD = depth-gate fail.

**Banned vocabulary** (Perforce 2026 anti-pattern list):
- "flows smoothly"
- "displays correctly"
- "performs well"
- "performs as expected"
- "handles gracefully"
- "appropriate messaging"

These are not testable. Replace with concrete observable outcomes referencing specific fields / states / counts.

---

## Depth-Pass Summary — final output format

Append to PRD draft working notes (NOT the PRD body itself):

```
### Depth-Pass Summary (Phase 4.5)

- FR-1: ✓ round 1
- FR-2: ✓ round 2 — added Pass/Fail long-text truncation + field mapping table
- FR-3: ⚠️ ceiling — AI Summary failure fallback deferred to Q4 Open Question
- FR-4: ✓ round 1
- FR-5: ✓ round 2 — aligned `checkedCritical/Major/Minor` vs `productQuantity` distinction; added per-SKU Given/When/Then AC
- FR-6: ✓ round 3
- FR-7: ⚠️ ceiling — POM sample size computation left to AC-13 user verification
- FR-8: ✓ round 1
- FR-9: ✓ round 2
- FR-10: ✓ round 2
```

---

## Background: why this works

- **CMU SEI 2025 research**: effective requirement management eliminates 50–80% of project defects; late-stage requirement fixes cost 8–20× more than early-stage.
- **GitHub 2025 analysis** (2500 repos) identified 6 areas effective specs must cover: commands, testing, structure, style, workflow, boundaries — this checklist maps to those.
- **Aditya Agarwal's edge-case checklist**: origin of the 4 API-contract must-answers.
- **Figr "10 Edge Cases Every PM Misses"**: origin of the 7-state enumeration.
- **AGENTS.md (2025)**: origin of the positively-stated scope rule.
- **Perforce 2026 PRD guide**: origin of the banned-vocabulary list and the Given/When/Then preference.

---

## When to escalate to user instead of looping

Per `feedback_prd_ask_when_uncertain`: if round 1 depth-gate failure on D3/D4/D5 can't be resolved by Confluence / Figma / service-doc search, batch the remaining unknowns into a single AskUserQuestion card before round 2. Don't ping the user per gap.
