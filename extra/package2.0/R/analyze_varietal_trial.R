#install.packages(c("lme4", "lmerTest", "emmeans", "dplyr"))
library(lme4)
library(lmerTest)
library(emmeans)
library(dplyr)
library(ggplot2)
library(dplyr)

library(lme4)
library(lmerTest)
library(emmeans)
library(dplyr)

#' Mixed Model Analysis for Single-Factor Varietal Trials
#'
#' @description 
#' Fits a mixed model to agricultural varietal trial data for RCBD, Alpha-Lattice, 
#' or P-rep (Row-Column) designs. It computes either Best Linear Unbiased Estimators (BLUEs, as LSMeans) 
#' or Best Linear Unbiased Predictors (BLUPs), calculates standard errors and confidence intervals, 
#' and provides robust options for handling missing plot data.
#'
#' @param data A `data.frame` containing the trial data.
#' @param design A character string specifying the experimental design. Must be one of `"RCBD"`, `"Lattice"`, or `"Prep"`.
#' @param model_type A character string specifying the estimation method. `"BLUE"` treats genotypes as fixed effects to extract LSMeans. `"BLUP"` treats genotypes as random effects (shrinking towards the mean).
#' @param handle_missing A character string specifying how to treat missing `y_var` values. `"drop"` completely removes rows with NA responses. `"predict"` fits the model on observed data and uses the variance components to impute missing values.
#' @param y_var A character string specifying the column name of the response variable (e.g., yield, height).
#' @param genotype_var A character string specifying the column name of the genotypes or varieties.
#' @param rep_var A character string specifying the column name for replicates. Required for `"RCBD"` and `"Lattice"` designs.
#' @param block_var A character string specifying the column name for incomplete blocks. Required for `"Lattice"` designs.
#' @param row_var A character string specifying the column name for rows. Required for `"Prep"` spatial designs.
#' @param col_var A character string specifying the column name for columns/ranges. Required for `"Prep"` spatial designs.
#' @param is_check_var An optional character string specifying the column name that flags check varieties. If provided during a `"BLUP"` analysis, checks are modeled as fixed effects while test lines remain random.
#' @param plot_id_var An optional character string specifying the column name for unique plot IDs.
#' @param alpha A numeric value for the significance level used to calculate confidence intervals. Default is 0.05.
#'
#' @return A list containing:
#' \itemize{
#'   \item \code{model}: The fitted `lmer` model object.
#'   \item \code{variance_components}: A data frame of the extracted variance components.
#'   \item \code{estimates}: A data frame containing the Genotype, Mean (BLUE or BLUP), Standard Error, and Confidence Intervals.
#'   \item \code{comparisons}: A data frame of pairwise comparisons (Tukey adjusted). Only returned if `model_type = "BLUE"`.
#'   \item \code{imputed_data}: A data frame of the original data with missing values filled. Only returned if `handle_missing = "predict"`.
#' }
#' 
#' @importFrom lme4 lmer VarCorr ranef fixef
#' @importFrom lmerTest lmer
#' @importFrom emmeans emmeans
#' @importFrom stats as.formula na.exclude predict qnorm
#' 
#' @export
#'
#' @examples
#' \dontrun{
#' # Example: Analyzing an RCBD trial to extract BLUEs
#' results <- analyze_varietal_trial(
#'   data = my_trial_data,
#'   design = "RCBD",
#'   model_type = "BLUE",
#'   handle_missing = "drop",
#'   y_var = "Yield_kg_ha",
#'   genotype_var = "Variety",
#'   rep_var = "Replicate"
#' )
#' 
#' # View estimates
#' head(results$estimates)
#' }
analyze_varietal_trial <- function(data, 
                                   design = c("RCBD", "Lattice", "Prep"), 
                                   model_type = c("BLUE", "BLUP"), 
                                   handle_missing = c("drop", "predict"),
                                   y_var, 
                                   genotype_var, 
                                   rep_var = NULL, 
                                   block_var = NULL, 
                                   row_var = NULL, 
                                   col_var = NULL, 
                                   is_check_var = NULL, 
                                   plot_id_var = NULL,
                                   alpha = 0.05) {
  
  # 1. Match arguments and validate inputs
  design <- match.arg(design)
  model_type <- match.arg(model_type)
  handle_missing <- match.arg(handle_missing)
  
  if(!y_var %in% colnames(data)) stop(paste("Response variable", y_var, "not found in data."))
  if(!genotype_var %in% colnames(data)) stop(paste("Genotype variable", genotype_var, "not found in data."))
  
  # Convert variables to factors
  data[[genotype_var]] <- as.factor(data[[genotype_var]])
  if(!is.null(rep_var)) data[[rep_var]] <- as.factor(data[[rep_var]])
  if(!is.null(block_var)) data[[block_var]] <- as.factor(data[[block_var]])
  if(!is.null(row_var)) data[[row_var]] <- as.factor(data[[row_var]])
  if(!is.null(col_var)) data[[col_var]] <- as.factor(data[[col_var]])
  if(!is.null(is_check_var)) data[[is_check_var]] <- as.factor(data[[is_check_var]])
  
  # Handle missing data strategy
  if (handle_missing == "drop") {
    message("Dropping rows with missing values in the response variable...")
    data <- data[!is.na(data[[y_var]]), ]
  }
  
  # 2. Construct Formula dynamically
  fixed_eff <- c("1") # Intercept
  random_eff <- c()
  
  if (model_type == "BLUE") {
    fixed_eff <- c(fixed_eff, genotype_var)
  } else if (model_type == "BLUP") {
    random_eff <- c(random_eff, paste0("(1|", genotype_var, ")"))
  }
  
  if (!is.null(is_check_var) && model_type == "BLUP") {
    fixed_eff <- c(fixed_eff, is_check_var)
  }
  
  if (design == "RCBD") {
    if(is.null(rep_var)) stop("rep_var must be provided for RCBD.")
    random_eff <- c(random_eff, paste0("(1|", rep_var, ")"))
    
  } else if (design == "Lattice") {
    if(is.null(rep_var) || is.null(block_var)) stop("rep_var and block_var required for Lattice.")
    random_eff <- c(random_eff, paste0("(1|", rep_var, ")"), paste0("(1|", rep_var, ":", block_var, ")"))
    
  } else if (design == "Prep") {
    if(is.null(row_var) || is.null(col_var)) stop("row_var and col_var required for P-rep (Row-Col).")
    random_eff <- c(random_eff, paste0("(1|", row_var, ")"), paste0("(1|", col_var, ")"))
  }
  
  formula_str <- paste(y_var, "~", paste(fixed_eff, collapse = " + "))
  if (length(random_eff) > 0) {
    formula_str <- paste(formula_str, "+", paste(random_eff, collapse = " + "))
  }
  
  message("Fitting model: ", formula_str)
  
  # 3. Fit the model
  mod <- tryCatch({
    lmer(as.formula(formula_str), data = data, na.action = na.exclude)
  }, error = function(e) {
    stop("Error fitting model: ", e$message)
  })
  
  # 4. Extract Core Results
  results <- list()
  results$model <- mod
  var_comp <- as.data.frame(VarCorr(mod))
  results$variance_components <- var_comp
  
  # Predict Missing Values
  if (handle_missing == "predict") {
    imputed_data <- data
    predicted_vals <- predict(mod, newdata = data, allow.new.levels = TRUE)
    imputed_data$Model_Predicted_Value <- predicted_vals
    imputed_data$Is_Imputed <- is.na(imputed_data[[y_var]])
    imputed_data[[y_var]] <- ifelse(is.na(imputed_data[[y_var]]), predicted_vals, imputed_data[[y_var]])
    results$imputed_data <- imputed_data
  }
  
  # 5. Extract Estimates
  if (model_type == "BLUE") {
    em <- emmeans(mod, specs = genotype_var, lmer.df = "satterthwaite")
    results$estimates <- as.data.frame(em)
    results$comparisons <- as.data.frame(pairs(em))
    
  } else if (model_type == "BLUP") {
    ranef_obj <- ranef(mod, condVar = TRUE)
    geno_blups <- ranef_obj[[genotype_var]]
    se_blups <- sqrt(attr(geno_blups, "postVar")[1, 1, ])
    grand_mean_intercept <- fixef(mod)["(Intercept)"]
    
    results$estimates <- data.frame(
      Genotype = rownames(geno_blups),
      BLUP = geno_blups[[1]],
      Adjusted_Mean = geno_blups[[1]] + grand_mean_intercept,
      SE = se_blups
    )
    
    z_val <- qnorm(1 - alpha/2)
    results$estimates$Lower_CI <- results$estimates$Adjusted_Mean - (z_val * results$estimates$SE)
    results$estimates$Upper_CI <- results$estimates$Adjusted_Mean + (z_val * results$estimates$SE)
    colnames(results$estimates)[1] <- genotype_var
  }
  
  # ---------------------------------------------------------
  # NEW: 6. Trial Summary Statistics (Mean, CV, Heritability)
  # ---------------------------------------------------------
  
  # Overall Grand Mean of the observed trait
  grand_mean_val <- mean(data[[y_var]], na.rm = TRUE)
  
  # Residual Error Variance
  resid_var <- var_comp$vcov[var_comp$grp == "Residual"]
  
  # Coefficient of Variation (CV) %
  cv_percent <- (sqrt(resid_var) / grand_mean_val) * 100
  
  # Broad-Sense Heritability
  h2 <- NA 
  
  if (model_type == "BLUP") {
    geno_var <- var_comp$vcov[var_comp$grp == genotype_var]
    
    # Check if genotypic variance was successfully estimated > 0
    if (length(geno_var) > 0 && geno_var > 1e-6) {
      # Generalized Heritability based on Prediction Error Variance (PEV)
      # PEV is the square of the Standard Error of the BLUPs
      mean_pev <- mean(results$estimates$SE^2, na.rm = TRUE)
      
      # H^2 = 1 - (mean(PEV) / Sigma2_G)
      h2 <- 1 - (mean_pev / geno_var)
      h2 <- max(0, h2) # Safeguard against negative heritability due to rounding
      
    } else {
      # If genotypic variance is essentially 0, heritability is 0
      h2 <- 0 
    }
  }
  
  # Save metrics to the results list
  results$trial_stats <- data.frame(
    Trait = y_var,
    Grand_Mean = grand_mean_val,
    CV_Percent = cv_percent,
    Heritability = h2
  )
  
  return(results)
}

library(ggplot2)
library(dplyr)

#' Plot Genotype Means from Varietal Trial Results
#'
#' @description 
#' Generates a publication-ready `ggplot2` visualization of genotype means and their 95% confidence intervals. 
#' It automatically detects whether the provided results contain BLUEs (LSMeans) or BLUPs (Adjusted Means) 
#' and updates the plot subtitle accordingly.
#'
#' @param results A list object returned by the `analyze_varietal_trial()` function. Must contain an `estimates` data frame.
#' @param plot_type A character string specifying the type of plot. Options are `"point"` (a dot plot with horizontal error bars, ideal for many genotypes) or `"bar"` (a standard bar chart with error bars). Default is `"point"`.
#' @param sort_by_mean A logical value. If `TRUE` (default), genotypes are ordered from highest to lowest mean. If `FALSE`, they are plotted in their original factor order (usually alphabetical).
#' @param title A character string for the main plot title. Default is `"Genotype Means with 95% CI"`.
#' @param x_label A character string for the trait axis label. Default is `"Trait Value"`. Note: Because the plot uses `coord_flip()`, this will visually appear on the horizontal axis.
#' @param y_label A character string for the genotype axis label. Default is `"Genotype"`. Visually appears on the vertical axis.
#'
#' @return A `ggplot` object representing the varietal means and their confidence intervals.
#' 
#' @import ggplot2
#' @importFrom stats reorder
#' 
#' @export
#'
#' @examples
#' \dontrun{
#' # Assuming 'rcbd_results' is the output from analyze_varietal_trial()
#' 
#' # Generate a point plot sorted by yield
#' p1 <- plot_varietal_means(
#'   results = rcbd_results, 
#'   plot_type = "point", 
#'   title = "RCBD Yield Performance", 
#'   x_label = "Yield (kg/ha)"
#' )
#' print(p1)
#' 
#' # Generate an alphabetical bar plot
#' p2 <- plot_varietal_means(
#'   results = rcbd_results, 
#'   plot_type = "bar",
#'   sort_by_mean = FALSE, 
#'   title = "RCBD Yield Performance", 
#'   x_label = "Yield (kg/ha)"
#' )
#' print(p2)
#' }
plot_varietal_means <- function(results, 
                                plot_type = c("point", "bar"),
                                sort_by_mean = TRUE, 
                                title = "Genotype Means with 95% CI",
                                x_label = "Trait Value",
                                y_label = "Genotype") {
  
  plot_type <- match.arg(plot_type)
  
  # 1. Extract the estimates dataframe
  if (is.null(results$estimates)) {
    stop("No estimates found in the results object.")
  }
  
  est_df <- results$estimates
  
  # 2. Standardize column names based on whether it was a BLUE or BLUP model
  if ("emmean" %in% colnames(est_df)) {
    # It's a BLUE model (LSMeans from emmeans)
    plot_df <- data.frame(
      Genotype = as.factor(est_df[[1]]), # First column is always the genotype variable
      Mean = est_df$emmean,
      Lower = est_df$lower.CL,
      Upper = est_df$upper.CL
    )
    model_subtitle <- "Estimates: BLUEs (LSMeans)"
    
  } else if ("Adjusted_Mean" %in% colnames(est_df)) {
    # It's a BLUP model (from our custom extraction)
    plot_df <- data.frame(
      Genotype = as.factor(est_df[[1]]),
      Mean = est_df$Adjusted_Mean,
      Lower = est_df$Lower_CI,
      Upper = est_df$Upper_CI
    )
    model_subtitle <- "Estimates: BLUPs (Adjusted Means)"
    
  } else {
    stop("Unrecognized estimates format. Ensure you are passing the output of analyze_varietal_trial().")
  }
  
  # 3. Sort Genotypes by Mean
  if (sort_by_mean) {
    plot_df$Genotype <- reorder(plot_df$Genotype, plot_df$Mean)
  }
  
  # 4. Generate the Plot
  p <- ggplot(plot_df, aes(x = Genotype, y = Mean))
  
  if (plot_type == "point") {
    p <- p + 
      geom_errorbar(aes(ymin = Lower, ymax = Upper), width = 0.2, color = "gray50", linewidth = 0.8) +
      geom_point(size = 3, color = "dodgerblue4")
  } else if (plot_type == "bar") {
    p <- p + 
      geom_col(fill = "steelblue", alpha = 0.8, width = 0.7) +
      geom_errorbar(aes(ymin = Lower, ymax = Upper), width = 0.2, color = "gray30", linewidth = 0.8)
  }
  
  # Add formatting and flip coordinates for readability
  p <- p + 
    coord_flip() + 
    labs(title = title, subtitle = model_subtitle, x = y_label, y = x_label) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      axis.text.y = element_text(size = 10), # Genotype names
      axis.title = element_text(face = "bold"),
      panel.grid.major.y = element_blank(),  # Clean up horizontal lines
      panel.grid.minor.x = element_blank()
    )
  
  return(p)
}

#################################################################
#Simulated RCBD Data (20 Genotypes, 3 Replicates)
# set.seed(123) # For reproducibility
# 
# # 1. Generate RCBD Data
# n_geno_rcbd <- 20
# n_rep_rcbd <- 3
# 
# rcbd_data <- expand.grid(
#   Variety = paste0("Geno_", sprintf("%02d", 1:n_geno_rcbd)),
#   Replicate = paste0("Rep_", 1:n_rep_rcbd)
# )
# 
# # Simulate Yield: Base (5000) + Geno effect + Rep effect + Error
# rcbd_data$Yield_kg_ha <- 5000 +
#   rep(rnorm(n_geno_rcbd, mean = 0, sd = 600), times = n_rep_rcbd) +
#   rep(rnorm(n_rep_rcbd, mean = 0, sd = 200), each = n_geno_rcbd) +
#   rnorm(nrow(rcbd_data), mean = 0, sd = 150)
# 
# # Introduce a missing value to test the "drop" functionality
# rcbd_data$Yield_kg_ha[7] <- NA
# 
# # Run Analysis (BLUE)
# rcbd_results <- analyze_varietal_trial(
#   data = rcbd_data,
#   design = "RCBD",
#   model_type = "BLUE",
#   handle_missing = "drop",
#   y_var = "Yield_kg_ha",
#   genotype_var = "Variety",
#   rep_var = "Replicate"
# )
# 
# # Plot Results
# plot_varietal_means(rcbd_results, plot_type = "point",
#                     title = "RCBD Simulated Trial", x_label = "Yield (kg/ha)")
# 
# # Run Analysis (BLUP)
# rcbd_results <- analyze_varietal_trial(
#   data = rcbd_data,
#   design = "RCBD",
#   model_type = "BLUP",
#   handle_missing = "drop",
#   y_var = "Yield_kg_ha",
#   genotype_var = "Variety",
#   rep_var = "Replicate"
# )
# 
# # Plot Results
# plot_varietal_means(rcbd_results, plot_type = "point",
#                     title = "RCBD Simulated Trial", x_label = "Yield (kg/ha)")

#################################################################
# 2. Simulated Alpha-Lattice Data (24 Genotypes, 3 Reps, 6 Blocks)
# set.seed(456)
# 
# # 2. Generate Lattice Data
# n_geno_lat <- 24
# n_rep_lat <- 3
# n_blocks <- 6 # 6 blocks of 4 plots per replicate
# 
# lattice_data <- expand.grid(
#   Variety = paste0("Geno_", sprintf("%02d", 1:n_geno_lat)),
#   Replicate = paste0("Rep_", 1:n_rep_lat)
# )
# 
# # Sort and assign incomplete blocks (simplistic assignment for simulation)
# lattice_data <- lattice_data[order(lattice_data$Replicate, lattice_data$Variety), ]
# lattice_data$Incomplete_Block <- rep(paste0("Blk_", 1:n_blocks), each = 4, times = n_rep_lat)
# 
# # Simulate Plant Height: Base (100) + Geno + Rep + Block(Rep) + Error
# lattice_data$Plant_Height_cm <- 100 +
#   rep(rnorm(n_geno_lat, 0, 15), times = n_rep_lat) + 
#   rep(rnorm(n_rep_lat, 0, 5), each = n_geno_lat) +
#   rep(rnorm(n_rep_lat * n_blocks, 0, 8), each = 4) +
#   rnorm(nrow(lattice_data), 0, 3)
# 
# # Introduce missing values to test the "predict" imputation
# lattice_data$Plant_Height_cm[c(12, 45, 68)] <- NA
# 
# # Run Analysis (BLUP with missing value prediction)
# lattice_results <- analyze_varietal_trial(
#   data = lattice_data,
#   design = "Lattice",
#   model_type = "BLUP",
#   handle_missing = "predict",
#   y_var = "Plant_Height_cm",
#   genotype_var = "Variety",
#   rep_var = "Replicate",
#   block_var = "Incomplete_Block"
# )
# 
# # View the imputed data (Original NAs are now filled, marked with TRUE in Is_Imputed)
# head(lattice_results$imputed_data %>% filter(Is_Imputed == TRUE))
# 
# # Plot Results
# plot_varietal_means(lattice_results, plot_type = "point", 
#                     title = "Alpha-Lattice Plant Height (BLUPs)", x_label = "Height (cm)")

################################################################## 
# # 3. Simulated P-rep Data (Row-Column with Checks)
# set.seed(789)
# 
# # 3. Generate P-rep Data (10x10 field grid)
# prep_data <- expand.grid(
#   Row_Number = 1:10,
#   Range_Number = 1:10
# )
# 
# # 90 Test Lines + 2 Checks (5 reps each)
# varieties <- c(paste0("TestLine_", sprintf("%02d", 1:90)), 
#                rep(c("Check_A", "Check_B"), each = 5))
# 
# # Randomize varieties across the grid
# prep_data$Variety <- sample(varieties)
# 
# # Create a Check_Status column
# prep_data$Check_Status <- ifelse(grepl("Check", prep_data$Variety), "Check", "Test")
# 
# # Simulate Yield with Spatial Trends (Row and Column effects)
# prep_data$Yield_kg_ha <- 6000 +
#   ifelse(prep_data$Check_Status == "Check",
#          ifelse(prep_data$Variety == "Check_A", 800, -400), # Fixed effects for checks
#          rnorm(100, 0, 700)) + # Random effects for test lines (will overwrite check values safely below)
#   rnorm(10, 0, 250)[prep_data$Row_Number] + # Spatial Row Trend
#   rnorm(10, 0, 250)[prep_data$Range_Number] + # Spatial Column Trend
#   rnorm(100, 0, 150) # Error
# 
# # Ensure test lines get their exact random genetic effect tied to their name
# test_line_effects <- rnorm(90, 0, 700)
# names(test_line_effects) <- paste0("TestLine_", sprintf("%02d", 1:90))
# is_test <- prep_data$Check_Status == "Test"
# prep_data$Yield_kg_ha[is_test] <- 6000 + 
#   test_line_effects[prep_data$Variety[is_test]] +
#   rnorm(10, 0, 250)[prep_data$Row_Number[is_test]] +
#   rnorm(10, 0, 250)[prep_data$Range_Number[is_test]] +
#   rnorm(sum(is_test), 0, 150)
# 
# # Run Analysis (BLUP accounting for Checks as fixed)
# prep_results <- analyze_varietal_trial(
#   data = prep_data,
#   design = "Prep",
#   model_type = "BLUP",
#   handle_missing = "drop",
#   y_var = "Yield_kg_ha",
#   genotype_var = "Variety",
#   row_var = "Row_Number",
#   col_var = "Range_Number",
#   is_check_var = "Check_Status"
# )
# 
# # Plot Results (Let's use a Bar plot for variety, just to see the top 20)
# top_20_prep <- prep_results$estimates %>% 
#   arrange(desc(Adjusted_Mean)) %>% 
#   slice(1:20)
# 
# # We can hack the plotting function slightly by passing it the subsetted dataframe
# prep_results_subset <- prep_results
# prep_results_subset$estimates <- top_20_prep
# 
# plot_varietal_means(prep_results_subset, plot_type = "bar", 
#                     title = "Top 20 P-rep Yields (Checks included)", x_label = "Yield (kg/ha)")
