---
title: Baobab Cluster
type: entity
tags: [cluster, baobab, hardware, gpu, cpu]
sources: [02_how_cluster_works.txt, 03_access_cluster.txt]
updated: 2026-04-16
---

# Baobab Cluster

Baobab is one of three UNIGE HPC clusters. See the [overview](overview.md) for context.

## Location and specs

- **Datacenter**: Uni Dufour, Geneva downtown
- **Interconnect**: InfiniBand 100 Gbit/s EDR
- **Public CPU cores**: ~900
- **Total CPU cores**: ~13,044
- **Total GPUs**: 273 (all private — no public GPU partition)
- **OS**: Rocky Linux 9
- **Storage**: [BeeGFS](storage.md)

## Login nodes

```
login1.baobab.hpc.unige.ch
login2.baobab.hpc.unige.ch
```

## CPU nodes (selection)

| Model       | Architecture  | Cores | Memory   | Nodesets (examples)                  |
|-------------|--------------|-------|----------|--------------------------------------|
| E5-2630V4   | Broadwell-EP  | 20    | 94 GB    | cpu[193-198, 200-201, ...]           |
| EPYC-7742   | Rome          | 128   | 503 GB   | cpu[273-277, 285-307, 314-335]       |
| EPYC-7742   | Rome          | 128   | 1007 GB  | cpu[312-313]                         |
| GOLD-6240   | Cascade Lake  | 36    | 187 GB   | cpu[084-090, 265-272, ...]           |
| EPYC-9654   | Genoa         | 192   | 768 GB   | cpu[350, 352]                        |

## GPU nodes (selection)

| Model        | VRAM  | Nodesets                        |
|-------------|-------|----------------------------------|
| RTX 2080 Ti | 11 GB | gpu[011, 013-016, 018-019]       |
| RTX 3080    | 10 GB | gpu[023-024, 036-043]            |
| RTX 3090    | 24 GB | gpu[017, 021, 025-026, 034-035]  |
| A100 40 GB  | 40 GB | gpu[020, 022, 027-028, 030-031]  |
| A100 80 GB  | 80 GB | gpu[027, 029, 032-033, 045]      |
| RTX A5000   | 25 GB | gpu[044, 047]                    |
| RTX A5500   | 24 GB | gpu046                           |
| RTX A6000   | 48 GB | gpu048                           |
| RTX 4090    | 24 GB | gpu049                           |
| RTX 5000    | 32 GB | gpu050                           |

## Special features

- **OpenOnDemand** web portal available (JupyterLab, RStudio, Matlab, VSCode): https://openondemand.baobab.hpc.unige.ch
- Supports teaching accounts (`<PI_NAME>_teach`) with free usage for students
- CVMFS client installed on all nodes

## Storage (Baobab-specific)

| Path                   | Size    | Type | Backup      | Quota           |
|------------------------|---------|------|-------------|-----------------|
| `/home/`               | 138 TB  | HDD  | Yes (tape)  | 1 TB/user       |
| `/srv/beegfs/scratch/` | 1.0 PB  | HDD  | No          | 10M files/user  |
| `/srv/fast`            | 5 TB    | SSD  | No          | 500G/user, 1T/group |

See [storage](storage.md) for full details.

## Related pages

- [Overview](overview.md) · [Yggdrasil](entity-yggdrasil.md) · [Bamboo](entity-bamboo.md)
- [Slurm](slurm.md) · [Storage](storage.md) · [Access](access.md)
