#!/bin/sh


######################################################
## Quality assessment of raw reads (using FastQC)
######################################################

#!/bin/sh

# FastQC is aleady available on erisone
module load FastQC/0.11.8-Java-1.8

# directory where raw data is saved
dir1=/data/humgen/guffantilab/exome/SystemsBio/raw/
# directory where results will be saved
dir2=/data/humgen/guffantilab/exome/SystemsBio/fastq_result1

cd ${dir1}

for file in $(ls $dir1)
do
    fastqc $file -o $dir2
done


## Aggregating quality assessments (using MultiQC)

# cd to the folder where multiqc results should be saved
cd /data/humgen/guffantilab/exome/SystemsBio/fastq_result1_multiqc/
multiqc /data/humgen/guffantilab/exome/SystemsBio/fastq_result1



######################################################
## Filtering problematic bases and reads (using Trimmomatic)
######################################################

# directory where raw data is saved
dir1=/data/humgen/guffantilab/exome/SystemsBio/raw/
# directory where results will be saved
dir2=/data/humgen/guffantilab/exome/SystemsBio/trimmomatic_results1

cd ${dir1}

for f1 in *R1_001.fastq.gz
do
    # f1 and f2 are inpute files for forward and reverse reads
    f2=$(basename $f1 _R1_001.fastq.gz)_R2_001.fastq.gz
    # the following four are output files (forward and revers for paired and single)
    f1p=$(basename $f1 _R1_001.fastq.gz)_R1_001.pe.fastq.gz 
    f1s=$(basename $f1 _R1_001.fastq.gz)_R1_001.se.fastq.gz
    f2p=$(basename $f1 _R1_001.fastq.gz)_R2_001.pe.fastq.gz
    f2s=$(basename $f1 _R1_001.fastq.gz)_R2_001.se.fastq.gz
    
    java -jar /PHShome/bm363/bin/trimmomatic/trimmomatic-0.39.jar PE -threads 24 \
        ${f1} ${f2} \
        ${dir2}/${f1p} ${dir2}/${f1s} ${dir2}/${f2p} ${dir2}/${f2s} \
        ILLUMINACLIP:/PHShome/bm363/bin/trimmomatic/adapters/TruSeq3-PE.fa:2:30:10:2:keepBothReads \
        LEADING:3 TRAILING:3 MINLEN:36
done


## Now rerun FastQC on results of trimmomatic

module load FastQC/0.11.8-Java-1.8

dir1=/data/humgen/guffantilab/exome/SystemsBio/trimmomatic_results1/
dir2=/data/humgen/guffantilab/exome/SystemsBio/fastq_result2

cd ${dir1}

for file in $(ls $dir1)
do
    fastqc $file -o $dir2
done


## Now run MultiQC on this new FastQC outputs

# cd to the folder where multiqc results should be saved
cd /data/humgen/guffantilab/exome/SystemsBio/fastq_result2_multiqc/
multiqc /data/humgen/guffantilab/exome/SystemsBio/fastq_result2/*pe*




######################################################
## Map read to reference genome (bwa mem)
######################################################

# the following script maps reads to a given reference genome 

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
    
    
## now call this script for each sample file

dir3=/data/humgen/guffantilab/exome/SystemsBio/trimmomatic_results1
dir4=/data/humgen/guffantilab/exome/SystemsBio/bwa_mapped

for f1 in ${dir3}/*R1_001.pe.fastq.gz
do
    # f1 and f2 are inpute files for forward and reverse reads
    f2=${dir3}/$(basename $f1 _R1_001.pe.fastq.gz)_R2_001.pe.fastq.gz
    fout=${dir4}/$(basename $f1 _R1_001.pe.fastq.gz)_mapped_bwa
    
    bsub -m "hna001" -n 8 -M 8000 -o "tmp1.out" -e "tmp1.err" "sh bwa_map.sh $f1 $f2 $fout"

    sleep 1
done




######################################################
## Mark duplicates (using Picard)
######################################################


# input bam file
f1=$1
# prefix of the output file
f2=$2
# directory where input files are saved
dir1=$3
# directory where output files will be saved
dir2=$4

module load picard
# on erisone the picard jar is located at $EBROOTPICARD
# (its full path is /apps/software/picard/2.6.0-Java-1.8.0_161 )

# Sorting the mapped file
# The aligned reads need to be sorted for the next steps. This can be done with Picard.

java -jar /apps/software/picard/2.6.0-Java-1.8.0_161/picard.jar SortSam \
     INPUT=${f1} \
     OUTPUT=${dir2}/${f2}_mapped_sorted.bam \
     SORT_ORDER=coordinate

# Mark duplicates
java -jar /apps/software/picard/2.6.0-Java-1.8.0_161/picard.jar MarkDuplicates \
      INPUT=${dir2}/${f2}_mapped_sorted.bam \
      OUTPUT=${dir2}/${f2}_marked_duplicates.bam \
      METRICS_FILE=${dir2}/${f2}_marked_dup_metrics.txt \
      CREATE_INDEX=TRUE \
      ASSUME_SORTED=TRUE


# Now call this script for each sample file

# input data directory
dir1=/data/humgen/guffantilab/exome/SystemsBio/bwa_mapped
# output data directory
dir2=/data/humgen/guffantilab/exome/SystemsBio/picard_mdupl/

for f1 in ${dir1}/*.bam
do
    # f1 is the input sam file
    f2=$(basename $f1 _mapped_bwa.bam)
    
    bsub -m "hna001" -n 8 -M 8000 -o "tmp2.out" -e "tmp2.err" "sh mark_duplicates.sh $f1 $f2 $dir1 $dir2"

    sleep 1
done




######################################################
## Base Quality Score Recalibration (BQSR)
######################################################


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
   
   
   
### run this script for individual bam files

# input data directory
dir1=/data/humgen/guffantilab/exome/SystemsBio/picard_mdupl/
# output data directory
dir2=/data/humgen/guffantilab/exome/SystemsBio/gatk_BQSR

#for f1 in ${dir1}/*marked_duplicates.bam 
for f1 in ${dir1}/*mapped_bwa.bam_marked_duplicates.bam 
do
    # f1 is the input sam file
    #f2=$(basename $f1 _marked_duplicates.bam)
    f2=$(basename $f1 _mapped_bwa.bam_marked_duplicates.bam)
    
    bsub -m "hna001" -n 8 -M 8000 -o "tmp3.out" -e "tmp3.err" "sh base_recalibration.sh $f1 $f2 $dir1 $dir2"

    sleep 1
done

   
   
   
  
   
######################################################
##  Variant calling (with HaplotypeCaller)
######################################################

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
# on erisone the GATK jar is located at $EBROOTGATK
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


### now run this script on individuale sample files

# input data directory
dir1=/data/humgen/guffantilab/exome/SystemsBio/gatk_BQSR/
# output data directory
dir2=/data/humgen/guffantilab/exome/SystemsBio/gatk_indiv_vcf

#for f1 in ${dir1}/*marked_duplicates.bam 
for f1 in ${dir1}/*_recal3.bam 
do
    # f1 is the input sam file
    f2=$(basename $f1 _recal3.bam)
    
    bsub -m "hna001" -n 4 -M 8000 -o "tmp4.out" -e "tmp4.err" "sh variant_calling.sh $f1 $f2 $dir1 $dir2"

    sleep 1
done



######################################################
##  Joint Genotyping
######################################################

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

# list of gVCF files to be analysed together
# ${dir1}/list_VCF1.list


java -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar -T GenotypeGVCFs \
    -R ${refloc1}/genome.fa \
    -V ${dir1}/list_VCF1.list \
    --dbsnp ${refloc1}/dbsnp_135.hg19.vcf \
    --out SysBio_exome_merged1.vcf 
#    -nt 24


## now run this on terminal

%%bash

# input data directory
dir1=/data/humgen/guffantilab/exome/SystemsBio/gatk_indiv_vcf
# output data directory
dir2=/data/humgen/guffantilab/exome/SystemsBio/gatk_merged_vcf

bsub -m "hna001" -n 24 -M 64000 -o "tmp52.out" -e "tmp52.err" "sh joint_variant_calling.sh  ${dir1}"

# now let's move the output to the desired directory
cp ${dir1}/SysBio_exome_merged1.vcf ${dir2}/


######################################################
##  Variant Recalibration
######################################################



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
    -input SysBio_exome_merged2.vcf \
    -resource:hapmap,known=false,training=true,truth=true,prior=15.0 ${refloc1}/hapmap_3.3.hg19.vcf \
    -resource:omni,known=false,training=true,truth=true,prior=12.0 ${refloc1}/1000G_omni2.5.hg19.vcf \
    -resource:1000G,known=false,training=true,truth=false,prior=10.0 ${refloc1}/Mills_and_1000G_gold_standard.indels.hg19.vcf \
    -resource:dbsnp,known=true,training=false,truth=false,prior=7 ${refloc1}/dbsnp_135.hg19.vcf \
    -an QD -an MQRankSum -an ReadPosRankSum -an FS -an MQ -an SOR -an DP \
    -mode SNP \
    -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 \
    -nt 24 \
    -recalFile SysBio_snps_recal \
    -tranchesFile SysBio_snps_tranches \
    -rscriptFile SysBio_recal_snps_plots.R

#    --max-gaussians 6 \


# Apply Recalibration of SNP's

java \
    -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar \
    -T ApplyRecalibration \
    -R ${refloc1}/genome.fa \
    -input SysBio_exome_merged2.vcf \
    -mode SNP \
    --ts_filter_level 99.0 \
    -nt 24 \
    -recalFile SysBio_snps_recal \
    -tranchesFile SysBio_snps_tranches \
    --out SysBio_snps_recalibrated.vcf


#### INDELs
# Variant recalibration of INDELs

java \
    -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar \
    -T VariantRecalibrator \
    -R ${refloc1}/genome.fa \
    -input SysBio_snps_recalibrated.vcf \
    -resource:1000G,known=false,training=true,truth=false,prior=12.0 ${refloc1}/Mills_and_1000G_gold_standard.indels.hg19.vcf \
    -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 ${refloc1}/dbsnp_135.hg19.vcf \
    -an FS -an ReadPosRankSum -an MQRankSum -an QD -an SOR -an DP \
    -mode INDEL \
    -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 \
    -nt 24 \
    -recalFile SysBio_indels_recal \
    -tranchesFile SysBio_indels_tranches \
    -rscriptFile SysBio_recal_indels_plots.R

#    --maxGaussians 4 \


# Apply Recalibration of SNP's

java \
    -jar /apps/software/GATK/3.8-0-Java-1.8.0_161/GenomeAnalysisTK.jar \
    -T ApplyRecalibration \
    -R ${refloc1}/genome.fa \
    -input SysBio_snps_recalibrated.vcf \
    -mode INDEL \
    --ts_filter_level 99.0 \
    -nt 24 \
    -recalFile SysBio_indels_recal \
    -tranchesFile SysBio_indels_tranches \
    --out SysBio_indels_recalibrated.vcf

