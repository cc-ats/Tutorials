#!/bin/bash
#SBATCH --partition=debug
#SBATCH --exclusive
#SBATCH --ntasks=20
#SBATCH --output=%j.out
#SBATCH --error=%j.err
#SBATCH --time=00:30:00
#SBATCH --job-name=vs

date

module load parallel/20190222-GCCcore-7.3.0
module load GCCcore/4.9.3
module load AutoDockVina/1.1.2

total=`ls compounds/*.pdbqt | wc -l`

mkdir -p docking

parallel --progress --jobs 10 bash rundocking.sh ::: $(seq 1 $total )

date

