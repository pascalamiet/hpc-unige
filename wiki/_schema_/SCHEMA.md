# Wiki Schema — hpc-unige

This file governs how the LLM maintains the wiki. Read it before any wiki operation.

## Purpose

A persistent, LLM-maintained knowledge base for hpc-unige. The LLM writes and maintains
all pages in `_wiki_/`. The researcher reads, directs, and sources.

## Directory Layout

```
wiki/
├── _raw_/      — raw sources (PDFs, web clips, exported notes)
├── _schema_/   — this file; wiki conventions
├── _wiki_/     — all LLM-generated content pages
├── index.md    — master catalog (wiki root)
└── log.md      — append-only session log (wiki root)
```

---

## Page Types

| Type | Prefix | Purpose |
|---|---|---|
| Overview | *(none)* | High-level project synthesis |
| Concept | *(none)* | A theoretical concept, method, or term |
| Paper | `paper-` | Summary and notes on a single source |
| Entity | `entity-` | A person, place, organization, or named thing |
| Comparison | `comparison-` | Side-by-side analysis of related items |
| Index | `index` | Master catalog — special file, see below |
| Log | `log` | Append-only history — special file, see below |

---

## Frontmatter

Every wiki page except `index.md` and `log.md` must begin with:

```yaml
---
title: <human-readable title>
type: <overview | concept | paper | entity | comparison>
tags: [tag1, tag2]
sources: [author-year, ...]   # paper keys or _raw_ filenames
updated: YYYY-MM-DD
---
```

---

## Naming Conventions

- Lowercase, hyphen-separated: `my-concept.md`
- Paper pages: `paper-<firstauthor>-<year>.md` — e.g. `paper-smith-2020.md`
- Entity pages: `entity-<name>.md` — e.g. `entity-john-smith.md`

---

## Cross-Linking

- Use standard markdown links: `[My Concept](my-concept.md)` within `_wiki_/`
- From `index.md` (wiki root), prefix links with `_wiki_/`: `[My Concept](_wiki_/my-concept.md)`
- Every page must link to at least one other page
- On first mention of a concept within a document, link to its page

---

## index.md (wiki root)

Master catalog of all pages, organized by category. Links use `_wiki_/` prefix. Format:

```markdown
## Overviews
- [Project Overview](_wiki_/overview.md) — one-line summary

## Concepts
- [My Concept](_wiki_/my-concept.md) — one-line summary

## Papers
- [Smith (2020)](_wiki_/paper-smith-2020.md) — one-line summary
```

Update `wiki/index.md` whenever a new page is created or an existing page's scope changes.
When answering a query, read `wiki/index.md` first to find relevant pages.

---

## log.md (wiki root)

Append-only. Add new entries at the **top** (most recent first):

```
## [YYYY-MM-DD] <operation> | <description>
```

Operations: `init`, `ingest`, `query`, `lint`, `update`

---

## Workflows

### Ingest a new source
1. Read the source (PDF or markdown from `wiki/_raw_/`)
2. Discuss key takeaways with the researcher
3. Write a content page in `wiki/_wiki_/`
4. Update relevant concept and entity pages (cross-references, contradictions, new claims)
5. Add entry to `wiki/index.md`
6. Prepend entry to `wiki/log.md`

### Answer a query
1. Read `wiki/index.md` to find relevant pages
2. Read those pages
3. Synthesize an answer with citations to wiki pages
4. If the answer is a valuable analysis or comparison, file it as a new page in `wiki/_wiki_/`

### Lint the wiki
Check for:
- Contradictions between pages
- Stale claims superseded by more recently ingested sources
- Orphan pages (no inbound links from other pages)
- Important concepts mentioned but lacking their own page
- Missing cross-references
- Gaps that suggest new sources to find
