#!/bin/bash

module load GATK
# on erisone the picard jar is located at $EBROOTGATK
# (its full path is /apps/software/GATK/3.8-0-Java-1.8.0_161 )

refloc1=/data/humgen/burook/ref
refloc2=/pub/genome_references/gatk-bundle/1.5/hg19


# Variant calling

java -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar -T HaplotypeCaller \
   -R ${refloc1}/genome.fa \
   -I test_recal3.bam \
   --genotyping_mode DISCOVERY \
   -stand_call_conf 10 \
   --emitRefConfidence GVCF \
   -variant_index_type LINEAR -variant_index_parameter 128000 \
   --dbsnp ${refloc1}/dbsnp_135.hg19.vcf \
   --out test_recal3.vcf
   

# Joint variant calling

# list of gVCF files to be analysed together
list_gVCF1=/path/to/the/file/containing/the/list

java -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar -T GenotypeGVCFs \
    -R ${refloc1}/genome.fa \
    -V ${list_gVCF1} \
    --dbsnp ${refloc1}/dbsnp_135.hg19.vcf \
    --out test_merged1.vcf 
#    -nt = 









