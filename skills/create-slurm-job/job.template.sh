#!/bin/sh
# =============================================================================
# Slurm job script template — UNIGE HPC clusters (Baobab / Yggdrasil / Bamboo)
# =============================================================================
# Fill in the placeholders below, then submit with:  sbatch job.sh
# Full reference: guides/slurm-jobs.md | wiki/_wiki_/slurm.md
# =============================================================================

# --- Identity -----------------------------------------------------------------
#SBATCH --job-name=__JOBNAME__
#SBATCH --output=__JOBNAME__-%j.out   # %j = job ID; stdout goes here
#SBATCH --error=__JOBNAME__-%j.err    # stderr goes here

# --- Partition and time -------------------------------------------------------
# debug-cpu   15 min  | Use while testing your script
# shared-cpu  12 h    | Short production jobs (most common)
# public-cpu   4 days | Longer jobs; fewer nodes than shared-cpu
# shared-gpu  12 h    | GPU jobs < 12 h
# public-gpu   4 days | Longer GPU jobs
# See full table: guides/slurm-jobs.md
#SBATCH --partition=__PARTITION__
#SBATCH --time=__TIME__              # format: HH:MM:SS

# --- CPU resources ------------------------------------------------------------
# Single-threaded  → ntasks=1, cpus-per-task=1
# Multi-threaded   → ntasks=1, cpus-per-task=N  (Python multiprocessing, R parallel, Matlab, Stata-MP)
# MPI              → ntasks=N, cpus-per-task=1  (OpenMPI, OpenFOAM — only if program explicitly uses MPI)
#SBATCH --ntasks=__NTASKS__
#SBATCH --cpus-per-task=__CPUS__

# --- Memory -------------------------------------------------------------------
# Default is 3000 MB per core. Override if your job needs more.
#SBATCH --mem-per-cpu=__MEM_MB__     # MB per core  (use this OR --mem, not both)
##SBATCH --mem=__MEM_TOTAL_MB__      # total MB for the job (alternative)

# --- GPU (uncomment if needed) ------------------------------------------------
##SBATCH --gpus=1                    # any GPU
##SBATCH --gpus=__GPU_TYPE__:__GPU_COUNT__   # e.g. a100:1, titan:2

# --- Email notifications (uncomment to enable) --------------------------------
##SBATCH --mail-type=END,FAIL
##SBATCH --mail-user=__EMAIL__

# =============================================================================
# Environment setup
# =============================================================================

# Load software modules (pin versions for reproducibility)
# Find modules: module spider <name>
module load __MODULE__

# Alternatively, activate a conda environment:
# module load Miniconda3
# conda activate my_env

# =============================================================================
# Job commands
# =============================================================================

# srun runs your command on the allocated compute node.
# For single-task jobs you can also call your program directly.
srun __COMMAND__
