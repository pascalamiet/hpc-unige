---
title: Best Practices
type: concept
tags: [best-practices, etiquette, resources, slurm, efficiency]
sources: [09_best_practices.txt, 00_getting_started.txt]
updated: 2026-04-16
---

# Best Practices

Rules and tips for being a good citizen on the UNIGE HPC clusters. See [overview](overview.md) for the big picture and [slurm](slurm.md) for job submission details.

## Rules (non-negotiable)

1. **Never run compute jobs on the login node.** This disturbs all users. Even small tests must go through [Slurm](slurm.md). Use `debug-cpu` or `debug-gpu` for tests. Violations result in process kill + email.

2. **Use `module` to load software.** Never hardcode paths. Pin version for reproducibility.

3. **No `sudo`, no `yum`/`apt-get`.** You are not root. Contact hpc@unige.ch to request software installs.

4. **Do not run code on the login node** — this applies to tests, compilation output, anything that uses significant CPU.

## Resource efficiency

### Choose the right partition

- Short jobs (<12h): `shared-cpu` — has more nodes, shorter wait
- Long jobs (12h–4 days): `public-cpu`
- Up to 7 days: need private partition
- See the full [partition table in Slurm](slurm.md)

### Estimate resources accurately

**CPU**: Request only as many cores as your job actually uses. A single-threaded job requesting 32 cores wastes 31 cores. Check job type: [single-threaded vs multi-threaded vs distributed](slurm.md).

**Memory**: Default is 3 GB/core. Over-requesting RAM prevents other jobs from using those cores. Check actual usage with:
```bash
sstat --format=MaxRSS -j <jobid>
sacct --format=MaxRSS,ReqMem --units=G -j <jobid>
```

**Time**: A 4-day time limit when your job finishes in 30 min blocks backfill scheduling for everyone. Accurate estimates help Slurm fill gaps better. `seff <jobid>` shows efficiency after the fact.

### Job arrays for parameter sweeps

Use `sbatch --array=1-100` instead of submitting 100 individual jobs. Limit concurrent tasks with `%N` (e.g. `--array=1-100%10`).

### Checkpointing for long jobs

If your software supports checkpointing:
- Run multiple 12h jobs instead of one 4-day job → shorter wait times, more backfill opportunities
- Save intermediate state files; restart uses them

## Storage discipline

- Store **only research data** on the clusters — no personal files, emails, etc.
- Clean up regularly — `$HOME/scratch` files older than 3 months are auto-deleted on Baobab
- Move outputs to permanent storage ([NASAC](storage.md), [Yareta](storage.md)) when done
- Avoid directories with >1,000 files — hurts BeeGFS metadata performance
- Do NOT run `find`, `ncdu`, `du` on the shared filesystem — it can slow down the entire cluster for everyone
- See [storage](storage.md) and [data-lifecycle](data-lifecycle.md) for full guidance

## I/O tips

- Prefer local `/scratch` (per-node) for high-frequency temp file I/O — no network overhead
- Work with larger files (1 MB+ instead of many tiny files)
- Cache files you read repeatedly

## Environment and reproducibility

```bash
# Good: pin versions
module load foss/2023a R/4.3.2

# Bad: let versions float (can break silently after system updates)
module load R
```

For custom dependencies, build a [container](software-modules.md) rather than polluting scratch with thousands of conda files.

## Departure checklist

When leaving UNIGE:
1. Retrieve personal data from `$HOME` and scratch
2. Delete unneeded files
3. If in a group: identify important shared data and arrange ownership transfer
4. Contact hpc@unige.ch for account deactivation

## Think green

The clusters consume ~80 kW each (not counting AC). Wasting resources = wasting electricity. Don't allocate resources you won't use. Delete outdated large files. This is an environment issue, not just a politeness issue.

## Quick checklist before submitting a job

- [ ] What job type? (single/multi/distributed) → choose `--ntasks` vs `--cpus-per-task`
- [ ] Which partition? (see [partition table](slurm.md))
- [ ] How much memory? (default 3 GB/core; use `--mem-per-cpu` or `--mem`)
- [ ] How long? (estimate carefully — not the partition maximum)
- [ ] Email notifications? (`--mail-type=END,FAIL --mail-user=your@email.ch`)
- [ ] Module loads correct version?
- [ ] Outputs going to `$HOME` or scratch (not local `/scratch` which is deleted)?

## Related pages

- [Slurm](slurm.md) · [Storage](storage.md) · [Data Lifecycle](data-lifecycle.md)
- [Software Modules](software-modules.md) · [Cost and Accounting](cost-and-accounting.md) · [Overview](overview.md)
