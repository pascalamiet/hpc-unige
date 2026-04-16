---
title: Storage Systems
type: concept
tags: [storage, beegfs, home, scratch, fast, backup, quota]
sources: [05_storate.txt, 06_data_life_cycle.txt]
updated: 2026-04-16
---

# Storage Systems

UNIGE HPC clusters use BeeGFS, a distributed parallel filesystem. Storage is **not shared between clusters** — each cluster has its own independent storage. See [data lifecycle](data-lifecycle.md) for data management strategy.

## Storage tiers overview

### Shared storage (accessible from login + all compute nodes)

| Cluster   | Path                   | Size    | Type | Backup      | Quota per user      |
|-----------|------------------------|---------|------|-------------|---------------------|
| Baobab    | `/home/`               | 138 TB  | HDD  | Yes (tape)  | 1 TB                |
| Baobab    | `/srv/beegfs/scratch/` | 1.0 PB  | HDD  | No          | 10M files           |
| Baobab    | `/srv/fast`            | 5 TB    | SSD  | No          | 500G/user, 1T/group |
| Yggdrasil | `/home/`               | 495 TB  | HDD  | Yes (tape)  | 1 TB                |
| Yggdrasil | `/srv/beegfs/scratch/` | 1.2 PB  | HDD  | No          | 10M files           |
| Bamboo    | `/home/`               | 378 TB  | SSD  | Yes (tape)  | 1 TB                |
| Bamboo    | `/srv/beegfs/scratch/` | 1.1 PB  | HDD  | No          | 10M files           |

### Local storage (per compute node, not shared)

| Path       | Notes                                              |
|------------|---------------------------------------------------|
| `/scratch`  | Local SSD/HDD; deleted after job ends            |
| `/dev/shm`  | RAM-based; fastest; requires enough RAM request  |
| `/var/tmp`  | Local disk; private to your job                  |
| `/tmp`      | Local disk; private to your job                  |

There is also a **shared local space** accessible to all your jobs running on the same node:  
`/share/users/${SLURM_JOB_USER:0:1}/${SLURM_JOB_USER}` — erased when you have no more jobs on that node.

## Home directory (`$HOME`)

- Available on login node and all compute nodes
- Backed up **daily** (tape)
- Backup retention: 10 versions for active files (modified in last 30 days); 2 versions for deleted/moved files kept for 90 days
- **Always use `$HOME` variable, not hardcoded paths**
- Permissions `0700` — automatically reset daily; you cannot change them
- If you delete something: email hpc@unige.ch with full path + deletion date/time ASAP

## Scratch directory (`$HOME/scratch`)

- `$HOME/scratch` is a symlink to `/srv/beegfs/scratch/users/<initial>/<username>/`
- Not backed up
- **Automatic deletion**: files not accessed for **3 months** are deleted (Baobab; rolling out to others)
- Quota: 10 million files (chunk-based counting)
- Use for: large temporary datasets, regenerable data, computation intermediates

## Fast directory (`/srv/fast`) — Baobab only

- SSD-based, for multi-node jobs that need shared scratch between nodes
- **Erased at each maintenance**
- Quota: 500 GB/user, 1 TB/group

## Local scratch (`/scratch` on compute node)

- Fastest local I/O, no network overhead
- Automatically deleted at job end — copy results to `$HOME` or scratch before job ends
- Yggdrasil nodes all have SSDs; some Baobab nodes still have HDDs

## Sharing files with other users

Request shared directories via the DW form:  
- `/home/share/` — for scripts and libraries  
- `/srv/beegfs/scratch/shares/` — for large datasets  

Set `umask 0002` for group-writable files in shared directories.

## Checking disk usage

```bash
beegfs-get-quota-home-scratch.sh    # quick summary of home + scratch quota
```

For NASAC quota:
```bash
quota --hide-device -s -f /acanas
```

## I/O performance tips

BeeGFS has two bottlenecks:
- **Metadata servers**: hit by `ls`, `find`, directory traversal — bottleneck for many small files
- **Storage servers**: hit by actual file reads/writes

Avoid:
- Directories with >1,000 files
- Running `find`, `ncdu`, `du`, `updatedb` on shared storage
- Reading/writing thousands of tiny files

Prefer:
- Larger files (1 MB+)
- Caching frequently accessed files
- Using local `/scratch` for high-I/O temporary work

## External storage

- **NASAC**: mount via `gio mount smb://server/share` (requires `dbus-launch bash` first) — see [access](access.md) for full mounting instructions
- **CVMFS**: available on all compute and login nodes (e.g., `/cvmfs/atlas.cern.ch`)
- **EOS**: mountable via `eos fuse mount` (do not mount in `$HOME` or scratch)
- **SWITCHfilesender**: CLI tool for large file transfers via browser — see [access](access.md) for setup
- For routine file sync between local machine and cluster, see [rsync](rsync.md)

## Archive options

- [NAS academic](https://catalogue-si.unige.ch/stockage-recherche): 75 CHF/TB/year, CIFS/NFS
- [Yareta](https://yareta.unige.ch): long-term preservation
- Clusters are NOT long-term archives

## Related pages

- [Overview](overview.md) · [Data Lifecycle](data-lifecycle.md) · [Best Practices](best-practices.md)
- [Baobab](entity-baobab.md) · [Yggdrasil](entity-yggdrasil.md) · [Bamboo](entity-bamboo.md)
