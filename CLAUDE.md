# CLAUDE.md

*Auto-maintained by /session-end. Read by /session-start.*

## Project Overview

Personal reference and knowledge base for using the UNIGE HPC clusters (Baobab, Yggdrasil, Bamboo). The repo has two layers: `guides/` holds generic, public how-to docs (SSH setup, file transfer); `wiki/` is an LLM-maintained wiki ingested from the official UNIGE HPC documentation. The wiki was seeded in one batch from 12 official docs and is meant to grow incrementally as new sources are dropped into `wiki/_raw_/`. Public GitHub repo: https://github.com/pascalamiet/hpc-unige.

## Project Structure

```
hpc-unige/
├── guides/
│   ├── ssh.md            — Generic SSH setup, key registration, config aliases, troubleshooting
│   └── file-transfer.md  — scp, rsync (flags, excludes, aliases), sftp, Windows, cross-cluster
├── wiki/
│   ├── _raw_/            — Source docs (12 official UNIGE HPC txt files, immutable)
│   ├── _schema_/
│   │   └── SCHEMA.md     — LLM wiki operating instructions (read before any wiki op)
│   ├── _wiki_/           — 11 LLM-generated pages (overview, entities, concepts)
│   ├── index.md          — Master catalog of all wiki pages
│   └── log.md            — Append-only ingest/query history
└── private-setup.md      — Personal setup notes (username, paths) — NOT in git
```

## Wiki

This project uses an LLM-maintained wiki at `wiki/`. **Before any wiki operation (ingest a source, answer a wiki query, lint the wiki), read `wiki/_schema_/SCHEMA.md` first.**

```
wiki/
├── _raw_/      — raw sources (PDFs, web clips, exported notes)
├── _schema_/   — SCHEMA.md: page conventions and workflows
├── _wiki_/     — all LLM-generated content pages
├── index.md    — master catalog
└── log.md      — append-only session log
```

Current pages (11): `overview`, `entity-baobab`, `entity-yggdrasil`, `entity-bamboo`, `slurm`, `storage`, `software-modules`, `cost-and-accounting`, `best-practices`, `access`, `data-lifecycle`.

## Conventions

- `guides/` is for **generic, public-safe** content — no usernames, no personal paths
- `private-setup.md` holds personal config (ISIS username, specific project paths, shell aliases) — keep out of git (add to `.gitignore`)
- Wiki sources go in `wiki/_raw_/`; never edit them — they are immutable references
- Wiki pages are LLM-written; always update `wiki/index.md` and prepend to `wiki/log.md` after any ingest
- Commit message style: imperative, one-line summary + optional body

## Active Todos

- [ ] Add `private-setup.md` to `.gitignore` (contains personal credentials/paths — currently untracked but not ignored)
- [ ] Stage and commit the deletion of `baobab.md` (was split into `guides/` + `private-setup.md`)
- [ ] Lint the wiki: check for orphan pages, missing cross-links, stale claims
- [ ] Add more sources to `wiki/_raw_/` as they become available (job scripts, cluster-specific tips)
- [ ] Consider adding a `guides/slurm-quickstart.md` — a practical cheat-sheet distilled from `wiki/_wiki_/slurm.md`

## Using Gemini CLI for Large Context Analysis

When analyzing large codebases or multiple files that might exceed context limits, use the Gemini CLI with its massive context window via `gemini -p`.

```bash
gemini -p "@wiki/_wiki_/ Summarize all wiki pages"
gemini -p "@wiki/_raw_/ What topics are not yet covered in the wiki?"
gemini --all_files -p "Analyze the project structure"
```

**Use `gemini -p` when:** analyzing entire wiki, comparing many pages, or finding coverage gaps.

## Session Log

### 2026-04-16 — Session 1 (init)

**Summary:** Created the repo from scratch. Initialized LLM wiki, ingested 12 official UNIGE HPC docs, built 11 wiki pages, split personal access guide into `guides/ssh.md` + `guides/file-transfer.md` + `private-setup.md`, initialized git and pushed to GitHub.

**Accomplished:**
- Wiki initialized and fully seeded from official docs
- `guides/ssh.md` and `guides/file-transfer.md` written (generic, public-safe)
- Git repo created and pushed to `pascalamiet/hpc-unige`

**Issues solved:**
- Filename typo `file-tranfer.md` → `file-transfer.md` fixed

**Todos added:**
- Gitignore `private-setup.md`, commit `baobab.md` deletion, wiki lint, more sources
