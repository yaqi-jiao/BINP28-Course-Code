### Overview

This Snakemake workflow performs comprehensive variant calling analysis, starting from raw FASTQ sequencing files and ending with identified genetic variants in VCF format. The pipeline automates read mapping, format conversion, and variant detection using established bioinformatics tools.

### Workflow Steps

The pipeline executes the following sequential steps for each sample:

1. Index Building (`bowtie_index`)

    - Creates Bowtie2 index files from the reference genome

    - Prerequisite for efficient read alignment

2. Read Mapping (map_reads)

    - Aligns sequencing reads to the reference genome using Bowtie2

    - Produces SAM (Sequence Alignment/Map) format files

    - Format Conversion (sam_to_bam)

    - Converts SAM files to sorted BAM (Binary Alignment/Map) format

    - Enables efficient storage and retrieval of aligned reads

3. BAM Indexing (index_bam)

    - Creates index files for BAM files

    - Allows rapid random access to alignment data

4. Variant Calling (call_variants)

    - Identifies genetic variants using bcftools

    - Generates VCF (Variant Call Format) files with detected variants

### Directory Structure

```tree
snake_workflow/
├── config/                    # Configuration files
│   ├── config.yaml           # Main configuration file
│   └── samples.tsv           # Sample information (sample_name, fastq path)
├── workflow/                  # Snakemake workflow definitions
│   └── Snakefile             # Main workflow file (or may be in root)
├── resources/                 # Reference genomes and other resources
├── results/                   # Analysis outputs (generated during execution)
│   ├── 00_mapped_reads/      # Alignment files (BAM format and indexes)
│   └── 01_called_variants/   # Final VCF files with detected variants
├── logs/                     # Execution logs (generated during execution)
└── README.md                 # This documentation file
```