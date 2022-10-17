#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --exclusive
#SBATCH --ntasks=20
#SBATCH --ntasks-per-node=20
#SBATCH --mem=0
#SBATCH --output=%j.out
#SBATCH --error=%j.err
#SBATCH --time=48:00:00
#SBATCH --job-name=INPUT

# THIS SCRIPT IS FOR MONOMER PREDICTION

#Loading module for GPU
module load CUDA/11.3.1

# Activates Richard's Conda environment prepared for Alphafold (Tensorflow, CuDNN, etc.)
eval "$(/ourdisk/hpc/ccats/dont_archive/van/.Programs/miniconda3/bin/conda shell.bash hook)"
conda activate af2.2.0

# Use Richard's Alphafold program
AF="/home/van/Programs/alphafold/run_alphafold.py"

# Sets output directory to the current folder
OUT_DIR=`pwd`

# Databases for Alphafold
#	DATA_DIR contains the sequence database for MSAs
#	DATA_DIR2 contains mmCIF and other files that require periodic updating
DATA_DIR="/opt/oscer/software/alphafold/2.0.0/data"
DATA_DIR2="/data/alphafold"

# Input name of sequence file. CHANGE THIS BETWEEN DIFFERENT RUNS!
input="INPUT"

# Set year for the maximum template year (oldest PDB you want included to the prediction).
year="2000"

python ${AF} \
 --fasta_paths=${input}.fasta \
 --output_dir=${OUT_DIR} \
 --max_template_date=${year}-01-01 \
 --use_gpu_relax=True \
 --jackhmmer_binary_path=/opt/oscer/software/HMMER/3.2.1-GCC-8.2.0-2.31.1/bin/jackhmmer \
 --data_dir=${DATA_DIR2} \
 --bfd_database_path=${DATA_DIR}/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt \
 --uniref90_database_path=${DATA_DIR}/uniref90/uniref90.fasta \
 --mgnify_database_path=${DATA_DIR}/mgnify/mgy_clusters.fa \
 --pdb70_database_path=${DATA_DIR}/pdb70/pdb70 \
 --uniclust30_database_path=${DATA_DIR}/uniclust30/uniclust30_2018_08/uniclust30_2018_08 \
 --template_mmcif_dir=${DATA_DIR2}/pdb_mmcif/mmcif_files \
 --obsolete_pdbs_path=${DATA_DIR2}/pdb_mmcif/obsolete.dat 

