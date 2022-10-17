#!/bin/bash
#SBATCH --partition=gpu_a100
#SBATCH --ntasks=10
#SBATCH --output=%j.out
#SBATCH --error=%j.err
#SBATCH --time=48:00:00
#SBATCH --job-name=pol3
##SBATCH --exclude=c736

export CUDA_VISIBLE_DEVICES=1

date
hostname

module load CUDA/11.3.1

eval "$(/ourdisk/hpc/ccats/dont_archive/van/.Programs/miniconda3/bin/conda shell.bash hook)"
conda activate omegafold 

input="rcsb_pdb_7AST"

# To Run: 
# omegafold [input.fasta] [working directory - output here]
#omegafold ${input}.fasta . 

grep ">" ${input}.fasta | sed 's/>//' | while read i; do
grep "${i}" ${input}.fasta -A 1 > ${i}.fa
omegafold ${i}.fa .
rm ${i}.fa
done


date

