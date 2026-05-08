# ==============================================================================
# 0. INSTALL AND LOAD REQUIRED PACKAGES
# ==============================================================================
# Run this line once if you don't have these installed:
# install.packages(c("emmeans", "dplyr", "tidyr", "ggplot2", "gstat", "sp", "plotly"))

library(emmeans)
library(dplyr)
library(tidyr)
library(ggplot2)
library(gstat)
library(sp)
library(plotly)

# ==============================================================================
# 1. THE UNIVERSAL ANCOVA FUNCTION
# ==============================================================================
#' Advanced Spatial ANCOVA with 2D and 3D Diagnostic Plots
#'
#' @param data Data frame containing the dataset.
#' @param response String. Name of the response variable.
#' @param treatment String. Name of the treatment factor.
#' @param numeric_covariate String. Name of the continuous covariate (optional).
#' @param block String. Name of the block factor (optional).
#' @param row String. Name of the row factor (optional for spatial models).
#' @param col String. Name of the column factor (optional for spatial models).
#' @return A list containing the model, adjusted data, and diagnostic plot objects.

analyze_spatial_ancova <- function(data, response, treatment, 
                                   numeric_covariate = NULL,
                                   block = NULL, row = NULL, col = NULL) {
  
  # A. Convert categorical variables to factors
  vars_to_factor <- c(treatment, block, row, col)
  vars_to_factor <- vars_to_factor[!sapply(vars_to_factor, is.null)]
  for (v in vars_to_factor) data[[v]] <- as.factor(data[[v]])
  
  # B. Build Formula & Fit Model (Spatial -> Covariate -> Treatment)
  model_terms <- c(block, row, col, numeric_covariate, treatment)
  model_terms <- model_terms[!sapply(model_terms, is.null)]
  formula_str <- paste(response, "~", paste(model_terms, collapse = " + "))
  
  model <- aov(as.formula(formula_str), data = data)
  
  cat("====================================================\n")
  cat("                   ANCOVA TABLE                     \n")
  cat(sprintf(" Model: %s\n", formula_str))
  cat("====================================================\n")
  print(summary(model))
  cat("\n")
  
  # C. Calculate Adjusted Group Means
  adj_means <- emmeans(model, specs = treatment)
  emms_df <- as.data.frame(adj_means)
  
  # D. Calculate Individual Adjusted Values
  data$Fitted_Value <- fitted(model)
  data$Treatment_EMM <- emms_df$emmean[match(data[[treatment]], emms_df[[treatment]])]
  adj_col_name <- paste0(response, "_Adjusted")
  
  # Universal adjustment formula
  data[[adj_col_name]] <- data[[response]] - (data$Fitted_Value - data$Treatment_EMM)
  
  # E. Generate Diagnostic Plots
  plot_list <- list()
  
  # Plot 1: 2D ANCOVA Regression
  if (!is.null(numeric_covariate)) {
    plot_list$ancova_plot <- ggplot(data, aes_string(x = numeric_covariate, y = response, color = treatment)) +
      geom_point(size = 3, alpha = 0.7) +
      geom_smooth(method = "lm", se = FALSE, linewidth = 1) +
      theme_classic(base_size = 14) +
      labs(title = "ANCOVA: Response vs Covariate",
           subtitle = "Parallel slopes indicate the covariate effect being removed",
           x = numeric_covariate, y = paste("Raw", response))
  }
  
  # Plot 2 & 3: Spatial Diagnostics
  if (!is.null(row) && !is.null(col)) {
    
    # Setup coordinates for mapping
    data$X_num <- as.numeric(as.character(data[[col]]))
    data$Y_num <- as.numeric(as.character(data[[row]]))
    
    # Plot 2: Spatial Variogram
    sp_data <- data
    sp_data$Residuals <- resid(model)
    coordinates(sp_data) <- ~ X_num + Y_num
    
    v_model <- suppressWarnings(variogram(Residuals ~ 1, data = sp_data, cutoff = 6, width = 1))
    
    plot_list$variogram_plot <- ggplot(v_model, aes(x = dist, y = gamma)) +
      geom_point(size = 4, color = "#4C72B0") +
      geom_smooth(method = "loess", se = FALSE, color = "darkred", linetype = "dashed", formula = 'y ~ x') +
      theme_classic(base_size = 14) + expand_limits(y = 0) +
      labs(title = "Spatial Variogram of Model Residuals",
           subtitle = "A flat line indicates spatial gradients were modeled out successfully",
           x = "Distance between plots", y = "Semivariance")
    
    # Plot 3: 3D Surface Plotly
    # Using base R tapply to build the matrices directly, bypassing any dplyr masking errors
    
    mat_raw <- tapply(data[[response]], list(data[[row]], data[[col]]), FUN = mean, na.rm = TRUE)
    mat_adj <- tapply(data[[adj_col_name]], list(data[[row]], data[[col]]), FUN = mean, na.rm = TRUE)
    
    plot_list$surface_3d <- plot_ly() %>%
      add_surface(z = ~mat_raw, opacity = 0.5, colorscale = "Viridis", name = "Raw") %>%
      add_surface(z = ~mat_adj, type = "surface", hidesurface = TRUE, 
                  contours = list(x = list(show = TRUE), y = list(show = TRUE), z = list(show = FALSE)),
                  colorscale = "Reds", name = "Adjusted") %>%
      layout(title = "3D Spatial Surface: Raw (Solid) vs Adjusted (Wireframe)",
             scene = list(xaxis = list(title = col), yaxis = list(title = row), zaxis = list(title = response)))    
    # Cleanup spatial temp columns
    data <- data[, !(names(data) %in% c("X_num", "Y_num"))]
  }
  
  return(invisible(list(model = model, anova = summary(model), 
                        adjusted_means = adj_means, adjusted_data = data, plots = plot_list)))
}


# # ==============================================================================
# # 2. EXAMPLE 1: NON-SPATIAL ANCOVA (RCBD)
# # ==============================================================================
# cat("\n--- RUNNING EXAMPLE 1: LIMA BEANS (RCBD) ---\n")
# 
# # A. Create the Lima Bean Dataset (Table 15.2 subset)
# df_lima <- data.frame(
#   Variety = rep(c("1", "2"), times = 5),
#   Replication = rep(1:5, each = 2),
#   X_DryMatter = c(34.0, 39.6, 33.4, 39.8, 34.7, 51.2, 38.9, 52.0, 36.1, 56.2),
#   Y_Ascorbic  = c(93.0, 47.3, 94.8, 51.5, 91.7, 33.3, 80.8, 27.2, 80.2, 20.6)
# )
# 
# # B. Run the Analysis
# res_lima <- analyze_spatial_ancova(
#   data = df_lima,
#   response = "Y_Ascorbic",
#   treatment = "Variety",
#   numeric_covariate = "X_DryMatter",
#   block = "Replication"
# )
# 
# # C. View Outputs
# print(head(res_lima$adjusted_data))       # See the new Y_Ascorbic_Adjusted column
# print(res_lima$plots$ancova_plot)         # View the 2D Regression plot
# 
# 
# # ==============================================================================
# # 3. EXAMPLE 2: SPATIAL ANCOVA (Lattice / Row-Col)
# # ==============================================================================
# cat("\n--- RUNNING EXAMPLE 2: 5x5 SPATIAL FIELD ---\n")
# 
# # A. Simulate the 5x5 Field Dataset
# set.seed(42) 
# df_lattice <- data.frame(
#   Row = rep(1:5, times = 5),
#   Column = rep(1:5, each = 5),
#   Variety = c("A","B","C","D","E", "B","C","D","E","A", "C","D","E","A","B", "D","E","A","B","C", "E","A","B","C","D"),
#   Nematodes = round(runif(25, 50, 150))
# )
# 
# # Simulate Yield = Base + Row Effect + Col Effect + Covariate Effect + Noise
# true_eff <- c(A=100, B=115, C=90, D=130, E=105)
# row_eff <- c(-10, -5, 0, 5, 10)
# col_eff <- c(15, 8, 0, -8, -15)
# df_lattice$Yield <- round(true_eff[df_lattice$Variety] + row_eff[df_lattice$Row] + 
#                             col_eff[df_lattice$Column] + (df_lattice$Nematodes * -0.4) + 
#                             rnorm(25, 0, 4), 1)
# 
# # B. Run the Analysis
# res_spatial <- analyze_spatial_ancova(
#   data = df_lattice,
#   response = "Yield",
#   treatment = "Variety",
#   numeric_covariate = "Nematodes",
#   row = "Row",       # Triggers the spatial mapping
#   col = "Column"     # Triggers the spatial mapping
# )
# 
# # C. View Outputs
# print(head(res_spatial$adjusted_data))    # See the new Yield_Adjusted column
# print(res_spatial$plots$ancova_plot)      # View 2D Regression Plot
# print(res_spatial$plots$variogram_plot)   # View 2D Variogram (Should be flat)
# res_spatial$plots$surface_3d              # View 3D Plotly Wireframe (Interactive)
# 
# # both additional covariate and spatial effects 
# # Set seed so the random numbers are exactly the same every time you run it
# set.seed(123)
# 
# # 1. Create a 6x6 Field Grid (36 total plots)
# rows <- rep(1:6, times = 6)
# cols <- rep(1:6, each = 6)
# 
# # 2. Assign Treatments (Standard 6x6 Latin Square layout)
# # This ensures each of the 6 varieties appears exactly once in every row and column
# treatments <- c(
#   "A", "B", "C", "D", "E", "F",
#   "B", "C", "D", "E", "F", "A",
#   "C", "D", "E", "F", "A", "B",
#   "D", "E", "F", "A", "B", "C",
#   "E", "F", "A", "B", "C", "D",
#   "F", "A", "B", "C", "D", "E"
# )
# 
# # 3. Define the "Hidden Truth" of the field
# # A. True Genetic Potential of the Varieties (D is the best, C is the worst)
# true_trt_effect <- c(A=50, B=60, C=40, D=70, E=55, F=65)
# 
# # B. Spatial Gradients
# # North rows (1,2) are poor, South rows (5,6) are highly productive
# row_gradient <- c(-15, -10, 0, 5, 10, 20)  
# # Edges are dry/poor, the center of the field (cols 3,4) holds moisture well
# col_gradient <- c(-10, 5, 15, 15, 5, -10)  
# 
# # C. The Covariate: Soil Nitrogen (measured before planting)
# # Ranges randomly between 20 and 80 lbs/acre
# soil_nitrogen <- runif(36, min = 20, max = 80)
# nitrogen_slope <- 0.5  # Every extra unit of N adds 0.5 to the final yield
# 
# # 4. Calculate the Final Raw Yield (Adding everything together + some random noise)
# yield <- true_trt_effect[treatments] + 
#   row_gradient[rows] + 
#   col_gradient[cols] + 
#   (soil_nitrogen * nitrogen_slope) + 
#   rnorm(36, mean = 0, sd = 3) # Random natural variance
# 
# # 5. Assemble the final dataset
# df_test_data <- data.frame(
#   Row = rows,
#   Column = cols,
#   Variety = treatments,
#   Soil_Nitrogen = round(soil_nitrogen, 1),
#   Yield = round(yield, 1)
# )
# 
# # View the first few rows
# head(df_test_data)
# 
# # Run the Spatial ANCOVA model
# test_results <- analyze_spatial_ancova(
#   data = df_test_data,
#   response = "Yield",
#   treatment = "Variety",
#   numeric_covariate = "Soil_Nitrogen",
#   row = "Row",
#   col = "Column"
# )
# print(head(test_results$adjusted_data))    # See the new Yield_Adjusted column
# print(test_results$plots$ancova_plot)      # View 2D Regression Plot
# print(test_results$plots$variogram_plot)   # View 2D Variogram (Should be flat)
# test_results$plots$surface_3d              # View 3D Plotly Wireframe (Interactive)
