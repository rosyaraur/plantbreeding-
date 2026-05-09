# Required libraries
if (!requireNamespace("lme4", quietly = TRUE)) install.packages("lme4")
library(lme4)

#' Genotype by Environment Interaction Analysis (Comstock & Robinson)
#'
#' @description
#' Performs stability analysis and partitions phenotypic variance. 
#' Supports both multi-year (GxLxY) and single-year (GxL) experimental designs.
#' Outputs variance components and individual effect estimates (BLUPs/BLUEs).
#'
#' @param data Data frame containing the phenotypic and experimental design data.
#' @param trait Character string for the trait column.
#' @param genotype Character string for the genotype column.
#' @param location Character string for the location column.
#' @param rep Character string for the replication column.
#' @param year Character string for the year column. Default is \code{NULL} for single-year analysis.
#' @param method "mixed" (REML) or "original" (ANOVA).
#'
#' @return A list containing Method, ANOVA_Table, Variance_Components, Heritability, and Effect_Estimates.
#' 
#' @importFrom lme4 lmer VarCorr ranef
#' @export
comstock_robinson_gxe <- function(data, trait, genotype, location, rep, year = NULL, method = c("mixed", "original")) {
  
  method <- match.arg(method)
  
  # Ensure core design variables are treated as factors
  data[[genotype]] <- as.factor(data[[genotype]])
  data[[location]] <- as.factor(data[[location]])
  data[[rep]]      <- as.factor(data[[rep]])
  
  g <- nlevels(data[[genotype]])
  l <- nlevels(data[[location]])
  r <- nlevels(data[[rep]])
  
  # Determine if analysis is multi-year or single-year
  is_multi_year <- !is.null(year)
  
  if (is_multi_year) {
    data[[year]] <- as.factor(data[[year]])
    y <- nlevels(data[[year]])
  } else {
    y <- 1 # Mathematically stabilizes denominators for single-year Vp calculation
  }
  
  # ==========================================
  # 1. ORIGINAL METHOD (ANOVA)
  # ==========================================
  if (method == "original") {
    if (is_multi_year) {
      formula_aov <- as.formula(paste(trait, "~", rep, "+", genotype, "+", location, "+", year, "+", 
                                      paste0(genotype, ":", location), "+",
                                      paste0(genotype, ":", year), "+",
                                      paste0(location, ":", year), "+",
                                      paste0(genotype, ":", location, ":", year)))
    } else {
      formula_aov <- as.formula(paste(trait, "~", rep, "+", genotype, "+", location, "+", 
                                      paste0(genotype, ":", location)))
    }
    
    model_aov <- aov(formula_aov, data = data)
    anova_table <- summary(model_aov)[[1]]
    rownames(anova_table) <- trimws(rownames(anova_table))
    
    ms_g  <- anova_table[genotype, "Mean Sq"]
    ms_l  <- anova_table[location, "Mean Sq"]
    ms_gl <- anova_table[paste0(genotype, ":", location), "Mean Sq"]
    ms_e  <- anova_table["Residuals", "Mean Sq"]
    
    effects_tables <- model.tables(model_aov, type = "effects")$tables
    effect_estimates <- list(
      G   = effects_tables[[genotype]],
      L   = effects_tables[[location]],
      GxL = effects_tables[[paste0(genotype, ":", location)]]
    )
    
    if (is_multi_year) {
      ms_y   <- anova_table[year, "Mean Sq"]
      ms_gy  <- anova_table[paste0(genotype, ":", year), "Mean Sq"]
      ms_ly  <- anova_table[paste0(location, ":", year), "Mean Sq"]
      ms_gly <- anova_table[paste0(genotype, ":", location, ":", year), "Mean Sq"]
      
      var_e   <- ms_e
      var_gly <- (ms_gly - ms_e) / r
      var_ly  <- (ms_ly - ms_gly) / (r * g)
      var_gy  <- (ms_gy - ms_gly) / (r * l)
      var_gl  <- (ms_gl - ms_gly) / (r * y)
      var_y   <- (ms_y - ms_gy - ms_ly + ms_gly) / (r * g * l)
      var_l   <- (ms_l - ms_gl - ms_ly + ms_gly) / (r * g * y)
      var_g   <- (ms_g - ms_gl - ms_gy - ms_gly) / (r * l * y)
      
      effect_estimates$Y <- effects_tables[[year]]
      effect_estimates$GxY <- effects_tables[[paste0(genotype, ":", year)]]
      effect_estimates$GxLxY <- effects_tables[[paste0(genotype, ":", location, ":", year)]]
      
    } else {
      # Single Year EMS Calculation
      var_e  <- ms_e
      var_gl <- (ms_gl - ms_e) / r
      var_l  <- (ms_l - ms_gl) / (r * g)
      var_g  <- (ms_g - ms_gl) / (r * l)
    }
    
    # ==========================================
    # 2. MIXED METHOD (REML)
    # ==========================================
  } else if (method == "mixed") {
    if (!requireNamespace("lme4", quietly = TRUE)) stop("Package 'lme4' is required.", call. = FALSE)
    
    if (is_multi_year) {
      formula_mixed <- as.formula(paste(trait, "~ 1 +",
                                        paste0("(1|", rep, ") +"),
                                        paste0("(1|", location, ") + (1|", year, ") + (1|", location, ":", year, ") +"),
                                        paste0("(1|", genotype, ") +"),
                                        paste0("(1|", genotype, ":", location, ") +"),
                                        paste0("(1|", genotype, ":", year, ") +"),
                                        paste0("(1|", genotype, ":", location, ":", year, ")")))
    } else {
      formula_mixed <- as.formula(paste(trait, "~ 1 +",
                                        paste0("(1|", rep, ") +"),
                                        paste0("(1|", location, ") +"),
                                        paste0("(1|", genotype, ") +"),
                                        paste0("(1|", genotype, ":", location, ")")))
    }
    
    model_mixed <- lme4::lmer(formula_mixed, data = data)
    var_comps <- as.data.frame(lme4::VarCorr(model_mixed))
    blups <- lme4::ranef(model_mixed)
    
    get_var <- function(group_name) {
      val <- var_comps$vcov[var_comps$grp == group_name]
      if(length(val) == 0) return(0) else return(val)
    }
    
    var_g  <- get_var(genotype)
    var_l  <- get_var(location)
    var_gl <- get_var(paste0(genotype, ":", location))
    var_e  <- get_var("Residual")
    anova_table <- "ANOVA table omitted for REML Mixed Models."
    
    effect_estimates <- list(
      G   = blups[[genotype]],
      L   = blups[[location]],
      GxL = blups[[paste0(genotype, ":", location)]]
    )
    
    if (is_multi_year) {
      var_y   <- get_var(year)
      var_gy  <- get_var(paste0(genotype, ":", year))
      var_ly  <- get_var(paste0(location, ":", year))
      var_gly <- get_var(paste0(genotype, ":", location, ":", year))
      
      effect_estimates$Y <- blups[[year]]
      effect_estimates$GxY <- blups[[paste0(genotype, ":", year)]]
      effect_estimates$GxLxY <- blups[[paste0(genotype, ":", location, ":", year)]]
    }
  }
  
  # ==========================================
  # 3. SHARED CALCULATIONS & OUTPUT
  # ==========================================
  
  if (is_multi_year) {
    var_p <- var_g + (var_gl / l) + (var_gy / y) + (var_gly / (l * y)) + (var_e / (l * y * r))
    var_table <- data.frame(
      Component = c("Genotypic (Vg)", "Location (Vl)", "Year (Vy)", "G x L (Vgl)", "G x Y (Vgy)", "L x Y (Vly)", "G x L x Y (Vgly)", "Error (Ve)", "Phenotypic (Vp)"),
      Estimate = round(c(var_g, var_l, var_y, var_gl, var_gy, var_ly, var_gly, var_e, var_p), 4)
    )
  } else {
    # Single Year Phenotypic Variance Formula
    var_p <- var_g + (var_gl / l) + (var_e / (l * r))
    var_table <- data.frame(
      Component = c("Genotypic (Vg)", "Location (Vl)", "G x L (Vgl)", "Error (Ve)", "Phenotypic (Vp)"),
      Estimate = round(c(var_g, var_l, var_gl, var_e, var_p), 4)
    )
  }
  
  h2_bs <- var_g / var_p
  
  results <- list(
    Method = toupper(method),
    Analysis_Type = ifelse(is_multi_year, "Multi-Year (GxLxY)", "Single-Year (GxL)"),
    ANOVA_Table = anova_table,
    Variance_Components = var_table,
    Heritability = h2_bs,
    Effect_Estimates = effect_estimates
  )
  
  return(results)
}

# wheat_yield_data <- data.frame(
#   Genotype = rep(c("A", "B", "C", "D", "E", "F", "G"), each = 18),
#   Location = rep(rep(c("L1", "L2", "L3"), each = 6), times = 7),
#   Year     = rep(rep(c("Y1", "Y2"), each = 3), times = 21),
#   Rep      = rep(c("R1", "R2", "R3"), times = 42),
#   Yield    = c(
#     # Genotype A
#     60, 65, 60, 80, 65, 75, 70, 75, 70, 72, 82, 90, 48, 45, 50, 50, 40, 40,
#     # Genotype B
#     80, 90, 83, 70, 60, 60, 85, 90, 90, 70, 85, 80, 40, 40, 40, 38, 40, 50,
#     # Genotype C
#     25, 28, 30, 40, 35, 35, 35, 30, 30, 40, 35, 35, 35, 25, 20, 35, 30, 30,
#     # Genotype D
#     50, 65, 50, 40, 40, 40, 48, 50, 52, 45, 45, 50, 50, 50, 45, 40, 48, 40,
#     # Genotype E
#     52, 50, 55, 55, 54, 50, 40, 40, 60, 48, 38, 45, 38, 30, 40, 35, 40, 35,
#     # Genotype F
#     22, 25, 25, 30, 28, 32, 28, 25, 30, 26, 28, 28, 45, 50, 45, 50, 50, 50,
#     # Genotype G
#     30, 30, 25, 28, 34, 35, 40, 45, 35, 30, 32, 35, 45, 35, 38, 44, 45, 40
#   )
# )
# 
# # 4. Run the Analyses
# cat("\n--- Running Original Textbook Approach (ANOVA) ---\n")
# results_original <- comstock_robinson_gxe(wheat_yield_data, "Yield", "Genotype", "Location", "Year", "Rep", method = "original")
# print(results_original$Variance_Components)
# results_original$Method
# cat("Heritability (H2):", results_original$Heritability, "\n")
# # View the Genotype effects
# print(results_original$Effect_Estimates$G)
# # View the Genotype by Location interaction effects
# print(results_original$Effect_Estimates$GxL)
# 
# cat("\n--- Running Modern Mixed Model Approach (REML) ---\n")
# results_mixed <- comstock_robinson_gxe(wheat_yield_data, "Yield", "Genotype", "Location", "Year", "Rep", method = "mixed")
# print(results_mixed$Variance_Components)
# print(results_mixed$Variance_Components$Component)
# results_mixed$Method
# print(results_mixed$Effect_Estimates$G)
# # View the Genotype by Location interaction effects
# print(results_mixed$Effect_Estimates$GxL)
# cat("Heritability (H2):", results_mixed$Heritability, "\n")
# 
