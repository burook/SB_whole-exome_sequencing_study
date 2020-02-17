%%bash

# input data directory
dir1=/data/humgen/burook/sysbio_exome/bwa_mapped
# output data directory
dir2=/data/humgen/burook/sysbio_exome/picard_mdupl/

for f1 in ${dir1}/*.bam
do
    # f1 is the input sam file
    f2=$(basename $f1 _mapped_bwa.bam)
    
    bsub -m "hna001" -n 8 -M 8000 -o "tmp2.out" -e "tmp2.err" "sh mark_duplicates.sh $f1 $f2 $dir1 $dir2"

    sleep 1
done
