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

subunit1="pard"
n_one=`tail -n 1 ${subunit1}.fa | wc -c`
subunit2="pare"
n_two=`tail -n 1 ${subunit2}.fa | wc -c`
WDIR=`pwd`

MAKEMSA ${subunit1}.fa 
MAKEMSA ${subunit2}.fa 

make_joint_MSA_bacterial.py ${subunit1}.a3m ${subunit2}.a3m

hhfilter -i paired.a3m -o filtered.a3m -id 90 -cov 75

2TRACKMSA paired.a3m complex_template.npz ${n_one} ${WDIR}

python network/predict_complex.py -i filtered.a3m -o complex -Ls ${n_one} ${n_two} 

conda deactivate
conda activate folding

MONOFOLD ${input}.fa

dir=`pwd`
BESTMODEL ${input}.fa ${dir}

date

