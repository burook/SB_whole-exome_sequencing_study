#!/bin/sh

dir1=/data/humgen/burook/sysbio_exome/gatk_indiv_vcf/
for file in `cd ${dir1};ls -1 *_recal3.vcf` ;do
    echo $(basename $file _recal3.vcf) $(bcftools query -l ${dir1}/$file) >> ${dir1}/smpl_name_convert.txt
done
