# Load necessary library
library(dplyr)

# Load necessary library
library(dplyr)

library(dplyr)

#' Calculate Global FST for multiple inbred subpopulations
#' 
#' @param data A dataframe where the first few columns are metadata (id, chr, position) 
#'             and the remaining columns are genotypes coded as 1 or -1.
#' @param meta_cols Number of metadata columns at the start of the dataframe (default is 3).
#' @param pop_assignments A character vector mapping each genotype column to a subpopulation.
#' @return A dataframe with the original metadata, allele frequencies per subpopulation, 
#'         mean allele frequency, and a new Global_FST column.
calculate_global_fst <- function(data, meta_cols = 3, pop_assignments) {
  
  # 1. Separate metadata from genotype data
  meta <- data[, 1:meta_cols]
  geno <- data[, (meta_cols + 1):ncol(data)]
  
  # Ensure population assignments match the number of samples
  if(length(pop_assignments) != ncol(geno)) {
    stop("The length of pop_assignments must match the number of genotype columns.")
  }
  
  # Identify all valid subpopulations (ignoring NAs or empty strings)
  valid_pops <- unique(pop_assignments)
  valid_pops <- valid_pops[!is.na(valid_pops) & valid_pops != ""]
  k_pops <- length(valid_pops)
  
  if(k_pops < 2) {
    stop("Global FST requires at least 2 distinct subpopulations.")
  }
  
  # 2. Convert 1 / -1 encoding to 1 / 0
  geno_01 <- (geno + 1) / 2
  
  # 3. Create a matrix to store allele frequencies for each subpopulation
  freq_matrix <- matrix(NA, nrow = nrow(geno_01), ncol = k_pops)
  colnames(freq_matrix) <- paste0("p_", valid_pops)
  
  # 4. Calculate frequencies per subpopulation
  for (i in 1:k_pops) {
    pop_name <- valid_pops[i]
    pop_idx <- which(pop_assignments == pop_name)
    
    # Calculate rowMeans for this specific subpopulation
    freq_matrix[, i] <- rowMeans(geno_01[, pop_idx, drop = FALSE], na.rm = TRUE)
  }
  
  # 5. Calculate Global FST parameters
  # Mean allele frequency across all populations
  p_bar <- rowMeans(freq_matrix, na.rm = TRUE)
  
  # Variance of allele frequencies across the k populations
  var_p <- rowSums(sweep(freq_matrix, 1, p_bar, "-")^2, na.rm = TRUE) / k_pops
  
  # Maximum possible variance
  max_var <- p_bar * (1 - p_bar)
  
  # Global FST calculation
  global_fst <- var_p / max_var
  
  # Handle division by zero
  global_fst[max_var == 0 | is.nan(global_fst)] <- 0
  
  # 6. Combine results
  result <- cbind(meta, 
                  as.data.frame(freq_matrix), 
                  Mean_p = p_bar, 
                  Global_FST = global_fst)
  
  return(result)
}

# Install required packages if you don't have them
# install.packages(c("ggplot2", "dplyr"))

library(ggplot2)
library(dplyr)

library(dplyr)

#' Calculate Average Pairwise FST across all subpopulation combinations
#' 
#' @param data A dataframe where the first few columns are metadata (id, chr, position) 
#'             and the remaining columns are genotypes coded as 1 or -1.
#' @param meta_cols Number of metadata columns at the start of the dataframe (default is 3).
#' @param pop_assignments A character vector mapping each genotype column to a subpopulation.
#' @return A dataframe with metadata, all individual pairwise FSTs, and the Average Pairwise FST.
calculate_avg_pairwise_fst <- function(data, meta_cols = 3, pop_assignments) {
  
  # 1. Separate metadata and genotype data
  meta <- data[, 1:meta_cols]
  geno <- data[, (meta_cols + 1):ncol(data)]
  
  # Ensure valid population assignments
  valid_pops <- unique(pop_assignments)
  valid_pops <- valid_pops[!is.na(valid_pops) & valid_pops != ""]
  
  if(length(valid_pops) < 2) {
    stop("Need at least 2 populations to calculate pairwise FST.")
  }
  
  # 2. Convert 1 / -1 encoding to 1 / 0
  geno_01 <- (geno + 1) / 2
  
  # 3. Pre-calculate allele frequencies (p) for EVERY subpopulation to save time
  k_pops <- length(valid_pops)
  freq_matrix <- matrix(NA, nrow = nrow(geno_01), ncol = k_pops)
  colnames(freq_matrix) <- valid_pops
  
  for (i in 1:k_pops) {
    pop_idx <- which(pop_assignments == valid_pops[i])
    # Calculate rowMeans for this specific subpopulation
    freq_matrix[, i] <- rowMeans(geno_01[, pop_idx, drop = FALSE], na.rm = TRUE)
  }
  
  # 4. Generate all unique pairwise combinations
  # combn() generates a matrix where each column is a unique pair
  pairs <- combn(valid_pops, 2)
  num_pairs <- ncol(pairs)
  
  # Matrix to store the FST results for each pair
  pairwise_fst_matrix <- matrix(NA, nrow = nrow(geno_01), ncol = num_pairs)
  colnames(pairwise_fst_matrix) <- paste0(pairs[1,], "_vs_", pairs[2,])
  
  # 5. Loop through every pair and calculate their specific FST
  for (j in 1:num_pairs) {
    # Extract the pre-calculated frequencies for the two populations in this pair
    p1 <- freq_matrix[, pairs[1, j]]
    p2 <- freq_matrix[, pairs[2, j]]
    
    # Standard Pairwise FST Math
    p_bar <- (p1 + p2) / 2
    var_p <- ((p1 - p_bar)^2 + (p2 - p_bar)^2) / 2
    max_var <- p_bar * (1 - p_bar)
    
    fst <- var_p / max_var
    
    # Handle division by zero (loci fixed in both populations)
    fst[max_var == 0 | is.nan(fst)] <- 0
    
    # Store in the matrix
    pairwise_fst_matrix[, j] <- fst
  }
  
  # 6. Calculate the AVERAGE across all pairwise comparisons
  avg_pairwise_fst <- rowMeans(pairwise_fst_matrix, na.rm = TRUE)
  
  # 7. Combine the metadata, individual pairwise columns, and the final average
  result <- cbind(meta, 
                  as.data.frame(pairwise_fst_matrix), 
                  Avg_Pairwise_FST = avg_pairwise_fst)
  
  return(result)
}

# ==============================================================================
# 1. Manhattan Plot Function
# ==============================================================================
#' Create a Manhattan plot for FST results
#' 
#' @param results_df Dataframe containing FST results (must have 'chr', 'position', and FST columns)
#' @param fst_column The name of the column containing FST values (e.g., "Global_FST" or "FST")
#' @param title Title for the plot
plot_fst_manhattan <- function(results_df, fst_column = "Global_FST", title = "Genome-wide FST Scan") {
  
  # 1. Data Preparation
  # Calculate cumulative base pair position for a continuous X-axis across chromosomes
  plot_data <- results_df %>%
    # Ensure columns are numeric and drop missing data
    mutate(chr = as.numeric(chr), position = as.numeric(position)) %>%
    filter(!is.na(chr) & !is.na(position) & !is.na(.data[[fst_column]])) %>%
    arrange(chr, position) %>%
    
    # Calculate offset for each chromosome
    group_by(chr) %>%
    summarise(chr_len = max(position)) %>%
    mutate(tot = cumsum(as.numeric(chr_len)) - chr_len) %>%
    select(-chr_len) %>%
    
    # Merge offsets back to original data and calculate absolute cumulative position
    left_join(results_df, by = "chr") %>%
    arrange(chr, position) %>%
    mutate(BPcum = as.numeric(position) + tot)
  
  # 2. Get X-axis label positions (center of each chromosome)
  axis_df <- plot_data %>%
    group_by(chr) %>%
    summarize(center = (max(BPcum) + min(BPcum)) / 2)
  
  # 3. Build the ggplot
  p <- ggplot(plot_data, aes(x = BPcum, y = .data[[fst_column]])) +
    
    # Add points, color alternately by chromosome
    geom_point(aes(color = as.factor(chr)), alpha = 0.6, size = 1.2) +
    scale_color_manual(values = rep(c("#1B4F72", "#5DADE2"), length(unique(plot_data$chr)))) +
    
    # Set X and Y axes
    scale_x_continuous(label = axis_df$chr, breaks = axis_df$center) +
    scale_y_continuous(expand = c(0, 0), limits = c(0, 1.05)) +
    
    # Clean up the theme
    theme_minimal() +
    theme(
      legend.position = "none",
      panel.border = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      axis.text.x = element_text(size = 10),
      axis.text.y = element_text(size = 10),
      plot.title = element_text(face = "bold", size = 14)
    ) +
    
    # Labels
    labs(x = "Chromosome", 
         y = expression(F[ST]), 
         title = title)
  
  return(p)
}

# ==============================================================================
# 2. Density / Distribution Plot Function
# ==============================================================================
#' Create a density plot of FST distribution
plot_fst_density <- function(results_df, fst_column = "Global_FST", title = "Distribution of FST Values") {
  
  p <- ggplot(results_df, aes(x = .data[[fst_column]])) +
    geom_density(fill = "#E74C3C", alpha = 0.6, color = "#900C3F") +
    theme_minimal() +
    labs(x = expression(F[ST]), y = "Density", title = title)
  
  return(p)
}

# # ==============================================================================
# # 2. Load the Data
# # ==============================================================================
# # Read in the CSVs (ensure they are in your working directory)
# geno_df <- read.csv("~/Documents/githubdir/plantbreeding-/package1.0/plantbreeding/data/rice44K.csv", stringsAsFactors = FALSE)
# disp_df <- read.csv("~/Documents/githubdir/plantbreeding-/package1.0/plantbreeding/data/rice44Kdisp.csv", stringsAsFactors = FALSE)
# 
# # 1. Get the names of the actual genotype columns (excluding id, chr, position)
# genotype_cols <- colnames(geno_df)[-c(1:3)]
# 
# # 2. Extract the NSFTV ID from the column names (e.g., "NSFTV_1" -> "1")
# # This uses gsub to replace "NSFTV_" with nothing
# sample_ids <- gsub("NSFTV_", "", genotype_cols)
# 
# # 3. Match the sample IDs to the descriptor file to get the correct subpopulation
# # match() ensures the vector order perfectly aligns with the genotype columns
# pop_assignments <- disp_df$Sub.population[match(sample_ids, disp_df$NSFTV.ID)]
# 
# # 4. Run the newly created function
# global_fst_results <- calculate_global_fst(data = geno_df, 
#                                            meta_cols = 3, 
#                                            pop_assignments = pop_assignments)
# 
# # 5. Sort by most divergent and view
# global_fst_results <- global_fst_results %>%
#   arrange(desc(Global_FST))
# 
# print(head(global_fst_results, 10))
# 
# # Save output
# write.csv(global_fst_results, "Global_FST_Results_Modular.csv", row.names = FALSE)
# 
# # ---------------------------------------------------------
# # Plotting the Global FST (All 6 subpopulations)
# # ---------------------------------------------------------
# 
# # 1. Manhattan Plot
# manhattan_plot_global <- plot_fst_manhattan(
#   results_df = global_fst_results, 
#   fst_column = "Global_FST", 
#   title = "Global FST across 6 Rice Subpopulations"
# )
# 
# # Show the plot
# print(manhattan_plot_global)
# 
# # Save the plot to a high-resolution image file
# ggsave("Manhattan_Global_FST.png", plot = manhattan_plot_global, width = 10, height = 5, dpi = 300)
# 
# # 2. Density Plot
# density_plot_global <- plot_fst_density(global_fst_results, "Global_FST")
# print(density_plot_global)
# 
# # calculate pair-wise fst 
# # 1. Get the names of the actual genotype columns
# genotype_cols <- colnames(geno_df)[-c(1:3)]
# 
# # 2. Extract the sample IDs and match them to the descriptor file
# sample_ids <- gsub("NSFTV_", "", genotype_cols)
# pop_assignments <- disp_df$Sub.population[match(sample_ids, disp_df$NSFTV.ID)]
# 
# # 3. Run the average pairwise function
# avg_pairwise_results <- calculate_avg_pairwise_fst(data = geno_df, 
#                                                    meta_cols = 3, 
#                                                    pop_assignments = pop_assignments)
# 
# # 4. Sort by the highest Average Pairwise FST
# avg_pairwise_results <- avg_pairwise_results %>%
#   arrange(desc(Avg_Pairwise_FST))
# 
# # 5. View the results (You will see the 15 individual pairwise columns + the final Average)
# print(head(avg_pairwise_results))
# 
# # 6. Export to CSV
# write.csv(avg_pairwise_results, "Average_Pairwise_FST.csv", row.names = FALSE)