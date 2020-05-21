%%bash

# directory where raw data is saved
dir1=/data/humgen/burook/sysbio_exome/raw/
# directory where results will be saved
dir2=/data/humgen/burook/sysbio_exome/trimmomatic_results2

cd ${dir2}

#for f1 in *R1_001.fastq.gz
for f1 in $(find /data/humgen/guffantilab/exome/SystemsBio/input/Exome/EXOME -type f -name '*R1_001.fastq.gz')

do
    # f1 and f2 are inpute files for forward and reverse reads
    f2=$(basename $f1 _R1_001.fastq.gz)_R2_001.fastq.gz
    # the following four are output files (forward and revers for paired and single)
    f1p=$(basename $f1 _R1_001.fastq.gz)_R1_001.pe.fastq.gz 
    f1s=$(basename $f1 _R1_001.fastq.gz)_R1_001.se.fastq.gz
    f2p=$(basename $f1 _R1_001.fastq.gz)_R2_001.pe.fastq.gz
    f2s=$(basename $f1 _R1_001.fastq.gz)_R2_001.se.fastq.gz
    
    # there are some duplicate fastq files let's identify and rename them
    if [ -f "$f1p" ]; then
    # file already exists (duplicate file)
    f1p=$(basename $f1 _R1_001.fastq.gz)_2_R1_001.pe.fastq.gz 
    f1s=$(basename $f1 _R1_001.fastq.gz)_2_R1_001.se.fastq.gz
    f2p=$(basename $f1 _R1_001.fastq.gz)_2_R2_001.pe.fastq.gz
    f2s=$(basename $f1 _R1_001.fastq.gz)_2_R2_001.se.fastq.gz    
    fi
    
    bsub -m "hna001" -n 4 -M 8000 -o "tmptrim1.out" -e "tmptrim1.err" "sh /PHShome/bm363/WES_analysis/notebooks/trimmomatic_analysis_2.sh $f1 $f2 $f1p $f1s $f2p $f2s ${dir2}"
    
    sleep 1
     
done



