<!-- brick-by-brick:begin -->

# brick-by-brick: Architecture Decision Tracking

## Session start
If `decisions.json` exists in this project, read it and briefly report:
"N open decisions" (or "no open decisions"). Nothing more unless asked.

## During work — when to propose a new decision
Propose logging a decision when:
- The user chooses between two non-trivial approaches ("let's go with X over Y")
- A concrete technology, pattern, or architectural choice is being made
- A tradeoff is being made that will shape future code

Do NOT log: trivial implementation details, style choices, obvious file organization.

Say: "This looks like a meaningful decision — should I log it in decisions.json?"
If yes, run `/brickbb log` or propose a draft entry.

## When stuck or something breaks
Check `decisions.json` for assumptions with status `unvalidated`.
Say: "The assumption '[text]' in D-NNN might explain this — should we mark it invalidated?"
If yes, run `/brickbb challenge`.

## When a feature ships
Ask once: "D-NNN is still open — should we close it or validate any of its assumptions?"
Do not ask for every decision, only the ones clearly related to what just shipped.

<!-- brick-by-brick:end -->
