---
name: hpc-resources
description: |
  Analyse the efficiency of a completed Slurm job and recommend better
  resource requests (--time, --cpus-per-task, --mem-per-cpu) for the next run.
  Reads seff output directly via SSH or accepts pasted output.
  Use when: a job has finished and the user wants to tune their job script,
  or after a test run before scaling up to the real job.
license: MIT
allowed-tools: Bash, Read, Edit
---

# HPC Resource Estimator

You help the user right-size their Slurm job script based on what a
completed job actually used. The goal is to avoid two failure modes:
- **Over-requesting**: wastes cluster resources, hurts fairshare score,
  and delays other users.
- **Under-requesting**: job gets killed (OOM or timeout).

---

## Step 1 — Get the job data

Ask in a single message:

```
To recommend better resource settings I need data from your completed job.

Option A — give me the job ID and cluster:
  Job ID:   (e.g. 1234567)
  Cluster:  [baobab]  (baobab / yggdrasil / bamboo)

Option B — paste the output of:
  seff <jobid>
  sacct -j <jobid> --format=JobID,Elapsed,ReqMem,MaxRSS,ReqCPUS,AllocCPUS,CPUTime,State
```

If the user already provided a job ID, go straight to fetching the data.

---

## Step 2 — Fetch efficiency data via SSH

If the user gave a job ID, run both commands on the cluster:

```bash
ssh <cluster> "seff <jobid>"
ssh <cluster> "sacct -j <jobid> --format=JobID,Elapsed,ReqMem,MaxRSS,ReqCPUS,AllocCPUS,CPUTimeRAW,State --units=G"
```

**If SSH fails or job ID is from a session ago and sacct has expired:**
ask the user to paste the `seff` output directly.

---

## Step 3 — Parse the efficiency data

From `seff`, extract:

| Field              | What it means                                |
|--------------------|----------------------------------------------|
| CPU Efficiency     | % of requested CPU time actually used        |
| Memory Efficiency  | % of requested memory actually used          |
| Job Wall-clock time| How long the job actually ran               |
| Memory Utilized    | Peak RAM used (MaxRSS)                       |
| Memory Requested   | What was in `--mem` or `--mem-per-cpu`       |
| Cores requested    | `--ntasks × --cpus-per-task`                |

From `sacct`, also get the job state (COMPLETED, FAILED, TIMEOUT, OUT_OF_MEMORY).

---

## Step 4 — Diagnose the job outcome

### If state is TIMEOUT
```
Your job was killed because it hit the time limit.
→ The job needed more time than requested.
→ Recommendation: increase --time, or split into checkpointed segments.
```

### If state is OUT_OF_MEMORY
```
Your job was killed because it ran out of memory.
→ Recommendation: increase --mem-per-cpu or switch to --mem for total memory.
```

### If state is FAILED (non-OOM, non-timeout)
```
Your job failed (exit code != 0). This is likely a software error,
not a resource issue. Check the .err file for the actual error message.
→ Use the guides/slurm-jobs.md monitoring section to read the output.
```

### If state is COMPLETED — evaluate efficiency
Assess CPU and memory efficiency and classify:

| Efficiency | Assessment        |
|------------|-------------------|
| > 85%      | Good — keep as-is |
| 50–85%     | Acceptable        |
| 20–50%     | Over-requested — reduce |
| < 20%      | Significantly over-requested |

---

## Step 5 — Give concrete recommendations

Always give specific, paste-ready `#SBATCH` lines. Never just say
"increase your memory" — say exactly what value to use.

### Time recommendation
```
Actual runtime:    00:47:23
Requested:         04:00:00  (only 20% used)

Recommended:
  #SBATCH --time=01:30:00   # 2× actual runtime as safety buffer
```

Rule: recommend **2× actual runtime**, capped at the partition limit.
If actual runtime was close to the limit (> 80%), recommend the next
partition up or a 3× buffer.

### CPU recommendation
```
CPU Efficiency: 24% (requested 4 cores, used ~1 core equivalent)

Likely cause: your script is single-threaded but requested 4 cores.
Recommended:
  #SBATCH --cpus-per-task=1

If you want multi-threading, make sure your program is actually
configured to use multiple cores (e.g. set OMP_NUM_THREADS,
or pass --cores N to your program).
```

### Memory recommendation
```
Memory Efficiency: 18% (requested 16 GB, used 2.9 GB peak)

Recommended:
  #SBATCH --mem-per-cpu=4000   # 4 GB/core — 40% headroom over peak
```

Rule: recommend **peak usage × 1.4**, rounded up to the nearest 1000 MB.
This gives ~40% headroom for run-to-run variation.

### Full revised script snippet
Always end with a clean block of just the revised `#SBATCH` lines:

```
Revised resource block for job.sh:

  #SBATCH --partition=shared-cpu
  #SBATCH --time=01:30:00
  #SBATCH --ntasks=1
  #SBATCH --cpus-per-task=1
  #SBATCH --mem-per-cpu=4000
```

If the user has a `job.sh` in the current directory, offer to update it:
```
I can update job.sh with these values — want me to do that? [yes/no]
```

If yes, use Edit to apply the changes to `job.sh`.

---

## Step 6 — Partition advice (if relevant)

If the revised time puts the job in a different partition's sweet spot,
say so:

```
With --time=01:30:00 you're well under 12h, so shared-cpu is ideal
(more nodes → shorter wait than public-cpu).
```

If the job needed > 12h but was on shared-cpu (which would have killed it):
```
Your job needed more than 12h. Switch to:
  #SBATCH --partition=public-cpu   # up to 4 days
```

---

## Efficiency reference

| Metric              | Green        | Yellow      | Red           |
|---------------------|-------------|-------------|---------------|
| CPU efficiency      | > 85%       | 50–85%      | < 50%         |
| Memory efficiency   | > 60%       | 30–60%      | < 30%         |
| Time used / limit   | 50–80%      | 20–50%      | < 20% or > 95%|

A job using < 20% of its time limit blocks backfill scheduling for everyone.
A job using > 95% is one run away from a TIMEOUT.
