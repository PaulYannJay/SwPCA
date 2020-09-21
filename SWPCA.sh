#!/bin/bash
##########
##
##
##	This workflow allow to create circos karyotype comparison plot based on the assembly
## 
##
#######################################

while [ $# -gt 0 ] ; do
  case $1 in
    -vcf ) VCF="$2" ;echo "the vcf file : $VCF" >&2;;
    -s | --sample) Sample="$2" ;echo "the file containing sample to analyse is $Sample" >&2;;
    -r | --region) Scaf="$2" ;echo "the file containing the scaffold and region to analyse is $Scaf" >&2;;
    -o | --output) OUT="$2" ;echo "the output prefix is $OUT" >&2;;
    -w | --window) Wind="$2" ;echo "the window size is $Wind" >&2;;
	-h | --help) echo -e "Option required:
-vcf \t the vcf file to analyse
-o/--output \t Output Prefix
-w/--window \t the window size to use for sliding window
Optional: 
-s/--sample \t set of samples to analyse. If not defined, all sample are used
-r/--region \t set of regions to analyse in format : Scaffold\tDebut\tFin. If not defined, all regions are analysed " >&2;exit 1;; 
  esac
  shift
done

if [ -z "$OUT" ] || [ -z "$VCF"] || [ -z "$Wind"]; then
  echo >&2 "Fatal error: Ouput, vcf or Window size are not defined"
  exit 2
fi

SEQ=$VCF

echo -e "\n"

mkdir $OUT

if [ -n "$r"] && [ -n "$o"]; then
bcftools view -R $Scaf -S $Sample -O z -o $OUT/FilteredDataset.vcf.gz $VCF
tabix -p vcf $OUT/FilteredDataset.vcf.gz
SEQ=$OUT/FilteredDataset.vcf.gz
elif [ -n "$r"] && [ -z "$o"] ; then
bcftools view -R $Scaf -O z -o $OUT/FilteredDataset.vcf.gz $VCF
tabix -p vcf $OUT/FilteredDataset.vcf.gz
SEQ=$OUT/FilteredDataset.vcf.gz
elif [ -z "$r"] && [ -n "$o"] ; then
bcftools view -S $Sample -O z -o $OUT/FilteredDataset.vcf.gz $VCF
tabix -p vcf $OUT/FilteredDataset.vcf.gz
SEQ=$OUT/FilteredDataset.vcf.gzfi 
else
tabix -p vcf $OUT
fi
