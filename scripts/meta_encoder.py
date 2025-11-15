# file: meta_wrapper.py
import argparse
import os
import subprocess
from typing import List, Tuple, Dict, Any

def expand_settings(spec: List) -> Tuple[List[int], dict, int, dict]:
    keys, shorts, values_list = [], [], []
    for i in range(0, len(spec), 3):
        keys.append(spec[i])
        shorts.append(spec[i + 1])
        values_list.append(spec[i + 2])

    sizes = [len(v) for v in values_list]
    total = 1
    for s in sizes:
        total *= s

    def index_to_combo(index: int) -> List[int]:
        combo = []
        for size in reversed(sizes):
            combo.append(index % size)
            index //= size
        return list(reversed(combo))

    hyper2short = {keys[i]: shorts[i] for i in range(len(keys))}
    return list(range(total)), {
        "keys": keys,
        "values_list": values_list,
        "index_to_combo": index_to_combo,
    }, total, hyper2short

def combo_to_setting(combo_idxes: List[int], keys: List[str], values_list: List[List[Any]]) -> Dict[str, Any]:
    actual = {}
    for i, key in enumerate(keys):
        actual[key] = values_list[i][combo_idxes[i]]
    return actual

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--setting", type=int, default=0)
    parser.add_argument("--dry", action="store_true", default=False)
    parser.add_argument("--repo_root", type=str, default=".")
    args = parser.parse_args()

    # edit only this block to sweep configs
    settings = [
        # algorithm choices from run_experiments.py
        "algorithm", "ALG", ["componet"],  # ["componet", "prognet", "packnet", "finetune", "from-scratch"],
        # seeds
        "seed", "S", [0],  # list(range(10)),
        # starting task id in their script
        "start_mode", "SM", [0],
        # optional toggle to print only
        "no_run", "NR", [False],
    ]

    indexes, spec, total, _ = expand_settings(settings)
    if args.setting >= total:
        print(f"Setting {args.setting} is out of range 0..{total - 1}")
        return

    combo = spec["index_to_combo"](args.setting)
    actual = combo_to_setting(combo, spec["keys"], spec["values_list"])

    # map setting keys to CLI flags for the paper repo
    flag_map = {
        "algorithm": "--algorithm",
        "seed": "--seed",
        "start_mode": "--start-mode",
        "no_run": "--no-run",
    }

    cmd = ["python3", "experiments/meta-world/run_experiments.py"]
    for k, v in actual.items():
        flag = flag_map.get(k)
        if flag is None:
            continue
        if isinstance(v, bool):
            if v:
                cmd.append(flag)
        else:
            cmd += [flag, str(v)]
    
    # Enable wandb tracking
    cmd.append("--track")

    print("Resolved setting")
    for k in spec["keys"]:
        print(f"  {k}: {actual[k]}")
    print("Launching:", " ".join(cmd))

    if args.dry or actual.get("no_run", False):
        return

    env = os.environ.copy()
    # safe defaults for headless mujoco on HPC
    env.setdefault("MUJOCO_GL", "egl")
    subprocess.run(cmd, check=True, cwd=args.repo_root, env=env)

if __name__ == "__main__":
    main()
