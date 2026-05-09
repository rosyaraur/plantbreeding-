#' @title Analysis of Augmented Row and Column Design
#' 
#' @description The function implements the analysis of an augmented random row and column design, 
#' adjusting un-replicated test lines based on replicated check varieties while safely handling missing (`NA`) data.
#'
#' @param dataframe A dataframe object containing at least the columns for rows, columns, genotypes/treatments, and the response variable (e.g., yield).
#' @param rows Character string; the name of the variable with row numbers.
#' @param columns Character string; the name of the variable with column numbers.
#' @param genotypes Character string; the name of the variable with treatments or genotypes (will be treated as a factor).
#' @param yield Character string; the name of the numeric response variable (e.g., yield).
#'
#' @return A list containing:
#' \itemize{
#'   \item \code{ANOVA}: Analysis of Variance Table for the checks.
#'   \item \code{Adjustment}: Dataframe with original and adjusted phenotypic values for all lines.
#'   \item \code{se_check}: Standard error of the difference between check means.
#'   \item \code{se_within}: Standard error of the difference in adjusted yield of two genotypes/varieties in the same row or column.
#'   \item \code{se_diff}: Standard error of the difference between two genotypes/varieties in different rows or blocks.
#'   \item \code{se_geno_check}: Standard error of the difference between two genotypes/varieties and a check mean.
#' }
#' 
#' @author Umesh Rosyara 
#' 
#' @export
#'
#' @examples
#' \dontrun{
#' # Example 1
#' data(rowcoldata)
#' outp <- aug.rowcol(dataframe = rowcoldata, rows = "rows", columns = "columns", 
#'                    genotypes = "genotypes", yield = "yield")
#' 
#' outp$ANOVA # analysis of variance 
#' outp$Adjustment # adjusted values 
#' 
#' # Calculation of means
#' stab <- aggregate(yield ~ genotypes, data = rowcoldata, FUN = mean, na.rm = TRUE)
#' 
#' hist(stab$yield, col = "cadetblue", xlab = "Grain Yield", 
#'      main = "Mean yields from Augmented Yield Trial")
#' }
aug.rowcol <- function(dataframe, rows, columns, genotypes, yield) {
  
  # 1. Safely extract columns and ensure correct data types
  df <- data.frame(
    rows = as.factor(dataframe[[rows]]),
    columns = as.factor(dataframe[[columns]]),
    genotypes = as.factor(dataframe[[genotypes]]),
    yield = as.numeric(dataframe[[yield]])
  )
  
  # 2. Identify checks (must have VALID/NON-NA data spanning all rows)
  df_valid <- df[!is.na(df$yield), ] 
  geno_counts <- table(df_valid$genotypes)
  num_rows <- length(levels(df$rows))
  
  checks <- names(geno_counts)[geno_counts == num_rows]
  if (length(checks) == 0) {
    stop("No check genotypes found with valid (non-NA) data spanning all rows. Check your data structure.")
  }
  
  # Subset checks for modeling
  checks_df <- df[df$genotypes %in% checks, ]
  
  # 3. Model and ANOVA on checks
  # na.exclude ensures residuals align with original dataframe indices
  model1 <- lm(yield ~ genotypes + rows + columns, data = checks_df, na.action = na.exclude)
  amodel1 <- anova(model1)
  
  amod2 <- as.data.frame(amodel1)
  rownames(amod2)[rownames(amod2) == "Residuals"] <- "Residual"
  
  # 4. Calculate adjustment factors (ignoring NAs)
  row_means <- aggregate(yield ~ rows, data = checks_df, 
                         FUN = function(x) mean(x, na.rm = TRUE))
  row_means$row_adj <- row_means$yield - mean(row_means$yield, na.rm = TRUE)
  
  col_means <- aggregate(yield ~ columns, data = checks_df, 
                         FUN = function(x) mean(x, na.rm = TRUE))
  col_means$col_adj <- col_means$yield - mean(col_means$yield, na.rm = TRUE)
  
  # 5. Apply adjustments to the ENTIRE dataset
  df_adj <- merge(df, row_means[, c("rows", "row_adj")], by = "rows", all.x = TRUE)
  df_adj <- merge(df_adj, col_means[, c("columns", "col_adj")], by = "columns", all.x = TRUE)
  
  # Calculate adjusted yield (if observed yield is NA, adjusted stays NA)
  df_adj$yield.adj <- df_adj$yield - df_adj$row_adj - df_adj$col_adj
  
  # Clean up dataframe for output
  df_adj <- df_adj[, c("genotypes", "rows", "columns", "yield", "yield.adj")]
  
  # 6. Graphical Output (Handling NAs safely)
  oldpar <- par(mfrow = c(1, 2), mar = c(5, 4, 4, 2) + 0.1)
  on.exit(par(oldpar)) 
  
  # Plot 1: Residuals of checks (Filter NAs for clean plotting)
  model1.res <- resid(model1)
  plot_idx <- !is.na(model1.res) & !is.na(checks_df$yield)
  
  plot(checks_df$yield[plot_idx], model1.res[plot_idx], 
       ylab = "Residuals", xlab = "Trait Yield", 
       main = "Residual Plot of Checks", pch = 16, col = "darkgray")
  text(checks_df$yield[plot_idx], model1.res[plot_idx], 
       labels = checks_df$genotypes[plot_idx], pos = 3, cex = 0.75, col = "red")
  abline(h = 0, col = "blue4", lty = 2)
  
  # Plot 2: Observed vs Adjusted (Filter NAs for clean plotting)
  adj_idx <- !is.na(df_adj$yield) & !is.na(df_adj$yield.adj)
  
  plot(df_adj$yield[adj_idx], df_adj$yield.adj[adj_idx], 
       xlab = "Observed Yield", ylab = "Adjusted Yield", 
       main = "Observed vs Adjusted", asp = 1, pch = 16, col = "lightseagreen")
  abline(a = 0, b = 1, col = "red", lty = 1)
  segments(df_adj$yield[adj_idx], df_adj$yield.adj[adj_idx], 
           df_adj$yield[adj_idx], df_adj$yield[adj_idx], 
           col = "blue1", lty = 2)
  grid(col = "cornsilk2", lty = "dotted")
  
  # 7. Standard Errors
  MSE <- amodel1["Residuals", "Mean Sq"]
  r <- amodel1["rows", "Df"] + 1
  
  SEcheck   <- sqrt(2 * MSE / r)
  SEwithin  <- sqrt(2 * MSE + (2 * MSE) / r)
  SEdiff    <- sqrt(2 * MSE + (4 * MSE) / r)
  SEgcheck  <- sqrt(MSE + (3 * MSE) / r - (2 * MSE) / (r^2))
  
  cat("\n--- Standard Errors for Comparisons ---\n")
  cat("Difference between check means: ", round(SEcheck, 4), "\n")
  cat("Difference (adj yield) of two varieties in same row/col: ", round(SEwithin, 4), "\n")
  cat("Difference between two varieties in different rows/blocks: ", round(SEdiff, 4), "\n")
  cat("Difference between two varieties and a check mean: ", round(SEgcheck, 4), "\n\n")
  
  # 8. Return List 
  results <- list(
    ANOVA = amod2, 
    Adjustment = df_adj, 
    se_check = SEcheck, 
    se_within = SEwithin, 
    se_diff = SEdiff, 
    se_geno_check = SEgcheck
  )
  
  return(invisible(results))   
}