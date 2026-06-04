---
pattern: pairing
description: "Two specialists work in lockstep on the same scope — driver implements, navigator cross-checks in real time. Used when the change is high-stakes or crosses two lanes of expertise"
---

# Pairing Workflow

## When to Use

- The scope is high-stakes (auth, payments, PII, irreversible migrations, safety-critical paths).
- The change requires two disciplines to converge in real time (e.g., contract + implementation, threat model + auth code, test design + production code).
- A reviewer-implementer loop has already burned 2+ iterations on the same scope — the cost of pairing now is less than another round of `iterative-refinement`.
- A junior-class agent is paired with a senior-class agent to lift the floor on a known-risky change.

Do **not** pair when two specialists could work in parallel without dependency — that is `fan-out`, not pairing.

## Topology

```
driver ◄──cross-check──► navigator
   │
   └──► single TEAM_HANDOFF (joint authorship)
```

The driver owns the keyboard (the writes). The navigator owns the lens (the catches). They produce **one** joint output, not two.

## Canonical Pairings

| Change type | Driver | Navigator |
|---|---|---|
| New external API contract | `architect` | `developer` |
| Auth or authz code | `developer` | `security-engineer` |
| Critical-path test coverage | `test-engineer` | `qa-analyst` |
| Risky data migration | `developer` | `devops-engineer` |
| RAG retrieval changes | `data-scientist` | `developer` |
| Rewrite of a debugged hot path | `debugger` | `developer` |

## Data-Flow Contract

The Tech Lead dispatches a single `MISSION` with two `ROLE`s:

```text
MISSION:
  PAIRING:
    DRIVER: <role>
    NAVIGATOR: <role>
  TASK: ...
  DONE_WHEN: ...
  ...
```

The pair returns a single joint `TEAM_HANDOFF` with both names in the authorship and a `NAVIGATOR_NOTES` block:

```text
TEAM_HANDOFF:
  STATUS: ...
  AUTHORS: <driver>, <navigator>
  CHANGED_FILES: ...
  NAVIGATOR_NOTES:
    - <issue caught and resolved during pairing>
    - <issue caught and accepted with rationale>
  VALIDATION: ...
  NEXT_OWNER: ...
```

## Rules

- The navigator does not write code or own files independently — that would split authorship and re-create the review loop.
- The navigator MUST surface concerns inline (in `NAVIGATOR_NOTES`). Silent agreement defeats the purpose of pairing.
- If the pair cannot agree on a material decision, escalate per the conflict-resolution protocol in `instructions/team-collaboration.instructions.md` — do not silently default to the driver's preference.
- A pairing dispatch replaces a subsequent code-review dispatch for the same scope. The navigator's notes are the review.

## Canonical Example

1. Tech Lead determines the OAuth token-exchange code is high-stakes and the developer alone has burned 2 review iterations on missing edge cases.
2. Tech Lead dispatches pairing with `DRIVER: developer`, `NAVIGATOR: security-engineer`.
3. Developer writes the implementation; Security-engineer flags two missing edge cases inline (rotation race, missing `aud` check).
4. Pair returns one joint `TEAM_HANDOFF` with `AUTHORS: developer, security-engineer` and `NAVIGATOR_NOTES` documenting the two catches.
5. Tech Lead records the pairing in `TEAM_STATE.DECISIONS` and proceeds to the production gate without a separate review dispatch.

## Anti-Patterns

- Two roles working independently and calling it pairing. Pairing requires lockstep authorship.
- Defaulting to pairing for ordinary work — the cost is roughly 2x. Use it only when the risk justifies it.
- Skipping `NAVIGATOR_NOTES` — without that the pairing is invisible to the audit trail.
- Treating the navigator as a passive observer. If they have nothing to add, they should not have been invited.
