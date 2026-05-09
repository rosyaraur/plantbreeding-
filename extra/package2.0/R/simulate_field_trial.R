#' Simulate Multi-Environment Field Trial Data
#'
#' @description
#' This function simulates multi-environment trial (MET) data for multiple correlated traits.
#' It accounts for genetic correlations between traits, environmental correlations, 
#' heterogeneous residual variances, and spatial autocorrelation (AR1 x AR1).
#'
#' @param n_locs Integer. Number of locations (environments).
#' @param n_traits Integer. Number of traits to simulate.
#' @param n_entries Integer. Number of genotypes/treatments.
#' @param n_reps Integer. Number of replications per location.
#' @param missing_prop Numeric (0-1). Proportion of missing data points.
#' @param G_cov Matrix (n_traits x n_traits). Genetic covariance between traits.
#' @param E_corr Matrix (n_locs x n_locs). Correlation matrix between environments.
#' @param loc_res_vars Numeric Vector. Residual variance for each location (length = n_locs).
#' @param rho_row Numeric (0-1). Autocorrelation coefficient for rows.
#' @param rho_range Numeric (0-1). Autocorrelation coefficient for ranges.
#' @param rows Integer. Number of rows in the field grid at each location.
#' @param ranges Integer. Number of ranges in the field grid at each location.
#'
#' @return A data frame in long format containing spatial coordinates, Entry IDs, 
#'         and simulated trait values.
#' @export
simulate_field_trial <- function(
    n_locs = 3,
    n_traits = 2,
    n_entries = 50,
    n_reps = 2,
    missing_prop = 0.05,
    G_cov = matrix(c(1.0, 0.6, 0.6, 1.2), 2, 2),
    E_corr = diag(n_locs), 
    loc_res_vars = c(0.2, 0.5, 0.8), 
    rho_row = 0.7,
    rho_range = 0.7,
    rows = 10,
    ranges = 10
) {
  
  library(MASS)
  library(Matrix)
  
  # --- 1. Structural Setup ---
  total_per_loc <- rows * ranges
  df_list <- list()
  
  # Helper: Generate AR1 correlation matrix
  # R_h = rho^|i-j|
  ar1_mat <- function(n, rho) {
    times <- 1:n
    H <- abs(outer(times, times, "-"))
    return(rho^H)
  }
  
  # --- 2. Genetic Effects (G x E) ---
  # Simulate genotype effects correlated across traits and environments
  # Sigma_G = E_corr %x% G_cov (Kronecker Product)
  g_effects_raw <- mvrnorm(n_entries, 
                           mu = rep(0, n_traits * n_locs), 
                           Sigma = kronecker(E_corr, G_cov))
  rownames(g_effects_raw) <- paste0("G", 1:n_entries)
  
  # --- 3. Location-Specific Simulation ---
  for (l in 1:n_locs) {
    # Generate spatial grid
    loc_df <- expand.grid(Row = 1:rows, Range = 1:ranges)
    loc_df$Loc <- l
    loc_df$Plot <- 1:nrow(loc_df)
    
    # Assign Genotypes (Randomized)
    loc_df$Entry <- sample(rep(paste0("G", 1:n_entries), length.out = nrow(loc_df)))
    
    # Assign Replication/Block (Simple blocking based on layout)
    loc_df$Rep <- (loc_df$Plot %% n_reps) + 1
    
    # Generate Spatial Residuals (AR1 x AR1)
    # The spatial surface is specific to the location's variance
    R_spatial <- loc_res_vars[l] * kronecker(ar1_mat(ranges, rho_range), 
                                             ar1_mat(rows, rho_row))
    
    for (t in 1:n_traits) {
      trait_name <- paste0("Trait_", t)
      
      # Map genetic effects
      loc_idx <- ((l-1) * n_traits) + t
      g_vals <- g_effects_raw[, loc_idx]
      
      # Combine components: Y = G + Error_spatial
      spatial_noise <- mvrnorm(1, mu = rep(0, nrow(loc_df)), Sigma = R_spatial)
      loc_df[[trait_name]] <- g_vals[loc_df$Entry] + spatial_noise
      
      # Apply Missingness
      if(missing_prop > 0) {
        mask <- sample(1:nrow(loc_df), floor(missing_prop * nrow(loc_df)))
        loc_df[mask, trait_name] <- NA
      }
    }
    df_list[[l]] <- loc_df
  }
  
  return(do.call(rbind, df_list))
}

# # Run the simulation
# trial_results <- simulate_field_trial(n_locs = 3)
# 
# library(ggplot2)
# ggplot(subset(trial_results, Loc == 1), aes(x = Row, y = Range, fill = Trait_1)) +
#   geom_tile() +
#   scale_fill_gradient2() +
#   labs(title = "Spatial Gradient Simulation (Location 1)")

