gencor.lm <- function(dataframe, yvar1, yvar2, genovar, replication, exout = FALSE) {
  
  # 1. Safely extract data into a clean, internal dataframe
  # Using [[ ]] allows inputs to be either strings ("colname") or integer indices
  df <- data.frame(
    y1 = dataframe[[yvar1]],
    y2 = dataframe[[yvar2]],
    geno = as.factor(dataframe[[genovar]]),
    rep = as.factor(dataframe[[replication]])
  )
  
  # 2. Fit models
  # CRITICAL FIX: I(y1 + y2) forces R to mathematically sum the variables before regression.
  # Without I(), R treats the '+' as a formula operator, not an arithmetic sum.
  mod1 <- lm(y1 ~ geno + rep, data = df)
  mod2 <- lm(y2 ~ geno + rep, data = df)
  mod3 <- lm(I(y1 + y2) ~ geno + rep, data = df)
  
  # 3. Cache ANOVA tables (Massive performance boost)
  aov1 <- anova(mod1)
  aov2 <- anova(mod2)
  aov3 <- anova(mod3)
  
  # Divisor is the number of replications (Replication Df + 1)
  r_divisor <- aov1$Df[2] + 1
  
  # 4. Variance components (Mean Sq: 1=Genotype, 2=Replication, 3=Residuals)
  g2gw <- (aov1$"Mean Sq"[1] - aov1$"Mean Sq"[3]) / r_divisor
  
  # CRITICAL FIX: Your original code used anova(mod1) here instead of mod2
  g2tg <- (aov2$"Mean Sq"[1] - aov2$"Mean Sq"[3]) / r_divisor
  
  # 5. Covariance components [ Cov(X,Y) = (Var(X+Y) - Var(X) - Var(Y)) / 2 ]
  cvtg.gy  <- (aov3$"Mean Sq"[1] - aov2$"Mean Sq"[1] - aov1$"Mean Sq"[1]) / 2
  ecvtg.gy <- (aov3$"Mean Sq"[3] - aov2$"Mean Sq"[3] - aov1$"Mean Sq"[3]) / 2
  
  # CRITICAL FIX: The original code divided by Df[3] + 1 (Residual Df). 
  # It should be divided by the number of replications (r_divisor), just like the variances.
  g2ecvtg.gy <- (cvtg.gy - ecvtg.gy) / r_divisor
  
  # 6. Final calculations
  cohert <- g2ecvtg.gy / (g2ecvtg.gy + ecvtg.gy) 
  genetic.corr <- g2ecvtg.gy / sqrt(g2gw * g2tg)
  
  # 7. Output handling
  if (!exout) {
    return(genetic.corr)
  } else {
    # Resolve actual column names for printing
    name.y1 <- if (is.numeric(yvar1)) colnames(dataframe)[yvar1] else yvar1
    name.y2 <- if (is.numeric(yvar2)) colnames(dataframe)[yvar2] else yvar2
    
    cat("Analysis of variance:", name.y1, "\n\n")
    print(aov1)
    
    cat("Analysis of variance:", name.y2, "\n\n")
    print(aov2)
    
    cat("Analysis of co-variance: (", name.y1, "+", name.y2, ")\n\n")
    print(aov3)
    
    cat("Genetic correlation between", name.y1, "and", name.y2, ":\n\n")
    print(genetic.corr)
    
    # Returning cohert since it was calculated but abandoned in the original code
    results <- list(
      genetic.corr = genetic.corr, 
      coherence = cohert,
      modelV1 = mod1, 
      modelV2 = mod2, 
      modelV1V2 = mod3
    )
    return(results)
  }
}


# # Load MASS for simulating correlated multivariate normal variables
# if (!require(MASS)) install.packages("MASS")
# library(MASS)
# 
# # ==========================================
# # 2. SIMULATE THE DATA
# # ==========================================
# set.seed(123) # Set seed for reproducibility
# 
# # Simulation Parameters
# n_geno <- 60  # Number of genotypes/lines
# n_rep  <- 4   # Number of replications/blocks
# 
# # Define the TRUE variances and the TRUE genetic correlation we want to test
# var_g1 <- 10.0   # True genetic variance for Trait 1
# var_g2 <- 15.0   # True genetic variance for Trait 2
# true_rg <- 0.70  # The TRUE genetic correlation (Our Target)
# 
# # Calculate covariance based on the formula: Cov = r * sqrt(Var1 * Var2)
# cov_g <- true_rg * sqrt(var_g1 * var_g2)
# 
# # Create the variance-covariance matrix for genotypes
# Sigma_G <- matrix(c(var_g1, cov_g, 
#                     cov_g, var_g2), 
#                   nrow = 2, ncol = 2)
# 
# # Simulate true genetic values for the 60 genotypes based on the matrix
# geno_effects <- mvrnorm(n = n_geno, mu = c(0, 0), Sigma = Sigma_G)
# 
# # Build the base experimental design (Grid of genotypes x replications)
# sim_data <- expand.grid(genovar = 1:n_geno, replication = 1:n_rep)
# 
# # Map the simulated true genetic effects to the specific rows
# sim_data$G1 <- geno_effects[sim_data$genovar, 1]
# sim_data$G2 <- geno_effects[sim_data$genovar, 2]
# 
# # Add random replication/block effects
# rep_eff_1 <- rnorm(n_rep, mean = 0, sd = 2)
# rep_eff_2 <- rnorm(n_rep, mean = 0, sd = 3)
# sim_data$R1 <- rep_eff_1[sim_data$replication]
# sim_data$R2 <- rep_eff_2[sim_data$replication]
# 
# # Add random residual/environmental noise
# sim_data$E1 <- rnorm(nrow(sim_data), mean = 0, sd = sqrt(5))
# sim_data$E2 <- rnorm(nrow(sim_data), mean = 0, sd = sqrt(6))
# 
# # Calculate final phenotypic traits (Y = Intercept + Genotype + Replication + Error)
# sim_data$Trait_A <- 50  + sim_data$G1 + sim_data$R1 + sim_data$E1
# sim_data$Trait_B <- 100 + sim_data$G2 + sim_data$R2 + sim_data$E2
# 
# # ==========================================
# # 3. TEST THE FUNCTION
# # ==========================================
# cat("Running Test...\n")
# results <- gencor.lm(dataframe = sim_data, 
#                      yvar1 = "Trait_A", 
#                      yvar2 = "Trait_B", 
#                      genovar = "genovar", 
#                      replication = "replication", 
#                      exout = TRUE)
# 
# cat("\n=== SIMULATION RESULTS ===\n")
# cat("Target (True) Genetic Correlation: ", true_rg, "\n")
# cat("Estimated Genetic Correlation:     ", round(results$genetic.corr, 4), "\n")