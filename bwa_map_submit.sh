%%bash
# Now submit it as follows

dir3=/data/humgen/burook/sysbio_exome/trimmomatic_results1
dir4=/data/humgen/burook/sysbio_exome/bwa_mapped

for f1 in ${dir3}/*R1_001.pe.fastq.gz
do
    # f1 and f2 are inpute files for forward and reverse reads
    f2=${dir3}/$(basename $f1 _R1_001.pe.fastq.gz)_R2_001.pe.fastq.gz
    fout=${dir4}/$(basename $f1 _R1_001.pe.fastq.gz)_mapped_bwa
    
    bsub -m "hna001" -n 8 -M 8000 -o "tmp1.out" -e "tmp1.err" "sh bwa_map.sh $f1 $f2 $fout"

    sleep 1
done
