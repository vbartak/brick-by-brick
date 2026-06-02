#!/usr/bin/env bash
# install.sh — Install the brick-by-brick skill.
# Usage:
#   ./install.sh --global              Install to ~/.claude/ (all projects)
#   ./install.sh [target-project-path] Install into a specific project
#   ./install.sh                       Install into current directory
# Safe to run multiple times (idempotent).

set -e

# ── Paths ──────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GLOBAL=false
if [ "${1}" = "--global" ]; then
  GLOBAL=true
  TARGET="${HOME}/.claude"
elif [ -n "${1}" ]; then
  TARGET="$(cd "${1}" && pwd)"
else
  TARGET="$(pwd)"
fi

SKILL_SRC="${SCRIPT_DIR}/skills/brickbb/SKILL.md"
CLAUDE_MD_SRC="${SCRIPT_DIR}/CLAUDE.md"
TEMPLATE_SRC="${SCRIPT_DIR}/schema/decisions.template.json"

if [ "${GLOBAL}" = true ]; then
  SKILL_DST="${TARGET}/skills/brickbb/SKILL.md"
  CLAUDE_MD_DST="${TARGET}/CLAUDE.md"
  DECISIONS_DST=""  # not created globally — decisions.json is always per-project
else
  SKILL_DST="${TARGET}/.claude/skills/brickbb/SKILL.md"
  CLAUDE_MD_DST="${TARGET}/CLAUDE.md"
  DECISIONS_DST="${TARGET}/decisions.json"
fi

IDEMPOTENCY_MARKER="brick-by-brick:begin"

# ── Validation ─────────────────────────────────────────────────────────────────

if [ "${GLOBAL}" = false ] && [ ! -d "${TARGET}" ]; then
  echo "ERROR: Target path does not exist: ${TARGET}" >&2
  exit 1
fi

if [ "${TARGET}" = "${SCRIPT_DIR}" ]; then
  echo "ERROR: Do not install into the brick-by-brick repo itself." >&2
  echo "       Use --global or pass a different target path." >&2
  exit 1
fi

if [ ! -f "${SKILL_SRC}" ]; then
  echo "ERROR: Skill source not found: ${SKILL_SRC}" >&2
  echo "       Make sure you are running this script from the brick-by-brick repo." >&2
  exit 1
fi

if [ ! -f "${CLAUDE_MD_SRC}" ]; then
  echo "ERROR: CLAUDE.md source not found: ${CLAUDE_MD_SRC}" >&2
  exit 1
fi

if [ ! -f "${TEMPLATE_SRC}" ]; then
  echo "ERROR: Template not found: ${TEMPLATE_SRC}" >&2
  exit 1
fi

if [ "${GLOBAL}" = true ]; then
  echo "Installing brick-by-brick globally into: ${TARGET}"
  echo "decisions.json will be created per-project when you run /brickbb init."
else
  echo "Installing brick-by-brick into: ${TARGET}"
fi
echo

# ── Step 1: Copy skill file ────────────────────────────────────────────────────

mkdir -p "$(dirname "${SKILL_DST}")"

if [ -f "${SKILL_DST}" ] && cmp -s "${SKILL_SRC}" "${SKILL_DST}"; then
  echo "[skip] Skill already up to date: ${SKILL_DST}"
else
  cp "${SKILL_SRC}" "${SKILL_DST}"
  echo "[ok]   Skill installed: ${SKILL_DST}"
fi

# ── Step 2: Append CLAUDE.md content (idempotent via embedded markers) ─────────
# CLAUDE.md already contains <!-- brick-by-brick:begin/end --> markers.
# Just cat it. Check for the marker before appending.

if [ -f "${CLAUDE_MD_DST}" ] && grep -qF "${IDEMPOTENCY_MARKER}" "${CLAUDE_MD_DST}"; then
  echo "[skip] CLAUDE.md already contains brick-by-brick block: ${CLAUDE_MD_DST}"
else
  echo "" >> "${CLAUDE_MD_DST}"
  cat "${CLAUDE_MD_SRC}" >> "${CLAUDE_MD_DST}"
  echo "[ok]   CLAUDE.md updated: ${CLAUDE_MD_DST}"
fi

# ── Step 3: Create decisions.json if absent (project installs only) ───────────

if [ "${GLOBAL}" = false ]; then
  if [ -f "${DECISIONS_DST}" ]; then
    echo "[skip] decisions.json already exists: ${DECISIONS_DST}"
  else
    cp "${TEMPLATE_SRC}" "${DECISIONS_DST}"
    echo "[ok]   decisions.json created: ${DECISIONS_DST}"
  fi
fi

echo
if [ "${GLOBAL}" = true ]; then
  echo "Done. brick-by-brick is now active in all projects."
  echo "Open any project in Claude Code and run /brickbb init to start tracking decisions."
else
  echo "Done. Open the project in Claude Code and run /brickbb init to log your first decisions."
fi
