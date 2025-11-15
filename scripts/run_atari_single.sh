#!/bin/bash
#SBATCH --job-name=atari_single
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=16
#SBATCH --mem=32GB
#SBATCH --partition=nvidia
#SBATCH --output=/scratch/yd2247/SelfcomponentRL/logs/atari_%j.out
#SBATCH --error=/scratch/yd2247/SelfcomponentRL/logs/atari_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yd2247@nyu.edu

# ============================================================================
# Simple Atari Experiment Script
# ============================================================================
# Runs a single algorithm on a single environment with sequential tasks
# (continual learning - tasks run one after another)
#
# Usage:
#   sbatch run_atari_single.sh <algorithm> <env> <seed>
#
#   algorithm: componet, finetune, from-scratch, prog-net, packnet
#   env: ALE/SpaceInvaders-v5 or ALE/Freeway-v5
#   seed: random seed (integer)
#
# Example:
#   sbatch run_atari_single.sh componet ALE/SpaceInvaders-v5 42
# ============================================================================

set -euo pipefail

# Parse arguments
ALGORITHM=${1:-componet}
ENV=${2:-ALE/SpaceInvaders-v5}
SEED=${3:-42}

echo "SLURM_JOBID: ${SLURM_JOBID:-}"
echo "Running Atari experiment:"
echo "  Algorithm: $ALGORITHM"
echo "  Environment: $ENV"
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

# Navigate to atari experiments
cd experiments/atari

# Determine number of modes based on environment
if [[ "$ENV" == "ALE/SpaceInvaders-v5" ]]; then
    NUM_MODES=10
elif [[ "$ENV" == "ALE/Freeway-v5" ]]; then
    NUM_MODES=8
else
    echo "ERROR: Unknown environment $ENV"
    exit 1
fi

# Run experiment with default options
# Tasks will run sequentially (continual learning)
python3 run_experiments.py \
    --algorithm "$ALGORITHM" \
    --env "$ENV" \
    --seed "$SEED" \
    --start-mode 0 \
    --first-mode 0 \
    --last-mode $((NUM_MODES - 1))

echo "=========================================="
echo "Atari experiment completed successfully!"
echo "=========================================="

