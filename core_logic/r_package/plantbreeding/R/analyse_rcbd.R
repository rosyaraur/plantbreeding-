# ==============================================================================
# COMPREHENSIVE RCBD ANALYSIS SCRIPT 
# Includes: ANOVA, Tukey HSD, Dunnett's Test, Permutation Power, and Plotting
# ==============================================================================

# Install missing packages if necessary
# install.packages(c("ggplot2", "agricolae", "multcomp", "lmPerm", "dplyr"))

library(ggplot2)
library(agricolae)
library(multcomp)
library(lmPerm)
library(dplyr)

#' Analyze Complete Randomized Block Design (RCBD)
#'
#' @param df Dataframe containing the experimental data
#' @param treatment_col Name of the treatment column (string)
#' @param block_col Name of the block/replication column (string)
#' @param response_col Name of the response variable column (string)
#' @param control_val The specific value in treatment_col representing the control
#' @param n_power_sims Number of Monte Carlo simulations for permutation power
#' @param alpha Significance level for testing
analyze_rcbd <- function(df, treatment_col, block_col, response_col, control_val = NULL, 
                         n_power_sims = 100, alpha = 0.05) {
  
  # Ensure strict factor conversion
  df[[treatment_col]] <- as.factor(df[[treatment_col]])
  df[[block_col]] <- as.factor(df[[block_col]])
  
  formula_str <- paste(response_col, "~", block_col, "+", treatment_col)
  
  cat("====================================================\n")
  cat("1. ANOVA TABLE (Hypothesis Testing)\n")
  cat("====================================================\n")
  model <- aov(as.formula(formula_str), data = df)
  print(summary(model))
  
  cat("\n====================================================\n")
  cat("2. PAIRWISE COMPARISONS (Tukey HSD via Agricolae)\n")
  cat("====================================================\n")
  tukey_res <- HSD.test(model, treatment_col, group = TRUE)
  print(tukey_res$groups)
  
  if (!is.null(control_val)) {
    cat("\n====================================================\n")
    cat("3. TREATMENT VS. CONTROL (Dunnett's Test)\n")
    cat("====================================================\n")
    # Relevel to make the control the baseline
    df[[treatment_col]] <- relevel(df[[treatment_col]], ref = as.character(control_val))
    model_dunnett <- aov(as.formula(formula_str), data = df)
    
    # Safely pass the dynamic column name to the multiple comparison function
    mcp_args <- setNames(list("Dunnett"), treatment_col)
    dunnett_test <- glht(model_dunnett, linfct = do.call(mcp, mcp_args))
    print(summary(dunnett_test))
  }
  
  cat("\n====================================================\n")
  cat("4. PERMUTATION POWER ANALYSIS\n")
  cat("====================================================\n")
  cat(sprintf("Simulating %d datasets...\n", n_power_sims))
  
  fitted_vals <- fitted(model)
  obs_residuals <- residuals(model)
  significant_count <- 0
  
  # Monte Carlo Simulation Loop
  for (i in 1:n_power_sims) {
    sim_data <- df
    sim_data[[response_col]] <- fitted_vals + sample(obs_residuals, replace = TRUE)
    
    capture.output({
      # Run permutation on simulated data
      sim_perm_model <- lmp(as.formula(formula_str), data = sim_data, perm = "Prob", seqs = FALSE)
      coef_table <- summary(sim_perm_model)$coefficients
      
      # Bulletproof extraction using grep to ignore hidden formatting spaces
      row_idx <- grep(treatment_col, rownames(coef_table))
      col_idx <- grep("Pr\\(Prob\\)", colnames(coef_table))
      
      if (length(row_idx) > 0 && length(col_idx) > 0) {
        p_val <- coef_table[row_idx[1], col_idx[1]]
      } else {
        p_val <- NA # Failsafe
      }
    })
    
    # Strict validation before boolean comparison
    if (is.numeric(p_val) && length(p_val) == 1 && !is.na(p_val) && p_val < alpha) {
      significant_count <- significant_count + 1
    }
  }
  
  perm_power <- (significant_count / n_power_sims) * 100
  cat(sprintf("Estimated Permutation Power: %.2f%%\n", perm_power))
  
  cat("\n====================================================\n")
  cat("5. GENERATING PLOT...\n")
  cat("====================================================\n")
  
  # Prepare plotting dataframe
  plot_data <- data.frame(
    Treatment = rownames(tukey_res$groups),
    Mean = tukey_res$groups[[response_col]],
    Groups = trimws(tukey_res$groups$groups)
  )
  
  # Calculate Standard Errors
  se_data <- df %>%
    group_by(!!sym(treatment_col)) %>%
    summarize(SE = sd(!!sym(response_col)) / sqrt(n()), .groups = 'drop')
  
  plot_data <- merge(plot_data, se_data, by.x = "Treatment", by.y = treatment_col)
  
  # Ensure treatments plot in logical (original) order rather than alphabetical
  plot_data$Treatment <- factor(plot_data$Treatment, levels = unique(as.character(df[[treatment_col]])))
  
  p <- ggplot(plot_data, aes(x = Treatment, y = Mean, fill = Treatment)) +
    geom_bar(stat = "identity", color = "black", width = 0.7) +
    geom_errorbar(aes(ymin = Mean - SE, ymax = Mean + SE), width = 0.2) +
    geom_text(aes(label = Groups, y = Mean + SE + (max(Mean)*0.05)), size = 5, fontface = "bold") +
    labs(
      title = "Treatment Means with 1 Standard Error",
      subtitle = "Means sharing a letter are not significantly different (Tukey HSD)",
      x = "Treatment",
      y = "Response Mean"
    ) +
    theme_minimal() +
    theme(
      legend.position = "none",
      plot.title = element_text(face = "bold", size = 14),
      axis.title = element_text(face = "bold")
    )
  
  print(p)
  
  return(invisible(list(model = model, tukey = tukey_res, power = perm_power)))
}

# ==============================================================================
# EXECUTION WITH YOUR DATA
# ==============================================================================

rice_data <- data.frame(
  Treatment = rep(c(25, 50, 75, 100, 125, 150), each = 4),
  Rep = rep(c("I", "II", "III", "IV"), times = 6),
  Yield = c(
    3113, 3398, 3307, 3678,  
    5346, 5952, 4719, 4264,  
    5272, 5713, 5483, 4749,  
    5164, 4831, 4986, 4410,  
    4804, 4848, 4432, 4748,  
    6254, 6542, 6919, 6098   
  )
)

results <- analyze_rcbd(
  df = rice_data, 
  treatment_col = "Treatment", 
  block_col = "Rep", 
  response_col = "Yield", 
  control_val = "25"
)