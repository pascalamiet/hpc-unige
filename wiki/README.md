# LLM Wiki — Quick Start Guide

A persistent, LLM-maintained knowledge base that compounds as you add sources and ask questions.
The LLM writes everything; you read, direct, and source.

---

## Setup

```
/wiki-init
```

Creates `wiki/_raw_/`, `wiki/_schema_/`, `wiki/_wiki_/`, `index.md`, and `log.md`.
Patches `CLAUDE.md` with a read instruction for the schema.

---

## Key Operations

### Ingest a source

Drop a file into `wiki/_raw_/`, then:

```
Ingest wiki/_raw_/smith-2020.pdf
```

The LLM reads the source, discusses key takeaways, writes a `paper-` page, updates relevant
concept pages, and logs the ingest. A single source typically touches 5–15 wiki pages.

### Query the wiki

Just ask a question — no special syntax needed:

```
How does compound welfare regret differ from L2 loss?
What are the main applications we've identified?
Compare Kitagawa-Tetenov and Moon (2026).
```

The LLM reads `index.md` first, drills into relevant pages, and synthesizes an answer with
citations. Valuable answers (comparisons, analyses) can be filed back as new wiki pages:

```
File that comparison as a wiki page.
```

### Lint the wiki

```
Lint the wiki.
```

The LLM checks for: contradictions between pages, stale claims superseded by newer sources,
orphan pages with no inbound links, concepts mentioned but lacking their own page, missing
cross-references, and gaps suggesting new sources to find.

### Add a page manually

```
Create a concept page for the margin condition.
```

The LLM writes the page, cross-links it, and updates `index.md` and `log.md`.

### Update a page

```
Update the overview page — we've added a third application.
```

---

## File Layout

```
wiki/
├── _raw_/          ← drop source files here before ingesting
├── _schema_/
│   └── SCHEMA.md   ← edit this to customize page types, naming, workflows
├── _wiki_/         ← all LLM-generated pages live here
├── index.md        ← master catalog; read this to navigate the wiki
└── log.md          ← append-only history of ingests, queries, lints
```

---

## Tips

- **File good answers back.** A comparison or synthesis you asked for is valuable — don't
  let it disappear into chat history. Say "file that as a wiki page."
- **Lint periodically.** After every 5–10 ingests, run a lint pass to keep the wiki healthy.
- **Customize the schema early.** If your domain needs different page types (e.g. `entity-`
  pages for characters, `company-` pages for competitive analysis), edit `SCHEMA.md` before
  building up many pages — renaming later is tedious.
- **Obsidian works well** as a reader alongside Claude Code. Open `wiki/` as a vault to
  browse pages, follow links, and use the graph view to spot orphans.
- **The wiki is just markdown files.** It's in your git repo — you get version history,
  diffs, and branching for free.
