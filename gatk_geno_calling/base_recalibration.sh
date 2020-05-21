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

module load R
module load GATK
# on erisone the GATK jar is located at $EBROOTGATK
# (its full path is /apps/software/GATK/3.8-0-Java-1.8.0_161 )

refloc1=/data/humgen/burook/ref
refloc2=/pub/genome_references/gatk-bundle/1.5/hg19

# Base recalibratin is done in two passes

# Base recalibration (first pass)

java -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar -T BaseRecalibrator \
   -I ${f1} \
   -R ${refloc1}/genome.fa \
   -knownSites ${refloc1}/1000G_omni2.5.hg19.vcf \
   -knownSites ${refloc1}/dbsnp_135.hg19.vcf \
   -knownSites ${refloc1}/hapmap_3.3.hg19.vcf \
   -knownSites ${refloc1}/Mills_and_1000G_gold_standard.indels.hg19.vcf \
   --out ${f2}_recal_data.table

# Base recalibration (second pass)

java -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar -T BaseRecalibrator \
   -I ${f1} \
   -R ${refloc1}/genome.fa \
   -knownSites ${refloc1}/1000G_omni2.5.hg19.vcf \
   -knownSites ${refloc1}/dbsnp_135.hg19.vcf \
   -knownSites ${refloc1}/hapmap_3.3.hg19.vcf \
   -knownSites ${refloc1}/Mills_and_1000G_gold_standard.indels.hg19.vcf \
   -BQSR ${f2}_recal_data.table \
   --out ${f2}_recal_data2.table

# Print reads

java -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar -T PrintReads \
   -R ${refloc1}/genome.fa \
   -I ${f1} \
   -BQSR ${f2}_recal_data.table \
   --out ${f2}_recal3.bam

# Analyze covariates

module load R

java -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar -T AnalyzeCovariates \
   -R ${refloc1}/genome.fa \
   -before ${f2}_recal_data.table \
   -after ${f2}_recal_data2.table \
   -plots ${f2}_AnalyzeCovariates.pdf \
   -csv ${f2}_AnalyzeCovariates.csv
   