#' @title Bi-parental Progeny Verification via Genomic Partitioning
#'
#' @description 
#' Evaluates suspected progenies from a bi-parental cross by partitioning markers into 
#' monomorphic (identical between parents) and polymorphic (segregating) sets. 
#' It flags outcrosses using the monomorphic error rate and verifies pedigree/generation 
#' by checking allele fixation and heterozygosity against expected Mendelian ratios.
#'
#' @param p1_vector Numeric vector. Genotype of Parent 1 (e.g., 0, 1, 2).
#' @param p2_vector Numeric vector. Genotype of Parent 2.
#' @param population_matrix Numeric matrix. Rows are individuals, columns are markers.
#' @param generation Integer. The filial generation (e.g., 6 for F6). Used to calculate 
#'   expected heterozygosity.
#' @param alpha Numeric. Significance level for hypothesis testing. Defaults to 0.01.
#'
#' @return A list containing loci counts, expected values, and a comprehensive data frame 
#'   of individual QA/QC calls and biological metrics.
#' 
#' @export
verify_biparental_progeny <- function(p1_vector, p2_vector, population_matrix, generation = 6, alpha = 0.01) {
  n_total <- nrow(population_matrix)
  
  # 1. Partition the Loci
  # Monomorphic: P1 and P2 are identical and homozygous (0 or 2)
  mono_idx <- which(p1_vector == p2_vector & p1_vector %in% c(0, 2))
  # Polymorphic: P1 and P2 differ and are homozygous
  poly_idx <- which(p1_vector != p2_vector & p1_vector %in% c(0, 2) & p2_vector %in% c(0, 2))
  
  n_mono <- length(mono_idx)
  n_poly <- length(poly_idx)
  
  # 2. Calculate Monomorphic Error Rate (Purity Check)
  if(n_mono > 0) {
    mono_matches <- sweep(population_matrix[, mono_idx, drop = FALSE], 2, p1_vector[mono_idx], `==`)
    mono_error_rate <- 1 - (rowSums(mono_matches) / n_mono)
  } else {
    mono_error_rate <- rep(NA, n_total)
  }
  
  # 3. Calculate Polymorphic Segregation (Inheritance & Generation Check)
  if(n_poly > 0) {
    pop_poly <- population_matrix[, poly_idx, drop = FALSE]
    
    match_p1 <- rowSums(sweep(pop_poly, 2, p1_vector[poly_idx], `==`)) / n_poly
    match_p2 <- rowSums(sweep(pop_poly, 2, p2_vector[poly_idx], `==`)) / n_poly
    het_rate <- rowSums(pop_poly == 1) / n_poly
  } else {
    match_p1 <- rep(NA, n_total); match_p2 <- rep(NA, n_total); het_rate <- rep(NA, n_total)
  }
  
  # 4. Theoretical Expectations (Based on Generation)
  exp_het <- (1/2)^(generation - 1)
  exp_p1 <- (1 - exp_het) / 2
  exp_p2 <- (1 - exp_het) / 2
  
  # Standard Deviations (Binomial Variance)
  sd_het <- sqrt(exp_het * (1 - exp_het) / n_poly)
  sd_p1  <- sqrt(exp_p1 * (1 - exp_p1) / n_poly)
  
  # Calculate Z-scores
  z_het <- (het_rate - exp_het) / sd_het
  z_p1  <- (match_p1 - exp_p1) / sd_p1
  
  p_val_het <- 2 * pnorm(-abs(z_het))
  p_val_p1  <- 2 * pnorm(-abs(z_p1))
  
  # 5. Compile Results & Diagnostic Status
  suspect_ids <- rownames(population_matrix)
  if(is.null(suspect_ids)) suspect_ids <- paste0("Ind_", 1:n_total)
  
  results <- data.frame(
    Individual_ID = suspect_ids,
    Mono_Error = round(mono_error_rate, 4),
    Poly_P1 = round(match_p1, 4),
    Poly_P2 = round(match_p2, 4),
    Obs_Het = round(het_rate, 4),
    Status = "VERIFIED"
  )
  
  # Diagnostic Waterfall (Order matters: most severe errors first)
  # > 5% monomorphic error indicates severe contamination/unrelated pollen
  results$Status[results$Mono_Error > 0.05] <- "REJECT: OUTCROSS/CONTAM" 
  
  # P-value failures on segregation
  results$Status[results$Status == "VERIFIED" & p_val_het < alpha] <- "REJECT: WRONG GENERATION"
  results$Status[results$Status == "VERIFIED" & p_val_p1 < alpha]  <- "REJECT: SKEWED INHERITANCE"
  
  return(list(
    Loci = c(Monomorphic = n_mono, Polymorphic = n_poly),
    Expected = c(P1 = exp_p1, P2 = exp_p2, Het = exp_het),
    Calls = results
  ))
}

# # =====================================================================
# # SIMULATION & DEMONSTRATION
# # =====================================================================
# set.seed(42)
# n_markers <- 5000
# 
# cat("Simulating Parent 1 and Parent 2 (40% divergence)...\n")
# p1 <- sample(c(0, 2), size = n_markers, replace = TRUE)
# is_diff <- runif(n_markers) < 0.40
# p2 <- ifelse(is_diff, ifelse(p1 == 0, 2, 0), p1)
# n_seg <- sum(is_diff)
# 
# # Helper function to generate progenies for a specific generation
# generate_progeny <- function(n_ind, generation) {
#   mat <- matrix(rep(p1, each = n_ind), nrow = n_ind, byrow = FALSE)
#   het_prob <- (1/2)^(generation - 1)
#   hom_prob <- (1 - het_prob) / 2
#   probs <- c(hom_prob, het_prob, hom_prob)
#   
#   seg_matrix <- matrix(sample(c(0, 1, 2), size = n_ind * n_seg, replace = TRUE, prob = probs), 
#                        nrow = n_ind, ncol = n_seg)
#   
#   p1_seg <- matrix(p1[is_diff], nrow = n_ind, ncol = n_seg, byrow = TRUE)
#   p2_seg <- matrix(p2[is_diff], nrow = n_ind, ncol = n_seg, byrow = TRUE)
#   mat[, is_diff] <- p1_seg + seg_matrix * (p2_seg - p1_seg) / 2
#   return(mat)
# }
# 
# # --- 1. Build the Matrix ---
# cat("Injecting errors: 5 True F6s, 1 F2 Mix-up, 1 P1 Self, 1 Unrelated...\n\n")
# 
# # A. 5 True F6s
# f6_lines <- generate_progeny(5, generation = 6)
# rownames(f6_lines) <- paste0("True_F6_", 1:5)
# 
# # B. 1 F2 Line (Seed mix-up from an earlier generation)
# f2_line <- generate_progeny(1, generation = 2)
# rownames(f2_line) <- "Error_F2_MixUp"
# 
# # C. 1 Accidental Self of P1 (with 0.1% mutation/seq error)
# p1_self <- p1
# muts <- runif(n_markers) < 0.001
# p1_self[muts] <- (p1_self[muts] + 1) %% 3
# p1_self <- matrix(p1_self, nrow = 1)
# rownames(p1_self) <- "Error_P1_Self"
# 
# # D. 1 Unrelated Line
# unrelated <- sample(c(0, 2), size = n_markers, replace = TRUE)
# unrelated <- matrix(unrelated, nrow = 1)
# rownames(unrelated) <- "Error_Unrelated"
# 
# population_matrix <- rbind(f6_lines, f2_line, p1_self, unrelated)
# 
# # --- 2. Run the Verification ---
# results <- verify_biparental_progeny(p1, p2, population_matrix, generation = 6, alpha = 0.01)
# 
# # --- 3. View Results ---
# cat("--- Genomic Architecture ---\n")
# print(results$Loci)
# cat("\n--- Expected F6 Target Ratios ---\n")
# print(round(results$Expected, 4))
# cat("\n--- Verification Calls ---\n")
# print(results$Calls)


#' @title Evaluate Marker Density Adequacy via Downsampling
#'
#' @description 
#' Evaluates the diagnostic power of varying marker densities using a user-supplied 
#' population matrix. It iteratively downsamples the provided markers to specified 
#' target densities, calculates the empirical mean and standard deviation of the 
#' genetic distance (Polymorphic P1 match), and computes the theoretical Z-score 
#' of an accidental Parent 1 self-pollination. This determines if the reduced 
#' marker panel still possesses the statistical power to detect crossing errors.
#'
#' @param p1_vector Numeric vector. Genotype of Parent 1.
#' @param p2_vector Numeric vector. Genotype of Parent 2.
#' @param population_matrix Numeric matrix. The full-density genotype matrix of the population.
#' @param target_densities Numeric vector. A list of marker counts to test 
#'   (e.g., c(50, 200, 500, 1000, 5000)).
#' @param target_z_score Numeric. The minimum Z-score required to classify a density 
#'   as "Adequate". Defaults to 4.0 (representing virtual certainty).
#' @param seed Integer. Seed for reproducible random downsampling.
#'
#' @return A data frame summarizing the diagnostic power at each requested marker density.
#' 
#' @export
evaluate_marker_adequacy <- function(p1_vector, p2_vector, population_matrix, 
                                     target_densities = c(50, 100, 500, 1000, 5000), 
                                     target_z_score = 4.0, seed = 123) {
  set.seed(seed)
  n_total_markers <- length(p1_vector)
  results <- list()
  
  for (n_markers in target_densities) {
    # Ensure we don't try to sample more markers than exist
    if (n_markers > n_total_markers) {
      warning(paste("Target density", n_markers, "exceeds total markers. Skipping."))
      next
    }
    
    # 1. Randomly sample 'n_markers' columns
    sampled_idx <- sample(1:n_total_markers, size = n_markers, replace = FALSE)
    
    sub_p1 <- p1_vector[sampled_idx]
    sub_p2 <- p2_vector[sampled_idx]
    sub_pop <- population_matrix[, sampled_idx, drop = FALSE]
    
    # 2. Identify Polymorphic Loci in the subset
    poly_idx <- which(sub_p1 != sub_p2 & sub_p1 %in% c(0, 2) & sub_p2 %in% c(0, 2))
    n_poly <- length(poly_idx)
    
    if (n_poly == 0) {
      results[[as.character(n_markers)]] <- data.frame(
        Tested_Markers = n_markers, Poly_Loci = 0, Emp_Mean_P1 = NA, 
        Emp_SD = NA, P1_Self_Z_Score = NA, Status = "FAILED: No Polymorphisms"
      )
      next
    }
    
    # 3. Calculate Empirical Distribution on the subset
    pop_poly <- sub_pop[, poly_idx, drop = FALSE]
    match_p1 <- rowSums(sweep(pop_poly, 2, sub_p1[poly_idx], `==`)) / n_poly
    
    emp_mean <- mean(match_p1, na.rm = TRUE)
    emp_sd <- sd(match_p1, na.rm = TRUE)
    
    # 4. Calculate Diagnostic Power (Z-Score of a P1 Self)
    # A true P1 self would have a 1.0 match at all polymorphic loci
    if (!is.na(emp_sd) && emp_sd > 0) {
      z_score_self <- (1.0 - emp_mean) / emp_sd
    } else {
      z_score_self <- NA # Failsafe if variance is exactly 0
    }
    
    # 5. Determine Status
    status <- ifelse(is.na(z_score_self), "INCONCLUSIVE",
                     ifelse(z_score_self >= target_z_score, "ADEQUATE", "INADEQUATE"))
    
    results[[as.character(n_markers)]] <- data.frame(
      Tested_Markers = n_markers,
      Poly_Loci = n_poly,
      Emp_Mean_P1 = round(emp_mean, 4),
      Emp_SD = round(emp_sd, 4),
      P1_Self_Z_Score = round(z_score_self, 2),
      Status = status
    )
  }
  
  # Combine list into a single data frame
  final_df <- do.call(rbind, results)
  rownames(final_df) <- NULL
  return(final_df)
}

# # =====================================================================
# # SIMULATION & DEMONSTRATION
# # =====================================================================
# set.seed(42)
# total_markers <- 5000
# n_lines <- 100
# 
# cat("Simulating a high-density matrix of 100 True F6 lines (5000 markers)...\n\n")
# 
# # 1. Generate Parents (40% divergence)
# p1 <- sample(c(0, 2), size = total_markers, replace = TRUE)
# is_diff <- runif(total_markers) < 0.40
# p2 <- ifelse(is_diff, ifelse(p1 == 0, 2, 0), p1)
# n_seg <- sum(is_diff)
# 
# # 2. Build the Population Matrix
# population_matrix <- matrix(rep(p1, each = n_lines), nrow = n_lines, byrow = FALSE)
# f6_probs <- c(0.484375, 0.03125, 0.484375)
# seg_matrix <- matrix(sample(c(0, 1, 2), size = n_lines * n_seg, replace = TRUE, prob = f6_probs), 
#                      nrow = n_lines, ncol = n_seg)
# p1_seg <- matrix(p1[is_diff], nrow = n_lines, ncol = n_seg, byrow = TRUE)
# p2_seg <- matrix(p2[is_diff], nrow = n_lines, ncol = n_seg, byrow = TRUE)
# population_matrix[, is_diff] <- p1_seg + seg_matrix * (p2_seg - p1_seg) / 2
# 
# # 3. Run the Downsampling Adequacy Analysis
# # We want to know if we can drop down to 30, 100, 300, or 1000 markers.
# densities_to_test <- c(30, 100, 300, 1000, 5000)
# 
# adequacy_report <- evaluate_marker_adequacy(
#   p1_vector = p1, 
#   p2_vector = p2, 
#   population_matrix = population_matrix, 
#   target_densities = densities_to_test,
#   target_z_score = 4.0 # We want 4 standard deviations of separation
# )
# 
# # 4. View Results
# cat("--- Marker Adequacy Downsampling Report ---\n")
# print(adequacy_report)