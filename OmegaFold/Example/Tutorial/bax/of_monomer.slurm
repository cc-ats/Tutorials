#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --ntasks=10
#SBATCH --output=%j.out
#SBATCH --error=%j.err
#SBATCH --time=00:30:00
#SBATCH --job-name=bax
#SBATCH --exclude=c736

date
hostname

module load CUDA/11.3.1

eval "$(/ourdisk/hpc/ccats/dont_archive/van/.Programs/miniconda3/bin/conda shell.bash hook)"
conda activate omegafold 

# To Run: 
# omegafold [input.fasta] [working directory - output here]
omegafold bax.fasta . 

date

