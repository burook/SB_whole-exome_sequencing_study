%%bash

# input data directory
dir1=/data/humgen/burook/sysbio_exome/picard_mdupl/
# output data directory
dir2=/data/humgen/burook/sysbio_exome/gatk_BQSR

#for f1 in ${dir1}/*marked_duplicates.bam 
for f1 in ${dir1}/*mapped_bwa.bam_marked_duplicates.bam 
do
    # f1 is the input sam file
    #f2=$(basename $f1 _marked_duplicates.bam)
    f2=$(basename $f1 _mapped_bwa.bam_marked_duplicates.bam)
    
    bsub -m "hna001" -n 8 -M 8000 -o "tmp3.out" -e "tmp3.err" "sh base_recalibration.sh $f1 $f2 $dir1 $dir2"

    sleep 1
done
