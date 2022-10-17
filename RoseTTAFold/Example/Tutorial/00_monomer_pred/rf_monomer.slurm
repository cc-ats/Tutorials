#!/bin/bash
#SBATCH --partition=gpu_a100
#SBATCH --ntasks=10
#SBATCH --mem=10G
#SBATCH --output=%j.out
#SBATCH --error=%j.err
#SBATCH --time=48:00:00
#SBATCH --job-name=rosetta

date

module load CUDA/11.3.1
eval "$(/ourdisk/hpc/ccats/dont_archive/van/.Programs/miniconda3/bin/conda shell.bash hook)"
conda activate RoseTTAFold

which conda

ln -sf /home/van/Programs/RoseTTAFold/run_pyrosetta_ver.sh

./run_pyrosetta_ver.sh bax.fa .

date

