#' @title Safety-First Risk Analysis for Multi-Environment Trials
#'
#' @description
#' Evaluates the genotypic risk in agricultural multi-environment trials based on
#' the safety-first selection concept (Roy, 1952; Eskridge, 1990). The function calculates
#' the probability of a genotype's yield falling below specified minimum threshold values (`d`)
#' and computes the corresponding safety-first index, assuming normally distributed yields.
#' It also generates a cumulative probability distribution plot for visual risk assessment.
#'
#' @param df A data frame containing the multi-environment trial data.
#' @param genotype_col A character string specifying the name of the column in `df`
#'   that contains the genotype or variety identifiers.
#' @param yield_col A character string specifying the name of the column in `df`
#'   that contains the continuous yield or performance data.
#' @param d_thresholds A numeric vector of minimum acceptable yield thresholds (d).
#'   These represent different risk scenarios (e.g., subsistence vs. commercial farming).
#'
#' @return A list containing two elements:
#' \describe{
#'   \item{\code{Table}}{A data frame with the calculated mean, standard deviation,
#'   probability of failure (P(Y <= d)), and safety-first index for each genotype across all provided thresholds.}
#'   \item{\code{Plot}}{A \code{ggplot2} object displaying the cumulative distribution
#'   functions (CDFs) of the genotypes, annotated with vertical lines representing the \code{d_thresholds}.}
#' }
#'
#' @import dplyr
#' @import ggplot2
#' @import rlang
#' @export
#'
#' @examples
#' \dontrun{
#' # Simulate trial data
#' set.seed(123)
#' n_env <- 30
#' sim_data <- data.frame(
#'   Variety = rep(c("G1", "G2", "G3", "G4"), each = n_env),
#'   Yield_Tons_Ha = c(rnorm(n_env, 3.0, 0.5), rnorm(n_env, 4.5, 0.5),
#'                     rnorm(n_env, 4.5, 1.2), rnorm(n_env, 6.0, 0.5))
#' )
#'
#' # Run analysis with thresholds at 2.5 and 5.0
#' output <- safety_first_analysis(
#'   df = sim_data,
#'   genotype_col = "Variety",
#'   yield_col = "Yield_Tons_Ha",
#'   d_thresholds = c(2.5, 5.0)
#' )
#'
#' # View the metrics table
#' print(output$Table)
#'
#' # Render the CDF plot
#' print(output$Plot)
#' }
safety_first_analysis <- function(df, genotype_col, yield_col, d_thresholds) {
  
  # A. Calculate Mean and Standard Deviation using standard evaluation
  summary_stats <- df %>%
    dplyr::group_by(!!rlang::sym(genotype_col)) %>%
    dplyr::summarise(
      Mean = mean(!!rlang::sym(yield_col), na.rm = TRUE),
      SD = sd(!!rlang::sym(yield_col), na.rm = TRUE),
      .groups = 'drop'
    ) %>%
    dplyr::rename(Genotype = !!rlang::sym(genotype_col))
  
  # B. Calculate Risk metrics for every threshold provided
  results <- summary_stats
  for (d in d_thresholds) {
    # Create dynamic column names based on the threshold value
    prob_col <- paste0("Prob_Fail_(d=", d, ")")
    index_col <- paste0("Safety_Index_(d=", d, ")")
    
    # Apply formulas: P(Y <= d) and (Mean - d)/SD
    results[[prob_col]] <- pnorm(d, mean = results$Mean, sd = results$SD)
    results[[index_col]] <- (results$Mean - d) / results$SD
  }
  
  # C. Prepare data for the Cumulative Distribution Function (CDF) Plot
  min_yield <- min(df[[yield_col]], na.rm = TRUE) - 1
  max_yield <- max(df[[yield_col]], na.rm = TRUE) + 1
  x_seq <- seq(min_yield, max_yield, length.out = 200)
  
  cdf_data <- do.call(rbind, lapply(1:nrow(summary_stats), function(i) {
    data.frame(
      Genotype = summary_stats$Genotype[i],
      Yield_d = x_seq,
      Cumulative_Prob = pnorm(x_seq, mean = summary_stats$Mean[i], sd = summary_stats$SD[i])
    )
  }))
  
  # D. Generate the Plot
  p <- ggplot2::ggplot(cdf_data, ggplot2::aes(x = Yield_d, y = Cumulative_Prob, color = Genotype, linetype = Genotype)) +
    ggplot2::geom_line(linewidth = 1) +
    ggplot2::geom_hline(yintercept = 0.5, linetype = "dashed", color = "gray50") +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = "Safety-First Risk Assessment: Cumulative Probabilities",
      x = "Minimum Acceptable Yield (d)",
      y = "Probability of Failure P(Y <= d)"
    )
  
  # Add vertical lines and labels for each threshold dynamically
  colors <- c("red", "blue", "darkgreen", "purple", "orange")
  for (i in seq_along(d_thresholds)) {
    d_val <- d_thresholds[i]
    col_val <- colors[((i - 1) %% length(colors)) + 1] # Cycle through colors
    
    p <- p + 
      ggplot2::geom_vline(xintercept = d_val, linetype = "dotted", color = col_val, linewidth = 0.8) +
      ggplot2::annotate("text", x = d_val, y = 0.05, label = paste("d =", d_val), 
                        angle = 90, vjust = -0.5, color = col_val)
  }
  
  # Return both the data table and the plot in a list
  return(list(Table = results, Plot = p))
}

# Simulate trial data
set.seed(123)
n_env <- 30
sim_data <- data.frame(
  Variety = rep(c("G1", "G2", "G3", "G4"), each = n_env),
  Yield_Tons_Ha = c(rnorm(n_env, 3.0, 0.5), rnorm(n_env, 4.5, 0.5),
                    rnorm(n_env, 4.5, 1.2), rnorm(n_env, 6.0, 0.5))
)

# Run analysis with thresholds at 2.5 and 5.0
output <- safety_first_analysis(
  df = sim_data,
  genotype_col = "Variety",
  yield_col = "Yield_Tons_Ha",
  d_thresholds = c(2.5, 5.0)
)
plot(output$Plot)
