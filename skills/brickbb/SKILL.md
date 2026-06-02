# Skill: brickbb (brick-by-brick)

**Trigger:** User types `/brickbb [command]`, or during normal coding when Claude detects an architectural decision point.

---

## Decision file

All decisions live in `decisions.json` at the project root. Schema version: `"1"`.
If the file does not exist, prompt the user to run `/brickbb init`.

---

## Commands

### /brickbb init

1. If `decisions.json` already exists, refuse to overwrite — tell the user to use `/brickbb log` instead.
2. Scan the current conversation from the beginning. Extract every decision that was actually made: choices between approaches, technology selections, architectural tradeoffs, rejected alternatives with reasons. Focus on decisions with real consequences — not trivial details.
3. For each extracted decision, draft a full entry: question, options considered (including rejected ones with rejection reasons), chosen option, assumptions that must hold, affected areas, and estimated `change_cost`. Pull the reasoning directly from what was said in the conversation — do not invent it.
4. Present all drafts at once. For each, ask: confirm, skip, or edit.
5. Write `decisions.json` with confirmed entries, IDs starting at `D-001`.
6. Do NOT scan git history. Do NOT infer decisions from file structure — only from what was explicitly discussed.

### /brickbb log

Guide the user through logging a new decision interactively:

1. Ask for the decision **question** (must be phrased as a question).
2. Ask what **options** were considered. Require at least one (the chosen option). For rejected options, ask for a `rejection_reason`.
3. Ask what **assumptions** must hold for this decision to be correct. Propose 1-3 drafts based on context if you can. New assumptions default to `status: "unvalidated"`.
4. Ask which **parts of the codebase** are affected (`affects`). Infer from context if possible; ask user to confirm.
5. Ask: has implementation already started? If yes, set `status: "open"`. If no, set `status: "decided"`.
6. Assign the next sequential `D-NNN` ID.
7. Append to `decisions.json`. Show the new entry before writing and ask for confirmation.

### /brickbb challenge <D-ID>

1. Load the specified decision.
2. Ask the user: what happened? Which assumption broke, or what new information arrived?
3. Set `status` to `"challenged"`.
4. In `notes`, append a timestamped entry describing what was challenged and why.
5. Mark the specific assumption as `"invalidated"`. Set `invalidated_by` to the D-ID of any decision that caused this (or `null` if no prior decision is responsible — capture the explanation in the assumption's `note` field instead).
6. **Impact cascade:** scan all other decisions. Flag to the user any decision that:
   - lists this decision in `informed_by`
   - shares an affected `scope` with tight or medium coupling
   Do not auto-update them — surface them for human review.
7. Ask whether a new decision should be proposed to replace this one. If yes, start `/brickbb log` flow with `triggered_by` pre-filled.

### /brickbb close <D-ID>

1. Load the specified decision.
2. Confirm with the user: is the feature working? Are the assumptions holding?
3. For each `unvalidated` assumption, ask: validated or still unvalidated?
4. Set `status` to `"closed"`. Set validated assumptions to `status: "validated"`.
5. Update `notes` with a brief closing note (what confirmed the decision was correct).
6. Write the updated entry.

### /brickbb status

Print a concise summary grouped by status:

- **challenged**: ID, question, what was challenged (from notes)
- **open**: ID, question, how many unvalidated assumptions, `change_cost`
- **decided**: ID, question, `change_cost`
- **proposed**: ID, question

Do not print `closed` or `superseded` unless the user asks with `/brickbb status --all`.

---

## Passive behavior (during normal coding)

### Logging new decisions
Propose logging a decision when:
- The user says "let's go with X", "I decided to use X", or "we'll use X instead".
- The user chooses between two non-trivial implementation approaches.

Do NOT propose for: trivial naming choices, file organization that has one obvious answer, pure style preferences.

When proposing: say "This looks like a decision worth logging — want me to add it to `decisions.json`?" then wait for confirmation before doing anything.

### Detecting close opportunities
When the user signals that a piece of work is done — phrases like "works", "that's it", "moving on", "onto the next", "done", "it's working", "let's continue with" — scan open decisions and check if any clearly maps to what just finished. If yes, ask once: "It looks like [D-NNN: question] might be resolved — should I mark it as closed?" Do not ask about decisions that are clearly unrelated to what just shipped.

### Detecting challenged decisions
Propose challenging a decision when the user says something that directly contradicts a recorded assumption — e.g. "turns out X doesn't work", "X is actually slower than we thought", "we can't do Y after all". Match the contradiction against `assumptions` text in open decisions. If a match is found, ask: "This sounds like it contradicts the assumption '[text]' in D-NNN — should I mark it as challenged?" Do not trigger on general frustration or confusion alone.

---

## Field rules

- `id`: `D-NNN`, sequential, never reuse.
- `status`: `proposed | decided | open | challenged | superseded | closed`
- `decided_at`: ISO date (YYYY-MM-DD) of when the choice was made.
- `assumptions[].status`: `unvalidated | validated | invalidated`
  - All new assumptions default to `unvalidated`.
- `affects[].coupling`: `tight` (must change if decision changes) | `medium` (likely needs updates) | `loose` (minor adjustments possible)
- `impact_scope`: `local | subsystem | api_boundary | system_wide`
- `change_cost`: `trivial | low | medium | high | critical`
- `notes`: free-form text. Append; never delete prior content.

---

## Conflict and cascade rules

- If an assumption is invalidated, always scan for other decisions that share the same assumption text or depend on the same scope. Surface matches to the user.
- If a decision is `superseded`, set `superseded_by` on the old entry and `triggered_by` on the new one.
- Never silently update a decision's `status` to `superseded` or `closed` without user confirmation.
- Never delete a decision entry. History is permanent.

---

## Output style

- Always show the JSON diff or new entry before writing it. Ask for confirmation on destructive or status-changing operations.
- Keep explanations short. The user is a developer, not a stakeholder.
- When summarizing, use a table or bullet list — not paragraphs.
