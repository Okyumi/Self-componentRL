# Progress Tracking in Original Code

The code uses **both TensorBoard and Weights & Biases (wandb)** for tracking experiments.

## Tracking Setup

### 1. Atari Experiments (`experiments/atari/`)

#### Tracking Flag
- **Location**: `run_experiments.py:47`
- **Code**: `params = f"--track --model-type={model_type} ..."`
- The `--track` flag is **always enabled** in the experiment runner

#### TensorBoard Setup
- **Location**: `run_ppo.py:174`
- **Code**: 
  ```python
  writer = SummaryWriter(f"runs/{run_name}")
  ```
- Creates TensorBoard logs in `experiments/atari/runs/{run_name}/`

#### Wandb Setup (Optional, when `--track` is True)
- **Location**: `run_ppo.py:162-173`
- **Code**:
  ```python
  if args.track:
      import wandb
      wandb.init(
          project=args.wandb_project_name,  # "ppo-atari"
          entity=args.wandb_entity,
          sync_tensorboard=True,  # Syncs TensorBoard logs to wandb
          config=vars(args),
          name=run_name,
          monitor_gym=True,
          save_code=True,
      )
  ```
- **Note**: `sync_tensorboard=True` means wandb reads from TensorBoard logs

#### Metrics Logged (via `writer.add_scalar()`)
- **Location**: `run_ppo.py:330-335, 443-454`
- **Metrics tracked**:
  - `charts/episodic_return` - Episode reward
  - `charts/episodic_length` - Episode length
  - `losses/value_loss` - Value function loss
  - `losses/policy_loss` - Policy gradient loss
  - `losses/entropy` - Entropy loss
  - `losses/old_approx_kl` - Old KL divergence
  - `losses/approx_kl` - Approximate KL divergence
  - `losses/clipfrac` - Clipping fraction
  - `losses/explained_variance` - Explained variance
  - `charts/learning_rate` - Learning rate
  - `charts/SPS` - Steps per second

#### Hyperparameters Logged
- **Location**: `run_ppo.py:175-179`
- **Code**:
  ```python
  writer.add_text(
      "hyperparameters",
      "|param|value|\n|-|-|\n%s"
      % ("\n".join([f"|{key}|{value}|" for key, value in vars(args).items()])),
  )
  ```

---

### 2. Meta-World Experiments (`experiments/meta-world/`)

#### Tracking Flag
- **Location**: `run_experiments.py:46`
- **Note**: Meta-World does **NOT** pass `--track` flag by default
- The `track` argument defaults to `False` in `run_sac.py:39`

#### TensorBoard Setup
- **Location**: `run_sac.py:206`
- **Code**: 
  ```python
  writer = SummaryWriter(f"runs/{run_name}")
  ```
- Creates TensorBoard logs in `experiments/meta-world/runs/{run_name}/`

#### Wandb Setup (Optional, when `--track` is True)
- **Location**: `run_sac.py:194-205`
- **Code**:
  ```python
  if args.track:
      import wandb
      wandb.init(
          project=args.wandb_project_name,  # "cw-sac"
          entity=args.wandb_entity,
          sync_tensorboard=True,  # Syncs TensorBoard logs to wandb
          config=vars(args),
          name=run_name,
          monitor_gym=True,
          save_code=True,
      )
  ```

#### Metrics Logged (via `writer.add_scalar()`)
- **Location**: `run_sac.py:342-348, 437-455, 186-187`
- **Metrics tracked**:
  - `charts/episodic_return` - Episode reward
  - `charts/episodic_length` - Episode length
  - `charts/success` - Task success rate
  - `charts/test_episodic_return` - Test episode return
  - `charts/test_success` - Test success rate
  - `losses/qf1_loss` - Q-function 1 loss
  - `losses/qf2_loss` - Q-function 2 loss
  - `losses/qf_loss` - Combined Q-function loss
  - `losses/actor_loss` - Actor/policy loss
  - `losses/alpha` - Entropy coefficient
  - `charts/SPS` - Steps per second

#### Hyperparameters Logged
- **Location**: `run_sac.py:207-211`
- **Code**: Same as Atari (logs all args as text)

---

## Summary

1. **TensorBoard**: Always used (writes to `runs/{run_name}/`)
2. **Wandb**: Only used when `--track` flag is passed
   - Atari: `--track` is **always** passed (line 47 of `run_experiments.py`)
   - Meta-World: `--track` is now **always** passed (line 46 of `run_experiments.py`)
3. **Log Location**: 
   - Atari: `experiments/atari/runs/`
   - Meta-World: `experiments/meta-world/runs/`
4. **Viewing Logs**: 
   - TensorBoard: **Must activate venv first!**
     ```bash
     cd /scratch/yd2247/SelfcomponentRL
     source venv/bin/activate
     tensorboard --logdir experiments/atari/runs
     # or
     tensorboard --logdir experiments/meta-world/runs
     ```
   - Wandb: If enabled, view at wandb.ai (project: "crl_atari" or "crl_metaworld", entity: "yd2247")

## Key Files for Tracking

- `experiments/atari/run_ppo.py` - Main training script with tracking
- `experiments/meta-world/run_sac.py` - Main training script with tracking
- `experiments/atari/run_experiments.py:47` - Enables `--track` flag
- `experiments/meta-world/run_experiments.py` - Does NOT enable `--track` by default

