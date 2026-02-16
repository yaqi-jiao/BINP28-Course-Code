#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Build gene trees for each 1 Mb window using IQ-TREE
#
# For each PHYLIP alignment:
#   - infer a constrained ML tree
#   - perform ultrafast bootstrap
#   - write results to a dedicated output directory
#
# Failed windows are recorded in an error log and skipped.
# ============================================================


PHYLIP_DIR=../03_convert/phylip_1Mb  # Directory containing PHYLIP alignments
TREE_DIR=./trees  # Output directory for tree files
CONSTRAINT=./constraint.tree  # Constraint tree (Newick format)
MODEL=GTR+G  # Substitution model
OUTGROUP=Naxos2  # Outgroup
THREADS=8  
ERROR_FILE=errors.log  # Error log file


mkdir -p ${TREE_DIR}
> "${ERROR_FILE}"  # clear previous error log


# main loop
for aln in ${PHYLIP_DIR}/*.phy
do
	base=$(basename ${aln} .phy)
	echo "Processing window: ${base}"

	iqtree -s ${aln} \
		-m ${MODEL} \
		-bb 1000 \
		-g ${CONSTRAINT} \
		-st DNA \
		-pre ${TREE_DIR}/${base}_tree \
		-nt ${THREADS} || {
			echo "Window ${base} failed. See errors above." >> "${ERROR_FILE}"  # record failed windows
			echo "	ERROR: ${base} skipped."
			continue
		}
	echo "	Completed: ${base}"
done

