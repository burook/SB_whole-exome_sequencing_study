#!/bin/bash

# directory where input files are saved
dir1=$1

cd ${dir1}

module load GATK
# on erisone the picard jar is located at $EBROOTGATK
# (its full path is /apps/software/GATK/3.8-0-Java-1.8.0_161 )

refloc1=/data/humgen/burook/ref
refloc2=/pub/genome_references/gatk-bundle/1.5/hg19


#### SNP's
# Variant recalibration of SNP's

java \
    -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar \
    -T VariantRecalibrator \
    -R ${refloc1}/genome.fa \
    -input SysBio_exome_merged12.vcf \
    -resource:hapmap,known=false,training=true,truth=true,prior=15.0 ${refloc1}/hapmap_3.3.hg19.vcf \
    -resource:omni,known=false,training=true,truth=true,prior=12.0 ${refloc1}/1000G_omni2.5.hg19.vcf \
    -resource:1000G,known=false,training=true,truth=false,prior=10.0 ${refloc1}/Mills_and_1000G_gold_standard.indels.hg19.vcf \
    -resource:dbsnp,known=true,training=false,truth=false,prior=2 ${refloc1}/dbsnp_135.hg19.vcf \
    -an QD -an MQRankSum -an ReadPosRankSum -an FS -an MQ -an SOR \
    -mode SNP \
    --maxGaussians 6 \
    -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 \
    -recalFile SysBio.snps.recal \
    -tranchesFile SysBio.snps.tranches \
    -rscriptFile SysBio_recal_snps_plots.R


# Apply Recalibration of SNP's

java \
    -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar \
    -T ApplyRecalibration \
    -R ${refloc1}/genome.fa \
    -input SysBio_exome_merged12.vcf \
    -mode SNP \
    --ts_filter_level 90.0 \
    -recalFile SysBio.snps.recal \
    -tranchesFile SysBio.snps.tranches \
    --out SysBio_snps_recalibrated.vcf

#    -nt 6 \



#### INDELs
# Variant recalibration of INDELs

java \
    -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar \
    -T VariantRecalibrator \
    -R ${refloc1}/genome.fa \
    -input SysBio_snps_recalibrated.vcf \
    -resource:1000G,known=false,training=true,truth=true,prior=12.0 ${refloc1}/Mills_and_1000G_gold_standard.indels.hg19.vcf \
    -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 ${refloc1}/dbsnp_135.hg19.vcf \
    -an FS -an ReadPosRankSum -an MQRankSum -an QD -an SOR -an MQ \
    -mode INDEL \
    --maxGaussians 4 \
    -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 \
    -recalFile SysBio.indels.recal \
    -tranchesFile SysBio.indels.tranches \
    -rscriptFile SysBio_recal_indels_plots.R

#    -nt 6 \


# Apply Recalibration of SNP's

java \
    -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar \
    -T ApplyRecalibration \
    -R ${refloc1}/genome.fa \
    -input SysBio_snps_recalibrated.vcf \
    -mode INDEL \
    --ts_filter_level 90.0 \
    -recalFile SysBio.indels.recal \
    -tranchesFile SysBio.indels.tranches \
    --out SysBio_indels_recalibrated.vcf
    
#    -nt 6 \



