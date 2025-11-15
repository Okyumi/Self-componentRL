# HPC Module Loading Guide

## Recommended Module Versions

Based on the installed packages and available modules on your HPC, here are the recommended module versions:

```bash
module purge
module load python/3.10          # Python 3.10 (compatible with 3.9 used in venv)
module load cuda/12.2.0           # CUDA 12.2.0 (best available match for PyTorch 2.8.0+cu128)
module load ffmpeg/4.2.2          # For video rendering/recording
module load mesa/20.2.1            # For graphics rendering (Meta-World, Atari)
```

## Available CUDA Versions on Your HPC

Based on `module avail cuda`, your HPC has:
- `cuda/10.0.130` - Too old, not recommended
- `cuda/11.2.67` - Too old, not recommended  
- `cuda/11.8.0` - May work but less ideal
- `cuda/12.2.0` - **RECOMMENDED** (closest to PyTorch's CUDA 12.8)

## CUDA Version Selection

**Best choice: CUDA 12.2.0** - This is the closest available version to PyTorch 2.8.0's CUDA 12.8 requirement. CUDA 12.x versions are generally backward compatible.

**Alternative: CUDA 11.8.0** - If CUDA 12.2.0 doesn't work, try this. PyTorch 2.8.0+cu128 may still work with CUDA 11.8, but you might encounter compatibility issues.

**Note:** PyTorch 2.8.0 was compiled with CUDA 12.8. While it may work with CUDA 11.8+, you might encounter issues. If you have problems, consider:
- Using CUDA 12.x if available
- Or reinstalling PyTorch with CUDA 11.8 support

## Python Version

- **Recommended:** Python 3.10 (close to 3.9.16 used in venv, good compatibility)
- **Alternative:** Python 3.9 (matches venv exactly)

## Complete Module Load Script

Save this as `load_modules.sh`:

```bash
#!/bin/bash
module purge
module load python/3.10
module load cuda/12.2.0    # Best available match for PyTorch 2.8.0+cu128
module load ffmpeg/4.2.2
module load mesa/20.2.1

# Activate virtual environment
cd /scratch/yd2247/Self-componentRL
source venv/bin/activate

# Verify CUDA is available
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda if torch.cuda.is_available() else \"N/A\"}')"
```

## Checking Available Modules

To see what's available on your HPC:

```bash
module avail python
module avail cuda
module avail ffmpeg
module avail mesa
```

## Troubleshooting

### If CUDA 12.2.0 doesn't work:
1. Try CUDA 11.8.0 as an alternative: `module load cuda/11.8.0`
2. If you still have issues, you may need to reinstall PyTorch with CUDA 11.8 support
3. Check CUDA compatibility: `python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"`

### If CUDA is not detected after loading modules:
```bash
# Check CUDA path
echo $CUDA_HOME
which nvcc

# Verify PyTorch can see CUDA
python -c "import torch; print(torch.cuda.is_available())"
```

### For rendering issues (Meta-World):
- Ensure Mesa is loaded
- May need X11 forwarding for display: `ssh -X username@hpc`
- Or use headless rendering: Set `MUJOCO_GL=osmesa` environment variable

