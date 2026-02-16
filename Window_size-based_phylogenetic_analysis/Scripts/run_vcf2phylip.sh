#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Convert sliding-window VCF files to PHYLIP format
#
# For each *.vcf.gz file:
#   1. unzip to a temporary VCF file
#   2. convert VCF to PHYLIP using vcf2phylip.py
#
# ============================================================

VCFDIR=../02_data_split/vcf_1Mb  # Directory containing per-window VCF files (gzipped)
OUTDIR=phylip_1Mb  # Output directory for phylip files
MIN_TAXA=4  # Minimum number of taxa required in a window
VCF2PHY=../software/vcf2phy/vcf2phylip.py  # vcf2phylip script
OUTGROUP=Naxos2  # outgroup sample name

mkdir -p ${OUTDIR}
mkdir -p tmp_vcf_unzip

# Main loop
for vcf in ${VCFDIR}/*.vcf.gz
do
    base=$(basename ${vcf} .vcf.gz)
    unzipped="tmp_vcf_unzip/${base}.vcf"

    gunzip -c ${vcf} > ${unzipped}

    python ${VCF2PHY} \
        -i ${unzipped} \
        -m ${MIN_TAXA} \
        -o ${OUTGROUP} 

done
