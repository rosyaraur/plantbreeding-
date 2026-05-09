# Load required libraries
library(agricolae)
library(emmeans)

#' Universal ANOVA Function (CRD, RCBD, & Factorial Designs)
#'
#' @param data Data frame containing the dataset.
#' @param response String. Name of the response variable column.
#' @param block String. Name of the block column (Optional; leave NULL for CRD).
#' @param treatments Vector of strings. Name(s) of the treatment factors 
#'                   (e.g., c("Trt") for 1-way, c("FactorA", "FactorB") for 2-way).
#' @param contrast_matrix Optional matrix for custom contrasts (applied to the first factor).
#' @param poly_split Optional list for polynomial splitting (applied to the first factor).
#' @param post_hoc String. Post-hoc test: "none", "LSD", "Tukey", or "Duncan".
#' @param alpha Numeric. Significance level.
#' @return A list containing the model, ANOVA table, contrasts, and post-hoc results.

analyze_factorial_anova <- function(data, response, block = NULL, treatments, 
                          contrast_matrix = NULL, 
                          poly_split = NULL,
                          post_hoc = c("none", "LSD", "Tukey", "Duncan"),
                          alpha = 0.05) {
  
  post_hoc <- match.arg(post_hoc)
  
  # 1. Ensure design variables are factors
  if (!is.null(block)) {
    data[[block]] <- as.factor(data[[block]])
  }
  for (trt in treatments) {
    data[[trt]] <- as.factor(data[[trt]])
  }
  
  # 2. Apply contrasts/polynomials (defaults to the primary factor in treatments[1])
  if (!is.null(poly_split) && !is.null(contrast_matrix)) {
    trt_main <- treatments[1]
    contrasts(data[[trt_main]]) <- contrast_matrix
  }
  
  # 3. Build the formula dynamically (handles 1, 2, 3+ factors and optional blocking)
  trt_term <- paste(treatments, collapse = " * ")
  if (!is.null(block)) {
    formula_str <- paste(response, "~", block, "+", trt_term)
  } else {
    formula_str <- paste(response, "~", trt_term)
  }
  
  # 4. Fit the ANOVA model
  model <- aov(as.formula(formula_str), data = data)
  
  cat("====================================================\n")
  cat(sprintf("   ANOVA TABLE (%s Factor %s)   \n", 
              length(treatments), 
              ifelse(is.null(block), "CRD", "RCBD")))
  cat("====================================================\n")
  
  # Print Summary with or without polynomial split
  if (!is.null(poly_split)) {
    split_args <- list()
    split_args[[treatments[1]]] <- poly_split
    anova_res <- summary(model, split = split_args)
    print(anova_res)
  } else {
    anova_res <- summary(model)
    print(anova_res)
  }
  cat("\n")
  
  results <- list(model = model, anova = anova_res)
  
  # 5. Emmeans Contrasts
  if (!is.null(contrast_matrix) && is.null(poly_split)) {
    cat("====================================================\n")
    cat("               ORTHOGONAL CONTRASTS                 \n")
    cat("====================================================\n")
    # For factorials, emmeans calculates marginal means across the full grid
    emm <- emmeans(model, specs = treatments)
    contrast_res <- contrast(emm, method = list(Custom = contrast_matrix))
    print(contrast_res)
    cat("\n")
    results$contrasts <- contrast_res
  }
  
  # 6. Post-Hoc Means Comparisons (using agricolae)
  if (post_hoc != "none") {
    cat("====================================================\n")
    cat(sprintf("       POST-HOC TEST: %s (alpha = %s)      \n", post_hoc, alpha))
    cat("====================================================\n")
    
    # In factorials, evaluate the highest order interaction for groupings
    if (post_hoc == "LSD") {
      out_test <- LSD.test(model, treatments, alpha = alpha, console = TRUE)
    } else if (post_hoc == "Tukey") {
      out_test <- HSD.test(model, treatments, alpha = alpha, console = TRUE)
    } else if (post_hoc == "Duncan") {
      out_test <- duncan.test(model, treatments, alpha = alpha, console = TRUE)
    }
    results$post_hoc <- out_test
  }
  
  return(invisible(results))
}

# # Greenhouse Stand (Single-Factor RCBD with Categorical Contrasts)
# # 1. Load the Greenhouse Data (Table 11.10)
# df_stand <- data.frame(
#   Block = rep(1:6, each = 8),
#   Treatment = rep(c("A", "B", "C", "D", "E", "F", "G", "H"), times = 6),
#   Stand = c(8, 16, 14, 10, 8, 8, 7, 12,  
#             8, 19, 16, 11, 7, 8, 6, 19,  
#             9, 24, 14, 12, 1, 3, 6, 9,   
#             7, 22, 13, 8,  1, 3, 6, 11,  
#             7, 19, 14, 7,  3, 3, 4, 9,   
#             5, 19, 13, 3,  2, 7, 4, 5)   
# )
# 
# # 2. Define the Orthogonal Contrasts (Table 11.11)
# contrasts_stand <- list(
#   "1: A vs rest"      = c(-7,  1,  1,  1,  1,  1,  1,  1),
#   "2: BC vs DEFGH"    = c( 0,  5,  5, -2, -2, -2, -2, -2),
#   "3: B vs C"         = c( 0,  1, -1,  0,  0,  0,  0,  0),
#   "4: DH vs EFG"      = c( 0,  0,  0,  3, -2, -2, -2,  3),
#   "5: D vs H"         = c( 0,  0,  0,  1,  0,  0,  0, -1),
#   "6: E vs FG"        = c( 0,  0,  0,  0,  2, -1, -1,  0),
#   "7: F vs G"         = c( 0,  0,  0,  0,  0,  1, -1,  0)
# )
# 
# # 3. Run the Universal Function
# # Notice we supply the block argument and a single treatment
# res_stand <- analyze_factorial_anova (
#   data = df_stand, 
#   response = "Stand", 
#   block = "Block", 
#   treatments = c("Treatment"), 
#   contrast_matrix = contrasts_stand, 
#   post_hoc = "LSD"
# )
# 
# # Soybean Yield (Single-Factor RCBD with Polynomial Splitting)
# # 1. Load the Soybean Yield Data (Table 11.14)
# df_yield <- data.frame(
#   Block = rep(1:6, each = 5),
#   Spacing = rep(c(18, 24, 30, 36, 42), times = 6),
#   Yield = c(33.6, 31.1, 33.0, 28.4, 31.4, 
#             37.1, 34.5, 29.5, 29.9, 28.3,
#             34.1, 30.5, 29.2, 31.6, 28.9, 
#             34.6, 32.7, 30.7, 32.3, 28.6,
#             35.4, 30.7, 30.7, 28.1, 29.6, 
#             36.1, 30.3, 27.9, 26.9, 33.4)
# )
# 
# # 2. Define the Polynomial Contrast Matrix (Columns = Degrees)
# poly_matrix <- cbind(
#   Linear    = c(-2, -1,  0,  1,  2),
#   Quadratic = c( 2, -1, -2, -1,  2),
#   Cubic     = c(-1,  2,  0, -2,  1),
#   Quartic   = c( 1, -4,  6, -4,  1)
# )
# 
# # 3. Map the matrix columns to the ANOVA split output
# split_list <- list(
#   Linear = 1, 
#   Quadratic = 2, 
#   Cubic = 3, 
#   Quartic = 4
# )

# 4. Run the Universal Function
# The function automatically routes the contrast matrix into the ANOVA summary
# res_yield <- analyze_factorial_anova(
#   data = df_yield, 
#   response = "Yield", 
#   block = "Block", 
#   treatments = c("Spacing"), 
#   contrast_matrix = poly_matrix, 
#   poly_split = split_list,
#   post_hoc = "none"
# )
# 
# # Table 11.2: Two-Factor CRD (Lambs)
# # Build Table 11.2 (2x2 Factorial, 5 replicates)
# df_lambs <- data.frame(
#   Time = rep(c("AM", "PM"), each = 10),
#   Estrogen = rep(rep(c("Control", "Treated"), each = 5), times = 2),
#   Phospholipid = c(
#     8.53, 20.53, 12.53, 14.00, 10.80,   # AM, Control
#     17.53, 21.07, 20.80, 17.33, 20.07,  # AM, Treated
#     39.14, 26.20, 31.33, 45.80, 40.20,  # PM, Control
#     32.00, 23.80, 28.87, 25.06, 29.33   # PM, Treated
#   )
# )
# 
# # Usage Example:
# analyze_factorial_anova(data = df_lambs, response = "Phospholipid", 
#                block = NULL, treatments = c("Time", "Estrogen"), 
#                post_hoc = "Tukey")
#  
#  #Three-Factor CRD (Legume Seeds)
#  # 1. Define the exact totals from Table 11.4
#  totals <- c(
#    266, 276, 286, 271, 66,  215, # Alfalfa
#    252, 275, 289, 292, 167, 203, # Red clover
#    152, 178, 197, 219, 52,  121  # Sweet clover
#  )
#  
#  # 2. Simulate 3 replicates that sum exactly to the totals
#  set.seed(123)
#  reps <- as.vector(sapply(totals, function(tot) {
#    base <- floor(tot / 3)
#    rem <- tot %% 3
#    val <- c(base, base, base)
#    if (rem > 0) val[1:rem] <- val[1:rem] + 1
#    return(val)
#  }))
#  
#  # 3. Build the 3-Factor dataset
#  df_seeds <- data.frame(
#    Species = rep(c("Alfalfa", "Red clover", "Sweet clover"), each = 18),
#    Soil = rep(rep(c("Silt loam", "Sand", "Clay"), each = 6), times = 3),
#    Fungicide = rep(rep(c("None", "Treated"), each = 3), times = 9),
#    Emerged = reps
#  )
#  
#  # Usage Example:
#  analyze_factorial_anova(data = df_seeds, response = "Emerged", 
#                block = NULL, treatments = c("Species", "Soil", "Fungicide"), 
#              post_hoc = "LSD")
#  
 