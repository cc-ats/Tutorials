#!/bin/bash

ls compounds/*.pdbqt | sed -e 's/compounds\///;s/.pdbqt//' > job_id.index

