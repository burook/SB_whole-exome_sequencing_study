#!/bin/bash

# directory where input files are saved
dir1=$1

cd ${dir1}

refloc1=/data/humgen/burook/ref

/PHShome/bm363/bin/gatk-4.1.7.0/gatk GenomicsDBImport \
    --genomicsdb-workspace-path ${dir1}/SB_gdb \
    -L ${dir1}/201035_S6_recal3.vcf \
    --sample-name-map ${dir1}/list_VCF2.sample_map

#     -L ${dir1}/exome.bed \