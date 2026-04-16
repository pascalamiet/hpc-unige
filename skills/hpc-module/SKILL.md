---
name: hpc-module
description: |
  Find the correct `module load` line for any software on the UNIGE HPC clusters.
  Searches the module system via SSH and returns the exact command to paste into
  a job script or interactive session.
  Use when: user wants to load software, can't find the right module name,
  or needs to know what versions are available.
license: MIT
allowed-tools: Bash
---

# HPC Module Finder

You help the user find the exact `module load` command for a piece of software
on the UNIGE HPC clusters. The module system uses Lmod; module names and
versions are not always obvious from the software name.

---

## Step 1 — Gather inputs

Ask the user two things in a single message:

```
Which software are you looking for?
  → Name (e.g. "Python", "R", "CUDA", "PyTorch", "Stata", "Matlab"):

Which cluster?  [baobab]  (baobab / yggdrasil / bamboo)
```

If the user already provided the software name when invoking the skill,
skip to Step 2 immediately.

---

## Step 2 — Search the module system via SSH

Run `module spider` on the cluster using SSH. The cluster aliases from
`~/.ssh/config` are `baobab`, `yggdrasil`, `bamboo`.

```bash
ssh <cluster> 'bash -l -c "module spider <software_name> 2>&1"'
```

Example:
```bash
ssh baobab 'bash -l -c "module spider Python 2>&1"'
```

If `module spider` returns nothing useful, also try `module avail`:
```bash
ssh <cluster> 'bash -l -c "module avail <software_name> 2>&1"'
```

**If SSH fails or is not configured:** tell the user to run the command
themselves and paste the output back:
```
Please run this on the cluster and paste the output:
  module spider <software_name>
```

---

## Step 3 — Parse and present results

The `module spider` output lists available versions. Parse it and present
a clean table:

```
Available versions of Python on baobab:

  Version                          Toolchain
  ─────────────────────────────────────────────────
  Python/3.9.6-GCCcore-11.2.0     GCCcore 11.2.0
  Python/3.10.8-GCCcore-12.2.0    GCCcore 12.2.0
  Python/3.11.3-GCCcore-12.3.0    GCCcore 12.3.0   ← recommended (newest)
  Python/3.12.3-GCCcore-13.3.0    GCCcore 13.3.0
```

Then give the recommended command:

```
Recommended (pin the version for reproducibility):
  module load Python/3.11.3-GCCcore-12.3.0

To use in a job script:
  #SBATCH ...
  module load Python/3.11.3-GCCcore-12.3.0
  srun python3 my_script.py

To use interactively (after salloc):
  module load Python/3.11.3-GCCcore-12.3.0
  python3
```

**Recommend the newest stable version** unless the user asked for a
specific version. Avoid recommending the absolute bleeding-edge if a
well-tested prior version exists.

---

## Step 4 — Handle common cases

### Software not found
If `module spider` returns nothing:
1. Try a shorter or alternative name (e.g. "PyTorch" → "PyTorch", "torch")
2. Try case variations (module names are case-sensitive on some clusters)
3. If still nothing, suggest:
   ```
   No module found for "<name>". Options:
   - Check spelling: module spider <partial_name>
   - It may be available as a different name. Try: module spider <alt_name>
   - If this is a Python package (not a standalone tool), install it with pip
     after loading the Python module:  pip install --user <package>
   - Request the software: hpc@unige.ch
   ```

### Dependencies / prerequisites
`module spider <name>/<version>` (with a specific version) shows which
prerequisite modules must be loaded first. If there are prerequisites,
show the full load sequence:

```
You need to load dependencies first:
  module load GCCcore/12.3.0
  module load Python/3.11.3-GCCcore-12.3.0
```

### Common software name mappings
Use these if the user's search term returns nothing:

| User says       | Try searching for           |
|-----------------|-----------------------------|
| python          | Python                      |
| r / R           | R                           |
| pytorch         | PyTorch                     |
| tensorflow      | TensorFlow                  |
| cuda            | CUDA                        |
| matlab          | MATLAB                      |
| stata           | Stata                       |
| gcc / gfortran  | GCC, foss                   |
| mpi / openmpi   | OpenMPI, foss               |
| julia           | Julia                       |
| java            | Java                        |
| singularity     | Singularity, Apptainer      |

### Toolchain note
UNIGE uses the EasyBuild toolchain naming convention. Common toolchains:
- `GCCcore-X.Y.Z` — GCC compiler only
- `foss-YYYY<a|b>` — GCC + OpenMPI + OpenBLAS + FFTW + ScaLAPACK
- `intel-YYYY<a|b>` — Intel compilers + MKL + Intel MPI

For most Python/R work, `GCCcore` is fine. For MPI or linear algebra
intensive work, prefer `foss`.
