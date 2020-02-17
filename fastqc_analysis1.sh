#!/bin/sh

# FastQC is aleady available on erisone
module load FastQC/0.11.8-Java-1.8

#dir1=/data/humgen/burook/sysbio_exome/raw/
dir1=/data/humgen/burook/sysbio_exome/trimmomatic_results1/
#dir2=/data/humgen/burook/sysbio_exome/fastq_result1
dir2=/data/humgen/burook/sysbio_exome/fastq_result2

cd ${dir1}

for file in $(ls $dir1)
do
    fastqc $file -o $dir2
done

