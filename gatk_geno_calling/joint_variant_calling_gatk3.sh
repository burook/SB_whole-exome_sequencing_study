#!/bin/bash

# directory where input files are saved
dir1=$1

cd ${dir1}

module load GATK
# on erisone the GATK jar is located at $EBROOTGATK
# (its full path is /apps/software/GATK/3.8-0-Java-1.8.0_161 )


refloc1=/data/humgen/burook/ref
refloc2=/pub/genome_references/gatk-bundle/1.5/hg19


# Joint variant calling
#  
java -Xmx200g -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar \
    -T GenotypeGVCFs \
    -R ${refloc1}/genome.fa \
    -V ${dir1}/list_VCF1.list \
    --dbsnp ${refloc1}/dbsnp_135.hg19.vcf \
    --intervals exome3.bed \
    --out SysBio_exome_merged12.vcf


#    --disable_auto_index_creation_and_locking_when_reading_rods \
#   --intervals exome3.bed \
#   --disable_auto_index_creation_and_locking_when_reading_rods \
#   -nt 8 \
#     


 