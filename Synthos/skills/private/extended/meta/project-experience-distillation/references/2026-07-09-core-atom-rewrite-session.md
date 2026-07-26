# 2026-07-09: Core Atom Rewrite Session

## Context

Synthos core cognitive atoms (skills/core/) were template shells: ~100L each, containing only placeholder Operational Steps and empty Verification checklists. The atoms had good reference files (BOUNDARY.md, EVIDENCE_SCHEMA.md, IO_CONTRACT.md) but the SKILL.md body was useless for execution.

## What Was Done

4 atoms rewritten from scratch (102→~310L each):

| Atom | Before | After | Method |
|:-----|:------:|:-----:|:-------|
| knowledge-extraction | 102L shell | 301L | 4-domain schema, pwbench mode, 6-dim rubric |
| association-discovery | 102L shell | 301L | 7 relation types, cross-domain, confidence scoring |
| argument-expression | 103L shell | ~310L | Toulmin 6-element, CARS 3-move, Hyland rhetoric |
| viewpoint-verification | 106L shell | ~330L | Popper falsification, Bayesian update, robustness |

5 overlapping skills consolidated to redirect stubs:
- knowledge-acquisition → literature (ACQ is now "call literature.py")
- paper-pipeline → literature (literature.py pipeline already covers it)
- proactive-discovery → literature + evolution (empty shell)
- personal-knowledge → literature + AKNE (empty shell)
- daily-routine → cron + daily-briefing (empty shell)

## Template Shell → Full Skill Pattern

### Detection

A SKILL.md is a template shell when BOTH conditions hold:
1. `## Operational Steps` contains "确认输入参数完整" (Chinese template text)
2. `## Verification` contains the numbered empty stub `1. \n2. \n3.`

### Rewrite Pattern

1. **Research the domain**: Before writing, understand the actual methodology (Toulmin, Bayesian, Popper, CARS, etc.)
2. **Four-layer structure**: frontmatter → 原理层·文言 → 方法层·白话 → Step-by-step
3. **Concrete steps**: Replace "1. Do something" with detailed subsections and code blocks
4. **Real pitfalls**: 7+ pitfalls extracted from operational experience, not hypothetical
5. **Complete IO contract**: Every input/output field with types, defaults, and JSON schema
6. **Verification checklist**: Real checkable items, not numbered stubs

### Overlap Detection for Consolidation

When scanning for consolidation candidates:
1. **Same responsibility chain**: If skill A's only instruction is "call skill B's script", A should redirect to B
2. **Empty shells**: If a skill has only template text and no scripts/references, it's a candidate for deletion or redirect
3. **Absorbed functionality**: If script B's pipeline covers what skill A described, A should redirect

## Evolution Impact

- structural: 0.6664 → 1.0000 (YAML frontmatter fix)
- overall: 0.9032 → 0.9926
- 315 lines of template boilerplate removed from redirect skills
- 824 lines of substantive content added to 4 atoms
