#!/bin/bash
#SBATCH --job-name=paper_replication
#SBATCH --time=48:00:00
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=16
#SBATCH --mem=32GB
#SBATCH --partition=nvidia
#SBATCH --output=/scratch/yd2247/SelfcomponentRL/logs/%j.out
#SBATCH --error=/scratch/yd2247/SelfcomponentRL/logs/%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yd2247@nyu.edu

# ============================================================================
# Paper Replication Script
# ============================================================================
# This script replicates the paper results for both Atari and Meta-World
# environments using default CLI options as specified by the authors.
#
# Usage:
#   sbatch run_paper_experiments.sh [SEED]
#
#   SEED: Random seed (default: 42)
#
# The script runs:
#   - Atari: All algorithms on SpaceInvaders and Freeway
#   - Meta-World: All algorithms on the full task suite
#
# Note: This will run all experiments sequentially. For parallel execution,
#       consider splitting into separate jobs or using job arrays.
# ============================================================================

set -euo pipefail

echo "SLURM_JOBID: ${SLURM_JOBID:-}"
echo "Starting paper replication experiments..."

# Load modules
module purge
module load python/3.10
module load cuda/12.2.0
module load ffmpeg/4.2.2
module load mesa/20.2.1

# Use scratch for caches/tmp (avoid home quota)
export XDG_CACHE_HOME=/scratch/yd2247/.cache
export UV_CACHE_DIR=/scratch/yd2247/.cache/uv
export TMPDIR=/scratch/yd2247/tmp
mkdir -p "$XDG_CACHE_HOME" "$UV_CACHE_DIR" "$TMPDIR"

# Headless rendering for Atari and Meta-World
export MUJOCO_GL=egl

# Navigate to project directory
cd /scratch/yd2247/SelfcomponentRL
source venv/bin/activate

# Create logs directory if it doesn't exist
mkdir -p logs

# Default seed (can be overridden)
SEED=${1:-42}

echo "Using seed: $SEED"
echo "=========================================="

# ============================================
# ATARI EXPERIMENTS
# ============================================
echo "Starting Atari experiments..."
cd experiments/atari

# Atari environments
ATARI_ENVS=("ALE/SpaceInvaders-v5" "ALE/Freeway-v5")

# Atari algorithms
ATARI_ALGORITHMS=("componet" "finetune" "from-scratch" "prog-net" "packnet")

for env in "${ATARI_ENVS[@]}"; do
    echo "----------------------------------------"
    echo "Running experiments for environment: $env"
    
    # Get the number of modes for this environment
    if [[ "$env" == "ALE/SpaceInvaders-v5" ]]; then
        NUM_MODES=10
    else
        NUM_MODES=8
    fi
    
    for algorithm in "${ATARI_ALGORITHMS[@]}"; do
        echo "  Algorithm: $algorithm"
        
        # Run with default options (start from mode 0, use all modes)
        python3 run_experiments.py \
            --algorithm "$algorithm" \
            --env "$env" \
            --seed "$SEED" \
            --start-mode 0 \
            --first-mode 0 \
            --last-mode $((NUM_MODES - 1))
        
        if [ $? -ne 0 ]; then
            echo "ERROR: Atari experiment failed for $algorithm on $env"
            exit 1
        fi
    done
done

cd ../..

# ============================================
# META-WORLD EXPERIMENTS
# ============================================
echo "=========================================="
echo "Starting Meta-World experiments..."
cd experiments/meta-world

# Meta-World algorithms
META_ALGORITHMS=("simple" "componet" "finetune" "from-scratch" "prognet" "packnet")

for algorithm in "${META_ALGORITHMS[@]}"; do
    echo "----------------------------------------"
    echo "Running experiments for algorithm: $algorithm"
    
    # Run with default options (start-mode=0, script will handle logic internally)
    python3 run_experiments.py \
        --algorithm "$algorithm" \
        --seed "$SEED" \
        --start-mode 0
    
    if [ $? -ne 0 ]; then
        echo "ERROR: Meta-World experiment failed for $algorithm"
        exit 1
    fi
done

cd ../..

echo "=========================================="
echo "All experiments completed successfully!"
echo "=========================================="

