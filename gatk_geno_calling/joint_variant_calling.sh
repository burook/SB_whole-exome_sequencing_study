#!/bin/bash

# directory where input files are saved
dir1=$1

cd ${dir1}

refloc1=/data/humgen/burook/ref
refloc2=/pub/genome_references/gatk-bundle/1.5/hg19

# Joint variant calling

#java -jar /PHShome/bm363/bin/gatk-4.1.7.0/gatk-package-4.1.7.0-local.jar \
#java -jar /PHShome/bm363/bin/gatk-4.1.7.0/gatk-package-4.1.7.0-spark.jar \
/PHShome/bm363/bin/gatk-4.1.7.0/gatk \
    GenotypeGVCFs \
    -R ${refloc1}/genome.fa \
    -V ${dir1}/SB_gdb \
    --dbsnp ${refloc1}/dbsnp_135.hg19.vcf \
    -O SysBio_exome_merged3.vcf
 
 