#!/bin/bash
#SBATCH --job-name=cleanrl_atari
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --gres=gpu:1           
#SBATCH --cpus-per-task=16
#SBATCH --mem=16GB
#SBATCH --partition=nvidia
#SBATCH --array=0                # 1 envs x 1 seed = 1 total combinations
#SBATCH --output=/scratch/yd2247/cleanrl/logs/%A_%a.out
#SBATCH --error=/scratch/yd2247/cleanrl/logs/%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yd2247@nyu.edu

set -euo pipefail

echo "SLURM_JOBID: ${SLURM_JOBID:-}"
echo "SLURM_ARRAY_JOB_ID: ${SLURM_ARRAY_JOB_ID:-}"
echo "SLURM_ARRAY_TASK_ID: ${SLURM_ARRAY_TASK_ID:-}"


module purge
module load python/3.10
module load cuda/12.2.0          # Best available match (closest to PyTorch's CUDA 12.8)
module load ffmpeg/4.2.2
module load mesa/20.2.1

# Use scratch for caches/tmp (avoid home quota)
export XDG_CACHE_HOME=/scratch/yd2247/.cache
export UV_CACHE_DIR=/scratch/yd2247/.cache/uv
export TMPDIR=/scratch/yd2247/tmp
mkdir -p "$XDG_CACHE_HOME" "$UV_CACHE_DIR" "$TMPDIR"

# Headless rendering for Atari
export MUJOCO_GL=egl    # fallback to osmesa if EGL is unavailable


cd /scratch/yd2247/Self-componentRL
source venv/bin/activate

echo "Running setting=${SLURM_ARRAY_TASK_ID:-0}"

python scripts/atari_encoder.py --setting "${SLURM_ARRAY_TASK_ID:-0}"