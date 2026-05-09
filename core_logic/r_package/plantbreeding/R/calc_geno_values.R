# Install required packages if missing:
# install.packages(c("lme4", "lmerTest", "emmeans", "ggplot2"))
library(lme4)
library(lmerTest) 
library(emmeans)  
library(ggplot2)  

calc_geno_values <- function(data = NULL, 
                             y_var = "yield", 
                             geno_var = "genotype", 
                             loc_var = NULL, 
                             block_var = NULL, 
                             row_var = NULL, 
                             col_var = NULL, 
                             method = c("BLUP", "BLUE"),
                             ci_level = 0.95,   
                             plot = TRUE) {
  
  method <- match.arg(method)
  
  # -------------------------------------------------------------------------
  # 1. SIMULATE DATA (If none provided)
  # -------------------------------------------------------------------------
  if (is.null(data)) {
    message("No data provided. Simulating an example multi-location dataset...")
    set.seed(42)
    
    locs <- paste0("Loc", 1:3)
    blocks <- paste0("Block", 1:2)
    genos <- paste0("G", sprintf("%02d", 1:20)) 
    
    data <- expand.grid(location = locs, block = blocks, genotype = genos)
    data$row <- sample(1:10, nrow(data), replace = TRUE)
    data$col <- sample(1:10, nrow(data), replace = TRUE)
    
    true_geno_effects <- setNames(rnorm(length(genos), mean = 100, sd = 15), genos)
    loc_effects <- setNames(rnorm(length(locs), 0, 5), locs)
    
    data$yield <- true_geno_effects[data$genotype] + 
      loc_effects[data$location] + 
      rnorm(nrow(data), mean = 0, sd = 5)
    
    y_var <- "yield"; geno_var <- "genotype"; loc_var <- "location"
    block_var <- "block"; row_var <- "row"; col_var <- "col"
  }
  
  # Ensure design variables are factors
  for (f in c(geno_var, loc_var, block_var, row_var, col_var)) {
    if (!is.null(f) && f %in% colnames(data)) data[[f]] <- as.factor(data[[f]])
  }
  
  # -------------------------------------------------------------------------
  # 2. BUILD THE MIXED MODEL FORMULA
  # -------------------------------------------------------------------------
  formula_str <- paste(y_var, "~")
  
  if (method == "BLUE") {
    formula_str <- paste(formula_str, geno_var) 
  } else {
    formula_str <- paste(formula_str, "1 + (1 |", geno_var, ")") 
  }
  
  random_terms <- c()
  if (!is.null(loc_var)) {
    random_terms <- c(random_terms, paste0("(1 | ", loc_var, ")"))
    if (!is.null(block_var)) random_terms <- c(random_terms, paste0("(1 | ", loc_var, ":", block_var, ")"))
    if (!is.null(row_var))   random_terms <- c(random_terms, paste0("(1 | ", loc_var, ":", row_var, ")"))
    if (!is.null(col_var))   random_terms <- c(random_terms, paste0("(1 | ", loc_var, ":", col_var, ")"))
  } else {
    if (!is.null(block_var)) random_terms <- c(random_terms, paste0("(1 | ", block_var, ")"))
    if (!is.null(row_var))   random_terms <- c(random_terms, paste0("(1 | ", row_var, ")"))
    if (!is.null(col_var))   random_terms <- c(random_terms, paste0("(1 | ", col_var, ")"))
  }
  
  if (length(random_terms) > 0) {
    formula_str <- paste(formula_str, "+", paste(random_terms, collapse = " + "))
  }
  
  message("Fitting model: ", formula_str)
  model <- lmerTest::lmer(as.formula(formula_str), data = data)
  
  results <- list(model = model, method = method)
  
  # -------------------------------------------------------------------------
  # 3. EXTRACT VALUES, INTERVALS, SIGNIFICANCE, AND HERITABILITY
  # -------------------------------------------------------------------------
  ci_percentage <- paste0(ci_level * 100, "%") 
  
  if (method == "BLUP") {
    re <- ranef(model, condVar = TRUE)
    blups_raw <- re[[geno_var]]
    
    # Extract prediction errors for intervals and heritability
    cond_var <- attr(blups_raw, "postVar")
    blup_se <- sqrt(cond_var[1, 1, ])
    grand_mean <- fixef(model)["(Intercept)"]
    
    plot_df <- data.frame(
      Genotype = rownames(blups_raw),
      Estimate = blups_raw[, 1] + grand_mean,
      SE = blup_se
    )
    
    z_score <- qnorm(1 - (1 - ci_level) / 2)
    plot_df$Lower <- plot_df$Estimate - (z_score * plot_df$SE)
    plot_df$Upper <- plot_df$Estimate + (z_score * plot_df$SE)
    results$values <- plot_df
    
    # NEW: Calculate Broad-Sense Heritability (Reliability of BLUPs)
    # 1. Get Genotypic Variance (Vg) from model variance components
    var_comp <- as.data.frame(VarCorr(model))
    Vg <- var_comp$vcov[var_comp$grp == geno_var]
    
    # 2. Get Mean Prediction Error Variance (PEV)
    mean_PEV <- mean(blup_se^2)
    
    # 3. Calculate Heritability
    # If Vg is effectively 0 (singular model), set H2 to 0 to avoid errors
    H2 <- ifelse(Vg > 1e-8, 1 - (mean_PEV / Vg), 0)
    
    results$heritability <- H2
    message(sprintf("Generalized Heritability (Reliability): %.3f", H2))
    message(paste("BLUPs and", ci_percentage, "Prediction Intervals calculated."))
    
  } else if (method == "BLUE") {
    message("Running ANOVA for overall genotype significance...")
    results$anova <- anova(model)
    print(results$anova)
    
    message(paste("Calculating BLUEs (lsmeans) and", ci_percentage, "Confidence Intervals..."))
    blue_em <- emmeans::emmeans(model, specs = geno_var)
    plot_df <- as.data.frame(confint(blue_em, level = ci_level))
    
    colnames(plot_df)[which(colnames(plot_df) == geno_var)] <- "Genotype"
    colnames(plot_df)[which(colnames(plot_df) == "emmean")] <- "Estimate"
    colnames(plot_df)[which(colnames(plot_df) == "lower.CL")] <- "Lower"
    colnames(plot_df)[which(colnames(plot_df) == "upper.CL")] <- "Upper"
    
    results$values <- plot_df
  }
  
  # -------------------------------------------------------------------------
  # 4. VISUALIZATION
  # -------------------------------------------------------------------------
  if (plot) {
    plot_df$Genotype <- reorder(plot_df$Genotype, plot_df$Estimate)
    
    title_prefix <- ifelse(method == "BLUP", 
                           paste("BLUPs with", ci_percentage, "Prediction Intervals"), 
                           paste("BLUEs with", ci_percentage, "Confidence Intervals"))
    
    # Append heritability to the title if method is BLUP
    if (method == "BLUP") {
      title_prefix <- sprintf("%s\n(Heritability: %.2f)", title_prefix, results$heritability)
    }
    
    p <- ggplot(plot_df, aes(x = Genotype, y = Estimate)) +
      geom_point(color = "dodgerblue4", size = 2) +
      geom_errorbar(aes(ymin = Lower, ymax = Upper), width = 0.2, color = "dodgerblue4") +
      coord_flip() + 
      labs(title = title_prefix,
           x = "Genotype",
           y = paste("Estimated", y_var)) +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, face = "bold"))
    
    results$plot <- p
    print(p)
  }
  
  return(results)
}

# # Calculate BLUPs (Genotype as a random effect)
# blup_results <- calc_geno_values(method = "BLUP", ci_level = 0.5)
# head(blup_results$values)
# 
# # Calculate BLUEs (Genotype as a fixed effect)
# blue_results <- calc_geno_values(method = "BLUE", ci_level = 0.5)
# head(blue_results$values)
# 
# # Assuming your dataframe is called 'my_field_data'
# my_results <- calc_geno_values(
#   data = my_field_data,
#   y_var = "Plant_Height",
#   geno_var = "Variety",
#   loc_var = "Environment",
#   block_var = "Rep",
#   row_var = "Grid_Row",     # Omit if you don't have row data
#   col_var = "Grid_Column",  # Omit if you don't have column data
#   method = "BLUP"
# )
# 
# # View the extracted BLUPs
# head(my_results$values)