# Load necessary libraries
library(metan)
library(tidyr)
library(dplyr)
library(patchwork) # For combining plots side-by-side

library(metan)
library(tidyr)
library(dplyr)
library(patchwork)

#' Perform Complete GGE Biplot Analysis
#'
#' @description 
#' A wrapper function that automates the workflow for Genotype main effect plus 
#' Genotype-by-Environment interaction (GGE) biplot analysis. It accepts wide-format 
#' trial data, reshapes it to long format, fits the standard Singular Value 
#' Decomposition (SVD) model, and generates a suite of diagnostic biplots using the `metan` package.
#'
#' @param data A data.frame containing wide-format trial data where one column represents 
#'   genotypes and the remaining columns represent different environments.
#' @param genotype_col A character string specifying the exact name of the column in `data` 
#'   that contains the genotype identifiers.
#'
#' @return A named list containing the fitted model and generated `ggplot2` objects:
#' \itemize{
#'   \item \code{model}: The fitted GGE model object returned by \code{metan::gge()}.
#'   \item \code{plot_basic}: A basic GGE biplot (SVP = symmetrical).
#'   \item \code{plot_ranking}: An Average Environment Coordination (AEC) biplot showing mean performance and stability.
#'   \item \code{plot_poly_gen}: A "Which-won-where" polygon biplot optimized for comparing genotypes (SVP = 1).
#'   \item \code{plot_poly_env}: A "Which-won-where" polygon biplot optimized for comparing environments (SVP = 2).
#'   \item \code{plot_poly_sym}: A "Which-won-where" polygon biplot with symmetrical scaling (SVP = 3).
#'   \item \code{plot_env_rank}: A biplot ranking environments based on discriminativeness and representativeness.
#' }
#' 
#' @import metan
#' @import tidyr
#' @import dplyr
#' @import patchwork
#' @export
#'
#' @examples
#' \dontrun{
#' # Create sample data
#' df <- data.frame(
#'   Cultivar = c("G1", "G2", "G3"),
#'   Env1 = c(4.5, 4.2, 3.8),
#'   Env2 = c(5.1, 4.8, 4.1),
#'   Env3 = c(3.9, 4.5, 4.7)
#' )
#' 
#' # Run analysis
#' results <- run_gge_analysis(data = df, genotype_col = "Cultivar")
#' 
#' # Print a specific plot
#' print(results$plot_ranking)
#' }
run_gge_analysis <- function(data, genotype_col) {
  
  # Step A: Reshape from wide to long format dynamically
  # Using standard evaluation (!!sym()) to handle the dynamic column name robustly
  long_data <- data %>%
    pivot_longer(
      cols = -!!sym(genotype_col), 
      names_to = "Environment", 
      values_to = "Yield"
    )
  
  # Step B: Fit the GGE Model
  cat("Fitting GGE Model...\n")
  model <- gge(long_data, 
               env = Environment, 
               gen = !!sym(genotype_col), 
               resp = Yield)
  
  # Step C: Generate all plot variations
  cat("Generating plots...\n")
  
  p_basic <- plot(model, type = 1) + 
    labs(title = "Basic GGE Biplot")
  
  p_ranking <- plot(model, type = 2) + 
    labs(title = "Mean Performance & Stability")
  
  p_poly_gen <- plot(model, type = 3, SVP = "genotype") + 
    labs(title = "Polygon: Genotype-focused (SVP=1)")
    
  p_poly_env <- plot(model, type = 3, SVP = "environment") + 
    labs(title = "Polygon: Environment-focused (SVP=2)")
    
  p_poly_sym <- plot(model, type = 3, SVP = "symmetrical") + 
    labs(title = "Polygon: Symmetrical (SVP=3)")
    
  p_env_rank <- plot(model, type = 4) +
    labs(title = "Rank Environments")
  
  # Step D: Return everything as a structured list
  cat("Analysis complete!\n")
  return(list(
    model = model,
    plot_basic = p_basic,
    plot_ranking = p_ranking,
    plot_poly_gen = p_poly_gen,
    plot_poly_env = p_poly_env,
    plot_poly_sym = p_poly_sym,
    plot_env_rank = p_env_rank
  ))
}

# -------------------------------------------------------------------
# 2. Recreate the Test Dataset (Table 4.4)
# -------------------------------------------------------------------
# gge_data <- data.frame(
#   Genotype = c("Ann", "Ari", "Aug", "Cas", "Del", "Dia", "Ena", "Fun", "Ham",
#                "Har", "Kar", "Kat", "Luc", "M12", "Reb", "Ron", "Rub", "Zav"),
#   BH93 = c(4.460, 4.417, 4.669, 4.732, 4.390, 5.178, 3.375, 4.852, 5.038, 5.195, 4.293, 3.151, 4.104, 3.340, 4.375, 4.940, 3.786, 4.238),
#   EA93 = c(4.150, 4.771, 4.578, 4.745, 4.603, 4.475, 4.175, 4.664, 4.741, 4.662, 4.530, 3.040, 3.878, 3.854, 4.701, 4.698, 4.969, 4.654),
#   HW93 = c(2.849, 2.912, 3.098, 3.375, 3.511, 2.990, 2.741, 4.425, 3.508, 3.596, 2.760, 2.388, 2.302, 2.419, 3.655, 2.950, 3.379, 3.607),
#   ID93 = c(3.084, 3.506, 3.460, 3.904, 3.848, 3.774, 3.157, 3.952, 3.437, 3.759, 3.422, 2.350, 3.718, 2.783, 3.592, 3.898, 3.353, 3.914),
#   KE93 = c(5.940, 5.699, 6.070, 6.224, 5.773, 6.583, 5.342, 5.536, 5.960, 5.937, 6.142, 4.229, 4.555, 4.629, 6.189, 6.063, 4.774, 6.641),
#   NN93 = c(4.450, 5.152, 5.025, 5.340, 5.421, 5.045, 4.267, 5.832, 4.859, 5.345, 5.250, 4.257, 5.149, 5.090, 5.141, 5.326, 5.304, 4.830),
#   OA93 = c(4.351, 4.956, 4.730, 4.226, 5.147, 3.985, 4.162, 4.168, 4.977, 3.895, 4.856, 3.384, 2.596, 3.281, 3.933, 4.302, 4.322, 5.014),
#   RN93 = c(4.039, 4.386, 3.900, 4.893, 4.098, 4.271, 4.063, 5.060, 4.514, 4.450, 4.137, 4.071, 4.956, 3.918, 4.208, 4.299, 4.858, 4.363),
#   WP93 = c(2.672, 2.938, 2.621, 3.451, 2.832, 2.776, 2.032, 3.574, 2.859, 3.300, 3.149, 2.103, 2.886, 2.561, 2.925, 3.031, 3.382, 3.111)
# )
# 
# # -------------------------------------------------------------------
# # 3. Apply the function to the dataset
# # -------------------------------------------------------------------
# # Call the function, specifying that "Genotype" is the column holding the names
# my_results <- run_gge_analysis(data = gge_data, genotype_col = "Genotype")
# 
# # -------------------------------------------------------------------
# # 4. View the outputs
# # -------------------------------------------------------------------
# # View a specific single plot (e.g., the basic plot)
# print(my_results$plot_basic)
# 
# # View the Mean Performance & Stability plot
# print(my_results$plot_ranking)
# 
# print(my_results$plot_poly_env)
# 
# print(my_results$plot_poly_sym)
# 
# # View a specific single plot (e.g., the basic plot)
# print(my_results$plot_basic)
# 
# # View the Mean Performance & Stability plot
# print(my_results$plot_ranking)
# 
# # View the newly added Rank Environments plot
# print(my_results$plot_env_rank)
# 
# print(my_results$plot_ranking)
# # Use patchwork to display all three Polygon variations side-by-side
# combined_polygon_plots <- (my_results$plot_poly_gen | my_results$plot_poly_env) / my_results$plot_poly_sym
# print(combined_polygon_plots)