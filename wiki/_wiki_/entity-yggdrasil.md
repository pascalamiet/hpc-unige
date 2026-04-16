---
title: Yggdrasil Cluster
type: entity
tags: [cluster, yggdrasil, hardware, gpu, cpu]
sources: [02_how_cluster_works.txt, 03_access_cluster.txt]
updated: 2026-04-16
---

# Yggdrasil Cluster

Yggdrasil is one of three UNIGE HPC clusters. See the [overview](overview.md) for context.

## Location and specs

- **Datacenter**: Observatory of Geneva, Sauverny (Astro)
- **Interconnect**: InfiniBand 100 Gbit/s EDR
- **Public CPU cores**: ~3,000
- **Total CPU cores**: ~8,008
- **Total GPUs**: 52 (44 public)
- **OS**: Rocky Linux 9
- **Storage**: [BeeGFS](storage.md)

## Login nodes

```
login1.yggdrasil.hpc.unige.ch
```

## CPU nodes (selection)

| Model       | Architecture | Cores | Memory   | Nodesets (examples)               |
|-------------|-------------|-------|----------|-----------------------------------|
| GOLD-6240   | Cascade Lake | 36    | 187 GB   | cpu[002-057, 059-082, 091-097]    |
| GOLD-6244   | Cascade Lake | 16    | 754 GB   | cpu[113-115]                      |
| GOLD-6240   | Cascade Lake | 36    | 1510 GB  | cpu[120-122]                      |
| EPYC-7742   | Rome         | 128   | 503 GB   | cpu[123-124, 135-150]             |
| EPYC-7742   | Rome         | 128   | 1007 GB  | cpu[125-134]                      |
| EPYC-7763   | Milan        | 128   | 503 GB   | cpu[151-158]                      |
| EPYC-9654   | Genoa        | 192   | 773 GB   | cpu[159-164]                      |

## GPU nodes

| Model     | VRAM  | Nodesets              |
|-----------|-------|-----------------------|
| Titan RTX | 24 GB | gpu[001, 003-007], gpustack |
| V100      | 32 GB | gpu008                |

## Storage (Yggdrasil-specific)

| Path                   | Size    | Type | Backup     | Quota           |
|------------------------|---------|------|------------|-----------------|
| `/home/`               | 495 TB  | HDD  | Yes (tape) | 1 TB/user       |
| `/srv/beegfs/scratch/` | 1.2 PB  | HDD  | No         | 10M files/user  |

See [storage](storage.md) for full details.

## Notes

- Energy monitoring available for Intel nodes via `sacct --format=ConsumedEnergy`
- CVMFS client installed on all nodes

## Related pages

- [Overview](overview.md) · [Baobab](entity-baobab.md) · [Bamboo](entity-bamboo.md)
- [Slurm](slurm.md) · [Storage](storage.md) · [Access](access.md)
