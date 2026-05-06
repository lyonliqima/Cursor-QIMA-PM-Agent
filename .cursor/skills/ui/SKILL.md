---
name: ui
description: Unified UI design skill for shaping, building, reviewing, and improving frontend interfaces. Consolidates the former impeccable, shape, critique, audit, polish, layout, typeset, adapt, animate, harden, optimize, clarify, colorize, bolder, quieter, distill, delight, and overdrive skills into one routed workflow. Use when the user asks to design, build, critique, audit, polish, simplify, make responsive, improve copy, add animation, harden edge cases, optimize UI performance, or make an interface more bold, quiet, colorful, delightful, or extraordinary.
version: 1.0.1
user-invocable: true
argument-hint: "[mode] [target or feature]"
---

# UI Design Skill

One entry point for UI work. Decide the right mode from the user's words, then follow the matching playbook below. If the user names a mode explicitly, honor it. If multiple modes apply, sequence them in the order that reduces risk: shape → build → adapt/harden → critique/audit → polish.

## Context gate

Before design work, confirm minimum design context:

1. **Target audience** — who uses this and in what context?
2. **Use case** — what job are they trying to get done?
3. **Brand / tone** — how should it feel?

If the task is small and context is already obvious from the current page or PRD, proceed and state the assumption. If the task asks for a new screen, major redesign, or visual direction, ask for missing context first.

## Mode router

| User intent | Mode | What to do |
|---|---|---|
| "plan the UX", "before coding", "shape this feature" | `shape` | Run a structured discovery interview and produce a design brief before implementation. |
| "build this page/component", "make an artifact", "create UI" | `craft` | Create distinctive, production-grade frontend code with strong visual direction. |
| "review", "critique", "evaluate this design" | `critique` | Assess hierarchy, IA, cognitive load, heuristics, emotional fit, and AI-slop patterns. |
| "accessibility/performance/theming/responsive audit" | `audit` | Run a scored technical quality review with severity-rated findings and action plan. |
| "polish", "finishing touches", "something looks off" | `polish` | Fix alignment, spacing, consistency, states, and micro-details. |
| "layout feels off", "spacing", "visual hierarchy" | `layout` | Improve composition, rhythm, grouping, alignment, and whitespace. |
| "font", "type", "readability", "text hierarchy" | `typeset` | Improve typography scale, font pairing, weight, line-height, and reading flow. |
| "responsive", "mobile", "tablet", "breakpoints" | `adapt` | Make the interface work across screen sizes, input types, and contexts. |
| "animation", "transition", "micro-interaction" | `animate` | Add purposeful motion that clarifies state and improves delight. |
| "production-ready", "empty states", "errors", "i18n", "overflow" | `harden` | Handle real-world data, edge cases, permissions, failures, and localization. |
| "slow", "janky", "bundle", "load time" | `optimize` | Diagnose and improve UI performance, rendering, images, animation, and bundle cost. |
| "unclear copy", "labels", "error messages" | `clarify` | Improve UX writing, labels, microcopy, instructions, and errors. |
| "too gray", "needs color", "more vibrant" | `colorize` | Add strategic color while preserving accessibility and hierarchy. |
| "too bland", "too safe", "needs impact" | `bolder` | Increase visual interest, contrast, and personality without hurting usability. |
| "too loud", "overwhelming", "calmer" | `quieter` | Reduce visual intensity while keeping quality and clarity. |
| "simplify", "declutter", "reduce noise" | `distill` | Remove unnecessary complexity and focus the interface. |
| "delight", "fun", "personality" | `delight` | Add memorable moments, warm details, and user-centered joy. |
| "wow", "go all out", "extraordinary" | `overdrive` | Use ambitious effects only when they serve the product and can stay performant. |

## Shared design principles

- Prefer the existing product stack, design system, tokens, and component patterns before inventing new ones.
- Make one strong design decision instead of many decorative ones.
- Use fewer type sizes with clearer contrast; keep body line length around 65-75 characters.
- Use spacing rhythm: tight groups, generous section separation, and consistent gap scales.
- Use color intentionally. Accents should be rare and meaningful.
- Do not rely on generic AI tells: gradient text, cyan/purple dark glow palettes, glassmorphism everywhere, identical card grids, hero metric layouts, or decorative side-stripe cards.
- Every interactive surface needs a clear state: default, hover/focus, loading, disabled, error, empty, and success where applicable.
- When writing or editing code, verify with the most relevant checks available: lints, tests, browser inspection, screenshots, or manual reasoning if tools are unavailable.

## Mode playbooks

### `shape` — plan before code

Output a short design brief:

- Target users and context
- Primary jobs-to-be-done
- Main flow and key decisions
- Screen / component inventory
- Content hierarchy
- Risks, constraints, and open questions
- Implementation guidance

Ask focused questions if the audience, goal, or success criteria are unclear.

### `craft` — build production-grade UI

Use when creating a new UI or substantial redesign.

1. Establish purpose, audience, tone, constraints, and differentiator.
2. Choose a clear aesthetic direction.
3. Build with accessible semantic structure.
4. Use responsive layout from the start.
5. Add states and edge cases, not only the happy path.
6. Verify and polish before returning.

For deeper implementation references, use:

- `reference/impeccable/typography.md`
- `reference/impeccable/color-and-contrast.md`
- `reference/impeccable/spatial-design.md`
- `reference/impeccable/interaction-design.md`
- `reference/impeccable/responsive-design.md`
- `reference/impeccable/motion-design.md`
- `reference/impeccable/ux-writing.md`

### `critique` — review design quality

Run two lenses:

1. **Human design review** — hierarchy, IA, cognitive load, discoverability, composition, typography, color, states, copy, emotional fit.
2. **Pattern review** — look for AI-slop tells, accessibility issues, overcomplication, missing states, and inconsistent tokens.

Report:

- Overall verdict
- What works
- Priority issues with why it matters and how to fix
- Optional score or severity if useful
- Residual risks / what was not verified

References:

- `reference/critique/cognitive-load.md`
- `reference/critique/heuristics-scoring.md`
- `reference/critique/personas.md`

### `audit` — technical quality check

Use severity levels:

- **P0** blocks use or shipping
- **P1** major accessibility, performance, or workflow risk
- **P2** visible quality issue
- **P3** polish

Check accessibility, responsive behavior, theming, performance, loading/error/empty states, text overflow, i18n, and anti-patterns.

### `polish` — final quality pass

Look for:

- Off-by-small alignment errors
- Inconsistent spacing
- Weak visual hierarchy
- Unclear primary action
- Missing hover/focus states
- Text wrapping and truncation issues
- Inconsistent icons, radii, borders, or shadows

Make the smallest coherent changes that lift perceived quality.

### `layout`

Improve:

- Page composition
- Grouping and scannability
- Grid behavior
- Whitespace rhythm
- Section hierarchy
- Alignment and optical balance

Prefer gap-based spacing and responsive grids over fixed one-off margins.

### `typeset`

Improve:

- Font choice and pairing
- Type scale
- Weight contrast
- Line height
- Measure / line length
- Label and metadata hierarchy
- Numeral and tabular alignment where relevant

### `adapt`

Make designs work across contexts:

- Mobile, tablet, desktop
- Touch and pointer input
- Narrow sidebars / embedded panels
- Print or export when relevant
- Reduced motion and accessibility settings

Use fluid layout, container-aware components, and touch-safe targets.

### `animate`

Use motion to explain:

- State changes
- Hierarchy
- Cause and effect
- Feedback
- Progressive disclosure

Avoid gratuitous bounce, layout-thrashing animations, and motion that slows task completion. Respect reduced-motion preferences.

### `harden`

Test against reality:

- Empty data
- Very long text
- Many items
- Permissions
- Network failure
- Validation errors
- Slow loading
- i18n and RTL
- Duplicate submissions
- Concurrent actions

Design the state, copy, and recovery path.

### `optimize`

Diagnose and improve:

- Initial load
- Bundle size
- Image weight
- Re-render frequency
- Animation smoothness
- Layout shifts
- Font loading
- Data waterfall

Prefer measurement when a running app is available.

### `clarify`

Improve:

- Labels
- Placeholder misuse
- Error messages
- Empty states
- Button text
- Help text
- Onboarding instructions

Use specific, plain, action-oriented language.

### Visual direction modes

- `colorize`: add purposeful color and improve palette structure.
- `bolder`: increase contrast, scale, composition, and personality.
- `quieter`: reduce saturation, density, visual noise, and excessive emphasis.
- `distill`: remove nonessential elements and simplify decisions.
- `delight`: add humane, memorable moments without reducing clarity.
- `overdrive`: use ambitious effects only when the user explicitly wants high impact.

## Output rules

- For implementation tasks: edit the code directly when the target project is available.
- For critique/audit tasks: lead with findings and severity.
- For planning tasks: produce a concise brief and next steps.
- For ambiguous design direction: ask before making large aesthetic choices.
- Do not split the work across old UI skill names. This `ui` skill is the single entry point.
