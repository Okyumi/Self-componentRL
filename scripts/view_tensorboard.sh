#!/bin/bash
# ============================================================================
# TensorBoard Viewer Script
# ============================================================================
# Helper script to view TensorBoard logs (fixes the conda path issue)
#
# Usage:
#   ./view_tensorboard.sh [atari|metaworld]
#
# Example:
#   ./view_tensorboard.sh atari
#   ./view_tensorboard.sh metaworld
# ============================================================================

set -euo pipefail

# Parse argument
ENV_TYPE=${1:-atari}

# Navigate to project directory
cd /scratch/yd2247/SelfcomponentRL

# Activate venv (this ensures we use the correct tensorboard)
source venv/bin/activate

# Determine log directory
if [[ "$ENV_TYPE" == "atari" ]]; then
    LOGDIR="experiments/atari/runs"
elif [[ "$ENV_TYPE" == "metaworld" ]]; then
    LOGDIR="experiments/meta-world/runs"
else
    echo "ERROR: Unknown environment type. Use 'atari' or 'metaworld'"
    exit 1
fi

# Check if log directory exists
if [[ ! -d "$LOGDIR" ]]; then
    echo "ERROR: Log directory $LOGDIR does not exist"
    exit 1
fi

echo "Starting TensorBoard for $ENV_TYPE..."
echo "Log directory: $LOGDIR"
echo "Access at: http://localhost:6006"
echo "Press Ctrl+C to stop"
echo "=========================================="

# Start TensorBoard
tensorboard --logdir "$LOGDIR" --port 6006

