# Setup Summary for Self-componentRL

## ✅ Completed Steps

### 1. Repository Cloned
- Repository cloned from: `https://github.com/Okyumi/Self-componentRL.git`
- Location: `/scratch/yd2247/Self-componentRL`

### 2. Virtual Environment Created
- Virtual environment created at: `venv/`
- Python version: 3.9.16
- pip version: 25.3

### 3. Dependencies Installed
- **Atari experiments requirements** installed successfully ✅
- **Meta-World experiments requirements** installed successfully ✅
- Key packages installed:
  - PyTorch 2.8.0+cu128 (upgraded for compatibility)
  - Torchvision 0.23.0+cu128
  - Gymnasium 0.29.1
  - Stable-Baselines3 2.2.1
  - Meta-World 2.0.0
  - MuJoCo 2.3.7
  - TensorBoard 2.15.1
  - OpenCV 4.7.0.72
  - WandB 0.16.1
  - And all other dependencies

## 📝 Notes

### Package Versions
- PyTorch was upgraded from 2.1.2 to 2.8.0 during torchvision installation to resolve version conflicts. All packages import successfully and should work correctly.
- NumPy is at version 1.26.3 (compatible with all packages).
- Meta-World doesn't expose a `__version__` attribute, but it's installed and imports successfully.

## 🚀 Next Steps

### To activate the environment:
```bash
cd /scratch/yd2247/Self-componentRL
source venv/bin/activate
```

### To run Atari experiments:
```bash
# See available options
python experiments/atari/run_ppo.py --help

# Run with default settings
python experiments/atari/run_ppo.py
```

### To test the agent:
```bash
python experiments/atari/test_agent.py --help
```

### To process results:
```bash
python experiments/atari/process_results.py --help
```

### To run Meta-World experiments:
```bash
# See available options
python experiments/meta-world/run_sac.py --help

# Run with default settings
python experiments/meta-world/run_sac.py
```

### To test Meta-World agent:
```bash
python experiments/meta-world/test_agent.py --help
```

## 📚 Repository Structure

```
Self-componentRL/
├── componet/          # CompoNet architecture implementation
├── experiments/
│   ├── atari/         # SpaceInvaders and Freeway experiments (✅ Setup complete)
│   └── meta-world/    # Meta-World experiments (✅ Setup complete)
├── utils/             # Shared utilities
└── venv/              # Virtual environment (✅ Created)
```

## 📊 Experiment Tracking Setup

### Wandb Configuration
- **Atari project**: `crl_atari`
- **Meta-World project**: `crl_metaworld`
- **Entity**: Uses default logged-in user (set to `None` in code to avoid permission errors)
- **Tracking**: Both environments have `--track` flag enabled by default in `run_experiments.py`
- View projects at: https://wandb.ai/[your-username]/crl_atari and https://wandb.ai/[your-username]/crl_metaworld

### TensorBoard
- **Atari logs**: `experiments/atari/runs/`
- **Meta-World logs**: `experiments/meta-world/runs/`
- **View logs**: Use the helper script or activate venv first:
  ```bash
  # Option 1: Use helper script
  ./scripts/view_tensorboard.sh atari
  ./scripts/view_tensorboard.sh metaworld
  
  # Option 2: Manual (must activate venv first!)
  cd /scratch/yd2247/SelfcomponentRL
  source venv/bin/activate
  tensorboard --logdir experiments/atari/runs
  tensorboard --logdir experiments/meta-world/runs
  ```

## 🎯 Running Experiments - Important Notes

### Meta-World Experiments
**⚠️ IMPORTANT**: For Meta-World, algorithms `componet`, `finetune`, and `from-scratch` require task 0 to be run first with `simple` algorithm.

**Correct order:**
1. First, run `simple` to create task 0's model:
   ```bash
   sbatch scripts/run_metaworld_single.sh simple 0
   ```

2. Then, run other algorithms (they will start from task 1 and load task 0's model):
   ```bash
   sbatch scripts/run_metaworld_single.sh componet 0
   sbatch scripts/run_metaworld_single.sh finetune 0
   ```

**Why?** These algorithms automatically skip task 0 and start from task 1, but they need task 0's model (`task_0__simple__run_sac__0/model.pt`) to exist.

**Algorithms that can start from task 0:**
- `simple` - Can start from task 0 (no dependencies)
- `packnet` - Can start from task 0
- `prognet` - Can start from task 0

### Atari Experiments
**✅ No special order needed!** You can start from mode 0 with any algorithm.

The script automatically handles sequential dependencies:
- Mode 0: Trains from scratch (no previous models needed)
- Mode 1: Automatically loads mode 0's model
- Mode 2: Automatically loads modes 0-1's models
- And so on...

**Example:**
```bash
# This will run all modes sequentially, handling dependencies automatically
# Usage:
sbatch run_atari_single.sh <algorithm> <env> <seed>

# Examples:
sbatch run_atari_single.sh componet ALE/SpaceInvaders-v5 42
sbatch run_atari_single.sh finetune ALE/Freeway-v5 123
sbatch scripts/run_atari_single.sh componet ALE/SpaceInvaders-v5 42
```

### HPC Scripts Available
- `scripts/run_atari_single.sh` - Run single Atari experiment (algorithm, env, seed)
- `scripts/run_metaworld_single.sh` - Run single Meta-World experiment (algorithm, seed)
- `scripts/run_paper_experiments.sh` - Run all experiments (comprehensive, takes long time)
- `scripts/view_tensorboard.sh` - View TensorBoard logs (fixes conda path issues)

## 🔗 References

- Original paper: [Self-Composing Policies for Scalable Continual Reinforcement Learning](https://openreview.net/pdf?id=f5gtX2VWSB)
- ICML 2024: [Oral Presentation](https://icml.cc/virtual/2024/oral/35492)
- Based on: [CleanRL](https://github.com/vwxyzjn/cleanrl)

