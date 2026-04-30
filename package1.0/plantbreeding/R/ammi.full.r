#' Additive Main Effects and Multiplicative Interaction (AMMI) analysis  
#'
#' \description{
#' The function implements Additive Main Effects and Multiplicative Interaction (AMMI) 
#' analysis for multiple environment replicated data. AMMI analysis (Gauch 1992) is 
#' one of the popular tools in GE analysis and is particularly effective for depicting 
#' adaptive responses. In this process, after genotype and environment main effects 
#' are fit in the model, the interaction is retained as a multiplicative term in the 
#' statistically significant GE-interaction principal-component (PC) axes. 
#' The results of AMMI can be visualized as a biplot (Gower and Hand 1996). 
#' }
#' 
#' @param dataframe dataframe object 
#' @param environment Name of environment (location or year) variable (string)
#' @param genotype Name of genotype variable (string)
#' @param replication Name of replication variable (string)
#' @param yvar Name of Y variable to be used in the analysis (string)
#' 
#' @references
#' Gauch H.G. (1992). Statistical analysis of regional yield trials: AMMI analysis of factorial designs. Elsevier, Amsterdam.
#' Gauch H.G. (2006). Statistical analysis of yield trials by AMMI and GGE. Crop Sci. 46:1488-1500.
#' Gower J.C., Hand D.J. (1996). Biplots. Monographs on Statistics and Applied Probability. London, UK: Chapman & Hall
#' 
#' @author Umesh Rosyara 
#' 
#' @examples
#' \dontrun{
#' data(multienv)
#' results <- ammi.full(dataframe = multienv, environment = "environments", 
#'                      genotype = "genotypes", replication = "replication", 
#'                      yvar = "yield")
#' print(results$analysis)
#' }
#' @export
ammi.full <- function(dataframe, environment, genotype, replication, yvar) {
  
  # 1. Standardize and clean input dataframe using list subsetting for safety
  df <- data.frame(
    environment = as.factor(dataframe[[environment]]),
    genotype    = as.factor(dataframe[[genotype]]),
    replication = as.factor(dataframe[[replication]]),
    Y           = dataframe[[yvar]]
  )
  
  cat("\nAMMI Analysis for variable: ", yvar, "\n")
  cat("........................................\n")
  
  nenv <- length(levels(df$environment))
  ngen <- length(levels(df$genotype))
  nrep <- length(levels(df$replication))
  minM <- min(ngen, nenv)
  
  # 2. Ordinary ANOVA Model
  # By ordering environment -> environment:replication -> genotype, 
  # aov outputs the table in the exact order needed without manual row swapping.
  model <- aov(Y ~ environment + environment:replication + genotype + environment:genotype, data = df)
  anmm  <- anova(model)
  
  # Rename the nested replication term for clarity
  row.names(anmm)[row.names(anmm) == "environment:replication"] <- "replication(environment)"
  
  # Custom F-test for Environment using replication(environment) as the error term
  anmm["environment", "F value"] <- anmm["environment", "Mean Sq"] / anmm["replication(environment)", "Mean Sq"]
  anmm["environment", "Pr(>F)"]  <- 1 - pf(anmm["environment", "F value"], 
                                           anmm["environment", "Df"], 
                                           anmm["replication(environment)", "Df"])
  print(anmm)
  
  DFE  <- df.residual(model)
  MSE  <- deviance(model) / DFE
  medy <- mean(df$Y, na.rm = TRUE)
  CV   <- sqrt(MSE) * 100 / medy
  errorlist <- list(DFE = DFE, MSE = MSE, mean_Y = medy, CV = CV)
  
  # 3. Calculate Means & Impute Missing Data
  avdm0 <- tapply(df$Y, list(df$genotype, df$environment), mean, na.rm = TRUE)
  cat("\nMeans for: ", yvar, "\n")
  print(round(avdm0, 2))
  
  # Base R equivalent of melt/reshape
  avdm <- as.data.frame(as.table(avdm0))
  names(avdm) <- c("genotype", "environment", "Y")
  
  # Vectorized missing value imputation
  if (any(is.na(avdm$Y))) {
    model2 <- lm(Y ~ genotype + environment, data = avdm)
    na_idx <- is.na(avdm$Y)
    avdm$Y[na_idx] <- predict(model2, newdata = avdm[na_idx, ])
  }
  
  # 4. Main effects model to extract GEI Residuals
  model1 <- lm(Y ~ environment + genotype, data = avdm)
  avdm$RESIDUAL <- model1$residuals
  
  # Reshape residuals directly into a matrix for SVD
  res_mat <- tapply(avdm$RESIDUAL, list(avdm$genotype, avdm$environment), sum)
  
  # 5. Singular Value Decomposition (SVD)
  sdc <- svd(res_mat)
  U <- sdc$u
  L <- sdc$d[1:minM]
  V <- sdc$v
  
  SS <- (L^2) * nrep
  a.sumsq <- sum(SS)
  percent <- round((SS / a.sumsq) * 100, 1)
  
  # 6. Build the AMMI PCA Table
  acum <- MSami <- F.ami <- f.prob <- DFami <- rep(0, minM)
  Acol1 <- 0
  
  for (i in 1:minM) {
    DF <- (ngen - 1) + (nenv - 1) - (2 * i - 1)
    if (DF <= 0) break
    
    DFami[i]  <- DF
    Acol1     <- Acol1 + percent[i]
    acum[i]   <- Acol1
    MSami[i]  <- SS[i] / DFami[i]
    F.ami[i]  <- round(MSami[i] / MSE, 2)
    f.prob[i] <- round(1 - pf(F.ami[i], DFami[i], DFE), 4)
  }
  
  ammi.ss <- data.frame(
    percent    = percent, 
    cumulative = acum, 
    Df         = DFami, 
    `Sum Sq`   = round(SS, 1),
    `Mean Sq`  = round(MSami, 1), 
    `F value`  = F.ami, 
    prob       = round(f.prob, 4),
    check.names = FALSE
  )
  
  # Keep only valid PCA axes
  ammi.ss <- ammi.ss[ammi.ss$Df > 0, ]
  nssammi <- nrow(ammi.ss)
  row.names(ammi.ss) <- paste0("PCA", 1:nssammi)
  
  cat("\nAMMI Analysis Results per PCA axis \n")
  print(ammi.ss)
  
  # 7. Calculate AMMI Scores for Biplots
  # diag() needs specific dimensions to prevent collapsing if nssammi == 1
  sql <- sqrt(diag(L[1:nssammi], nrow = nssammi, ncol = nssammi))
  
  regscr  <- U[, 1:nssammi, drop = FALSE] %*% sql
  scoree1 <- V[, 1:nssammi, drop = FALSE] %*% sql
  
  gen_means <- tapply(avdm$Y, avdm$genotype, mean)
  env_means <- tapply(avdm$Y, avdm$environment, mean)
  
  gen.m <- data.frame(category = "genotype", Y = gen_means, regscr)
  m.env <- data.frame(category = "environment", Y = env_means, scoree1)
  
  scrs.plot <- rbind(gen.m, m.env)
  colnames(scrs.plot)[3:ncol(scrs.plot)] <- paste0("PC", 1:nssammi)
  
  # 8. Return Compiled Output
  return(list(
    means_matrix = avdm0, 
    anova        = anmm, 
    errorlist    = errorlist, 
    gei_matrix   = res_mat, 
    analysis     = ammi.ss, 
    means_df     = avdm,
    pc_scrs      = scrs.plot, 
    percentAxis  = percent[1:nssammi], 
    sdc          = sdc
  ))
}