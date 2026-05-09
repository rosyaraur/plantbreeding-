#' Analysis of Augmented Randomized Complete Block Design
#'
#' @description 
#' Implements an analysis of an augmented randomized complete block design (ARCBD). 
#' The function assumes that checks (controls) are replicated *r* times, making complete 
#' blocks, while other treatments (new entries) are unreplicated. The checks are completely 
#' randomized making complete blocks, and the remaining experimental units are completely 
#' randomized with the unreplicated new treatments.
#'
#' @param dataframe A dataframe object containing at least the variables for genotypes, blocks, and the response variable.
#' @param genotypes A character string representing the name of the column consisting of genotypes or treatments (e.g., "genotype_col").
#' @param block A character string representing the name of the column consisting of blocks (e.g., "block_col").
#' @param yvar A character string representing the name of the response variable column (e.g., "yield").
#' @param plot Logical. If \code{TRUE}, generates base R plots comparing the observed and adjusted values. Default is \code{TRUE}.
#' @param verbose Logical. If \code{TRUE}, prints standard errors and a preview of the adjusted dataset to the console. Default is \code{TRUE}.
#'
#' @return A list consisting of the following items:
#' \itemize{
#'   \item \code{anova}: Analysis of variance object (ANOVA table) based on the checks.
#'   \item \code{adjusted_values}: A dataframe containing the raw observed and block-adjusted values for the unreplicated entries.
#'   \item \code{se_check}: Standard error of the difference between two check means.
#'   \item \code{se_within}: Standard error of the difference between adjusted yields of two entries in the same block.
#'   \item \code{se_diff}: Standard error of the difference between adjusted yields of two entries in different blocks.
#'   \item \code{se_geno}: Standard error of the difference between an adjusted entry and a check mean.
#' }
#'
#' @author Umesh R. Rosyara 
#'
#' @export
#'
#' @examples
#' \dontrun{
#' data(augblock)
#' 
#' # Run analysis silently, saving outputs to 'out'
#' out <- aug.rcb(dataframe = augblock, genotypes = "var", block = "blk", 
#'                yvar = "gw", verbose = FALSE, plot = FALSE)
#' 
#' out$anova  # View analysis of variance 
#' head(out$adjusted_values) # View yield observed and expected value table  
#' 
#' # Calculation of means
#' stab <- aggregate(gw ~ var, data = augblock, FUN = mean)
#' hist(stab$gw, col = "cadetblue", xlab = "Grain Yield", 
#'      main = "Mean yields from Augmented Yield Trial")
#' }
aug.rcb <- function(dataframe, genotypes, block, yvar, plot = TRUE, verbose = TRUE) {
  
  # 1. Format inputs and prep data
  df <- dataframe
  df[[block]] <- as.factor(df[[block]])
  df[[genotypes]] <- as.factor(df[[genotypes]])
  
  # 2. Identify Checks (replicated in all blocks) vs New Genotypes (unreplicated)
  n_blocks <- length(levels(df[[block]]))
  geno_freq <- table(df[[genotypes]])
  
  checks <- names(geno_freq)[geno_freq == n_blocks]
  tests <- names(geno_freq)[geno_freq < n_blocks]
  
  if(length(checks) == 0) stop("No checks found. Checks must be present in all blocks.")
  
  check_data <- df[df[[genotypes]] %in% checks, ]
  test_data <- df[df[[genotypes]] %in% tests, ]
  
  # 3. Fit Linear Model and ANOVA (using formula interface for cleaner output)
  formula_str <- paste(yvar, "~", genotypes, "+", block)
  model1 <- lm(as.formula(formula_str), data = check_data)
  
  # Clean up the ANOVA table
  amodel <- anova(model1)
  rownames(amodel)[1:2] <- c("Genotypes (Checks)", "Block")
  
  # 4. Calculate Block Adjustments
  # Block effect = Block Mean - Grand Mean of Checks
  block_means <- aggregate(as.formula(paste(yvar, "~", block)), data = check_data, FUN = mean)
  grand_mean <- mean(block_means[[yvar]])
  block_means$block_effect <- block_means[[yvar]] - grand_mean
  
  # Adjust the unreplicated test genotypes
  block_match <- match(test_data[[block]], block_means[[block]])
  test_data$yvar_adj <- test_data[[yvar]] - block_means$block_effect[block_match]
  
  # 5. Standard Error Calculations
  # Extract Degrees of Freedom and MSE
  c <- amodel$Df[1] + 1  # Number of checks
  b <- amodel$Df[2] + 1  # Number of blocks
  MSE <- amodel$"Mean Sq"[3]
  
  se_check  <- sqrt(2 * MSE / b)
  se_within <- sqrt(2 * MSE)
  se_diff   <- sqrt(2 * MSE * (1 + 1 / c))
  se_geno   <- sqrt(MSE * (b + 1) * (c + 1) / (b * c))
  
  # 6. Console Output (Controlled by 'verbose')
  if (verbose) {
    cat("\n--- Augmented RCB Analysis ---\n\n")
    cat("Phenotypes and adjusted values:\n")
    print(head(test_data)) # Printing head to avoid flooding console with large datasets
    cat("\nStandard Errors for Comparisons:\n")
    cat("  Difference between check means:                         ", round(se_check, 4), "\n")
    cat("  Difference between two test varieties in same block:    ", round(se_within, 4), "\n")
    cat("  Difference between two test varieties in diff blocks:   ", round(se_diff, 4), "\n")
    cat("  Difference between a test variety and a check mean:     ", round(se_geno, 4), "\n\n")
  }
  
  # 7. Visualization (Controlled by 'plot')
  if (plot) {
    # Store old plotting parameters and ensure they reset on exit
    old_par <- par(no.readonly = TRUE)
    on.exit(par(old_par))
    
    par(mfrow = c(1, 2))
    
    # Plot 1: Simple Scatter
    plot(test_data[[yvar]], test_data$yvar_adj, 
         xlab = paste(yvar, "(Observed)"), ylab = paste(yvar, "(Adjusted)"),
         main = "Observed vs Adjusted", pch = 16, col = "darkgray")
    abline(a = 0, b = 1, col = "red", lty = 2)
    
    # Plot 2: Detailed adjustment visualization
    plot(test_data[[yvar]], test_data$yvar_adj, 
         xlab = paste(yvar, "(Observed)"), ylab = paste(yvar, "(Adjusted)"), 
         asp = 1, pch = 16, col = "lightseagreen", main = "Adjustment Magnitude")
    abline(a = 0, b = 1, col = "red", lty = 1)
    
    # Draw segments showing the shift
    segments(x0 = test_data[[yvar]], y0 = test_data$yvar_adj, 
             x1 = test_data[[yvar]], y1 = test_data[[yvar]], 
             col = "blue1", lty = 2)
    grid(NULL, NULL, lty = 3, col = "cornsilk3")
  }
  
  # 8. Return List
  results <- list(
    anova = amodel, 
    adjusted_values = test_data, 
    se_check = se_check, 
    se_within = se_within, 
    se_diff = se_diff, 
    se_geno = se_geno
  )
  
  # Return invisibly so it doesn't auto-print the entire list if not assigned
  invisible(results)
}