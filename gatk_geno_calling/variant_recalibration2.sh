#!/bin/bash

# directory where input files are saved
dir1=$1

cd ${dir1}

module load GATK
# on erisone the picard jar is located at $EBROOTGATK
# (its full path is /apps/software/GATK/3.8-0-Java-1.8.0_161 )

refloc1=/data/humgen/burook/ref
refloc2=/pub/genome_references/gatk-bundle/1.5/hg19


# Apply Recalibration of SNP's

java \
    -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar \
    -T ApplyRecalibration \
    -R ${refloc1}/genome.fa \
    -input SysBio_exome_merged2.vcf \
    -mode SNP \
    --ts_filter_level 99.9 \
    -recalFile SysBio.snps.recal \
    -tranchesFile SysBio.snps.tranches \
    --out SysBio_snps_recalibrated2.vcf

#    -nt 6 \



# Apply Recalibration of SNP's

java \
    -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar \
    -T ApplyRecalibration \
    -R ${refloc1}/genome.fa \
    -input SysBio_snps_recalibrated.vcf \
    -mode INDEL \
    --ts_filter_level 99.9 \
    -recalFile SysBio.indels.recal \
    -tranchesFile SysBio.indels.tranches \
    --out SysBio_indels_recalibrated2.vcf
    
#    -nt 6 \




