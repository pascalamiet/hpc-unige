---
title: Software Modules and Applications
type: concept
tags: [module, lmod, easybuild, conda, singularity, apptainer, python, R, matlab]
sources: [04_applications_and_libraries.txt]
updated: 2026-04-16
---

# Software Modules and Applications

Software on UNIGE HPC clusters is managed with **lmod** via the `module` command. This avoids PATH conflicts and ensures reproducibility. See the [overview](overview.md) for the broader context.

## Module commands

```bash
module spider                    # list all available software
module spider <app>              # find versions of a specific app
module spider <app>/<version>    # show dependencies needed to load a version
module load <app>                # load latest version
module load <app>/<version>      # load specific version (recommended for reproducibility)
module load app1 app2 app3       # load multiple modules
module list                      # show currently loaded modules
module purge                     # unload all modules
module help <app>                # show help for a loaded module
ml                               # shorthand for `module`
```

**Always pin versions** if results reproducibility matters (e.g. `module load R/4.2.1` not just `module load R`).

## Compiler toolchains

Use toolchain modules instead of loading GCC/MPI separately.

### FOSS toolchain (GCC + OpenMPI)

| Module      | GCC    | OpenMPI |
|-------------|--------|---------|
| foss/2022a  | 11.3.0 | 4.1.4   |
| foss/2023a  | 12.3.0 | 4.1.5   |
| foss/2023b  | 13.2.0 | 4.1.6   |
| foss/2024a  | 13.3.0 | 5.0.3   |

### Intel toolchain

| Module      | Compiler   | MPI          |
|-------------|-----------|--------------|
| intel/2022a | icc 2022.1 | impi 2021.6  |

Intel compilers ≥ 2021a no longer require a license (OneAPI).

### CUDA/fosscuda toolchain

```bash
module load fosscuda/2020b    # GCC 10.2.0 + OpenMPI 4.0.5 + CUDA 11.1.1
# Or load CUDA directly:
module load CUDA
```

## MPI compilation

Always use MPI wrappers, not the compiler directly:
```bash
mpicc    # C
mpic++   # C++
mpicxx   # C++
```

## Loading R (example with dependencies)

```bash
module spider R/4.2.1                    # check dependencies
module load GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1
# or using foss toolchain:
module load foss/2022a R/4.2.1
```

Install user R packages: create `~/.Rprofile` (set CRAN mirror) and `~/.Renviron` (set `R_LIBS=~/Rpackages/`), then `mkdir ~/Rpackages`.

## Python

```bash
module load GCC/13.3.0 Python/3.11.6
# For numpy/scipy/pandas:
module load GCC/8.2.0-2.31.1 OpenMPI/3.1.3 Python/3.7.2 SciPy-bundle/2019.03
```

### Python virtualenv

```bash
module load GCC/13.3.0 Python/3.12.3 virtualenv/20.26.3   # example; check module spider Python
virtualenv --system-site-packages ~/my_env    # create venv
. ~/my_env/bin/activate                        # activate
~/my_env/bin/pip install <package>            # install
```

**Must reload same modules** before reusing the venv.

> **Note**: always run `module spider Python` to find currently available versions and their required dependencies — the exact version strings above may not match what is installed on your cluster.

## Conda / containers

**Warning**: raw conda environments create thousands of small files — they hurt [BeeGFS performance](storage.md). **Preferred approach**: package your conda environment in a Singularity/Apptainer container.

### Build a conda container with cotainr

```bash
# 1. Export your conda environment
conda env export > bioenv.yml    # remove the `prefix:` line at the bottom

# 2. Build SIF image
module load GCCcore/13.3.0 cotainr
cotainr build bioenv.sif --base-image=docker://ubuntu:latest \
    --accept-licenses --conda-env=bioenv.yml

# 3. Use it
apptainer exec bioenv.sif python3 -c "import numpy; print(numpy.__version__)"
```

### Apptainer (formerly Singularity)

```bash
# Pull an image (run on compute node, not login)
salloc --partition=shared-cpu --time=00:30:00 --cpus-per-task=12
apptainer pull docker://rocker/rstudio:4.2    # → rstudio_4.2.sif

# Run
apptainer run image.sif
apptainer exec image.sif <command>
apptainer shell image.sif

# Persistent writable overlay
apptainer overlay create --fakeroot --sparse --size 10000 my_overlay.img
apptainer exec --fakeroot --overlay my_overlay.img image.sif
```

Do NOT run heavy apptainer builds on the login node.

## Notable applications

### Matlab
```bash
#SBATCH --licenses=matlab@matlablm.unige.ch
module load MATLAB/2022a
srun matlab -nodesktop -nosplash -nodisplay -r myscript
```
Compile to avoid license usage: `mcc -m -v -R '-nojvm, -nodisplay' -o hello hello.m`

### Stata
```bash
module load Stata/17
srun stata-mp -b do myscript.do
```

### TensorFlow
TensorFlow modules are GPU-compiled — must run on a GPU partition. See examples at https://gitlab.unige.ch/hpc/softs

### Jupyter / JupyterLab
Easiest via [OpenOnDemand](access.md) (Baobab). Alternatively use `public-interactive-cpu` partition and SSH tunnel.

### Gurobi
```bash
module load Gurobi
gurobi_cl --tokens    # check token server status (master.cluster)
```

## Software not available via module

1. Email hpc@unige.ch with details — they often install via EasyBuild
2. Compile in `$HOME` (no sudo; load compiler module first)
3. Use Apptainer/Singularity container

Check EasyBuild supported software list: https://docs.easybuild.io/en/latest/version-specific/Supported_software.html

## Git on the cluster

```bash
# Add to ~/.gitconfig:
[core]
createObject = rename

# Clone with:
git clone --no-hardlinks <repo>
```

## Related pages

- [Overview](overview.md) · [Slurm](slurm.md) · [Best Practices](best-practices.md)
- [Storage](storage.md) · [Access](access.md)
