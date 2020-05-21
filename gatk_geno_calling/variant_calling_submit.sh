%%bash

# input data directory
#dir1=/data/humgen/burook/sysbio_exome/gatk_BQSR/
dir1=/data/humgen/guffantilab/exome/SystemsBio/gatk_BQSR

# output data directory
#dir2=/data/humgen/burook/sysbio_exome/gatk_indiv_vcf
dir2=/data/humgen/guffantilab/exome/SystemsBio/gatk_indiv_vcf

cd ${dir2}

#for f1 in ${dir1}/*marked_duplicates.bam 
for f1 in ${dir1}/*_recal3.bam 
do
    # f1 is the input sam file
    f2=$(basename $f1 _recal3.bam)
    
    bsub -m "hna001" -n 4 -M 8000 -o "tmp4.out" -e "tmp4.err" "sh /PHShome/bm363/WES_analysis/notebooks/variant_calling.sh $f1 $f2 $dir1 $dir2"

    sleep 1
done
