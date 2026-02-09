#!/usr/bin/env python3

"""
Author: Yaqi Jiao
Date: 7th, February, 2026

link_phylum.py
--------------

Description: This script is hard coded. It uses otus.tsv and all.fixedrank as input files, 
and generate  phylum_composition.tsv for plot

Input file: otus.tsv, all.fixedrank
Output file: phylum_composition.tsv

Usage Example: python link_phylum.py

"""

# package prepartion
import pandas as pd

# read otus.tsv file
otu = pd.read_csv("otus.tsv", sep="\t", index_col=0)
otu.index.name = "OTU"

# read taxonomy, and extract otu names, remove unnecessary part
tax = pd.read_csv("all.fixedrank", sep="\t", header=None)
tax["OTU"] = tax[0].str.split(";").str[0]
is_bacteria = tax[2].str.contains("Bacteria", case=False)

# extract phylum and confidence(>=0.8)
tax_subset = tax.loc[is_bacteria, ["OTU", 5, 7]]
tax_subset.columns = ["OTU", "phylum", "confidence"]
tax_subset["confidence"] = tax_subset["confidence"].astype(float)
tax_subset = tax_subset[tax_subset["confidence"] >= 0.8]

# merge data
data = otu.join(tax_subset.set_index("OTU"), how="inner") 
colony_cols = otu.columns.tolist()
phylum_table = data.groupby("phylum")[colony_cols].sum()
rel = phylum_table.div(phylum_table.sum(axis=0), axis=1)

# make output file
rel_long = rel.reset_index().melt(
    id_vars="phylum",
    var_name="colony",
    value_name="abundance"
)
rel_long.to_csv("phylum_composition.tsv", sep="\t", index=False)
