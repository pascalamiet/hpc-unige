# Wiki Log — hpc-unige

Append-only. Most recent entry first.
Format: `## [YYYY-MM-DD] <operation> | <description>`

---

## [2026-04-16] lint | Wiki lint — 4 fixes, 1 flag

Missing cross-links fixed:
- slurm.md → added Software Modules + Access to related pages
- overview.md → added rsync + Data Lifecycle to related pages
- storage.md → added access/rsync links in External storage section

Stale claim fixed:
- software-modules.md → virtualenv example used GCC/14.3.0 (not in toolchain table);
  replaced with a version-agnostic example and a note to use `module spider`.

Gap filled:
- best-practices.md → added `public-longrun-cpu` (14-day, max 2 cores) to partition guidance.

Remaining gap (not fixed — needs new source):
- entity-bamboo.md mentions EOS filesystem with no explanation or external link.

---

## [2026-04-16] ingest | Ingest of 4 rsync source files → 1 new page + cross-links in 4 pages

Sources: rsync_manpage.html (rsync(1) v3.4.1), rsync-ssl_manpage.html, rsyncd-conf_manpage.html,
rsync-tutorial.html (frameset only — no ingestible content).

Pages created: rsync (1 page).
Pages updated: access (rsync link + related pages), data-lifecycle (rsync migration link),
best-practices (rsync link in storage discipline + related pages).

---

## [2026-04-16] ingest | Batch ingest of 12 official UNIGE HPC documentation files

Ingested: 00_getting_started.txt, 01_linux.txt, 02_how_cluster_works.txt, 03_access_cluster.txt,
04_applications_and_libraries.txt, 05_storate.txt, 06_data_life_cycle.txt, 07_slurm.txt,
08_utilization_and_accounting.txt, 09_best_practices.txt, 10_contact.txt, 11_faq.txt.

Pages created: overview, entity-baobab, entity-yggdrasil, entity-bamboo, slurm, storage,
software-modules, cost-and-accounting, best-practices, access, data-lifecycle (11 pages).

---

## [2026-04-16] init | Wiki initialized

Created wiki structure: `_raw_/`, `_schema_/`, `_wiki_/`, `index.md`, `log.md`.
No pages yet. Drop sources into `_raw_/` and run an ingest to get started.
