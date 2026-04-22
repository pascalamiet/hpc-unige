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

Work through the questions in order. Ask **one question at a time** and wait
for the answer before asking the next one. Do not dump the full questionnaire
up front.

Keep the interaction stateful:

- Reuse anything the user already provided.
- Ask only the next missing field needed to fill the template.
- Provide a sensible default in brackets where possible.
- If the user gives several answers at once, accept them and skip ahead.
- If an answer is ambiguous, resolve that field before moving on.

Question order:

1. Job name (default `[myjob]`)
2. Command to run
3. Modules to load
4. Partition
5. Time limit
6. Job type
7. CPUs / tasks
8. Memory
9. GPU
10. Email notifications

Example opening question:

```text
I'll create a job.sh for you. First question:

What command will you run?
For example: python3 train.py, Rscript analysis.R, matlab -r run_sim
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
