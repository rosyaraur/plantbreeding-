# Load necessary library for spatial visualization
if(!require(ggplot2)) install.packages("ggplot2")
library(ggplot2)

set.seed(42)

# 1. Setup Dimensions
n_families <- 90
n_cols <- 300
rows_per_block <- 30
check_rows_gap <- 2
n_check_intervals <- n_cols / rows_per_block # 10 intervals

# Total rows = 300 + (10 intervals * 2 check rows) = 320
total_rows <- 320
total_cols <- 90 # Assuming families are arranged across columns

# 2. Generate Effects
family_effects <- rnorm(n_families, mean = 50, sd = 5)
check_effect <- 55 # Constant for the check variety

# 3. Create Spatial Fertility Pattern (The "Peaks and Dips")
# Using a 2D sine wave + noise to simulate soil heterogeneity
row_coords <- 1:total_rows
col_coords <- 1:total_cols
grid <- expand.grid(Row = row_coords, Col = col_coords)

grid$fertility <- with(grid, {
  10 * sin(Row / 20) * cos(Col / 15) +  # Large scale peaks/dips
    5 * sin(Row / 5) +                   # Smaller row-wise variation
    rnorm(nrow(grid), 0, 2)              # Random residual noise
})

# 4. Assign Families and Checks
# We identify check rows: 31, 32, 63, 64, etc.
grid$is_check <- FALSE
for(i in 1:n_check_intervals) {
  start_check <- i * rows_per_block + (i - 1) * check_rows_gap + 1
  grid$is_check[grid$Row %in% c(start_check, start_check + 1)] <- TRUE
}

# Assign family IDs (cycling through 1:90 for non-check rows)
grid$family_id <- NA
non_check_indices <- which(!grid$is_check)
grid$family_id[non_check_indices] <- rep(1:n_families, length.out = length(non_check_indices))

# 5. Calculate Final Yield
# Yield = Family Effect + Spatial Fertility
grid$yield <- ifelse(grid$is_check, 
                     check_effect + grid$fertility,
                     family_effects[grid$family_id] + grid$fertility)

# 6. Visualization
ggplot(grid, aes(x = Col, y = Row, fill = yield)) +
  geom_tile() +
  scale_fill_viridis_c(option = "magma") +
  labs(title = "Simulated Field Yield with Spatial Trends",
       subtitle = "Horizontal bands represent periodic check plots",
       x = "Range (Columns)", y = "Row") +
  theme_minimal()

# Make sure you have these packages installed: install.packages(c("ggplot2", "lattice"))
library(ggplot2)
# Optional: install.packages("gridExtra") if you want to plot them side-by-side
library(gridExtra) 

library(ggplot2)
library(gridExtra)
library(FNN)
library(lme4)
library(sommer)

library(ggplot2)
library(gridExtra)
library(FNN)
library(lme4)
library(sommer)

library(ggplot2)
library(gridExtra)
library(FNN)
library(lme4)
library(sommer)

library(ggplot2)
library(gridExtra)
library(FNN)
library(lme4)
library(SpATS)
library(mgcv)

adjust_spatial_unreplicated <- function(field_data, method = "spats", knn_k = 4) {
  
  # Ensure the data has the basic required columns
  if(!all(c("Row", "Col", "yield", "is_check", "family_id") %in% names(field_data))) {
    stop("Data must contain columns: Row, Col, yield, is_check, family_id")
  }
  
  # Setup factor columns for mixed models
  field_data$Row_f <- as.factor(field_data$Row)
  field_data$Col_f <- as.factor(field_data$Col)
  field_data$genotype <- as.factor(ifelse(field_data$is_check, "CHECK", as.character(field_data$family_id)))
  
  check_data <- field_data[field_data$is_check == TRUE, ]
  overall_check_mean <- mean(check_data$yield, na.rm = TRUE)
  
  # ==========================================
  # 1. SPATIAL MODELING
  # ==========================================
  
  if (method == "loess") {
    message("Fitting LOESS surface model...")
    model <- loess(yield ~ Row * Col, data = check_data, span = 0.3, control = loess.control(surface = "direct"))
    field_data$fitted_trend <- as.numeric(predict(model, newdata = field_data))
    field_data$adjusted_yield <- field_data$yield - field_data$fitted_trend + overall_check_mean
    
  } else if (method == "knn") {
    message(paste("Fitting KNN model with k =", knn_k, "..."))
    knn_model <- knn.reg(train = check_data[, c("Row", "Col")], 
                         test = field_data[, c("Row", "Col")], 
                         y = check_data$yield, k = knn_k)
    field_data$fitted_trend <- knn_model$pred
    field_data$adjusted_yield <- field_data$yield - field_data$fitted_trend + overall_check_mean
    
  } else if (method == "rowcol") {
    message("Fitting Row/Column Mixed Model (lme4)...")
    model <- lmer(yield ~ genotype + (1|Row_f) + (1|Col_f), data = field_data)
    field_data$fitted_trend <- predict(model, re.form = ~(1|Row_f) + (1|Col_f))
    field_data$adjusted_yield <- field_data$yield - field_data$fitted_trend
    
  } else if (method == "spats") {
    message("Fitting 2D P-Spline Spatial Model (SpATS)...")
    # nseg controls the flexibility of the spline mesh over the columns and rows
    model <- SpATS(response = "yield", 
                   spatial = ~ PSANOVA(Col, Row, nseg = c(20, 20)), 
                   genotype = "genotype", 
                   genotype.as.random = FALSE, 
                   data = field_data)
    
    # SpATS internally isolates the spatial surface for us
    field_data$fitted_trend <- model$fitted.spatial
    field_data$adjusted_yield <- field_data$yield - field_data$fitted_trend
    
  } else if (method == "gam") {
    message("Fitting 2D Spline Model via Generalized Additive Model (mgcv)...")
    # s(Col, Row) fits a 2D isotropic smooth surface
    model <- gam(yield ~ genotype + s(Col, Row), data = field_data)
    
    # We predict using type="terms" to isolate JUST the spatial smooth, ignoring the fixed genetics
    terms_pred <- predict(model, type = "terms")
    spatial_col <- grep("s\\(", colnames(terms_pred)) # Find the column with the spline
    
    field_data$fitted_trend <- as.numeric(terms_pred[, spatial_col])
    field_data$adjusted_yield <- field_data$yield - field_data$fitted_trend
    
  } else {
    stop("Invalid method. Choose 'loess', 'knn', 'rowcol', 'spats', or 'gam'.")
  }
  
  # Calculate final residuals for the heatmap
  field_data$residuals <- field_data$yield - field_data$fitted_trend
  
  # ==========================================
  # 2. VISUALIZATIONS
  # ==========================================
  
  base_theme <- theme_minimal() + theme(panel.grid = element_blank())
  
  plot_raw <- ggplot(field_data, aes(x = Col, y = Row, fill = yield)) +
    geom_tile() +
    scale_fill_viridis_c(option = "magma") +
    labs(title = "Raw Yield", subtitle = "Unadjusted field data", x = "Col", y = "Row", fill = "Yield") +
    base_theme
  
  plot_adj <- ggplot(field_data, aes(x = Col, y = Row, fill = adjusted_yield)) +
    geom_tile() +
    scale_fill_viridis_c(option = "magma") +
    labs(title = paste("Adjusted Yield (", toupper(method), ")", sep=""), 
         subtitle = "Spatial variation removed", x = "Col", y = "Row", fill = "Adj Yield") +
    base_theme
  
  plot_res <- ggplot(field_data, aes(x = Col, y = Row, fill = residuals)) +
    geom_tile() +
    scale_fill_gradient2(low = "firebrick", mid = "white", high = "steelblue", midpoint = 0) +
    labs(title = "Spatial Trend", subtitle = "Modeled environmental pattern", x = "Col", y = "Row", fill = "Trend") +
    base_theme
  
  return(list(
    data          = field_data,
    plot_raw      = plot_raw,
    plot_adj      = plot_adj,
    plot_res      = plot_res
  ))
}

# # 1. Run LOESS (Default)
# results_loess <- adjust_spatial_unreplicated(grid, method = "loess")
# grid.arrange(results_loess$plot_raw, results_loess$plot_adj, results_loess$plot_res, ncol = 3)
# 
# # 2. Run KNN (Using the 6 nearest check plots)
# results_knn <- adjust_spatial_unreplicated(grid, method = "knn", knn_k = 6)
# grid.arrange(results_knn$plot_raw, results_knn$plot_adj, results_knn$plot_res, ncol = 3)
# 
# # 3. Run Mixed Model (Row and Column Effects)
# results_rc <- adjust_spatial_unreplicated(grid, method = "rowcol")
# grid.arrange(results_rc$plot_raw, results_rc$plot_adj, results_rc$plot_res, ncol = 3)
# 
# # 1. Run the SpATS 2D Spline # may need significant resources 
# results_spats <- adjust_spatial_unreplicated(grid, method = "spats")
# grid.arrange(results_spats$plot_raw, results_spats$plot_adj, results_spats$plot_res, ncol = 3)
# 
# # 2. Run the GAM 2D Spline
# results_gam <- adjust_spatial_unreplicated(grid, method = "gam")
# grid.arrange(results_gam$plot_raw, results_gam$plot_adj, results_gam$plot_res, ncol = 3)
