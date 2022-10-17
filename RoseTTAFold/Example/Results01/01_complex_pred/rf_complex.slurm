#!/bin/bash
#SBATCH --partition=gpu_a100
#SBATCH --ntasks=10
#SBATCH --mem=20G
#SBATCH --output=%j.out
#SBATCH --error=%j.err
#SBATCH --time=48:00:00
#SBATCH --job-name=rosetta

date

module load CUDA/11.3.1

eval "$(/ourdisk/hpc/ccats/dont_archive/van/.Programs/miniconda3/bin/conda shell.bash hook)"
conda activate RoseTTAFold

ln -sf /home/van/Programs/RoseTTAFold/network_2track/predict_msa.py .
cp /home/van/Programs/RoseTTAFold/example/complex_modeling/make_joint_MSA_bacterial.py . 

subunit1="pard"
subunit2="pare"
MAKE_MSA="/home/van/Programs/RoseTTAFold/input_prep/make_msa.sh"
WDIR=`pwd`
PIPEDIR="/home/van/Programs/RoseTTAFold"
n_1=`cat ${subunit1}.fa | grep -v ">" | wc -c`
n_2=`cat ${subunit2}.fa | grep -v ">" | wc -c`
CPU=8
MEM=15

mkdir -p ${WDIR}/log

#Generate MSA for subunit1 and subunit2
if [ ! -s ${subunit2}.a3m ]; then
bash ${MAKE_MSA} ${subunit1}.fa ${WDIR} ${CPU} ${MEM} 1> ${WDIR}/log/make_msa1.stdout 2> ${WDIR}/log/make_msa1.stderr
bash ${MAKE_MSA} ${subunit2}.fa ${WDIR} ${CPU} ${MEM} 1> ${WDIR}/log/make_msa2.stdout 2> ${WDIR}/log/make_msa2.stderr
echo "Finished MSA for Subunit1 & Subunit2!"
date
fi

# Make pair alignments
if [ ! -s paired.a3m ]; then
python make_joint_MSA_bacterial.py ${subunit1}.a3m ${subunit2}.a3m
echo "Finished Preparing Pair Alignments!"
date
fi

# Filter pair alignments
if [ ! -s filtered.a3m ]; then
hhfilter -i paired.a3m -o filtered.a3m -id 90 -cov 75
echo "Finished Filtering Pair Alignments!"
date
fi

# template prediction
python predict_msa.py -msa paired.a3m -npz complex_template.npz -L1 ${n_1}
echo "Finished Templated Prediction for pair!"
date

# structure prediction
#export PYTHONPATH="/home/van/Programs/RoseTTAFold/network"
python -u ${PIPEDIR}/network/predict_complex.py -i ${WDIR}/filtered.a3m -o ${WDIR}/complex -Ls ${n_1} ${n_2} --templ_npz complex_template.npz 1>${WDIR}/log/distance.stdout 2>${WDIR}/log/distance.stderr

echo "Finished Predicting Complex!"
date

conda deactivate

# Adding side chains and relaxing structure
conda activate folding
echo $CONDA_PREFIX
mkdir -p ${WDIR}/pdb-3track
complex="paparde"

# Prepare folding list for GNU Parallel
for m in 0 1 2; do
    for p in 0.05 0.15 0.25 0.35 0.45; do
        for ((i=0;i<1;i++)); do
            if [ ! -f ${WDIR}/pdb-3track/model${i}_${m}_${p}.pdb ]; then
                echo "python -u ${PIPEDIR}/folding/RosettaTR.py --roll -r 3 -pd $p -m $m -sg 7,3 ${WDIR}/complex.npz ${WDIR}/${complex}.fa ${WDIR}/pdb-3track/model${i}_${m}_${p}.pdb"
            fi
        done
    done
done > $WDIR/parallel.fold.list

#Running GNU Parallel
N=`cat $WDIR/parallel.fold.list | wc -l`
if [ "$N" -gt "0" ]; then
    echo "Running parallel RosettaTR.py"    
    parallel -j $CPU < $WDIR/parallel.fold.list > $WDIR/log/folding.stdout 2> $WDIR/log/folding.stderr
fi

count=$(find $WDIR/pdb-3track -maxdepth 1 -name '*.npz' | grep -v 'features' | wc -l)
if [ "$count" -lt "15" ]; then
    # run DeepAccNet-msa
    echo "Running DeepAccNet-msa"
    python ${PIPEDIR}/DAN-msa/ErrorPredictorMSA.py --roll -p $CPU ${WDIR}/${in_fasta}.npz ${WDIR}/pdb-3track ${WDIR}/pdb-3track 1> ${WDIR}/log/DAN_msa.stdout 2> ${WDIR}/log/DAN_msa.stderr

fi

mkdir -p ${WDIR}/model
if [ ! -s ${WDIR}/model/model_5.crderr.pdb ]
then
    echo "Picking final models"
    python -u -W ignore ${PIPEDIR}/DAN-msa/pick_final_models.div.py \
        $WDIR/pdb-3track $WDIR/model $CPU > $WDIR/log/pick.stdout 2> $WDIR/log/pick.stderr
    echo "Final models saved in: ${WDIR}/model"
fi
echo "Done"
