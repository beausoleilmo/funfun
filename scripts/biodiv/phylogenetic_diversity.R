# Load packages
library(readr)
library(dplyr)
library(rotl)
library(ape)
library(picante)
library(h3)
library(sf)

# Load Tree with branch length 
# Source tree : https://www.pnas.org/doi/10.1073/pnas.2409658122
bt_um = read.tree(file = "https://raw.githubusercontent.com/McTavishLab/AvesData/refs/heads/main/Tree_versions/Aves_1.4/Clements2023/phylo_only_clements_labels_ultrametric.tre")
plot(bt_um)

# Get Species names that will be compared with list of species in Québec 
sp_in_tree = gsub(pattern = '_', 
                  replacement = ' ',
                  x = bt_um$tip.label)
bt_um$tip.label = sp_in_tree

# Liste de la faune vertébré du Québec : CSV file is downloaded
lfvq_data <- read_csv("~/Downloads/LFVQ_31_01_2025.csv")
"~/Downloads/listes_biologie/LFVQ_31_01_2025.csv""~/Downloads/listes_biologie/LFVQ_31_01_2025.csv""~/Downloads/listes_biologie/LFVQ_31_01_2025.csv"
# Extract unique scientific names
species_names <- unique(lfvq_data$Nom_scientifique)

# Extraction of the first 2 words to get a species list that is comparable with phylogenetic trees 
first_two_words_string <- sapply(species_names, function(x) {
  paste(strsplit(x, " ")[[1]][1:2], collapse = " ")
})
# Extract only the data without the names 
sp_lfvq = unname(first_two_words_string)

# Find the match between 
match_sp = sp_lfvq %in% sp_in_tree

# Prune the original phylogenetic tree with only the BIRD species in Québec 
quebec_tree = drop.tip(phy = bt_um,
                       # Remove the tips that are not found in the lfvq 
                       tip = bt_um$tip.label[-match(sp_lfvq[match_sp], sp_in_tree)])

# Plot the pruned tree 
plot(quebec_tree)

# Check if all matched species are in the tree
setdiff(sp_lfvq[match_sp], quebec_tree$tip.label) # Should be character(0) if all matched names are in the tree

# Create a presence-only community matrix for Quebec
# Ensure column names match tree tip labels
quebec_community_matrix <- as.data.frame(matrix(1, nrow = 1, ncol = length(quebec_tree$tip.label)))
colnames(quebec_community_matrix) <- quebec_tree$tip.label
rownames(quebec_community_matrix) <- "Quebec"


# Calculate Faith's PD
quebec_pd_result <- picante::pd(samp = quebec_community_matrix, 
                                tree = quebec_tree, 
                                include.root = TRUE)

# Display the result
print(quebec_pd_result)


