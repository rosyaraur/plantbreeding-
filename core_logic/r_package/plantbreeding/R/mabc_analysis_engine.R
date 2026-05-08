#' @title  MABC Engine: Multi-Locus, Haplotype-Aware, and Error-Corrected
#'
#' @description 
#' Processes MABC populations with a dual-strategy approach for foreground selection.
#' Calculates background recovery and linkage drag while accounting for 
#' genotyping error (epsilon) and missing data.
#'
#' @param pop_mat Numeric matrix. Rows = individuals, Cols = markers (0, 1, 2).
#' @param map_df Data frame. Columns: 'Marker_ID', 'Chr', 'Pos_cM'.
#' @param trait_list List. A named list where each element is a vector of Marker_IDs 
#'   forming a trait/haplotype. Single-SNP traits are vectors of length 1.
#' @param epsilon Numeric. Expected genotyping error rate (e.g., 0.01).
#' @param rp_val Numeric. Genotype of Recurrent Parent (default = 0).
#' @param buffer_cM Numeric. Exclusion window around traits for RPG% calculation.
#'
#' @export
mabc_analysis_engine <- function(pop_mat, map_df, trait_list, epsilon = 0.01, rp_val = 0, buffer_cM = 5) {
  
  n_ind <- nrow(pop_mat)
  all_targets <- unlist(trait_list)
  
  # --- 1. Background RPG% Calculation (NA-Aware) ---
  # Define background as markers outside target haplotypes +/- buffer
  exclude_idx <- unique(unlist(lapply(all_targets, function(id) {
    t_idx <- which(map_df$Marker_ID == id)
    t_pos <- map_df$Pos_cM[t_idx]; t_chr <- map_df$Chr[t_idx]
    which(map_df$Chr == t_chr & abs(map_df$Pos_cM - t_pos) <= buffer_cM)
  })))
  
  bg_indices <- setdiff(1:nrow(map_df), exclude_idx)
  bg_subset <- pop_mat[, bg_indices, drop = FALSE]
  
  obs_bg <- rowSums(!is.na(bg_subset))
  rp_hom <- rowSums(bg_subset == rp_val, na.rm = TRUE)
  hets <- rowSums(bg_subset == 1, na.rm = TRUE)
  
  # RPG % calculation with a 'soft' error correction
  # We assume epsilon of the background mismatch is actually just error
  rpg_raw <- ((rp_hom + (0.5 * hets)) / obs_bg) * 100
  rpg_corrected <- rpg_raw + (epsilon * 25) # Soft correction for miscalled RP alleles
  
  # --- 2. Foreground Selection (Haplotype vs SNP) ---
  # We calculate a 'Confidence Score' for each trait/haplotype
  trait_confidence <- sapply(trait_list, function(ids) {
    trait_mat <- pop_mat[, ids, drop = FALSE]
    obs_t <- rowSums(!is.na(trait_mat))
    # In MABC BC generations, we expect Het (1) for the introgression
    matches <- rowSums(trait_mat == 1, na.rm = TRUE)
    conf <- matches / obs_t
    return(conf)
  })
  
  # Carrier status: Must meet the error-tolerant threshold across ALL traits
  # Threshold is (1 - epsilon). e.g., if epsilon=0.05, we need 95% match in the haplotype.
  full_carrier <- rowSums(trait_confidence >= (1 - epsilon)) == length(trait_list)
  
  # --- 3. Linkage Drag (cM) ---
  # Drag is calculated from the boundaries of the haplotype block
  drag_per_trait <- lapply(trait_list, function(ids) {
    t_idx_range <- which(map_df$Marker_ID %in% ids)
    t_chr <- map_df$Chr[t_idx_range[1]]
    t_pos_min <- min(map_df$Pos_cM[t_idx_range])
    t_pos_max <- max(map_df$Pos_cM[t_idx_range])
    
    chr_map <- map_df[map_df$Chr == t_chr, ]
    chr_pop <- pop_mat[, map_df$Chr == t_chr, drop = FALSE]
    
    # Internal indices for this chromosome
    rel_start <- which(chr_map$Marker_ID == map_df$Marker_ID[min(t_idx_range)])
    rel_end <- which(chr_map$Marker_ID == map_df$Marker_ID[max(t_idx_range)])
    
    t(apply(chr_pop, 1, function(row) {
      # Left drag: find first RP homozygote to the left
      left_match <- which(row[1:rel_start] == rp_val)
      l_drag <- if(length(left_match) > 0) t_pos_min - chr_map$Pos_cM[max(left_match)] else t_pos_min - min(chr_map$Pos_cM)
      
      # Right drag: find first RP homozygote to the right
      right_match <- which(row[rel_end:ncol(chr_pop)] == rp_val) + (rel_end - 1)
      r_drag <- if(length(right_match) > 0) chr_map$Pos_cM[min(right_match)] - t_pos_max else max(chr_map$Pos_cM) - t_pos_max
      
      return(l_drag + r_drag)
    }))
  })
  
  total_drag <- Reduce("+", drag_per_trait)
  
  # --- 4. Result Compilation ---
  results <- data.frame(
    Individual_ID = rownames(pop_mat),
    Call_Rate = round(rowSums(!is.na(pop_mat)) / ncol(pop_mat), 3),
    RPG_Recovery = round(rpg_corrected, 2),
    Total_Drag_cM = round(as.numeric(total_drag), 2),
    Carrier_Status = full_carrier
  )
  
  # Add individual trait confidence scores for transparency
  results <- cbind(results, round(trait_confidence, 3))
  
  return(results)
}

#' @title Calculate MABC Selection Index
#'
#' @description 
#' Filters individuals for full-carrier status and ranks them using a weighted 
#' selection index of RPG recovery and total linkage drag.
#'
#' @param mabc_results Data frame from analyze_multilocus_mabc.
#' @param weight_rpg Numeric. Importance of RPG% (default = 1).
#' @param weight_drag Numeric. Importance of minimizing drag (default = 1).
#' @param min_call_rate Numeric. Filter for data quality (default = 0.8).
#'
#' @return A data frame of ranked individuals with a calculated 'Selection_Index'.
#' 
#' @export
#' @title Calculate MABC Selection Index (Fixed)
#' @description Aligned with mabc_analysis_engine output.
rank_mabc_progenies <- function(mabc_results, weight_rpg = 1, weight_drag = 1, min_call_rate = 0.8) {
  
  # 1. Quality & Carrier Filtering (Now using 'Carrier_Status')
  candidates <- mabc_results[mabc_results$Carrier_Status == TRUE & 
                               mabc_results$Call_Rate >= min_call_rate, ]
  
  if (nrow(candidates) == 0) {
    # Debug message to help identify if it's a Call_Rate or Carrier issue
    n_carriers <- sum(mabc_results$Carrier_Status)
    max_cr <- max(mabc_results$Call_Rate)
    stop(sprintf("No candidates found. Carriers found: %d. Highest Call Rate: %.3f", 
                 n_carriers, max_cr))
  }
  
  # 2. Standardization Logic
  scale_val <- function(x) {
    if(sd(x, na.rm = TRUE) == 0) return(rep(0, length(x)))
    as.numeric(scale(x))
  }
  
  std_rpg <- scale_val(candidates$RPG_Recovery)
  std_drag <- scale_val(candidates$Total_Drag_cM)
  
  # 3. Index Calculation (Higher RPG is good (+), Higher Drag is bad (-))
  candidates$Selection_Index <- (weight_rpg * std_rpg) - (weight_drag * std_drag)
  
  # 4. Sorting
  return(candidates[order(-candidates$Selection_Index), ])
}

#' @title Chromosome Recovery Visualizer
#' @description Generates a faceted idiogram showing Recurrent Parent (RP) recovery 
#' and donor segments (Linkage Drag) for a specific individual.
#' 
#' @param ind_id String. The ID of the individual to visualize.
#' @param pop_mat Genotype matrix.
#' @param map_df Genetic map with Chr and Pos_cM.
#' @param trait_list List of target haplotypes/SNPs.
plot_mabc_chromosome_maps <- function(ind_id, pop_mat, map_df, trait_list) {
  library(ggplot2)
  library(dplyr)
  
  # Prepare data for plotting
  geno <- data.frame(
    Marker_ID = colnames(pop_mat),
    Genotype = as.factor(pop_mat[ind_id, ]),
    stringsAsFactors = FALSE
  ) %>% inner_join(map_df, by = "Marker_ID")
  
  # Identify target regions for highlighting
  target_markers <- unlist(trait_list)
  geno$Is_Target <- geno$Marker_ID %in% target_markers
  
  # Recode genotypes for clarity: 0=RP, 1=Het, 2=Donor, NA=Missing
  levels(geno$Genotype) <- c("RP (Homo)", "Carrier (Het)", "Donor (Homo)")
  
  ggplot(geno, aes(x = Pos_cM, y = 1, fill = Genotype)) +
    geom_tile(height = 0.8) +
    # Highlight target trait positions
    geom_vline(data = filter(geno, Is_Target), 
               aes(xintercept = Pos_cM), color = "red", size = 1, alpha = 0.5) +
    facet_wrap(~Chr, ncol = 1, strip.position = "left") +
    scale_fill_manual(values = c("RP (Homo)" = "#2c7bb6", 
                                 "Carrier (Het)" = "#fdae61", 
                                 "Donor (Homo)" = "#d7191c"),
                      na.value = "grey90") +
    theme_minimal() +
    theme(axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          panel.grid = element_blank(),
          legend.position = "bottom") +
    labs(title = paste("Genomic Recovery Idiogram:", ind_id),
         subtitle = "Blue: Recurrent Parent | Orange: Heterozygous (Donor Segment) | Red Line: Target Trait",
         x = "Position (cM)", y = "Chromosome")
}

# --- Simulation Setup ---
set.seed(88)
n_markers <- 1000
map_df <- data.frame(
  Marker_ID = paste0("M_", 1:n_markers),
  Chr = rep(1:10, each = 100),
  Pos_cM = rep(seq(0, 99, 1), 10)
)

# Define Traits
traits <- list(
  Trait_A = "M_50",                    # Single SNP
  Trait_B = c("M_245", "M_246", "M_247", "M_248", "M_249") # Haplotype
)

# Simulate BC2 Population (~87.5% RP recovery)
# RP = 0, Donor = 2.
pop_mat <- matrix(sample(c(0, 1), 100 * n_markers, replace = TRUE, prob = c(0.875, 0.125)), 
                  nrow = 100, ncol = n_markers)
colnames(pop_mat) <- map_df$Marker_ID
rownames(pop_mat) <- paste0("Ind_", 1:100)

# Force carriers for Trait A and Trait B (dosage = 1)
pop_mat[, unlist(traits)] <- 1

# Inject Real-World Messiness
# 2% Genotyping Error, 15% Missing Data
noise_indices <- sample(1:length(pop_mat), length(pop_mat) * 0.17)
pop_mat[sample(noise_indices, length(noise_indices)*0.1)] <- NA # 15% NA
pop_mat[sample(noise_indices, length(noise_indices)*0.02)] <- 2  # 2% Error

# --- Execute Analysis ---
mabc_report <- mabc_analysis_engine(
  pop_mat = pop_mat, 
  map_df = map_df, 
  trait_list = traits, 
  epsilon = 0.02, 
  buffer_cM = 10
)


# --- EXECUTION WORKFLOW ---

# 1. ANALYZE: Multi-Locus Engine with NA & Error Handling
mabc_results <- mabc_analysis_engine(
  pop_mat = pop_mat, 
  map_df = map_df, 
  trait_list = traits, 
  epsilon = 0.02, 
  buffer_cM = 10
)

# 2. RANK: Apply Selection Index
# We prioritize individuals with low Linkage Drag (w=2)
final_selection <- rank_mabc_progenies(
  mabc_report, 
  weight_rpg = 1, 
  weight_drag = 2, 
  min_call_rate = 0.7 
)

# 3. VISUALIZE: Plot the #1 Ranked Individual
top_id <- final_selection$Individual_ID[1]
plot_mabc_chromosome_maps(top_id, pop_mat, map_df, traits)

