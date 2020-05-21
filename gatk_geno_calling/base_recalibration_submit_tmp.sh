%%bash

#
# some files were not processed due to memory shortage. 
# We cleaned some memory space. Let's processes just those files
#

# input data directory
dir1=/data/humgen/burook/sysbio_exome/picard_mdupl/
# output data directory
dir2=/data/humgen/burook/sysbio_exome/gatk_BQSR

cd ${dir2}

#for f1 in ${dir1}/*marked_duplicates.bam 
for f1 in ${dir1}/*mapped_bwa.bam_marked_duplicates.bam 
do
    # f1 is the input sam file
    #f2=$(basename $f1 _marked_duplicates.bam)
    f2=$(basename $f1 _mapped_bwa.bam_marked_duplicates.bam)
    
    if [ -f "${f2}_recal3.bam" ];
    then
    echo "it already exits"
    else
    bsub -q normal -n 6 -o "tmp6.out" -e "tmp6.err" "sh base_recalibration.sh $f1 $f2 $dir1 $dir2"
    fi
    sleep 1
done


