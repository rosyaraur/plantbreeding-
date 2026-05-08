# Load required libraries
library(agricolae)
library(emmeans)

#' Perform Randomized Complete Block Design (RCBD) Analysis
#'
#' @description
#' A flexible wrapper function to conduct an Analysis of Variance (ANOVA) for a 
#' Randomized Complete Block Design (RCBD). It natively handles single or multi-factor 
#' designs, custom orthogonal contrasts, orthogonal polynomial sum-of-squares 
#' partitioning, and standard post-hoc mean comparisons (LSD, Tukey, Duncan).
#'
#' @param data A data frame containing the experimental dataset.
#' @param response A character string specifying the name of the continuous response variable column.
#' @param block A character string specifying the name of the blocking factor column.
#' @param treatments A character vector specifying the name(s) of the treatment factor column(s). 
#'   Use a single string for one-factor RCBD (e.g., \code{c("Treatment")}) or multiple strings 
#'   for factorial RCBDs (e.g., \code{c("FactorA", "FactorB")}).
#' @param contrast_matrix An optional numeric matrix or list defining custom orthogonal 
#'   contrasts for the treatment levels.
#' @param poly_split An optional named list defining the degrees of freedom partition 
#'   for orthogonal polynomials. Used in conjunction with \code{contrast_matrix} to split 
#'   the treatment sum of squares in the ANOVA table 
#'   (e.g., \code{list(Linear = 1, Quadratic = 2, Cubic = 3)}).
#' @param post_hoc A character string indicating the desired post-hoc multiple comparisons test. 
#'   Options are \code{"none"} (default), \code{"LSD"}, \code{"Tukey"}, or \code{"Duncan"}.
#' @param alpha A numeric value specifying the significance level for the post-hoc tests. 
#'   Default is \code{0.05}.
#'
#' @return A named list containing the following components:
#' \describe{
#'   \item{model}{The fitted \code{aov} model object.}
#'   \item{anova}{The summary table of the ANOVA, potentially with partitioned treatment components.}
#'   \item{contrasts}{An \code{emm_list} object containing the evaluated orthogonal contrasts (if applicable).}
#'   \item{post_hoc}{The post-hoc test results object from the \code{agricolae} package (if requested).}
#' }
#' 
#' @importFrom stats aov as.formula contrasts<- summary
#' @importFrom agricolae LSD.test HSD.test duncan.test
#' @importFrom emmeans emmeans contrast
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Standard RCBD with LSD test
#' results <- analyze_rcbd(
#'   data = my_data,
#'   response = "Yield",
#'   block = "Block",
#'   treatments = c("Variety"),
#'   post_hoc = "LSD"
#' )
#' 
#' # RCBD with Orthogonal Polynomials (e.g., spacing trends)
#' poly_matrix <- cbind(Linear = c(-2, -1, 0, 1, 2), Quadratic = c(2, -1, -2, -1, 2))
#' results_poly <- analyze_rcbd(
#'   data = spacing_data,
#'   response = "Yield",
#'   block = "Block",
#'   treatments = c("Spacing"),
#'   contrast_matrix = poly_matrix,
#'   poly_split = list(Linear = 1, Quadratic = 2)
#' )
#' }
analyze_rcbd_contrast <- function(data, response, block, treatments, 
                         contrast_matrix = NULL, 
                         poly_split = NULL,
                         post_hoc = c("none", "LSD", "Tukey", "Duncan"),
                         alpha = 0.05) {
  
  post_hoc <- match.arg(post_hoc)
  
  # 1. Ensure design variables are treated as factors
  data[[block]] <- as.factor(data[[block]])
  for (trt in treatments) {
    data[[trt]] <- as.factor(data[[trt]])
  }
  
  # 2. Apply custom contrasts directly to the factor if doing polynomial splitting
  if (!is.null(poly_split) && !is.null(contrast_matrix)) {
    trt_main <- treatments[1]
    contrasts(data[[trt_main]]) <- contrast_matrix
  }
  
  # 3. Build the formula dynamically
  trt_term <- paste(treatments, collapse = " * ")
  formula_str <- paste(response, "~", block, "+", trt_term)
  
  # 4. Fit the ANOVA model
  model <- aov(as.formula(formula_str), data = data)
  
  cat("====================================================\n")
  cat("                    ANOVA TABLE                     \n")
  cat("====================================================\n")
  
  # 5. Print Summary (with or without polynomial splitting)
  if (!is.null(poly_split)) {
    # Dynamically build the split list for the specific treatment
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
  
  # 6. Emmeans Contrasts (Only if NO poly_split is provided, to avoid redundancy)
  if (!is.null(contrast_matrix) && is.null(poly_split)) {
    cat("====================================================\n")
    cat("               ORTHOGONAL CONTRASTS                 \n")
    cat("====================================================\n")
    
    emm_term <- if(length(treatments) == 1) treatments[1] else treatments
    emm <- emmeans(model, specs = emm_term)
    contrast_res <- contrast(emm, method = list(Custom = contrast_matrix))
    
    print(contrast_res)
    cat("\n")
    results$contrasts <- contrast_res
  }
  
  # 7. Post-Hoc Means Comparisons (using agricolae)
  if (post_hoc != "none") {
    cat("====================================================\n")
    cat(sprintf("          POST-HOC TEST: %s (alpha = %s)      \n", post_hoc, alpha))
    cat("====================================================\n")
    
    trt_for_test <- if(length(treatments) > 1) treatments else treatments[1]
    
    if (post_hoc == "LSD") {
      out_test <- LSD.test(model, trt_for_test, alpha = alpha, console = TRUE)
    } else if (post_hoc == "Tukey") {
      out_test <- HSD.test(model, trt_for_test, alpha = alpha, console = TRUE)
    } else if (post_hoc == "Duncan") {
      out_test <- duncan.test(model, trt_for_test, alpha = alpha, console = TRUE)
    }
    
    results$post_hoc <- out_test
  }
  
  return(invisible(results))
}
# Example Usage for Table 11.14 (Polynomial Partitioning)
# 1. Create the dataset (Table 11.14)
yield_data <- data.frame(
  Block = rep(1:6, each = 5),
  Spacing = rep(c(18, 24, 30, 36, 42), times = 6),
  Yield = c(
    33.6, 31.1, 33.0, 28.4, 31.4,
    37.1, 34.5, 29.5, 29.9, 28.3,
    34.1, 30.5, 29.2, 31.6, 28.9,
    34.6, 32.7, 30.7, 32.3, 28.6,
    35.4, 30.7, 30.7, 28.1, 29.6,  # Note: 29.6 is the estimated missing plot
    36.1, 30.3, 27.9, 26.9, 33.4
  )
)

# 2. Define the exact polynomial contrast matrix (columns = degrees)
poly_matrix <- cbind(
  Linear    = c(-2, -1,  0,  1,  2),
  Quadratic = c( 2, -1, -2, -1,  2),
  Cubic     = c(-1,  2,  0, -2,  1),
  Quartic   = c( 1, -4,  6, -4,  1)
)

# 3. Run the updated function
analysis_results <- analyze_rcbd_contrast(
  data = yield_data,
  response = "Yield",
  block = "Block",
  treatments = c("Spacing"),
  contrast_matrix = poly_matrix,         # Pass the matrix here
  poly_split = list(                     # Map matrix columns to the split output
    Linear = 1, 
    Quadratic = 2, 
    Cubic = 3, 
    Quartic = 4
  ),
  post_hoc = "none" # Skipping LSD since we are looking at continuous trends
)

# 1. Create a sample dataset based on Table 11.10 (Greenhouse Stand)
# (Showing just the first few blocks for brevity, but the function handles the whole dataset)
df <- data.frame(
  Block = rep(1:6, each = 8),
  Treatment = rep(c("A", "B", "C", "D", "E", "F", "G", "H"), times = 6),
  Stand = c(8, 16, 14, 10, 8, 8, 7, 12,  # Block 1
            8, 19, 16, 11, 7, 8, 6, 19,  # Block 2
            9, 24, 14, 12, 1, 3, 6, 9,   # Block 3
            7, 22, 13, 8,  1, 3, 6, 11,  # Block 4
            7, 19, 14, 7,  3, 3, 4, 9,   # Block 5
            5, 19, 13, 3,  2, 7, 4, 5)   # Block 6
)

# 2. Define the Orthogonal Contrasts based on Table 11.11
# Ensure the order matches the alphabetical levels of the Treatment factor (A, B, C, D, E, F, G, H)
my_contrasts <- list(
  "1: A vs rest"      = c(-7,  1,  1,  1,  1,  1,  1,  1),
  "2: BC vs DEFGH"    = c( 0,  5,  5, -2, -2, -2, -2, -2),
  "3: B vs C"         = c( 0,  1, -1,  0,  0,  0,  0,  0),
  "4: DH vs EFG"      = c( 0,  0,  0,  3, -2, -2, -2,  3),
  "5: D vs H"         = c( 0,  0,  0,  1,  0,  0,  0, -1),
  "6: E vs FG"        = c( 0,  0,  0,  0,  2, -1, -1,  0),
  "7: F vs G"         = c( 0,  0,  0,  0,  0,  1, -1,  0)
)

# 3. Run the function
# We will ask for the contrasts defined above, plus an LSD test.
analysis_results <- analyze_rcbd_contrast(
  data = df,
  response = "Stand",
  block = "Block",
  treatments = c("Treatment"), # Single factor here. For two-factor, use c("Factor1", "Factor2")
  contrast_matrix = my_contrasts,
  post_hoc = "LSD"
)