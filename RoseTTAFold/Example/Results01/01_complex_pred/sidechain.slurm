#!/bin/bash
#SBATCH --partition=gpu_a100
#SBATCH --ntasks=10
#SBATCH --mem=20G
#SBATCH --output=%j.out
#SBATCH --error=%j.err
#SBATCH --time=48:00:00
#SBATCH --job-name=rosetta

set -xe

export CUDA_VISIBLE_DEVICES=1

date

module load CUDA/11.3.1

eval "$(/ourdisk/hpc/ccats/dont_archive/van/.Programs/miniconda3/bin/conda shell.bash hook)"


subunit1="pard"
subunit2="pare"
MAKE_MSA="/home/van/Programs/RoseTTAFold/input_prep/make_msa.sh"
WDIR=`pwd`
PIPEDIR="/home/van/Programs/RoseTTAFold"
n_1=`cat ${subunit1}.fa | grep -v ">" | wc -c`
n_2=`cat ${subunit2}.fa | grep -v ">" | wc -c`
CPU=8
MEM=15

# Adding side chains and relaxing structure
conda activate folding
echo $CONDA_PREFIX
mkdir -p ${WDIR}/pdb-3track
complex="paparde"

# Prepare folding list for GNU Parallel

#Running GNU Parallel
N=`cat $WDIR/parallel.fold.list | wc -l`
parallel -j $CPU < parallel.fold.list > log/folding.stdout 2> log/folding.stderr

