#!/bin/bash

compound=`awk "NR==$1" job_id.index`

vina --config dock.conf --ligand compounds/${compound}.pdbqt --out docking/${compound}_out.pdbqt --log docking/${compound}_out.log 

