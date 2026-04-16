---
title: UNIGE HPC Overview
type: overview
tags: [hpc, unige, baobab, yggdrasil, bamboo, slurm]
sources: [00_getting_started.txt, 02_how_cluster_works.txt]
updated: 2026-04-16
---

# UNIGE HPC Overview

The University of Geneva operates three HPC clusters: [Baobab](entity-baobab.md), [Yggdrasil](entity-yggdrasil.md), and [Bamboo](entity-bamboo.md). They are **completely separate** entities with their own storage, network, and login nodes. Accounting (user accounts, job usage) is shared.

## Quick cluster comparison

| Cluster   | Location       | Public CPU | Public GPU | Total CPU | Total GPU |
|-----------|---------------|------------|------------|-----------|-----------|
| Baobab    | Uni Dufour     | ~900       | 0          | ~13,044   | 273       |
| Yggdrasil | Astro/Sauverny | ~3,000     | 44         | ~8,008    | 52        |
| Bamboo    | Campus Biotech | ~5,700     | 20         | ~5,700    | 20        |

All three use 100 Gbit/s InfiniBand EDR interconnect and run Rocky Linux 9.

## Architecture

Each cluster has:
- **Login node** (headnode): user entry point; limited to 2 CPU cores and 8 GB RAM per user — do NOT run compute jobs here
- **Compute nodes**: heterogeneous mix of CPU-only and GPU nodes (8–192 cores per node)
- **Management servers**: handled by the HPC team
- **BeeGFS storage**: shared parallel filesystem for `$HOME` and `$HOME/scratch`

## Typical workflow

1. SSH to the login node
2. Manage files in `$HOME`
3. Load software with `module load`
4. Write an sbatch script and submit with `sbatch`
5. [Slurm](slurm.md) queues the job and runs it on a compute node
6. Retrieve results from `$HOME`

## Key principle: always use Slurm

You never run programs directly on the login node. Everything goes through [Slurm](slurm.md). Use the `debug-cpu` or `debug-gpu` partition for tests.

## Choosing a cluster

- Stick to one cluster — data is not shared between clusters
- Use the cluster where your private partition is located (if any)
- If you need GPU resources, Yggdrasil and Bamboo have public GPUs; Baobab GPUs are private only
- For teaching use Baobab (OpenOnDemand available)

## Support

- Documentation: https://doc.eresearch.unige.ch/hpc/start
- Account request: https://catalogue-si.unige.ch/en/hpc
- Contact: hpc@unige.ch
- Community forum: https://hpc-community.unige.ch
- Monitoring: https://monitor.hpc.unige.ch/dashboards

## Related pages

- [Baobab](entity-baobab.md) · [Yggdrasil](entity-yggdrasil.md) · [Bamboo](entity-bamboo.md)
- [Slurm](slurm.md) · [Storage](storage.md) · [Software Modules](software-modules.md)
- [Cost and Accounting](cost-and-accounting.md) · [Best Practices](best-practices.md) · [Access](access.md)
