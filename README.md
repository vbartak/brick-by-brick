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

Global install activates the skill for every Claude Code session. `decisions.json` is still created per-project when you run `/brickbb init`.

## Usage

| Command | What it does |
|---|---|
| `/brickbb init` | Extract decisions from conversations and seed `decisions.json` (see options below) |
| `/brickbb log` | Manually log a new decision |
| `/brickbb challenge D-001` | Mark a decision as challenged (escape hatch — normally triggered automatically) |
| `/brickbb close D-001` | Close a decision (escape hatch — normally triggered automatically) |
| `/brickbb status` | Show all open, decided, and challenged decisions |

**`/brickbb init` options** (default: current conversation + up to 2 most recent within last 7 days):
```
/brickbb init                  # default
/brickbb init --last 5         # current + 5 most recent conversations
/brickbb init --days 30        # current + all conversations within last 30 days
```
Scanning beyond the default will prompt a token cost warning before proceeding.

Most interaction is passive — Claude watches the conversation and acts without being called:

- **New decision detected** — when you choose between approaches, Claude offers to log it
- **Close detected** — when you say "works", "done", "moving on" etc., Claude checks if any open decision maps to what just finished and asks to close it
- **Challenge detected** — when you say something that contradicts a recorded assumption, Claude flags the decision and asks to mark it challenged

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
