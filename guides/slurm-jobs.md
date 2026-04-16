# Running Jobs on the HPC Cluster (Slurm)

Assumes SSH is configured and you can connect to a login node. See [ssh.md](ssh.md).

---

## The golden rule

**Never run compute jobs on the login node.**

When you SSH into the cluster you land on a *login node* — a shared machine with hard per-user limits (2 CPU cores, 8 GB RAM on Baobab). It is meant for editing files, transferring data, and submitting jobs. Running anything compute-intensive there disturbs every other user, and the HPC team will kill your processes.

All real work — including short tests — must go through **Slurm**, the job scheduler that routes your job to a compute node.

---

## How Slurm works

```
Your laptop → SSH → login node → sbatch / srun → Slurm queue → compute node
```

1. You write a job script (or type a command) on the login node.
2. You submit it to Slurm.
3. Slurm waits until a compute node with enough resources is free.
4. Slurm runs your job there, captures stdout/stderr, and releases the node when done.

You never SSH directly to a compute node — Slurm handles that.

---

## The three submission commands

| Command  | What it does                                        | Blocking? | Use it for                      |
|----------|-----------------------------------------------------|-----------|----------------------------------|
| `sbatch` | Submits a script; runs in background                | No        | Most jobs — batch work           |
| `srun`   | Runs a single command on a compute node             | Yes       | Quick interactive commands       |
| `salloc` | Reserves a compute node; gives you a shell on it    | Yes       | Interactive sessions, debugging  |

---

## Picking a partition

A partition is a group of nodes. You must always specify one.

| Partition                  | Time limit | Notes                                    |
|----------------------------|------------|------------------------------------------|
| `debug-cpu`                | 15 min     | **Start here** — fastest to get a node  |
| `debug-gpu`                | 15 min     | GPU testing                              |
| `shared-cpu`               | 12 hours   | Most nodes, short jobs — lowest wait     |
| `shared-gpu`               | 12 hours   | GPU jobs < 12h                           |
| `public-cpu`               | 4 days     | Fewer nodes, longer runtime              |
| `public-gpu`               | 4 days     | GPU jobs up to 4 days                    |
| `public-bigmem`            | 4 days     | High-RAM CPU jobs                        |
| `public-interactive-cpu`   | 8 hours    | Interactive CPU; max 6 cores             |
| `public-interactive-gpu`   | 4 hours    | Interactive GPU                          |
| `public-longrun-cpu`       | 14 days    | Max 2 cores; long, low-resource work     |

**Rule of thumb**: use `debug-cpu` while testing your script, switch to `shared-cpu` for jobs under 12h, `public-cpu` for longer runs.

List all available partitions and node states:
```bash
sinfo
```

---

## Batch jobs with `sbatch`

This is how you submit most work.

### Minimal job script

Create a file `job.sh`:

```bash
#!/bin/sh
#SBATCH --job-name=myjob
#SBATCH --output=myjob-%j.out    # %j = job ID
#SBATCH --error=myjob-%j.err
#SBATCH --partition=shared-cpu
#SBATCH --time=01:00:00           # HH:MM:SS — be accurate, not the partition max
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4000        # MB per core (default is 3000)

module load Python/3.11.3-GCCcore-12.3.0
python3 my_script.py
```

Submit it:
```bash
sbatch job.sh
```

Slurm prints a job ID. Your script's stdout goes to `myjob-<jobid>.out`.

### Key `#SBATCH` options

| Option               | Example                  | Effect                                          |
|----------------------|--------------------------|-------------------------------------------------|
| `--partition`        | `shared-cpu`             | Which partition to use                          |
| `--time`             | `02:00:00`               | Wall-clock time limit                           |
| `--ntasks`           | `1`                      | Number of tasks (= MPI ranks); almost always 1  |
| `--cpus-per-task`    | `4`                      | CPU cores for multi-threaded programs           |
| `--mem-per-cpu`      | `4000`                   | MB per core                                     |
| `--mem`              | `16000`                  | Total MB for the job (alternative to per-cpu)  |
| `--mail-type`        | `END,FAIL`               | Email when job ends or fails                    |
| `--mail-user`        | `you@unige.ch`           | Where to send the email                         |

### Choosing CPU and memory

- **Single-threaded** (Python, R, Stata SE): `--ntasks=1 --cpus-per-task=1`
- **Multi-threaded** (Matlab, Stata MP, OpenMP): `--ntasks=1 --cpus-per-task=N`
- **MPI** (OpenFOAM, OpenMPI): `--ntasks=N` — only use this if your program explicitly uses MPI

**Important**: requesting more cores than your program actually uses wastes resources for everyone. If unsure, start with 1 and check efficiency afterwards.

Default memory is **3 GB per core**. If your job needs more, set `--mem-per-cpu` or `--mem`.

---

## Interactive sessions with `salloc`

Use this when you want to test things interactively on a compute node — same as a regular shell, just on compute hardware.

```bash
salloc --ntasks=1 --cpus-per-task=2 --partition=debug-cpu --time=00:15:00
```

Slurm waits until a node is free, then drops you into a shell on that node. When you're done, type `exit` or press `Ctrl-D` to release the node.

For GUI apps (requires `-X` or `-Y` in your SSH connection):
```bash
salloc -n1 -c2 --partition=debug-cpu --time=00:15:00 --x11
```

---

## Quick test with `srun`

Run a single command on a compute node without writing a script:

```bash
srun --partition=debug-cpu --time=00:05:00 --ntasks=1 python3 -c "import sys; print(sys.version)"
```

`srun` blocks until the job finishes and prints output directly to your terminal.

---

## Monitoring your jobs

```bash
squeue -u $USER                  # see your queued and running jobs
squeue -u $USER --start          # show estimated start time
scontrol show jobid <jobid>      # detailed info about a specific job
```

Check efficiency after a job completes:
```bash
seff <jobid>                     # CPU and memory efficiency summary
sacct -j <jobid> --format=Start,Elapsed,State,MaxRSS,ReqMem
```

Cancel a job:
```bash
scancel <jobid>
scancel --user=$USER --state=pending    # cancel all your pending jobs
```

---

## GPU jobs

```bash
#SBATCH --partition=shared-gpu
#SBATCH --gpus=1                           # any available GPU
#SBATCH --gpus=a100:1                      # specific GPU model
```

Check what GPU types are available:
```bash
sinfo -o "%P %G %N" | grep gpu
```

---

## Job arrays (parameter sweeps)

To run the same script 100 times with different inputs, use an array instead of submitting 100 separate jobs:

```bash
#SBATCH --array=1-100%10     # 100 jobs, 10 running at a time
```

Inside the script, `$SLURM_ARRAY_TASK_ID` gives the current index (1–100). Use it to select input files, seeds, or parameter values.

---

## A first workflow: test → scale

1. **Write your script** on the login node (edit files, test that it imports correctly with `python3 -c "import ..."`).
2. **Run a tiny test** via `debug-cpu` — same script, 10 rows of data, 5-minute time limit.
3. **Check the output** and efficiency with `seff <jobid>`.
4. **Scale up**: switch to `shared-cpu` or `public-cpu`, set real resource estimates.
5. **Submit** and monitor with `squeue -u $USER`.

---

## See also

- [ssh.md](ssh.md) — connecting to the cluster
- [file-transfer.md](file-transfer.md) — moving data in and out
- Wiki: [slurm](../wiki/_wiki_/slurm.md) — full partition table, job arrays, dependencies, priority
- Wiki: [best-practices](../wiki/_wiki_/best-practices.md) — resource efficiency checklist
- Wiki: [software-modules](../wiki/_wiki_/software-modules.md) — loading software with `module`
