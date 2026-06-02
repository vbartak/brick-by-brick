# brick-by-brick

A Claude Code skill for tracking architectural decisions as a living document. Log which paths were taken and why, trace failures back to broken assumptions, and understand the blast radius before changing your mind.

## How it works

Decisions live in `decisions.json` at your project root. Each entry records the question, options considered, the choice made, the assumptions that make it valid, and which parts of the codebase it affects. When something breaks, you find the assumption that failed. When a feature ships, you close the decisions it validated.

## Install

**Into a specific project:**
```bash
git clone <this-repo>
cd brick-by-brick
./install.sh /path/to/your/project
```

**Globally (all projects):**
```bash
./install.sh --global
```

Global install activates the skill for every Claude Code session. `decisions.json` is still created per-project when you run `/adr init`.

## Usage

| Command | What it does |
|---|---|
| `/adr init` | Scan the project, propose up to 5 decisions to seed `decisions.json` |
| `/adr log` | Interactively log a new decision |
| `/adr challenge D-001` | Mark a decision as challenged, identify the broken assumption, cascade impact |
| `/adr close D-001` | Close a decision after the feature ships and assumptions are validated |
| `/adr status` | Show all open, decided, and challenged decisions |

Claude also prompts passively — when it detects you choosing between approaches it will offer to log the decision, and after a feature ships it will ask if any open decisions can be closed.

## Decision lifecycle

```
proposed → decided → open → closed
                  ↘ challenged → (superseded by new decision)
```

- **proposed** — question raised, not yet resolved
- **decided** — choice made, implementation not started
- **open** — implementation underway, assumptions unvalidated
- **challenged** — an assumption broke or new information arrived
- **superseded** — replaced by a newer decision
- **closed** — stable, implementation worked, assumptions validated

## Schema

See [`schema/decisions.example.json`](schema/decisions.example.json) for a realistic example covering all statuses, assumption invalidation, and cross-decision references.

## License

MIT
