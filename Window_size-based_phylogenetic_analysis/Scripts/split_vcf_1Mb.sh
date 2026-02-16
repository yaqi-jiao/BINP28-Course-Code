#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Split a whole-genome VCF into 1 Mb window VCFs
#
# For each window defined in a BED file:
#   - extract variants from the input VCF
#   - write a window-specific VCF (bgzip-compressed)
#   - report the number of SNPs in that window
#
# NOTE:
#   BED coordinates are 0-based, half-open.
#   bcftools uses 1-based inclusive coordinates.
#   Therefore, start position is converted as (start + 1).
# ============================================================


VCF=../01_vcf_filter/filtered.recode.vcf.gz  # Filtered whole-genome VCF (bgzipped)
WINDOW=windows_1Mb.bed  # BED file defining windows (chr  start  end)  
OUTDIR=vcf_1Mb  
mkdir -p ${OUTDIR}

# main loop
while read -r chr start end
do
	out=${chr}_${start}_${end}.vcf.gz
	
	# Extract window region from the VCF
	bcftools view \
        -r ${chr}:$((start+1))-${end} \
        ${VCF} \
        -Oz -o ${OUTDIR}/${out}

	n=$(bcftools view -H ${OUTDIR}/${out} | wc -l)
	
	echo "Number of SNPs in ${out}: ${n}"

done < ${WINDOW}

