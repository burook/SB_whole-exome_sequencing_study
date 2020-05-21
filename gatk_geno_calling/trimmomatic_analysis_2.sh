#!/bin/bash

f1=$1
f2=$2
f1p=$3
f1s=$4
f2p=$5
f2s=$6
dir2=$7

java -jar /PHShome/bm363/bin/trimmomatic/trimmomatic-0.39.jar PE -threads 24 \
        ${f1} $(dirname ${f1})/${f2} \
        ${dir2}/${f1p} ${dir2}/${f1s} ${dir2}/${f2p} ${dir2}/${f2s} \
        ILLUMINACLIP:/PHShome/bm363/bin/trimmomatic/adapters/TruSeq3-PE.fa:2:30:10:2:keepBothReads \
        LEADING:3 TRAILING:3 MINLEN:36



