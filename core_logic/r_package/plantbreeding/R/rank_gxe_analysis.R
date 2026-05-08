#' Calculate Rank-Based Non-Parametric Stability Statistics for GxE Analysis
#'
#' @description 
#' Computes a suite of non-parametric rank-based stability metrics for multi-environment 
#' trial (MET) evaluations. This function is designed to handle crossover Genotype-by-Environment 
#' (GxE) interactions without relying on parametric distributional assumptions.
#'
#' @param df A data frame or tibble containing the multi-environment trial data.
#' @param gen_col A character string specifying the name of the column containing genotype identifiers.
#' @param env_col A character string specifying the name of the column containing environment identifiers.
#' @param trait_col A character string specifying the name of the column containing the phenotypic trait (e.g., yield).
#'
#' @details 
#' The function calculates the following stability and simultaneous selection metrics:
#' \itemize{
#'   \item \strong{S1 & S2 (Huehn):} Based on raw phenotypic ranks across environments. 
#'   S1 is the mean absolute rank difference, and S2 is the variance of ranks. 
#'   Lower values indicate higher stability.
#'   \item \strong{NP1 & NP2 (Thennarasu):} Based on the ranks of adjusted means (removing 
#'   the environmental main effect). Lower values indicate higher stability.
#'   \item \strong{Kang's Rank-Sum:} A simultaneous selection index summing the genotype's 
#'   overall yield rank and its stability rank (using Wricke's Ecovalence). 
#'   The lowest sum indicates the best balance of high yield and high stability.
#'   \item \strong{Fox's Top-Third (Percentage):} The percentage of environments in which 
#'   the genotype ranked in the top third of all tested genotypes. Higher percentages 
#'   indicate broad adaptation.
#' }
#'
#' @return A `tibble` containing the stability metrics for each genotype, ordered by 
#'   Kang's Rank-Sum (from most favorable to least favorable).
#' 
#' @import dplyr
#' @import tidyr
#' @import purrr
#' 
#' @export
#'
#' @examples
#' \dontrun{
#' # Assuming 'df_trials' is your dataset with columns 'Variety', 'Location', and 'Grain_Yield'
#' stability_results <- rank_gxe_analysis(df = df_trials, 
#'                                        gen_col = "Variety", 
#'                                        env_col = "Location", 
#'                                        trait_col = "Grain_Yield")
#' head(stability_results)
#' }
rank_gxe_analysis <- function(df, gen_col, env_col, trait_col) {
  
  # Helper function for S1 / NP1 (Mean absolute rank difference)
  calc_mean_abs_diff <- function(ranks) {
    E <- length(ranks)
    if(E <= 1) return(NA)
    diff_matrix <- abs(outer(ranks, ranks, "-"))
    sum(diff_matrix) / (E * (E - 1))
  }
  
  # Standardize column names for NSE
  data <- df %>%
    select(Genotype = all_of(gen_col), 
           Environment = all_of(env_col), 
           Yield = all_of(trait_col)) %>%
    drop_na()
  
  E_count <- n_distinct(data$Environment)
  G_count <- n_distinct(data$Genotype)
  
  # Calculate Main Effects and Adjustments
  grand_mean <- mean(data$Yield)
  
  env_means <- data %>% 
    group_by(Environment) %>% 
    summarize(E_mean = mean(Yield), .groups = 'drop')
  
  gen_means <- data %>% 
    group_by(Genotype) %>% 
    summarize(G_mean = mean(Yield), .groups = 'drop') %>%
    arrange(desc(G_mean)) %>%
    mutate(Yield_Rank = row_number()) # 1 is best
  
  # Calculate ranks within environments and Wricke's components
  data_processed <- data %>%
    left_join(env_means, by = "Environment") %>%
    left_join(gen_means, by = "Genotype") %>%
    group_by(Environment) %>%
    mutate(
      Env_Rank = rank(-Yield, ties.method = "average"), # 1 is highest yield
      Adj_Yield = Yield - E_mean,
      Adj_Env_Rank = rank(-Adj_Yield, ties.method = "average"),
      Fox_Top_Third = ifelse(Env_Rank <= ceiling(G_count / 3), 1, 0),
      GE_effect = Yield - G_mean - E_mean + grand_mean,
      Wricke_sq = GE_effect^2
    ) %>%
    ungroup()
  
  # Aggregate stability statistics per Genotype
  stability_metrics <- data_processed %>%
    group_by(Genotype) %>%
    summarize(
      # Huehn's Statistics (Based on standard ranks)
      S1 = calc_mean_abs_diff(Env_Rank),
      S2 = var(Env_Rank) * (n() - 1) / n(), # Population variance of ranks
      
      # Thennarasu's Statistics (Based on adjusted ranks)
      NP1 = calc_mean_abs_diff(Adj_Env_Rank),
      NP2 = var(Adj_Env_Rank) * (n() - 1) / n(),
      
      # Kang's Rank-Sum Components
      Wricke_Ecovalence = sum(Wricke_sq),
      
      # Fox's Top Third
      Fox_Top_Third_Pct = round((sum(Fox_Top_Third) / E_count) * 100, 1),
      
      .groups = 'drop'
    ) %>%
    left_join(gen_means, by = "Genotype") %>%
    # Finalize Kang's Rank-Sum
    mutate(
      Wricke_Rank = rank(Wricke_Ecovalence, ties.method = "average"), # 1 is lowest variance (most stable)
      Kang_Rank_Sum = Yield_Rank + Wricke_Rank
    ) %>%
    select(Genotype, Mean_Yield = G_mean, Yield_Rank, S1, S2, NP1, NP2, Wricke_Ecovalence, Kang_Rank_Sum, Fox_Top_Third_Pct) %>%
    arrange(Kang_Rank_Sum) # Order by Kang's simultaneous selection metric
  
  return(stability_metrics)
}

# test cases 

set.seed(123) # For reproducibility

n_G <- 20
n_E <- 8
mu <- 100 # Base yield

# Generate Main Effects
G_effects <- seq(-15, 15, length.out = n_G) # Genotype effects
E_effects <- seq(-30, 30, length.out = n_E) # Environment effects

# Base grid
sim_grid <- expand.grid(Genotype = paste0("G", sprintf("%02d", 1:n_G)), 
                        Environment = paste0("E", 1:n_E))
sim_grid$G_eff <- rep(G_effects, times = n_E)
sim_grid$E_eff <- rep(E_effects, each = n_G)

# --- Dataset 1: High Scale (Non-crossover) GxE ---
# Interaction is a multiplier of the genotypic effect based on environment quality
scale_factors <- runif(n_E, min = 0.5, max = 2.0)
df_scale <- sim_grid %>%
  mutate(
    Env_Scale = rep(scale_factors, each = n_G),
    GE_eff = G_eff * Env_Scale - G_eff, # Scale expansion
    Error = rnorm(n(), mean = 0, sd = 2), # Low noise
    Yield = mu + G_eff + E_eff + GE_eff + Error
  )

# --- Dataset 2: High Crossover GxE ---
# Random GE effects that are much larger than G main effects
df_crossover <- sim_grid %>%
  mutate(
    GE_eff = rnorm(n(), mean = 0, sd = 25), # High SD causes rank inversions
    Error = rnorm(n(), mean = 0, sd = 2),
    Yield = mu + G_eff + E_eff + GE_eff + Error
  )

# --- Dataset 3: Medium GxE ---
# Random GE effects roughly equal to G main effects
df_medium <- sim_grid %>%
  mutate(
    GE_eff = rnorm(n(), mean = 0, sd = 8), 
    Error = rnorm(n(), mean = 0, sd = 2),
    Yield = mu + G_eff + E_eff + GE_eff + Error
  )

# Execute Analysis
res_scale <- rank_gxe_analysis(df_scale, "Genotype", "Environment", "Yield")
res_crossover <- rank_gxe_analysis(df_crossover, "Genotype", "Environment", "Yield")
res_medium <- rank_gxe_analysis(df_medium, "Genotype", "Environment", "Yield")

# Examine Top 5 genotypes selected by Kang's Rank-Sum in each scenario
head(res_scale, 5)
head(res_crossover, 5)
head(res_medium, 5)