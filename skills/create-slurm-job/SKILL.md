---
name: create-slurm-job
description: |
  Interactively create a Slurm job script (job.sh) for the UNIGE HPC clusters.
  Asks the user a short series of questions, then writes a ready-to-submit
  job.sh in the current directory using skills/create-slurm-job/job.template.sh.
  Use when: user wants to create, generate, or set up a Slurm job script.
license: MIT
allowed-tools: Read, Write, Bash
---

# Create Slurm Job Script

You are helping the user generate a `job.sh` file for the UNIGE HPC clusters
(Baobab, Yggdrasil, or Bamboo). Your job is to ask a short series of focused
questions, then produce a clean, ready-to-submit script.

**Template location:** `skills/create-slurm-job/job.template.sh`
Read the template first so you understand all the placeholders before you
start asking questions.

---

## Step 0 — Read the template

Before asking anything, read `skills/create-slurm-job/job.template.sh`.
This is the file you will copy and fill in. Every `__PLACEHOLDER__` in that
file corresponds to one or more questions below.

---

## Step 1 — Ask the user these questions

Work through the questions in order. Ask **all of them in a single message**
so the user can answer in one go. Do not ask one question at a time.

Format your questions clearly, like a numbered form. Provide sensible defaults
in square brackets wherever possible — the user can just press Enter or type
a value to override.

```
I'll create a job.sh for you. Answer these questions (press Enter to use the
default shown in [brackets]):

1. Job name (no spaces, used for output file names)  [myjob]

2. What command will you run?
   e.g. "python3 train.py", "Rscript analysis.R", "matlab -r run_sim"

3. Which software modules do you need to load?
   e.g. "Python/3.11.3-GCCcore-12.3.0", "R/4.3.2-foss-2023a"
   (Leave blank if you will use conda or load modules yourself)

4. Partition — choose one:
   [debug-cpu]   15 min — use while testing your script
   shared-cpu    12 h   — most production CPU jobs
   public-cpu    4 days — longer CPU jobs
   shared-gpu    12 h   — GPU jobs under 12 h
   public-gpu    4 days — longer GPU jobs
   → Your choice:

5. Time limit (HH:MM:SS)  [00:15:00]
   Tip: be accurate — over-requesting blocks backfill scheduling.

6. Job type:
   [1] Single-threaded  (one core — Python, R, Stata SE)
    2  Multi-threaded   (one node, N cores — Matlab, Stata-MP, OpenMP, multiprocessing)
    3  MPI              (N tasks across nodes — OpenMPI, OpenFOAM; only if your program uses MPI)
   → Your choice:

7. Number of CPUs / tasks:
   (If single-threaded: how many cores? Usually 1)
   (If multi-threaded:  how many cores does your program use?)
   (If MPI:            how many MPI tasks?)
   → [1]

8. Memory per CPU in MB  [3000]
   Default is 3 GB/core. Increase if your job runs out of memory.
   (For a total memory cap instead, type "total:XXXX")

9. GPU?  [no]
   If yes, specify type and count, e.g. "1" (any), "a100:1", "titan:2"

10. Email notifications when job ends or fails?  [no]
    If yes, enter your email address:
```

---

## Step 2 — Confirm before writing

After the user responds, echo back a brief summary of the settings you
understood, like this:

```
Here's what I'll put in job.sh:

  Job name:   myjob
  Command:    python3 train.py
  Modules:    Python/3.11.3-GCCcore-12.3.0
  Partition:  debug-cpu
  Time:       00:15:00
  CPUs:       1 task × 1 core
  Memory:     3000 MB/core
  GPU:        no
  Email:      no

Shall I write this to job.sh in the current directory? [yes]
```

If the user says yes (or just presses Enter), proceed. If they want to
correct something, apply the correction and confirm again.

---

## Step 3 — Write job.sh

Read the template at `skills/create-slurm-job/job.template.sh`, then write
`job.sh` in the current working directory with all placeholders replaced.

### Placeholder substitution rules

| Placeholder        | Value                                                                 |
|--------------------|-----------------------------------------------------------------------|
| `__JOBNAME__`      | Job name from Q1                                                      |
| `__PARTITION__`    | Partition from Q4                                                     |
| `__TIME__`         | Time limit from Q5                                                    |
| `__NTASKS__`       | 1 for single/multi-threaded; N for MPI                               |
| `__CPUS__`         | N for multi-threaded; 1 for single-threaded and MPI                  |
| `__MEM_MB__`       | Memory per CPU from Q8                                               |
| `__MODULE__`       | Module(s) from Q3, or remove the `module load` line if blank         |
| `__COMMAND__`      | Command from Q2                                                       |

**GPU handling:**
- If no GPU: leave the GPU lines commented out (keep them as-is from template)
- If GPU: uncomment the `--gpus` line and fill in the value

**Email handling:**
- If no email: leave the `--mail-*` lines commented out
- If email: uncomment both `--mail-type` and `--mail-user` lines

**Memory alternative:**
- If user typed "total:XXXX": comment out `--mem-per-cpu`, uncomment `--mem`
  and set the total value

**Module handling:**
- If the user gave a single module: `module load Python/3.11.3-GCCcore-12.3.0`
- If multiple modules (space- or comma-separated): one `module load` per module
- If blank: remove the module load line entirely and add a comment:
  `# No modules requested — load software manually or activate conda env`

---

## Step 4 — Tell the user what to do next

After writing the file, print:

```
Written: job.sh

Next steps:
  1. Review the file:        cat job.sh
  2. Test on a compute node: sbatch job.sh          (partition is debug-cpu — 15 min limit)
  3. Check job status:       squeue -u $USER
  4. View output:            cat __JOBNAME__-<jobid>.out
  5. Check efficiency:       seff <jobid>            (after job completes)

When your test passes, change --partition and --time for a real run.
```

---

## Decision guide: ntasks vs cpus-per-task

| Job type       | `--ntasks` | `--cpus-per-task` | Notes                              |
|----------------|-----------|-------------------|------------------------------------|
| Single-thread  | 1         | 1                 | Default for most Python/R scripts  |
| Multi-thread   | 1         | N                 | Set N = cores your program uses    |
| MPI            | N         | 1                 | Only if program explicitly uses MPI|

**Important:** requesting more cores than your program uses wastes resources.
If unsure, use single-threaded (1×1) and verify with `seff` after the job.

---

## Partition quick reference

| Partition      | Max time | Nodes        | Best for                      |
|----------------|----------|--------------|-------------------------------|
| `debug-cpu`    | 15 min   | limited      | Testing scripts               |
| `debug-gpu`    | 15 min   | limited      | Testing GPU code              |
| `shared-cpu`   | 12 h     | all CPU      | Most production CPU jobs      |
| `public-cpu`   | 4 days   | public only  | Longer CPU jobs               |
| `shared-gpu`   | 12 h     | all GPU      | Most production GPU jobs      |
| `public-gpu`   | 4 days   | public only  | Longer GPU jobs               |
| `public-bigmem`| 4 days   | bigmem       | High-RAM CPU jobs             |
