#!/bin/bash
#SBATCH --partition=debug
#SBATCH --ntasks=4
#SBATCH --output=%j.out
#SBATCH --error=%j.err
#SBATCH --time=00:05:00
#SBATCH --job-name=vs

date
module load GCCcore/4.9.3
module load AutoDockVina/1.1.2

vina --config dock.conf --ligand venetoclax.pdbqt --out venetoclax_out.pdbqt --log venetoclax_out.log

date
