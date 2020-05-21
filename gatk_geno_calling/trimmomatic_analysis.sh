#!/bin/bash

# directory where raw data is saved
dir1=/data/humgen/burook/sysbio_exome/raw/
# directory where results will be saved
dir2=/data/humgen/burook/sysbio_exome/trimmomatic_results1

cd ${dir1}

#for f1 in *R1_001.fastq.gz
for f1 in $(find /data/humgen/guffantilab/exome/SystemsBio/input/Exome/EXOME -type f -name '*R1_001.fastq.gz')

do
    # f1 and f2 are inpute files for forward and reverse reads
    f2=$(basename $f1 _R1_001.fastq.gz)_R2_001.fastq.gz
    # the following four are output files (forward and revers for paired and single)
    f1p=$(basename $f1 _R1_001.fastq.gz)_R1_001.pe.fastq.gz 
    f1s=$(basename $f1 _R1_001.fastq.gz)_R1_001.se.fastq.gz
    f2p=$(basename $f1 _R1_001.fastq.gz)_R2_001.pe.fastq.gz
    f2s=$(basename $f1 _R1_001.fastq.gz)_R2_001.se.fastq.gz
    
    java -jar /PHShome/bm363/bin/trimmomatic/trimmomatic-0.39.jar PE -threads 24 \
        ${f1} $(dirname ${f1})/${f2} \
        ${dir2}/${f1p} ${dir2}/${f1s} ${dir2}/${f2p} ${dir2}/${f2s} \
        ILLUMINACLIP:/PHShome/bm363/bin/trimmomatic/adapters/TruSeq3-PE.fa:2:30:10:2:keepBothReads \
        LEADING:3 TRAILING:3 MINLEN:36
done


