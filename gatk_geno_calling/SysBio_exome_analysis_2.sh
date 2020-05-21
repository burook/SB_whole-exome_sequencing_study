
#### Statistics of the variants obtained

# run the following from an hna001 terminal (where bcftools is already installed)
cd /data/humgen/guffantilab/exome/SystemsBio/gatk_merged_vcf/
bcftools stats SysBio_indels_recalibrated.vcf > SysBio_variant_stats.vchk

# let's plot the results
plot-vcfstats SysBio_variant_stats.vchk -p stats_plots/
# The plots are not being generated due to an issue with Python.
# So let's generate it manually using the script generated.
cd stats_plots/
python plot.py


######################################


#### Number of variants per chromosome

cd /data/humgen/guffantilab/exome/SystemsBio/gatk_merged_vcf
grep -v '#' SysBio_indels_recalibrated.vcf | cut -f1 | uniq -c


######################################

#### Relatedness between samples to check duplicate samples

# run the following on an erisone terminal (where vcftool is installed)
cd /data/humgen/guffantilab/exome/SystemsBio/gatk_merged_vcf/
vcftools --vcf SysBio_indels_recalibrated.vcf --out relatedness --relatedness
vcftools --vcf SysBio_indels_recalibrated.vcf --relatedness2


