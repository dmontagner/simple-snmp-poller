#!/bin/bash

echo "Removing old graphs ..."
rm ./graphs/*

DBIDX=`ls DB_IDX_*.POLLDB`

echo "Generating gnuplot files ..."
for file in $DBIDX; do ./prepare-data.pl DB_CPU_MEM_WITH_IDX.DAT $file; done

PLOT=`ls *.gnuplot`

echo "Generating graphs ..."
for file in $PLOT; do gnuplot $file > $file.png; done

mv *.gnuplot* ./graphs/
mv *.dat ./graphs/

echo "Graphs generated!"
