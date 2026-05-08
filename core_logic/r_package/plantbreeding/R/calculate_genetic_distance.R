# The Genetic Distance Calculator Function
library(dplyr)

#' Calculate Genetic Distance among subpopulations
#' 
#' @param data A dataframe with metadata and genotypes coded as 1 or -1.
#' @param meta_cols Number of metadata columns at the start (default 3).
#' @param pop_assignments A character vector mapping columns to subpopulations.
#' @param method Either "Nei" or "Euclidean".
#' @return A 'dist' object containing the pairwise genetic distances.
calculate_genetic_distance <- function(data, meta_cols = 3, pop_assignments, method = "Nei") {
  
  # Separate genotypes and filter valid populations
  geno <- data[, (meta_cols + 1):ncol(data)]
  valid_pops <- unique(pop_assignments)
  valid_pops <- valid_pops[!is.na(valid_pops) & valid_pops != ""]
  k_pops <- length(valid_pops)
  
  if(k_pops < 2) stop("Need at least 2 populations to calculate distance.")
  
  # Convert 1 / -1 encoding to 1 / 0
  geno_01 <- (geno + 1) / 2
  
  # Compute allele frequencies (p) for every subpopulation
  freq_matrix <- matrix(NA, nrow = nrow(geno_01), ncol = k_pops)
  colnames(freq_matrix) <- valid_pops
  
  for (i in 1:k_pops) {
    pop_idx <- which(pop_assignments == valid_pops[i])
    freq_matrix[, i] <- rowMeans(geno_01[, pop_idx, drop = FALSE], na.rm = TRUE)
  }
  
  # ---------------------------------------------------------
  # Calculate Distances
  # ---------------------------------------------------------
  if (method == "Euclidean") {
    # Transpose so rows are populations, columns are loci
    dist_obj <- dist(t(freq_matrix), method = "euclidean")
    
  } else if (method == "Nei") {
    # Nei's Standard Genetic Distance formula
    dist_mat <- matrix(0, nrow = k_pops, ncol = k_pops)
    rownames(dist_mat) <- colnames(dist_mat) <- valid_pops
    
    for (i in 1:(k_pops - 1)) {
      for (j in (i + 1):k_pops) {
        p1 <- freq_matrix[, i]
        p2 <- freq_matrix[, j]
        
        # Remove loci with missing data in either population
        valid <- !is.na(p1) & !is.na(p2)
        p1 <- p1[valid]
        p2 <- p2[valid]
        
        # Calculate Identity (I)
        numerator <- sum(p1 * p2)
        denominator <- sqrt(sum(p1^2) * sum(p2^2))
        I <- numerator / denominator
        
        # Handle floating point edge cases
        I <- min(I, 1) 
        
        # Nei's Distance (D) = -ln(I)
        D <- -log(I)
        
        dist_mat[i, j] <- D
        dist_mat[j, i] <- D
      }
    }
    dist_obj <- as.dist(dist_mat)
    
  } else {
    stop("Method must be 'Nei' or 'Euclidean'")
  }
  
  return(dist_obj)
}

library(ggplot2)

# ====================================================================
# Plot 1: Hierarchical Clustering Dendrogram (Phylogenetic Tree style)
# ====================================================================
plot_distance_dendrogram <- function(dist_obj, title = "Genetic Distance Dendrogram") {
  # Use Ward's minimum variance method for clean, distinct clusters
  hc <- hclust(dist_obj, method = "ward.D2")
  
  # Base R plot handles hclust objects natively very well
  plot(hc, main = title, xlab = "Subpopulations", sub = "", 
       ylab = "Distance", col = "#2C3E50", lwd = 2, cex = 1.2)
}

# ====================================================================
# Plot 2: Principal Coordinate Analysis (PCoA / MDS)
# ====================================================================
plot_distance_pcoa <- function(dist_obj, title = "PCoA of Subpopulations") {
  # Perform Multidimensional Scaling
  pcoa_res <- cmdscale(dist_obj, k = 2, eig = TRUE)
  
  # Calculate % variance explained by the first two axes
  var_exp <- round(pcoa_res$eig / sum(pcoa_res$eig) * 100, 1)
  
  # Format data for ggplot
  df <- data.frame(
    Pop = rownames(pcoa_res$points),
    PC1 = pcoa_res$points[, 1],
    PC2 = pcoa_res$points[, 2]
  )
  
  p <- ggplot(df, aes(x = PC1, y = PC2, label = Pop, color = Pop)) +
    geom_point(size = 5, alpha = 0.8) +
    geom_text(vjust = -1.5, size = 4.5, fontface = "bold") +
    theme_minimal() +
    labs(title = title,
         x = paste0("Coordinate 1 (", var_exp[1], "% variance)"),
         y = paste0("Coordinate 2 (", var_exp[2], "% variance)")) +
    theme(legend.position = "none",
          panel.grid.minor = element_blank())
  
  return(p)
}

# ====================================================================
# Plot 3: Distance Heatmap Matrix
# ====================================================================
plot_distance_heatmap <- function(dist_obj, title = "Pairwise Genetic Distance Matrix") {
  # Convert dist object to a square matrix, then to a flat dataframe for ggplot
  dist_mat <- as.matrix(dist_obj)
  df <- as.data.frame(as.table(dist_mat))
  
  # Force factor ordering so the matrix mirrors correctly
  df$Var2 <- factor(df$Var2, levels = rev(levels(df$Var2)))
  
  p <- ggplot(df, aes(x = Var1, y = Var2, fill = Freq)) +
    geom_tile(color = "white", linewidth = 0.5) +
    # Add text overlay of the actual distance values
    geom_text(aes(label = round(Freq, 3)), color = "black", size = 4) +
    scale_fill_gradient(low = "#FFFFFF", high = "#E74C3C", name = "Distance") +
    theme_minimal() +
    labs(title = title, x = "", y = "") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 11, face = "bold"),
          axis.text.y = element_text(size = 11, face = "bold"),
          panel.grid = element_blank())
  
  return(p)
}

# Execution Pipeline: How to put it all together
# 1. Load your datasets
geno_df <- read.csv("~/Documents/githubdir/plantbreeding-/package1.0/plantbreeding/data/rice44K.csv", stringsAsFactors = FALSE)
disp_df <- read.csv("~/Documents/githubdir/plantbreeding-/package1.0/plantbreeding/data/rice44Kdisp.csv", stringsAsFactors = FALSE)

# 2. Extract population assignments dynamically
sample_ids <- gsub("NSFTV_", "", colnames(geno_df)[-c(1:3)])
pop_assignments <- disp_df$Sub.population[match(sample_ids, disp_df$NSFTV.ID)]

# 3. Calculate Nei's Distance
# Note: You can switch method = "Nei" to method = "Euclidean"
nei_dist <- calculate_genetic_distance(data = geno_df, 
                                       meta_cols = 3, 
                                       pop_assignments = pop_assignments, 
                                       method = "Nei")

# 4. Generate the Visualizations

# A. Display the Dendrogram (Plots directly to the R Viewer)
plot_distance_dendrogram(nei_dist, title = "Rice Subpopulations: Nei's Distance")

# B. Generate and display the PCoA
pcoa_plot <- plot_distance_pcoa(nei_dist, title = "PCoA: Rice Subpopulations")
print(pcoa_plot)

# C. Generate and display the Heatmap
heatmap_plot <- plot_distance_heatmap(nei_dist, title = "Nei's Distance Matrix")
print(heatmap_plot)

# plot invidual level diversity 
# Load required libraries
library(ggplot2)
library(dplyr)

# 2. Prepare the Genotype Matrix
# Drop the metadata columns (id, chr, position) so only genotype calls remain
geno_data <- geno_df[, -c(1:3)]

# Transpose the data: prcomp() requires individuals to be ROWS and markers to be COLUMNS
geno_matrix <- t(geno_data)

# Extract sample IDs from the new rownames (e.g., "NSFTV_1" -> "1")
sample_ids <- gsub("NSFTV_", "", rownames(geno_matrix))

# 3. Match Subpopulations
# Look up the subpopulation for each individual based on the descriptor file
sub_pops <- disp_df$Sub.population[match(sample_ids, disp_df$NSFTV.ID)]

# Replace any missing or empty assignments with "Unknown"
sub_pops[is.na(sub_pops) | sub_pops == ""] <- "Unknown"

# 4. Perform Principal Component Analysis (PCA)
print("Running PCA across 44K markers... this may take a few seconds.")
# We center the data (standard practice), but do not scale it for 1/-1 encoded SNPs
pca_res <- prcomp(geno_matrix, center = TRUE, scale. = FALSE)

# 5. Extract Results
# Calculate the percentage of total genetic variance explained by the first two axes
var_explained <- round(pca_res$sdev^2 / sum(pca_res$sdev^2) * 100, 1)

# Create a clean dataframe for ggplot
pca_df <- data.frame(
  Sample = rownames(geno_matrix),
  Subpopulation = sub_pops,
  PC1 = pca_res$x[, 1],
  PC2 = pca_res$x[, 2]
)

# 6. Plot the Data
p_pca <- ggplot(pca_df, aes(x = PC1, y = PC2, color = Subpopulation)) +
  # Plot the individual dots
  geom_point(size = 3, alpha = 0.8) +
  
  # Add confidence ellipses around each subpopulation (helps visualize the clusters)
  stat_ellipse(level = 0.95, linetype = 2, linewidth = 0.6) +
  
  # Styling and labels
  theme_minimal() +
  labs(
    title = "Genetic Structure of Individual Rice Accessions",
    subtitle = "Based on 44K SNP array",
    x = paste0("Principal Component 1 (", var_explained[1], "% variance)"),
    y = paste0("Principal Component 2 (", var_explained[2], "% variance)"),
    color = "Subpopulation"
  ) +
  theme(
    legend.position = "right",
    plot.title = element_text(face = "bold", size = 15),
    axis.title = element_text(face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, size = 0.5)
  ) +
  # Use a distinct, colorblind-friendly palette
  scale_color_brewer(palette = "Set1")

# Display the plot
print(p_pca)

# Save the plot as a high-resolution PNG
ggsave("PCA_Individuals_by_Subpop.png", plot = p_pca, width = 9, height = 7, dpi = 300)