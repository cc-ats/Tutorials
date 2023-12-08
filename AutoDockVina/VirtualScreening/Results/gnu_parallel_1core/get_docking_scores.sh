#!/bin/bash

ls docking/*out.pdbqt | while read i; do 
echo $i | awk -F '/' '{print $2}' | sed 's/_out.pdbqt//' | tr "\n" "\t"
grep "REMARK VINA RESULT:" ${i} -m 1 | awk '{print $4}'
done | column -t | sort -n -k 2 > docking_scores.txt

