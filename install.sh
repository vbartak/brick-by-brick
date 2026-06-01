#!/usr/bin/env bash
# install.sh — Install the brick-by-brick skill into a target project.
# Usage: ./install.sh [target-project-path]
# Default target: current working directory (where the user runs this from).
# Safe to run multiple times (idempotent).

set -e

# ── Paths ──────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$(cd "${1:-$(pwd)}" && pwd)"

SKILL_SRC="${SCRIPT_DIR}/skills/adr-track/SKILL.md"
CLAUDE_MD_SRC="${SCRIPT_DIR}/CLAUDE.md"
TEMPLATE_SRC="${SCRIPT_DIR}/schema/decisions.template.json"

SKILL_DST="${TARGET}/.claude/skills/adr-track/SKILL.md"
CLAUDE_MD_DST="${TARGET}/CLAUDE.md"
DECISIONS_DST="${TARGET}/decisions.json"

IDEMPOTENCY_MARKER="brick-by-brick:begin"

# ── Validation ─────────────────────────────────────────────────────────────────

if [ ! -d "${TARGET}" ]; then
  echo "ERROR: Target path does not exist: ${TARGET}" >&2
  exit 1
fi

if [ "${TARGET}" = "${SCRIPT_DIR}" ]; then
  echo "ERROR: Do not install into the brick-by-brick repo itself." >&2
  echo "       Run this from your project directory: ./install.sh /path/to/your/project" >&2
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

echo "Installing brick-by-brick into: ${TARGET}"
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

# ── Step 3: Create decisions.json if absent ────────────────────────────────────

if [ -f "${DECISIONS_DST}" ]; then
  echo "[skip] decisions.json already exists: ${DECISIONS_DST}"
else
  cp "${TEMPLATE_SRC}" "${DECISIONS_DST}"
  echo "[ok]   decisions.json created: ${DECISIONS_DST}"
fi

echo
echo "Done. Open the project in Claude Code and run /adr init to log your first decisions."
