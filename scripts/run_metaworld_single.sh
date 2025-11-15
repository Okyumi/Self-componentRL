#!/bin/bash
#SBATCH --job-name=metaworld_single
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=16
#SBATCH --mem=32GB
#SBATCH --partition=nvidia
#SBATCH --output=/scratch/yd2247/SelfcomponentRL/logs/metaworld_%j.out
#SBATCH --error=/scratch/yd2247/SelfcomponentRL/logs/metaworld_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yd2247@nyu.edu

# ============================================================================
# Simple Meta-World Experiment Script
# ============================================================================
# Runs a single algorithm with sequential tasks
# (continual learning - tasks run one after another)
#
# Usage:
#   sbatch run_metaworld_single.sh <algorithm> <seed>
#
#   algorithm: simple, componet, finetune, from-scratch, prognet, packnet
#   seed: random seed (integer)
#
# Example:
#   sbatch run_metaworld_single.sh componet 42
# ============================================================================

set -euo pipefail

# Parse arguments
ALGORITHM=${1:-componet}
SEED=${2:-42}

echo "SLURM_JOBID: ${SLURM_JOBID:-}"
echo "Running Meta-World experiment:"
echo "  Algorithm: $ALGORITHM"
echo "  Seed: $SEED"
echo "=========================================="

# Load modules
module purge
module load python/3.10
module load cuda/12.2.0
module load ffmpeg/4.2.2
module load mesa/20.2.1

# Use scratch for caches/tmp
export XDG_CACHE_HOME=/scratch/yd2247/.cache
export UV_CACHE_DIR=/scratch/yd2247/.cache/uv
export TMPDIR=/scratch/yd2247/tmp
mkdir -p "$XDG_CACHE_HOME" "$UV_CACHE_DIR" "$TMPDIR"

# Headless rendering
export MUJOCO_GL=egl

# Navigate to project directory
cd /scratch/yd2247/SelfcomponentRL
source venv/bin/activate

# Create logs directory
mkdir -p logs

# Navigate to meta-world experiments
cd experiments/meta-world

# Run experiment with default options
# Tasks will run sequentially (continual learning)
# start-mode=0: script will handle the logic internally
python3 run_experiments.py \
    --algorithm "$ALGORITHM" \
    --seed "$SEED" \
    --start-mode 0

echo "=========================================="
echo "Meta-World experiment completed successfully!"
echo "=========================================="

