## Amplicon sequencing analysis – 16S rRNA (*Reticulitermes flavipes*)

# Aim

The aim of this exercise is to learn how to analyse amplicon sequencing data, in this case 16S rRNA gene data.

The results are compared with the published study:

Benjamino et al. (2016), NCBI PubMed: 26925043.

# Data

Illumina paired-end fastq files originating from hindgut samples of *R. flavipes* workers.

Samples represent different colonies:

- CT.A, CT.B, CT.C, CT.D

- MA.A, MA.B, MA.C

# Analysis overview

The analysis follows a standard 16S rRNA amplicon workflow:

1. Quality control and preprocessing of reads

2. Dereplication of sequences

3. Chimera removal

4. OTU clustering

5. Construction of an OTU table

6. Taxonomic classification using the RDP classifier

7. Post-processing and visualization of bacterial community composition

# Files used in Data/

- otus.tsv: This file contains the read counts of each OTU in each sample.

- all.fixedRank: This file contains the taxonomic classification for each OTU, including the confidence values for each taxonomic rank.

# Post-processing for visualization

To generate the community composition plot:

1. Each OTU is linked to its phylum using all.fixedRank.

2. Only OTUs that:

    - are classified as Bacteria, and

    - have a confidence of at least 0.8 at the phylum level are kept.

3. The phylum information is merged with the OTU read counts from otus.tsv.

4. Read counts are summed per phylum and per sample.

5. Relative abundances are calculated and plotted as a stacked bar plot.

The final table used for plotting contains:

    - rows: phyla

    - columns: samples
