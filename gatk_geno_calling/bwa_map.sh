#!/bin/bash

header=$(zcat $1 | head -n 1)
id=$(echo $header | head -n 1 | cut -f 1-4 -d":" | sed 's/@//' | sed 's/:/_/g')
sm=$(echo $header | head -n 1 | grep -Eo "[ATGCN]+$")
echo "Read Group @RG\tID:$id\tSM:$id"_"$sm\tLB:$id"_"$sm\tPL:ILLUMINA"

refloc1=/data/humgen/burook/ref


bwa mem \
    -M \
    -t 8 \
    -R $(echo "@RG\tID:$id\tSM:$id"_"$sm\tLB:$id"_"$sm\tPL:ILLUMINA") \
    ${refloc1}/genome.fa \
    $1 $2 | samtools view -Sb -  >  $3.bam

# $1 $2 > $3.sam | samtools view -Sb -  >  $3.bam
