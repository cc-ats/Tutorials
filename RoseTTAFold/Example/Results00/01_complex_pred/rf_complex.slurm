#!/bin/bash
#SBATCH --partition=gpu_a100
#SBATCH --output=%j.out
#SBATCH --error=%j.err
#SBATCH --time=48:00:00
#SBATCH --job-name=rosetta

date

module load CUDA/11.3.1

eval "$(/ourdisk/hpc/ccats/dont_archive/van/.Programs/miniconda3/bin/conda shell.bash hook)"
conda activate RoseTTAFold

ln -sf /home/van/Programs/RoseTTAFold/network_2track/predict_msa.py .
ln -sf /home/van/Programs/RoseTTAFold/network/predict_complex.py .
cp /home/van/Programs/RoseTTAFold/example/complex_modeling/make_joint_MSA_bacterial.py . 

subunit1="pard"
subunit2="pare"
MAKE_SS="/home/van/Programs/RoseTTAFold/input_prep/make_msa.sh"
WDIR=`pwd`
CPU=8
MEM=10

#Generate MSA for subunit1 and subunit2
bash ${MAKE_SS} ${subunit1}.fa ${WDIR} ${CPU} ${MEM} > ${WDIR}/log/make_msa.stdout 2> ${WDIR}/log/make_msa.std
bash ${MAKE_SS} ${subunit2}.fa ${WDIR} ${CPU} ${MEM} > ${WDIR}/log/make_msa.stdout 2> ${WDIR}/log/make_msa.std
echo "Finished MSA for Subunit1 & Subunit2!"
date


# Make pair alignments
python make_joint_MSA_bacterial.py ${subunit1}.a3m ${subunit2}.a3m
echo "Finished Preparing Pair Alignments!"
date


# Filter pair alignments
hhfilter -i paired.a3m -o filtered.a3m -id 90 -cov 75
echo "Finished Filtering Pair Alignments!"


date


# template prediction
#export PYTHONPATH="/home/van/Programs/RoseTTAFold/network_2track"
python predict_msa.py -msa subunit1.a3m -npz complex.npz -L1 218
echo "Finished Templated Prediction for Subunit1!"
date


# structure prediction
#export PYTHONPATH="/home/van/Programs/RoseTTAFold/network"
python predict_complex.py -i filtered.a3m -o complex -Ls 218 310 
echo "Finished Predicting Complex!"
date

