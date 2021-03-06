%%bash

# input data directory
#dir1=/data/humgen/burook/sysbio_exome/picard_mdupl/
dir1=/data/humgen/guffantilab/exome/SystemsBio/picard_mdupl/
# output data directory
#dir2=/data/humgen/burook/sysbio_exome/gatk_BQSR
dir2=/data/humgen/guffantilab/exome/SystemsBio/gatk_BQSR

cd ${dir2}

#for f1 in ${dir1}/*marked_duplicates.bam 
for f1 in ${dir1}/*marked_duplicates.bam 
do
    # f1 is the input sam file
    f2=$(basename $f1 _marked_duplicates.bam)
    
    bsub -m "hna001" -n 4 -M 8000 -o "tmp3.out" -e "tmp3.err" "sh /PHShome/bm363/WES_analysis/notebooks/base_recalibration.sh $f1 $f2 $dir1 $dir2"

    sleep 1
done
