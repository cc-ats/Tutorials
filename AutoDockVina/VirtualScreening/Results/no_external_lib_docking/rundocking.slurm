#!/bin/bash
#SBATCH --partition=debug
#SBATCH --exclusive
#SBATCH --ntasks=20
#SBATCH --output=%j.out
#SBATCH --error=%j.err
#SBATCH --time=00:30:00
#SBATCH --job-name=vs

date
module load GCCcore/4.9.3
module load AutoDockVina/1.1.2

mkdir -p docking

cat job_id.index | while read -r line1; do
read -r line2
read -r line3
read -r line4
read -r line5
read -r line6
read -r line7
read -r line8
read -r line9
read -r line10
vina --config dock.conf --ligand compounds/${line1}.pdbqt --out docking/${line1}_out.pdbqt --log docking/${line1}_out.log &
vina --config dock.conf --ligand compounds/${line2}.pdbqt --out docking/${line2}_out.pdbqt --log docking/${line2}_out.log &
vina --config dock.conf --ligand compounds/${line3}.pdbqt --out docking/${line3}_out.pdbqt --log docking/${line3}_out.log &
vina --config dock.conf --ligand compounds/${line4}.pdbqt --out docking/${line4}_out.pdbqt --log docking/${line4}_out.log &
vina --config dock.conf --ligand compounds/${line5}.pdbqt --out docking/${line5}_out.pdbqt --log docking/${line5}_out.log &
vina --config dock.conf --ligand compounds/${line6}.pdbqt --out docking/${line6}_out.pdbqt --log docking/${line6}_out.log &
vina --config dock.conf --ligand compounds/${line7}.pdbqt --out docking/${line7}_out.pdbqt --log docking/${line7}_out.log &
vina --config dock.conf --ligand compounds/${line8}.pdbqt --out docking/${line8}_out.pdbqt --log docking/${line8}_out.log &
vina --config dock.conf --ligand compounds/${line9}.pdbqt --out docking/${line9}_out.pdbqt --log docking/${line9}_out.log &
vina --config dock.conf --ligand compounds/${line10}.pdbqt --out docking/${line10}_out.pdbqt --log docking/${line10}_out.log &
wait
done

date
