#!/bin/bash

module load GATK
# on erisone the picard jar is located at $EBROOTGATK
# (its full path is /apps/software/GATK/3.8-0-Java-1.8.0_161 )

refloc1=/data/humgen/burook/ref
refloc2=/pub/genome_references/gatk-bundle/1.5/hg19


#### SNP's
# Variant recalibration of SNP's
    
java -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar \
    -T VariantRecalibrator \
    -R ${refloc1}/genome.fa \
    -input test_merged1.vcf \
    -resource:hapmap,known=false,training=true,truth=true,prior=15 ${refloc1}/hapmap_3.3.hg19.vcf \
    -resource:omni,known=false,training=true,truth=true,prior=12 ${refloc1}/1000G_omni2.5.hg19.vcf \
    -resource:1000G,known=false,training=true,truth=false,prior=10 ${refloc1}/Mills_and_1000G_gold_standard.indels.hg19.vcf \
    -resource:dbsnp,known=true,training=false,truth=false,prior=7 ${refloc1}/dbsnp_135.hg19.vcf \
    -an QD -an MQRankSum -an ReadPosRankSum -an FS -an MQ -an SOR -an DP \
    -mode SNP \
    -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 \
    -nt 24 \
    -recalFile test_snps_recal \
    -tranchesFile test_snps_tranches \
    -rscriptFile test_recal_snps_plots.R


# Apply Recalibration of SNP's

java -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar \
    -T ApplyRecalibration \
    -R ${refloc1}/genome.fa \
    -input test_merged1.vcf \
    -mode SNP \
    --ts_filter_level 99.0 \
    -recalFile test_snps_recal \
    -tranchesFile test_snps_tranches \
    --out test_snps_recalibrated.vcf


#### INDELs
# Variant recalibration of INDELs

java -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar \
    -T VariantRecalibrator \
    -R ${refloc1}/genome.fa \
    -input test_snps_recalibrated.vcf \
    -resource:1000G,known=false,training=true,truth=false,prior=12 ${refloc1}/Mills_and_1000G_gold_standard.indels.hg19.vcf \
    -resource:dbsnp,known=true,training=false,truth=false,prior=2 ${refloc1}/dbsnp_135.hg19.vcf \
    -an FS -an ReadPosRankSum -an MQRankSum -an QD -an SOR -an DP \
    -mode INDEL \
    -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 \
    --maxGaussians 4 \
    -recalFile test_indels_recal \
    -tranchesFile test_indels_tranches \
    -rscriptFile test_recal_indels_plots.R

# Apply Recalibration of SNP's

java -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar \
    -T ApplyRecalibration \
    -R ${refloc1}/genome.fa \
    -input test_snps_recalibrated.vcf \
    -mode INDEL \
    --ts_filter_level 99.0 \
    -recalFile test_indels_recal \
    -tranchesFile test_indels_tranches \
    --out test_indels_recalibrated.vcf





