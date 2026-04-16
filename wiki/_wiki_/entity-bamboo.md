---
title: Bamboo Cluster
type: entity
tags: [cluster, bamboo, hardware, gpu, cpu]
sources: [02_how_cluster_works.txt, 03_access_cluster.txt]
updated: 2026-04-16
---

# Bamboo Cluster

Bamboo is the newest of three UNIGE HPC clusters. See the [overview](overview.md) for context.

## Location and specs

- **Datacenter**: Campus Biotech
- **Interconnect**: InfiniBand 100 Gbit/s EDR
- **Public CPU cores**: ~5,700
- **Total CPU cores**: ~5,700
- **Total GPUs**: 20 (all public)
- **OS**: Rocky Linux 9
- **Storage**: [BeeGFS](storage.md), backed by SSD for home

## Login nodes

```
login1.bamboo.hpc.unige.ch
```

## CPU nodes

| Model      | Architecture | Cores | Memory   | Nodesets         |
|-----------|-------------|-------|----------|------------------|
| EPYC-7742  | Rome         | 128   | 512 GB   | cpu[001-043]     |
| EPYC-7742  | Rome         | 128   | 251 GB   | cpu[049-052]     |
| EPYC-72F3  | Milan        | 128   | 1024 GB  | cpu[044-045]     |
| EPYC-7763  | Milan        | 128   | 512 GB   | cpu[046-048]     |

## GPU nodes

| Model       | VRAM   | Nodesets       |
|-------------|--------|----------------|
| RTX 3090    | 24 GB  | gpu[001-002]   |
| A100 80 GB  | 80 GB  | gpu003         |
| H100        | 94 GB  | gpu004         |
| H200        | 141 GB | gpu[005-006]   |
| RTX Pro 6000 Blackwell | 96 GB | gpu[007-008, 011] |
| RTX 5090    | 32 GB  | gpu[009-010]   |

## Storage (Bamboo-specific)

| Path                   | Size    | Type | Backup     | Quota           |
|------------------------|---------|------|------------|-----------------|
| `/home/`               | 378 TB  | SSD  | Yes (tape) | 1 TB/user       |
| `/srv/beegfs/scratch/` | 1.1 PB  | HDD  | No         | 10M files/user  |

## Notes

- Home directory storage is SSD-backed (faster than Baobab/Yggdrasil)
- Has the most modern GPU hardware (H100, H200, RTX 5090, RTX Pro 6000 Blackwell)
- EOS filesystem mounting supported

## Related pages

- [Overview](overview.md) · [Baobab](entity-baobab.md) · [Yggdrasil](entity-yggdrasil.md)
- [Slurm](slurm.md) · [Storage](storage.md) · [Access](access.md)
