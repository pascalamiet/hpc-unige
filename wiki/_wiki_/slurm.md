---
title: Slurm Job Scheduler
type: concept
tags: [slurm, jobs, partitions, sbatch, srun, salloc, scheduling]
sources: [07_slurm.txt, 09_best_practices.txt]
updated: 2026-04-16
---

# Slurm Job Scheduler

Slurm is the only way to access compute resources on UNIGE HPC clusters. You submit jobs from the login node; Slurm queues them and runs them on compute nodes. See the [overview](overview.md) for the big picture.

## Partitions

Partitions are groups of nodes with specific properties (time limits, access rules).

### Public partitions (available to all)

| Partition              | Time Limit | Notes                                      |
|------------------------|------------|---------------------------------------------|
| `debug-cpu`            | 15 min     | **Default.** For testing only               |
| `debug-gpu`            | 15 min     | GPU testing                                 |
| `public-cpu`           | 4 days     | Standard CPU jobs (12h–4 days)             |
| `public-gpu`           | 4 days     | GPU jobs                                    |
| `public-bigmem`        | 4 days     | High-RAM CPU jobs                           |
| `public-interactive-cpu` | 8 hours  | Interactive CPU jobs; max 6 cores          |
| `public-interactive-gpu` | 4 hours  | Interactive GPU jobs                        |
| `public-longrun-cpu`   | 14 days    | Max 2 cores; long low-resource jobs         |
| `public-short-cpu`     | 1 hour     | Max 6 CPU; max 1 running job/user          |
| `shared-cpu`           | 12 hours   | All nodes (public + private); jobs <12h    |
| `shared-gpu`           | 12 hours   | GPU jobs <12h                              |
| `shared-bigmem`        | 12 hours   | Large RAM jobs <12h                        |

### Private partitions

| Partition           | Time Limit | Notes                                    |
|--------------------|------------|------------------------------------------|
| `private-<name>`   | 7 days     | Higher priority for partition owners     |

**Key rule**: `shared-*` contains more nodes (public + private), but max 12h. `public-*` has fewer nodes but up to 4 days.

Check available partitions: `sinfo`

## Submitting jobs

### Method comparison

| Method   | Runs job | Blocking | Supports arrays | Script needed |
|----------|----------|----------|-----------------|---------------|
| `sbatch` | Yes      | No       | Yes             | Yes           |
| `srun`   | Yes      | Yes      | No              | No            |
| `salloc` | No       | Yes      | No              | No            |

### Basic sbatch script

```bash
#!/bin/sh
#SBATCH --job-name jobname
#SBATCH --output jobname-out.o%j
#SBATCH --error jobname-err.e%j
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --partition shared-cpu
#SBATCH --time 02:00:00
#SBATCH --mem-per-cpu 4000    # MB

module load my_software
srun my_software
```

Submit: `sbatch my_script.sh`

### Job types

| Type            | Slurm option         | Examples             |
|-----------------|---------------------|----------------------|
| Single-threaded | `--ntasks=1`         | Python, R script     |
| Multi-threaded  | `--cpus-per-task=N`  | Matlab, Stata-MP     |
| Distributed MPI | `--ntasks=N`         | OpenMPI, OpenFOAM    |

**Critical**: only use `--ntasks > 1` if your program actually uses MPI. Otherwise it launches N identical copies.

### Memory

Default: **3 GB per core**. Override with:
```
#SBATCH --mem-per-cpu=4000    # 4 GB per core, in MB
#SBATCH --mem=60000           # 60 GB total node memory
#SBATCH --mem=0               # all node memory
```

### GPU jobs

```bash
#SBATCH --partition=shared-gpu
#SBATCH --gpus=1                          # any GPU
#SBATCH --gpus=titan:2                    # 2 Titan GPUs
#SBATCH --constraint=DOUBLE_PRECISION_GPU # double precision
#SBATCH --constraint="COMPUTE_CAPABILITY_8_0|COMPUTE_CAPABILITY_8_6"
```

GPU billing weights: see [cost-and-accounting](cost-and-accounting.md).

### CPU type constraints

```bash
#SBATCH --constraint=EPYC-7742   # specific model
#SBATCH --constraint=V8          # generation V8
#SBATCH --constraint="V8|V10|V12"  # multiple generations
```

### Job arrays

```bash
sbatch --array=1-100%4 my_script.sh    # 100 jobs, 4 at a time
```

Access task ID inside script: `$SLURM_ARRAY_TASK_ID`. Max array size: 10,000.

### Interactive jobs

```bash
salloc -n1 -c2 --partition=debug-cpu --time=15:00 --x11
```

Or use [OpenOnDemand](access.md) for graphical sessions.

### Job dependencies

```bash
sbatch pre_process.sh                          # → jobid nnnnn
sbatch --dependency=afterok:nnnnn do_work.sh   # runs after nnnnn succeeds
```

## Monitoring jobs

```bash
squeue -u $USER              # your jobs
squeue -u $USER --start      # estimated start time
scontrol show jobid 12345    # detailed job info
sstat -j <jobid> --format=AveCPU,MaxRSS,JobID,NodeList   # while running
sacct -j <jobid> --format=Start,AveCPU,State,MaxRSS,...  # after completion
seff <jobid>                 # efficiency summary
```

Cancel jobs:
```bash
scancel <jobid>
scancel --user=$USER --state=pending
```

## Priority and scheduling

Priority formula: `partition (up to 15000) + fairshare (up to 30000) + age (up to 300) + jobsize (up to 1000)`

- **Fairshare**: decreases as you use more resources; halves every 2 weeks
- **Private partitions**: 4× partition multiplier → much higher priority
- **Backfill**: small jobs can start ahead of large pending jobs if they fit in gaps
- **Tip**: accurate `--time` estimates help Slurm schedule you faster via backfill

## Related pages

- [Overview](overview.md) · [Best Practices](best-practices.md) · [Cost and Accounting](cost-and-accounting.md)
- [Baobab](entity-baobab.md) · [Yggdrasil](entity-yggdrasil.md) · [Bamboo](entity-bamboo.md)
