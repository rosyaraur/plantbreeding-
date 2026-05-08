#' Calculate Probability of Superiority from Summary Stats (with optional GxE)
#'
#' @param line_mean Numeric. The grand mean of the test genotype.
#' @param check_mean Numeric. The grand mean of the check genotype.
#' @param pop_var_means Numeric. The variance of all genotype means in the trial.
#' @param H2 Numeric. Broad-sense heritability on an entry-mean basis (0 to 1).
#' @param line_gxe_var Numeric. Optional. The specific environmental variance of the test line.
#' @return A data.frame containing the estimates, implied SED, and probability.

calc_prob_from_summary <- function(line_mean, check_mean, pop_var_means, H2, line_gxe_var = NULL) {
  
  if (H2 < 0 || H2 > 1) stop("Heritability must be between 0 and 1.")
  
  # 1. Back-calculate the trial's average error variance (assigned to the check)
  var_error_check <- pop_var_means * (1 - H2)
  
  # 2. Determine the Line's error variance
  if (is.null(line_gxe_var)) {
    # Homogeneous assumption
    var_error_line <- var_error_check 
    calc_type <- "Homogeneous (Standard)"
  } else {
    # Heterogeneous assumption (Specific GxE penalty applied)
    var_error_line <- line_gxe_var
    calc_type <- "Heterogeneous (GxE Penalized)"
  }
  
  # 3. Calculate the Standard Error of the Difference
  sed <- sqrt(var_error_check + var_error_line)
  
  # 4. Calculate Z-score and Probability
  diff <- line_mean - check_mean
  z_score <- diff / sed
  prob <- pnorm(z_score)
  
  return(data.frame(
    Test_Mean = line_mean,
    Advantage = diff,
    Model = calc_type,
    Implied_SED = round(sed, 4),
    Prob_Superiority = round(prob, 4)
  ))
}

# Scenario A: We only have trial averages (Homogeneous assumption)
res_standard <- calc_prob_from_summary(
  line_mean = 104, 
  check_mean = 100, 
  pop_var_means = 25, 
  H2 = 0.75
)

# Scenario B: We know the test line is highly unstable across environments
res_penalized <- calc_prob_from_summary(
  line_mean = 104, 
  check_mean = 100, 
  pop_var_means = 25, 
  H2 = 0.75,
  line_gxe_var = 45  # Specific penalty applied
)

# Combine and print to compare
print(rbind(res_standard, res_penalized))

