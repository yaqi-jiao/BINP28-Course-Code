# ============================================================
# Gene tree topology comparison among three populations
#
# For each tree file:
#   - infer the supported topology among (A, B, C)
#   - count the number of trees supporting each topology
#   - compare results between chromosomes
# ============================================================


# package preparation
library(ape)
library(dplyr)
library(stringr)
library(ggplot2)
library(cowplot)

# read data
tree_dirs <- c("Treefile/chr5/", "Treefile/chrZ/")
names(tree_dirs) <- c("chr5", "chrZ")

# prepare samples
pop <- read.table("pop_information", stringsAsFactors = FALSE,
                  col.names = c("sample", "group"))
pop_list <- split(pop$sample, pop$group)   # split samples by population
A_samples <- pop_list$A
B_samples <- pop_list$B
C_samples <- pop_list$C

# Function: infer topology among A, B and C
get_topology <- function(tree, A, B, C) {
  
  mrca_A <- getMRCA(tree, A)
  mrca_B <- getMRCA(tree, B)
  mrca_C <- getMRCA(tree, C)
  
  # depth of each node from the root
  depth <- node.depth.edgelength(tree)
  
  # MRCA depth for each population pair
  dAB <- depth[getMRCA(tree, c(A, B))]
  dAC <- depth[getMRCA(tree, c(A, C))]
  dBC <- depth[getMRCA(tree, c(B, C))]
  
  # choose the topology with the deepest MRCA
  if (dAB > dAC & dAB > dBC) {
    return("((A,B),C)")
  } else if (dAC > dAB & dAC > dBC) {
    return("((A,C),B)")
  } else if (dBC > dAB & dBC > dAC) {
    return("((B,C),A)")
  } else {
    return("unresolved")
  }
}


# main logic
all_results <- list()
all_stats <- list()

for (chr_name in names(tree_dirs)) {
  
  cat("Processing", chr_name, "...\n")
  
  # get tree files for current chromosome
  tree_files <- list.files(tree_dirs[chr_name], full.names = TRUE)
  
  # process each tree file
  results <- lapply(tree_files, function(f) {
    
    tree <- read.tree(f)
    
    topo <- get_topology(
      tree,
      A = A_samples,
      B = B_samples,
      C = C_samples
    )
    
    data.frame(
      treefile = basename(f),
      topology = topo,
      stringsAsFactors = FALSE
    )
  })
  
  # combine results
  results <- bind_rows(results)
  
  # add chromosome and position information
  results <- results %>%
    mutate(
      chr   = chr_name,
      start = as.numeric(str_extract(treefile, "(?<=_)\\d+(?=_)")),
      end   = as.numeric(str_extract(treefile, "(?<=_)\\d+(?=\\.min4_treefile)"))
    )
  
  # store results
  all_results[[chr_name]] <- results
  
  # calculate statistics
  stat <- results %>%
    count(topology) %>%
    mutate(chr = chr_name)
  
  all_stats[[chr_name]] <- stat
}

# combine all statistics
combined_stats <- bind_rows(all_stats)

# Visualization
# create plots using for loop
plots <- list()

base_theme <- theme_bw() + 
  theme(
    text = element_text(family = "serif"),
    axis.text.x = element_text(angle = 45, hjust = 1, family = "serif"),
    axis.title = element_text(family = "serif"),
    legend.position = "none"
  )

for (chr_name in names(tree_dirs)) {
  
  # get data for current chromosome
  stat_data <- all_stats[[chr_name]]
  
  # create plot without title
  p <- ggplot(stat_data, aes(x = topology, y = n, fill = topology)) +
    geom_col(width = 0.7) +
    theme_bw() +
    labs(
      title = NULL,
      x = NULL,
      y = "Number of trees"
    ) + base_theme
  
  # store plot
  plots[[chr_name]] <- p
}

# combine plots side by side with A and B labels
combined_plot <- plot_grid(
  plots$chr5 + labs(title = NULL),
  plots$chrZ + labs(title = NULL),
  ncol = 2,
  align = "h",
  labels = c("A", "B"),
  label_fontfamily = "serif",
  label_size = 14
)

# display combined plot
print(combined_plot)
ggsave("topology_comparison.png", combined_plot, width = 10, height = 4, dpi = 300)
