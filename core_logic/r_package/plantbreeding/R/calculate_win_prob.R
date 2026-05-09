# ==============================================================================
# PART 1: SETUP AND REQUIRED LIBRARIES
# ==============================================================================

# Install packages if they are not already installed
required_packages <- c("lme4", "emmeans", "tidyr", "ggplot2", "dplyr", "leaflet")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

# Load libraries
library(lme4)
library(emmeans)
library(tidyr)
library(ggplot2)
library(dplyr)
library(leaflet)

# ==============================================================================
# PART 2: HISTORICAL ANALYSIS (Student's 1923 Barley Data)
# ==============================================================================
cat("\n--- Running Historical Data Analysis (Student's 1923 Data) ---\n")

# 1. Create the dataset (Transcribed from Table 9.5)
raw_data <- data.frame(
  Location = c("Ballinacurra", "Ballinacurra", "Whitegate", "Whitegate", 
               "Bagnalstown", "Bagnalstown", "Birr", "Birr", 
               "Monasterevan 1", "Monasterevan 1", "Monasterevan 2", "Monasterevan 2",
               "Monasterevan 3", "Monasterevan 3", "Nenagh", "Nenagh",
               "Portarlington", "Portarlington", "Thurles", "Thurles",
               "Tullamore", "Tullamore", "Arnestown", "Arnestown",
               "Castlebridge", "Castlebridge", "Enniscorthy", "Enniscorthy",
               "New Ross 1", "New Ross 1", "New Ross 2", "New Ross 2",
               "Carlingford 1", "Carlingford 1", "Carlingford 2", "Carlingford 2",
               "Greenore", "Greenore", "Dunleer", "Dunleer"),
  Variety = rep(c("A", "G"), 20),
  Y1901 = c(2.82, 1.76, 2.56, 1.95, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 2.76, 2.51, NA, NA, 3.80, 3.48, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA),
  Y1902 = c(3.11, 2.98, 3.52, 3.26, NA, NA, 3.11, 2.31, NA, NA, NA, NA, NA, NA, 3.04, 3.36, NA, NA, NA, NA, NA, NA, NA, NA, 2.81, 2.82, 2.84, 2.98, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA),
  Y1903 = c(1.66, 1.82, 2.20, 1.84, NA, NA, 2.46, 2.01, NA, NA, NA, NA, NA, NA, 2.04, 2.12, NA, NA, NA, NA, NA, NA, 1.33, 1.93, 3.12, 2.50, NA, NA, NA, NA, NA, NA, 2.95, 2.31, 2.81, 1.96, NA, NA, NA, NA),
  Y1904 = c(2.57, 2.98, 2.68, 2.57, NA, NA, 2.81, 2.98, 2.62, 2.59, NA, NA, NA, NA, 3.31, 2.89, 3.03, 2.81, NA, NA, NA, NA, NA, NA, 2.29, 1.57, NA, NA, 2.04, 1.76, NA, NA, NA, NA, NA, NA, NA, NA, 3.03, 2.87),
  Y1905 = c(3.14, 3.28, 2.94, 2.84, NA, NA, 3.69, 3.39, NA, NA, 3.64, 3.22, NA, NA, 3.61, 3.92, 3.03, 2.64, NA, NA, 3.45, 2.67, NA, NA, 2.86, 2.86, NA, NA, NA, NA, 3.26, 3.42, 2.01, 2.37, NA, NA, 3.62, 3.14, NA, NA),
  Y1906 = c(2.48, 2.43, 2.65, 2.23, 3.83, 3.48, 2.75, 2.50, NA, NA, 2.42, 2.65, 3.14, 3.48, 2.95, 2.21, NA, NA, NA, NA, 2.23, 2.18, NA, NA, 2.92, 2.65, NA, NA, NA, NA, 3.56, 3.09, 3.61, 2.82, 2.94, 3.20, 3.61, 3.36, NA, NA)
)

# Reshape to Long Format
barley_long <- raw_data %>%
  pivot_longer(cols = starts_with("Y"), names_to = "Year", values_to = "Yield") %>%
  mutate(Year = gsub("Y", "", Year)) %>%
  filter(!is.na(Yield))

# Fit the REML Model
model <- lmer(Yield ~ Variety + 
                (1 | Location) + 
                (1 | Year) + 
                (1 | Location:Year) + 
                (1 | Variety:Location) + 
                (1 | Variety:Year), 
              data = barley_long, 
              REML = TRUE)

# Extract Means and SED
adj_means <- emmeans(model, pairwise ~ Variety)
print(adj_means$emmeans)
print(adj_means$contrasts)

# Probability calculation (from Table 9.6 parameters)
mean_diff <- 0.210
sed <- 0.0532
prob_G_greater_than_A <- pt(0, df = 50, ncp = mean_diff / sed)
cat(sprintf("\nProbability of G yielding more than A: %.4f%%\n", prob_G_greater_than_A * 100))


# ==============================================================================
# PART 3: MODERN AGRONOMIC SIMULATION WITH SPATIAL DATA
# ==============================================================================
cat("\n--- Generating Modern Agronomic Trial Data ---\n")

set.seed(42)
n_farms <- 150

farm_trials <- data.frame(
  Farm_ID = 1:n_farms,
  Genotype = sample(c("Experimental_X1", "Standard_Check"), n_farms, replace = TRUE),
  Soil_Texture = sample(c("Clay", "Loam", "Sandy"), n_farms, replace = TRUE),
  Irrigation_Status = sample(c("Irrigated", "Dryland"), n_farms, replace = TRUE)
)

# Spatial & Envirotyping Data (SD, MN, IA, NE region)
farm_trials$Latitude <- runif(n_farms, min = 40.0, max = 48.5)
farm_trials$Longitude <- runif(n_farms, min = -103.5, max = -90.0)
farm_trials$Rainfall_mm <- runif(n_farms, min = 400, max = 850)
farm_trials$GDU <- 3500 - (farm_trials$Latitude - 40) * 100 + rnorm(n_farms, 0, 100)

# Biological Yield Engine
base_yield <- 100 
geno_effect <- ifelse(farm_trials$Genotype == "Experimental_X1", 6, 0)
soil_effect <- ifelse(farm_trials$Soil_Texture == "Loam", 10, 
                      ifelse(farm_trials$Soil_Texture == "Clay", 0, -12))
irr_effect <- ifelse(farm_trials$Irrigation_Status == "Irrigated", 20, 0)
rain_effect <- (farm_trials$Rainfall_mm - 500) * 0.10 
gdu_effect <- (farm_trials$GDU - 2500) * 0.02
random_noise <- rnorm(n_farms, mean = 0, sd = 10)

# Finalize Data
farm_trials$Yield_bu_ac <- round(base_yield + geno_effect + soil_effect + 
                                   irr_effect + rain_effect + gdu_effect + random_noise, 1)
farm_trials$Yield_bu_ac <- pmax(farm_trials$Yield_bu_ac, 20) 
farm_trials$Rainfall_mm <- round(farm_trials$Rainfall_mm, 1)
farm_trials$GDU <- round(farm_trials$GDU, 0)


# ==============================================================================
# PART 4: ANALYSIS AND PLOTTING FUNCTIONS
# ==============================================================================

# Function: Calculate Win Probability
calculate_win_prob <- function(data, yield_col, variety_col, new_line, farmer_line, env_classes = NULL) {
  formula_str <- paste(yield_col, "~", variety_col)
  
  if (!is.null(env_classes) && length(env_classes) > 0) {
    env_str <- paste(env_classes, collapse = " + ")
    formula_str <- paste(formula_str, "+", env_str)
  }
  
  mod <- lm(as.formula(formula_str), data = data)
  emms_df <- as.data.frame(emmeans(mod, specs = variety_col))
  
  mu_new <- emms_df[emms_df[[variety_col]] == new_line, "emmean"]
  mu_farmer <- emms_df[emms_df[[variety_col]] == farmer_line, "emmean"]
  
  sigma_e <- sigma(mod)
  sd_diff <- sqrt(2) * sigma_e
  mean_diff <- mu_new - mu_farmer
  prob_win <- pnorm(0, mean = mean_diff, sd = sd_diff, lower.tail = FALSE)
  
  cat("\n--- Agronomic Win Probability Analysis ---\n")
  cat(sprintf("New Line (%s) Estimated Mean: %.2f\n", new_line, mu_new))
  cat(sprintf("Farmer Line (%s) Estimated Mean: %.2f\n", farmer_line, mu_farmer))
  cat(sprintf("Residual Std Error (Noise): %.2f\n", sigma_e))
  cat(sprintf("Probability of %s winning against %s: %.2f%%\n", new_line, farmer_line, prob_win * 100))
  
  return(invisible(list(Win_Probability = prob_win, Means_Table = emms_df, Model = mod)))
}

# Function: Plot Trial Results
plot_trial_results <- function(data, results, yield_col, variety_col, facet_col = NULL) {
  prob <- results$Win_Probability * 100
  subtitle_text <- sprintf("Overall Probability of Experimental Line Winning: %.1f%%", prob)
  
  p <- ggplot(data, aes(x = .data[[variety_col]], y = .data[[yield_col]], fill = .data[[variety_col]])) +
    geom_boxplot(alpha = 0.5, outlier.shape = NA) + 
    geom_jitter(width = 0.15, alpha = 0.7, size = 2, color = "#444444") + 
    scale_fill_manual(values = c("Standard_Check" = "#E69F00", "Experimental_X1" = "#56B4E9")) +
    labs(title = "On-Farm Trial Yield Distributions", subtitle = subtitle_text, y = "Yield (bu/ac)", x = "Variety") +
    theme_minimal(base_size = 14) +
    theme(legend.position = "none", plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())
  
  if (!is.null(facet_col)) {
    p <- p + facet_wrap(as.formula(paste("~", facet_col)))
  }
  return(p)
}


# # ==============================================================================
# # PART 5: EXECUTION AND VISUALIZATION
# # ==============================================================================
# 
# # Run the analysis
# results <- calculate_win_prob(
#   data = farm_trials,
#   yield_col = "Yield_bu_ac",
#   variety_col = "Genotype",
#   new_line = "Experimental_X1",
#   farmer_line = "Standard_Check",
#   env_classes = c("Soil_Texture", "Irrigation_Status") 
# )
# 
# # Plot overall results and display in R viewer
# overall_plot <- plot_trial_results(farm_trials, results, "Yield_bu_ac", "Genotype")
# print(overall_plot)
# 
# # Create spatial map
# variety_palette <- colorFactor(palette = c("#E69F00", "#56B4E9"), domain = farm_trials$Genotype)
# 
# agronomic_map <- leaflet(data = farm_trials) %>%
#   addProviderTiles(providers$CartoDB.Positron) %>%
#   addCircleMarkers(
#     lng = ~Longitude, lat = ~Latitude,
#     color = ~variety_palette(Genotype), fillOpacity = 0.7, stroke = TRUE, weight = 1,
#     radius = ~Yield_bu_ac / 20, 
#     popup = ~paste0(
#       "<b>Farm ID:</b> ", Farm_ID, "<br/>",
#       "<b>Variety:</b> ", Genotype, "<br/>",
#       "<b>Yield:</b> <span style='color:green'>", Yield_bu_ac, " bu/ac</span><br/><hr/>",
#       "<b>Soil:</b> ", Soil_Texture, "<br/>",
#       "<b>Water:</b> ", Irrigation_Status, "<br/>",
#       "<b>Rainfall:</b> ", Rainfall_mm, " mm<br/>",
#       "<b>GDUs:</b> ", GDU
#     )
#   ) %>%
#   addLegend("bottomright", pal = variety_palette, values = ~Genotype, title = "Planted Variety", opacity = 1)
# 
# # Display the map
# agronomic_map