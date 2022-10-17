#!/bin/bash
#SBATCH --partition=gpu_a100
#SBATCH --output=%j.out
#SBATCH --error=%j.err
#SBATCH --time=48:00:00
#SBATCH --job-name=rosetta

export CUDA_VISIBLE_DEVICES=1

date

module load CUDA/11.3.1
source /home/van/Programs/RoseTTAFold/rosettafold.sh

eval "$(/home/van/ourdisk/.Programs/miniconda3/bin/conda shell.bash hook)"
conda activate RoseTTAFold

input="bax"

MAKEMSA ${input}.fa 

MAKESS ${input}.ss2

cat ${input}.ss2 ${input}.a3m > ${input}.msa0.ss2.a3m
HHSEARCH ${input}

PREDICTDO ${input}.a3m

conda deactivate
conda activate folding

MONOFOLD ${input}.fa

dir=`pwd`
BESTMODEL ${input}.fa ${dir}

date

