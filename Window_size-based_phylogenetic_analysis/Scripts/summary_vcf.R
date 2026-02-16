# ============================================================
# Summary statistics visualization for variant-level QC
# ------------------------------------------------------------
# This script visualizes:
#   1) Variant QUAL distribution
#   2) Variant mean depth distribution
#   3) Variant missing rate distribution
#
# The results are used to determine VCF filtering thresholds.
# ============================================================



# Load required packages
library(tidyverse)

# check variant quality
var_qual <- read_delim("./00_summary/out.lqual", delim = "\t",
                       col_names = c("chr", "pos", "qual"), skip = 1)
# Density plot of QUAL
a <- ggplot(var_qual, aes(qual)) + 
            geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3)
a + theme_light() +xlim(0, 1000)

# check variant mean depth
var_depth <- read_delim("./00_summary/out.ldepth.mean", delim = "\t",
                        col_names = c("chr", "pos", "mean_depth", "var_depth"), skip = 1)
# Density plot of mean depth
a <- ggplot(var_depth, aes(mean_depth)) + geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3)
a + theme_light() + xlim(0, 100)
summary(var_depth$mean_depth)  # Summary statistics for mean depth


# check variant missing
var_miss <- read_delim("./00_summary/out.lmiss", delim = "\t", col_names = c("chr", "pos", "nchr", "nfiltered", "nmiss", "fmiss"), skip = 1)
# Density plot of missing rate
a <- ggplot(var_miss, aes(fmiss)) + geom_density(fill = "dodgerblue1", colour = "black", alpha = 0.3)
a + theme_light()
summary(var_miss$fmiss)  # Summary statistics for missing



# ============================================================
# Filtering thresholds chosen based on the above statistics
# ============================================================
#
# MISS       = 0.75
# QUAL       = 30
# MIN_DEPTH  = 7
# MAX_DEPTH  = 18
#
# These thresholds will be applied in the downstream VCF filtering
