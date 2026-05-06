# Keyword Expansion — QIMA Naming Patterns

A QIMA feature typically has 4-6 different names across PRDs, Jira, code, Teams, and Confluence. Searching only the canonical product name misses relevant context. This reference explains how to expand a seed term into a practical keyword map.

---

## Why Expansion Is Mandatory

Observed naming drift across QIMA sources:

| Layer | Typical name form | Example |
|---|---|---|
| PRD / product doc | Full product name, Title Case | "Package Charge Management" |
| Marketing / external | Shortened marketing name | "Package Fee" |
| Jira epic | Title with abbreviation suffix | "Package Charge Mgmt (PCM)" |
| Jira labels | lowercase-hyphen | `package-charge`, `billing` |
| Code repo name | kebab-case with version/module | `charge-service-cloud`, `billing-v2` |
| Local-language discussion | Direct translation or colloquial wording | localized names used by the team |
| Engineering shorthand | Acronym | "PCM", "Charge v2" |
| Stakeholder references | Informal | "the billing project", "the old package-fee work" |

Searching only "Package Charge Management" misses the other layers.

---

## Expansion Procedure

### Step 1 — Classify the Seed

Identify which category the seed belongs to:

- **Product name**: expand down to code names.
- **Code / module name**: expand up to product names.
- **Acronym**: expand in both directions.
- **Localized term**: find English equivalents and internal project names.

### Step 2 — Apply QIMA Naming Rules

**Rule 1 · English and localized pairing**

Always generate both English and localized variants when available. Common QIMA domain concepts:

| Domain | English keyword set |
|---|---|
| Inspection | inspection, audit, check |
| Report | report, lab report, test report |
| Sample | sample, specimen |
| Lab | laboratory, QIMAlabs |
| Package / Charge | package, parcel, charge, fee, billing |
| Inspector | inspector, auditor |
| Order | order, booking |
| Factory | factory, supplier |

**Rule 2 · Version and module suffixes**

QIMA codebases commonly use `-v1`, `-v2`, `-cloud`, `-service`, and `-web` suffixes. If the seed refers to an existing system, add variants:

- `<name>-service-cloud` — backend service
- `<name>-web-cloud` or `<name>-web` — frontend
- `<name>-v2` / `<name>-next` — rewrite project
- `<name>-external-service-cloud` — external-facing API

Example: seed "sample" expands to `sample-service-cloud`, `sample-web`, and `sample-v2`.

**Rule 3 · Team ownership as keyword**

The owning team name is a strong retrieval signal in Teams chats and Confluence. Use the team-to-project map in reverse:

| Team | Typical domains |
|---|---|
| Apollo | audit, inspection, IRP, IPTB, PSI, factory |
| Titan | auth, e-signature, lab, sample, program, report, user |
| Loong | check the team mapping |

If the seed is "lab report", Titan is a likely owner, so add "Titan" and "Titan team" to retrieval keywords.

**Rule 4 · Acronym expansion**

Common QIMA acronyms:

| Acronym | Full form |
|---|---|
| PRD | Product Requirements Document |
| QSP | QIMA Service Platform |
| PSI | Pre-Shipment Inspection |
| GI | General Instruction |
| JTBD | Jobs to be Done |

If the seed is an acronym not in this table, ask the user and append the new entry to this file.

**Rule 5 · Stakeholder names as keywords**

Pull likely stakeholder names from:

- Jira epic assignees / reporters
- Confluence page contributors
- Team leads from the team-project map

Stakeholder names in Teams or Outlook often signal relevant context.

### Step 3 — Lightweight Verification Pass

Before committing to the keyword map, run cheap queries in parallel:

```text
# Jira — pull epic titles/labels
text ~ "<seed>" OR labels = "<seed-kebab>"

# Confluence — pull page titles and labels
text ~ "<seed>" AND type = page
```

Harvest additional variants from result titles, labels, and linked code repos.

### Step 4 — Ask the User Once

Use one `AskUserQuestion` card:

> What other names might this feature have?
>
> I will search all of these. Add internal code names, past project names, team abbreviations, localized names, or abbreviations.
>
> Current list: `[canonical] + [N auto-expanded variants]`

Cap at one round.

---

## Output Format — `keyword-map.md`

```markdown
# Keyword map for <feature>

canonical:    Package Charge Management
en-variants:  package fee, parcel charge, shipping billing, package charge
local-variants: <localized terms supplied by sources or user>
code-names:   PCM, charge-v2, billing-module
code-repos:   charge-service-cloud, billing-v2-web
jira-labels:  billing, package-charge, pcm
teams:        Apollo (owner), Titan (integration touchpoint)
stakeholders: <names from Jira + Confluence queries>

# Sources of these variants
- Jira epic title
- Confluence page title
- User clarification
```

Phase 1 scanners must join these variants with `OR`, not search the canonical name only.

---

## Stop Conditions

Expansion is done when any of these are true:

- Map has at least 3 English variants, at least 1 localized variant, and at least 1 code name.
- User confirms the list is complete.
- Verification pass surfaces no new variants in two consecutive queries.
- Time budget for this phase exceeds 5 minutes of tool calls.

Do not loop forever pursuing completeness.

---

## Anti-Patterns

- Searching only the canonical product name in Phase 1.
- Auto-translating localized terms without checking QIMA's actual usage.
- Asking the user to list all variants before any auto-expansion.
- Treating the keyword map as immutable when Phase 1 surfaces a new name.
- Ignoring team names as retrieval keys.

---

## Maintenance — Living Dictionary

This reference should grow over time. Whenever a user supplies a new QIMA-specific name, acronym, repo suffix, team, or English/localized term pair during a PRD run, append it to the appropriate table before ending the turn.

Commit message convention, if version-controlled: `docs(keyword-expansion): add <term> from <context>`.
