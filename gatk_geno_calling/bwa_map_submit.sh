%%bash
# Now submit it as follows

dir3=/data/humgen/burook/sysbio_exome/trimmomatic_results1
#dir4=/data/humgen/burook/sysbio_exome/bwa_mapped
dir4=/data/humgen/guffantilab/exome/SystemsBio/bwa_mapped

cd ${dir4}

for f1 in ${dir3}/*R1_001.pe.fastq.gz
do
    # f1 and f2 are input files for forward and reverse reads
    f2=${dir3}/$(basename $f1 _R1_001.pe.fastq.gz)_R2_001.pe.fastq.gz
    fout=${dir4}/$(basename $f1 _R1_001.pe.fastq.gz)_mapped_bwa
    
    bsub -m "hna001" -n 4 -M 8000 -o "tmp1.out" -e "tmp1.err" "sh /PHShome/bm363/WES_analysis/notebooks/bwa_map.sh $f1 $f2 $fout"

    sleep 1
done
