import subprocess
import argparse
import random
import os
from tasks import tasks


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--algorithm",
        type=str,
        choices=[
            "simple",
            "componet",
            "finetune",
            "from-scratch",
            "prognet",
            "packnet",
        ],
        required=True,
    )
    parser.add_argument("--seed", type=int, required=True)
    parser.add_argument("--no-run", default=False, action="store_true")

    parser.add_argument("--start-mode", type=int, required=True)
    parser.add_argument("--track", default=False, action="store_true", help="if toggled, this experiment will be tracked with Weights and Biases")
    return parser.parse_args()


args = parse_args()

modes = list(range(20)) if args.algorithm != "simple" else list(range(10))

# NOTE: If the algoritm is not `simple`, it always should start from the second task
# But we need to run task 0 first with "simple" algorithm to create the base model
needs_task0 = args.algorithm not in ["simple", "packnet", "prognet"] and args.start_mode == 0

if needs_task0:
    start_mode = 1
else:
    start_mode = args.start_mode

run_name = (
    lambda task_id: f"task_{task_id}__{args.algorithm if task_id > 0 or args.algorithm in ['packnet', 'prognet'] else 'simple'}__run_sac__{args.seed}"
)

# Initialize wandb if tracking is enabled
if args.track:
    import wandb
    
    experiment_run_name = f"{args.algorithm}__seed_{args.seed}__start_{start_mode}"
    wandb.init(
        project="self-componentCRL-test",
        entity=None,
        sync_tensorboard=True,
        config=vars(args),
        name=experiment_run_name,
        monitor_gym=True,
        save_code=True,
    )

# If we need task 0, run it first with "simple" algorithm
if needs_task0 and not args.no_run:
    task0_run_name = run_name(0)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    task0_path = os.path.join(script_dir, f"agents/{task0_run_name}")
    
    # Check if task 0 model already exists
    if not os.path.exists(f"{task0_path}/model.pt"):
        print(f"Running task 0 with 'simple' algorithm to create base model...")
        task0_params = f"--model-type=simple --task-id=0 --seed={args.seed} --save-dir=agents"
        if args.track:
            task0_params += " --track --wandb-project-name=self-componentCRL-test"
        cmd = f"python3 run_sac.py {task0_params}"
        print(cmd)
        res = subprocess.run(cmd.split(" "), cwd=script_dir)
        if res.returncode != 0:
            print(f"*** Task 0 failed with code {res.returncode}. Stopping on error.")
            quit(1)
        print(f"Task 0 completed. Continuing with {args.algorithm} from task 1...")
    else:
        print(f"Task 0 model already exists at {task0_path}/model.pt. Skipping task 0.")

first_idx = modes.index(start_mode)
for i, task_id in enumerate(modes[first_idx:]):
    params = f"--model-type={args.algorithm} --task-id={task_id} --seed={args.seed}"
    params += f" --save-dir=agents"

    if first_idx > 0 or i > 0:
        # multiple previous modules
        if args.algorithm in ["componet", "prognet"]:
            params += " --prev-units"
            for i in modes[: modes.index(task_id)]:
                params += f" agents/{run_name(i)}"
        # single previous module
        elif args.algorithm in ["finetune", "packnet"]:
            params += f" --prev-units agents/{run_name(task_id-1)}"

    # Launch experiment
    cmd = f"python3 run_sac.py {params}"
    print(cmd)

    if not args.no_run:
        # Run from the meta-world directory so relative imports work
        script_dir = os.path.dirname(os.path.abspath(__file__))
        res = subprocess.run(cmd.split(" "), cwd=script_dir)
        if res.returncode != 0:
            print(f"*** Process returned code {res.returncode}. Stopping on error.")
            quit(1)
