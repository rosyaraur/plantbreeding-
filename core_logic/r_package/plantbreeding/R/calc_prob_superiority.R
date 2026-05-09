# ==============================================================================
# PROBABILITY OF SUPERIORITY (RELIABILITY) MET PIPELINE
# Integrates Empirical, BLUE, BLUP, and modern GBLUP methods.
# ==============================================================================

library(dplyr)
library(tidyr)
library(ggplot2)
library(lme4)
library(emmeans)
library(sommer)

# ==========================================
# 1. MET Data Simulation Engine
# ==========================================

#' Simulate Multi-Environment Trial (MET) Data
#'
#' @description
#' Generates synthetic phenotypic data for multi-environment trials, including
#' specific Genotype-by-Environment (GxE) interaction variances to test stability metrics.
#'
#' @param n_envs Integer. The number of environments to simulate. Default is 15.
#' @param n_reps Integer. The number of replicates per genotype within each environment. Default is 3.
#' @param var_ge Numeric. The GxE variance component specifically assigned to the high-GxE test line. Default is 150.
#'
#' @return A \code{tibble} (data.frame) containing plot-level phenotypic data.
#' @export
simulate_met_data <- function(n_envs = 15, n_reps = 3, var_ge = 150) {
  set.seed(42) 
  
  genotypes <- data.frame(
    Genotype = c("Check", "Line_A_HighGxE", "Line_B_Stable"),
    True_Mean = c(100, 108, 104) 
  )
  
  environments <- data.frame(
    Environment = paste0("Env_", 1:n_envs),
    Env_Effect = rnorm(n_envs, mean = 0, sd = 15)
  )
  
  df <- expand_grid(
    Genotype = genotypes$Genotype,
    Environment = environments$Environment,
    Rep = 1:n_reps
  ) %>%
    left_join(genotypes, by = "Genotype") %>%
    left_join(environments, by = "Environment") %>%
    rowwise() %>%
    mutate(
      GxE_Effect = case_when(
        Genotype == "Line_A_HighGxE" ~ rnorm(1, 0, sqrt(var_ge)),
        TRUE ~ rnorm(1, 0, sqrt(2)) # Low background GxE
      ),
      Plot_Error = rnorm(1, 0, sd = 3),
      Yield = True_Mean + Env_Effect + GxE_Effect + Plot_Error
    ) %>%
    ungroup()
  
  return(df)
}

# ==========================================
# 2. Master Reliability Function
# ==========================================

#' Calculate Probability of Superiority (Reliability)
#'
#' @description
#' Computes the probability that a set of test lines will outperform a designated
#' check variety in a randomly selected target environment using Mean, BLUE, BLUP, or GBLUP.
#'
#' @param data A data.frame or tibble containing the phenotypic MET data.
#' @param trait Character. The name of the trait column to analyze (e.g., "Yield").
#' @param geno_col Character. The name of the column containing genotype identifiers.
#' @param env_col Character. The name of the column containing environment identifiers.
#' @param check_id Character. The exact string identifier of the check variety to compare against.
#' @param method Character. One of "mean", "BLUE", "BLUP", or "GBLUP".
#' @param G_matrix Matrix. Optional. A genomic relationship matrix. Required only if \code{method = "GBLUP"}.
#'
#' @return A \code{data.frame} containing \code{Genotype}, \code{Estimate_Diff}, \code{SED}, \code{Z_Score}, and \code{Prob_Superiority}.
#' @export
calc_prob_superiority <- function(data, trait, geno_col, env_col, check_id, method = "BLUE", G_matrix = NULL) {
  
  data[[geno_col]] <- as.factor(data[[geno_col]])
  data[[env_col]] <- as.factor(data[[env_col]])
  
  if (method == "mean") {
    # ---------------------------------------------------------
    # METHOD 1: Empirical Means (Robust tidy eval mapping)
    # ---------------------------------------------------------
    ge_means <- data %>%
      group_by(.data[[geno_col]], .data[[env_col]]) %>%
      summarize(mean_val = mean(.data[[trait]], na.rm = TRUE), .groups = "drop")
    
    check_data <- ge_means %>% 
      filter(.data[[geno_col]] == check_id) %>% 
      dplyr::rename(check_val = mean_val) %>%
      dplyr::select(dplyr::all_of(c(env_col, "check_val")))
    
    results <- ge_means %>%
      filter(.data[[geno_col]] != check_id) %>%
      inner_join(check_data, by = env_col) %>%
      mutate(diff = mean_val - check_val) %>%
      group_by(.data[[geno_col]]) %>%
      summarize(
        Estimate_Diff = mean(diff, na.rm = TRUE),
        SED = sqrt(var(diff, na.rm = TRUE) / n()), 
        .groups = "drop"
      ) %>%
      mutate(
        Z_Score = Estimate_Diff / SED, 
        Prob_Superiority = pnorm(Z_Score)
      ) %>%
      arrange(desc(Prob_Superiority)) %>%
      dplyr::rename(Genotype = dplyr::all_of(geno_col))
    
    return(as.data.frame(results))
    
  } else if (method == "BLUE") {
    # ---------------------------------------------------------
    # METHOD 2: BLUEs (lme4 + emmeans)
    # ---------------------------------------------------------
    data[[geno_col]] <- relevel(data[[geno_col]], ref = check_id)
    formula_str <- paste0(trait, " ~ ", geno_col, " + (1|", env_col, ")")
    model <- lmer(as.formula(formula_str), data = data)
    
    emm_specs <- as.formula(paste0("trt.vs.ctrl ~ ", geno_col))
    emm <- emmeans(model, specs = emm_specs, ref = 1) 
    
    results <- as.data.frame(summary(emm$contrasts)) %>%
      mutate(
        Genotype = gsub(paste0(" - ", check_id), "", contrast),
        Estimate_Diff = estimate,
        SED = SE,
        Z_Score = Estimate_Diff / SED,
        Prob_Superiority = pnorm(Z_Score)
      ) %>%
      dplyr::select(Genotype, Estimate_Diff, SED, Z_Score, Prob_Superiority) %>%
      arrange(desc(Prob_Superiority))
    
    return(results)
    
  } else if (method == "BLUP") {
    # ---------------------------------------------------------
    # METHOD 3: Base BLUPs (lme4, assumption Cov(i, j) = 0)
    # ---------------------------------------------------------
    formula_str <- paste0(trait, " ~ (1|", geno_col, ") + (1|", env_col, ")")
    model <- lmer(as.formula(formula_str), data = data)
    
    ranef_obj <- ranef(model, condVar = TRUE)
    blups <- ranef_obj[[geno_col]]
    pevs <- attr(blups, "postVar")[1, 1, ] 
    
    blup_df <- data.frame(Genotype = rownames(blups), BLUP = blups[, 1], PEV = pevs)
    
    check_blup <- blup_df$BLUP[blup_df$Genotype == check_id]
    check_pev <- blup_df$PEV[blup_df$Genotype == check_id]
    
    results <- blup_df %>%
      filter(Genotype != check_id) %>%
      mutate(
        Estimate_Diff = BLUP - check_blup,
        SED = sqrt(PEV + check_pev),
        Z_Score = Estimate_Diff / SED,
        Prob_Superiority = pnorm(Z_Score)
      ) %>%
      dplyr::select(Genotype, Estimate_Diff, SED, Z_Score, Prob_Superiority) %>%
      arrange(desc(Prob_Superiority))
    
    return(results)
    
  } else if (method == "GBLUP") {
    # ---------------------------------------------------------
    # METHOD 4: G-BLUPs (sommer v4.0+, modern variance syntax)
    # ---------------------------------------------------------
    if (is.null(G_matrix)) stop("A G_matrix must be provided for GBLUP.")
    
    fixed_form <- as.formula(paste0(trait, " ~ 1 + ", env_col))
    random_form <- as.formula(paste0("~ vsr(", geno_col, ", Gu = G_matrix)"))
    
    model <- mmer(fixed = fixed_form, random = random_form, rcov = ~ units, data = data, verbose = FALSE)
    
    term_name <- paste0("u:", geno_col)
    
    # Modern extraction mapping to handle multi-trait structures
    blups <- model$U[[term_name]][[trait]]
    pev_mat <- model$PevU[[term_name]][[trait]] 
    
    names(blups) <- gsub(paste0(geno_col, ""), "", names(blups))
    rownames(pev_mat) <- colnames(pev_mat) <- gsub(paste0(geno_col, ""), "", rownames(pev_mat))
    
    check_blup <- blups[check_id]
    pev_c <- pev_mat[check_id, check_id]
    
    results_list <- list()
    for (line in names(blups)) {
      if (line != check_id) {
        line_blup <- blups[line]
        pev_l <- pev_mat[line, line]
        pev_lc <- pev_mat[line, check_id] 
        
        # Exact SED accounting for covariance from G-matrix
        sed <- sqrt(pev_l + pev_c - 2 * pev_lc)
        est_diff <- line_blup - check_blup
        z_score <- est_diff / sed
        
        results_list[[length(results_list) + 1]] <- data.frame(
          Genotype = line, 
          Estimate_Diff = as.numeric(est_diff), 
          SED = as.numeric(sed),
          Z_Score = as.numeric(z_score), 
          Prob_Superiority = pnorm(as.numeric(z_score))
        )
      }
    }
    
    final_results <- do.call(rbind, results_list) %>% 
      arrange(desc(Prob_Superiority))
    
    return(final_results)
    
  } else {
    stop("Invalid method. Must be one of: 'mean', 'BLUE', 'BLUP', 'GBLUP'.")
  }
}

# ==========================================
# 3. Execution & Comparison Workflow
# ==========================================

# # A. Generate Data
# cat("\nGenerating MET Data...\n")
# sim_data <- simulate_met_data(n_envs = 15, n_reps = 3, var_ge = 150)
# 
# # B. Generate Dummy Genomic Relationship Matrix (G)
# genotypes <- as.character(unique(sim_data$Genotype))
# G <- diag(length(genotypes))
# rownames(G) <- colnames(G) <- genotypes
# 
# # Simulate that "Line_B_Stable" and the "Check" share 50% of their genome
# G["Line_B_Stable", "Check"] <- 0.50
# G["Check", "Line_B_Stable"] <- 0.50
# diag(G) <- diag(G) + 0.001 # Ensure matrix is perfectly positive definite
# 
# # C. Calculate using all methods
# cat("\n--- 1. Empirical Means ---\n")
# print(calc_prob_superiority(sim_data, "Yield", "Genotype", "Environment", "Check", method = "mean"))
# 
# cat("\n--- 2. BLUEs (lme4) ---\n")
# print(calc_prob_superiority(sim_data, "Yield", "Genotype", "Environment", "Check", method = "BLUE"))
# 
# cat("\n--- 3. Base BLUPs (lme4, no G matrix) ---\n")
# print(calc_prob_superiority(sim_data, "Yield", "Genotype", "Environment", "Check", method = "BLUP"))
# 
# cat("\n--- 4. GBLUPs (sommer, with G matrix) ---\n")
# print(calc_prob_superiority(sim_data, "Yield", "Genotype", "Environment", "Check", method = "GBLUP", G_matrix = G))