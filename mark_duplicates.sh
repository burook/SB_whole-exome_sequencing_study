#!/bin/bash

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
