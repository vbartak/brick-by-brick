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

## When the user signals something is done
Phrases like "works", "done", "moving on", "onto the next", "it's working": check open decisions for any that map to what just finished. Ask once: "It looks like [D-NNN] might be resolved — should I close it?" Only ask if there's a clear match.

## When the user contradicts a recorded assumption
Phrases like "turns out X doesn't work", "X is slower than expected", "we can't do Y": match against assumption text in open decisions. If matched, ask: "This sounds like it contradicts the assumption '[text]' in D-NNN — should I mark it as challenged?"

<!-- brick-by-brick:end -->
