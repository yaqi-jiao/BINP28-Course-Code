### Window size-based phylogenetic analysis

**Overview:** This workflow performed window-based phylogenetic analysis from VCF files and summarizes population-level topological patterns among three predefined populations.

**The workflow includes:**

1. filtering VCF files

2. converting VCF windows to phylip format

3. constructing phylogenetic trees under topological constraints

4. summarizing topological relationships among populations

## 1. Data Structure

```text
project/
│
├── Data/
│   ├── constraint.tree: 
│   │   └── Newick formatted constraint tree
│   │
│   └── pop_information.txt
│       └── Population assignment file
│
├── scripts/
│   ├── run_vcf2phylip.sh
│   │   └── Convert each window-based VCF file into  PHYLIP format
│   │
│   ├── split_vcf_1Mb.sh
│   │   └── Split filtered VCF files into non-overlapping 1 Mb windows
│   │
│   ├── build_tree.sh
│   │   └── Run phylogenetic inference for each PHYLIP alignment
│   │
│   ├── Visualization.R
│   │   └── Plot and visualize the topology summary results
│   │
│   └── summarize_topology.R
│       └── Read and summarize window-based phylogenetic trees
│  
└── README.md
```

## 2. Requirements

The following softwares and R packages are requires:

- python 3.13.11
- conda 25.11.1
- vcftools 0.1.16
- vcf2phylip.py
- IQ-TREE 2.0.6
- bedtools v2.30.0
- bcftools 1.23
- samtools 1.15.1
- R 4.5.2
- ape 5.8-1
- ggplot2 4.0.2
- stringr 1.6.0
- dplyr 1.1.4
- cowplot 1.2.0
- tidyverse 2.0.0

Different tools were executed in separate conda environments.

## 3. Workflow

### Step 1 – VCF filtering
All performance is under home directory:`~/Binp28_project/`

Download raw data from /resources/binp28/Por.vcf.gz into `./raw_data`
```bash
mkdir ./raw_data
```
Create a directory for summary statistics, and set the input VCF file:
```bash
mkdir ./00_summary
cd 00_summary
VCF=~/Binp28_project/raw_data/ProjTaxa.vcf.gz
```
Calculate allele frequencies, depth and site quality:
```bash
vcftools --gzvcf $VCF --freq2 --max-alleles 2
vcftools --gzvcf $VCF --site-mean-depth
vcftools --gzvcf $VCF --site-quality
vcftools --gzvcf $VCF --missing-site
```
These outputs are used only for data inspection and quality assessment. Each command produces outputs including: 
```bash
out.frq
out.ldepth.mean
out.lmiss
out.log
out.lqual
```
`out.lqual`,`out.ldepth.mean`, and `out.lmiss` are downloaded to local environment. Perform summary visualization in R studio using R script `summarize_topology.R`.

Create a directory for filtering:
```bash
mkdir 01_vcf_filter
cd 01_vcf_filter
```
Run following command to filter VCF:

```bash
vcftools --gzvcf ../raw_data/ProjTaxa.vcf.gz   --max-missing 0.75   --minQ 30   --minDP 7 --maxDP 18 --remove-indels --min-alleles 2 --max-alleles 2 --recode --recode-INFO-all --out filtered_output
```

Compress and index the filtered VCF:
```
bcftools view filtered_output.recode.vcf.gz -Oz -o filtered.recode.vcf.gz
bcftools index filtered.recode.vcf.gz
```
Output file used in downstream analyses:
```bash
filtered.recode.vcf.gz
```

### Step 2 – Convert VCF windows to PHYLIP alignments

Create a directory for spliting.

```bash
mkdir ./02_data_split
cd 02_data_split
```
Index the reference genome and extract chromosome sizes:
```bash
samtools faidx ../raw_data/ProjTaxaRef.fa
cut -f1,2 ProjTaxaRef.fa.fai > genome.txt
```
Generate non-overlapping 1 Mb windows:
```bash
bedtools makewindows -g genome.txt -w 1000000 > windows_1Mb.bed
```
A bash script `scripts/split_vcf_1Mb.sh` is used to extract each genomic window into a separate VCF.

Run:
```bash
./run_vcf2phylip.sh
```
The script uses:

    - filtered.recode.vcf.gz

    - windows_1Mb.bed

Output directory:
```bash
02_data_split/vcf_1Mb/
```
Each file represents one genomic window, for example:
```bash
chr5_0_1000000.vcf.gz
chrZ_9000000_10000000.vcf.gz
```

Create the conversion directory:
```bash
mkdir ./03_convert
cd 03_convert
```

The conversion is performed using `vcf2phylip.py`.

Run
```bash
./run_vcf2phylip.sh
```

Output alignments are stored in:
```bash
03_convert/phylip_1Mb/
```
Each file is a nucleotide alignment in PHYLIP format:
```bash
*.min4.phy
```

The outgroup used during conversion is `Naxos2`:

### Step 3 – Phylogenetic inference

A constraint tree `Data/constraint.tree` defining predefined monophyletic groups is prepared manually.

Create the phylogeny directory:
```bash
mkdir 04_phylogeny
cd 04_phylogeny
```

Tree inference is run for all alignments using a bash script `scripts/build_tree.sh`.

Main settings for running iqtree:

    - input: `03_convert/phylip_1Mb/*.phy`

    - substitution model: GTR+G

    - constraint tree: `Data/constraint.tree`

    - ultrafast bootstrap: 1000

    - multithreading enabled

    - failed windows are logged

Run in background:
```bash
nohup bash ./build_tree.sh > iqtree_log.txt 2>&1 &
```

Failed windows are recorded in `errors.log`

Output trees are written to:
```bash
./04_phylogeny/Treefile
```

Each window produces standard output files including:
```bash
*.treefile
*.iqtree
*.log
```

### Step 4 – Topology summarization among populations

Population assignment file:
```bash
Data/pop_information.txt
```

This file links each sample to its population.

Topology summarisation and visualization is performed in R using R script `scripts/Visualization.R`:

This script classifies each window tree into one of the three possible population-level topologies, 
and plot figures.


## Notes on reproducibility

All scripts are designed to be executed sequentially as described in this README.

All file paths and parameters are explicitly defined inside the scripts and can be modified according to local directory structure.






