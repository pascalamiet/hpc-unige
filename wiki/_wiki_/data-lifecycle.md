---
title: Data Lifecycle
type: concept
tags: [data-management, lifecycle, archive, scratch, storage]
sources: [06_data_life_cycle.txt, 05_storate.txt, 09_best_practices.txt]
updated: 2026-04-16
---

# Data Lifecycle

The HPC clusters are **not long-term storage providers**. Each user is responsible for managing their data from generation to deletion. See [storage](storage.md) for technical storage details.

## Lifecycle stages

1. **Acquisition** — collect or generate data (external datasets, simulation inputs)
2. **Storage on HPC** — `$HOME` for code/scripts; `$HOME/scratch` for large working data
3. **Processing** — run [Slurm](slurm.md) jobs on compute nodes
4. **Usage** — analyze, iterate
5. **Disposal** — archive to permanent storage, delete from HPC cluster

**Key rule**: any data not needed for computation must be removed from the cluster.

## Where to store what

| Data type | Where |
|-----------|-------|
| Code, scripts, small configs | `$HOME` (backed up daily) |
| Large input datasets during jobs | `$HOME/scratch` (not backed up) |
| Very high-I/O temp files | local `/scratch` on compute node (deleted at job end) |
| Long-term project archives | NASAC or Yareta (off-cluster) |

## Auto-deletion policy (Baobab, rolling out to others)

- Scratch files **not accessed for 3 months** are automatically deleted
- Deletion is based on last access (read or write) date
- Frequently used files are not affected

## After your jobs: clean up

1. Copy important outputs from local `/scratch` (per-node) to `$HOME` or `$HOME/scratch` before the job ends
2. Migrate final results to permanent off-cluster storage
3. Delete intermediate files no longer needed from `$HOME/scratch`

## Permanent storage options

| Service | Details |
|---------|---------|
| [NAS academic (NASAC)](https://catalogue-si.unige.ch/stockage-recherche) | CIFS/NFS share, 75 CHF/TB/year |
| [Yareta](https://yareta.unige.ch) | Long-term preservation/archival |
| [Hedera](https://www.unige.ch/eresearch/fr/services/hedera/) | UNIGE research data service |

NASAC can be [mounted directly from the cluster](access.md).

## Data Management Plan (DMP)

UNIGE provides a DMP template: https://www.unige.ch/researchdata/fr/accueil/

From the Terms of Use:
> "The HPC clusters are not a long-term storage provider: users are requested to manage their files on a regular basis by deleting unneeded files and migrating results or valuable data to a permanent location such as Tape NASAC or Yareta."

## Departure from UNIGE

1. Back up and retrieve all personal data from `$HOME` and scratch
2. Clean directories (delete unneeded files)
3. If in a group: identify important shared data; request ownership transfer via HPC team
4. Confirm transfer completion

Expired accounts are eligible for deletion at any time. Prepare well in advance.

## Related pages

- [Storage](storage.md) · [Best Practices](best-practices.md) · [Access](access.md)
- [Overview](overview.md) · [Slurm](slurm.md)
