#!/bin/bash
#SBATCH --partition=gpu_a100
#SBATCH --output=%j.out
#SBATCH --error=%j.err
#SBATCH --time=48:00:00
#SBATCH --job-name=rosetta

date

module load CUDA/11.3.1
ln -sf /home/van/Programs/RoseTTAFold/run_pyrosetta_ver.sh

./run_pyrosetta_ver.sh bax.fa .

date

