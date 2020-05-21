#!/bin/bash

# input bam file
f1=$1
# prefix of the output file
f2=$2
# directory where input files are saved
dir1=$3
# directory where output files will be saved
dir2=$4

cd ${dir2}

module load GATK
# on erisone the picard jar is located at $EBROOTGATK
# (its full path is /apps/software/GATK/3.8-0-Java-1.8.0_161 )

refloc1=/data/humgen/burook/ref
refloc2=/pub/genome_references/gatk-bundle/1.5/hg19


# Variant calling

java \
   -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar \
   -T HaplotypeCaller \
   -R ${refloc1}/genome.fa \
   -I ${f1} \
   --genotyping_mode DISCOVERY \
   -stand_call_conf 10 \
   --emitRefConfidence GVCF \
   -variant_index_type LINEAR -variant_index_parameter 128000 \
   --dbsnp ${refloc1}/dbsnp_135.hg19.vcf \
   --out ${f2}_recal3.vcf
