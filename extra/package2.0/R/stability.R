#' Stability analysis based on Eberhart and Russell (1966) model  
#'
#' @description
#' This function implements the Eberhart and Russell (1966) model for Genotype 
#' by Environment (GxE) stability analysis. It calculates the regression coefficient 
#' (bij) and the deviation from regression (sdij) to identify stable genotypes 
#' across multiple environments.
#'
#' @param dataframe A data frame containing the phenotypic data.
#' @param yvar A character string specifying the name of the response variable (trait).
#' @param genotypes A character string specifying the name of the genotype column.
#' @param environments A character string specifying the name of the environment column.
#' @param replication A character string specifying the name of the replication column.
#' @param verbose Logical. If \code{TRUE} (default), prints the ANOVA tables, 
#'   stability scores, and generates diagnostic plots to the active graphics device. 
#'   Set to \code{FALSE} to run silently and only return the results list.
#'
#' @return An invisible list containing the following components:
#' \itemize{
#'   \item \code{ANOVA}: A data frame containing the full stability ANOVA table.
#'   \item \code{Means}: A matrix of genotype-by-environment means.
#'   \item \code{scores}: A data frame of stability parameters (bij and sdij) for each genotype.
#'   \item \code{devtab}: A data frame containing deviations and regression table components.
#'   \item \code{plot_data}: A data frame used for generating the stability index plot.
#' }
#' 
#' @references
#' Eberhart S.A., Russell W.A. (1966) Stability parameters for comparing varieties. Crop Sci. 6: 36-40.
#' 
#' Singh R.K., Chaudhary B.D. (1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers.
#' 
#' @author Umesh R Rosyara (Original)
#'
#' @examples
#' \dontrun{
#' yvar <- c(36.4, 40.0, 32.4, 33.5, 41.3, 27.9, 38.5, 38.6, 41.6, 22.6,
#'           41.3, 38.9, 30.9, 40.1, 43.6, 36.3, 43.0, 29.6, 34.4, 35.1,
#'           51.7, 37.1, 25.5, 47.4, 39.5, 36.1, 40.6, 28.6, 32.8, 33.0,
#'           22.6, 42.6, 52.8, 20.3, 38.3, 39.4, 36.5, 31.7, 22.8, 33.2,
#'           39.4, 28.2, 45.8, 28.6, 35.4, 36.5, 37.4, 21.0, 25.4, 28.3,
#'           30.2, 29.5, 32.9, 29.5, 47.6, 40.3, 30.8, 30.1, 34.5, 35.8,
#'           21.8, 27.1, 28.6, 25.5, 28.5, 24.5, 27.1, 25.4, 22.4, 32.4,
#'           26.4, 27.7, 36.8, 21.5, 29.6, 31.5, 25.8, 17.3, 24.3, 24.3,
#'           22.6, 17.7, 35.5, 32.8, 25.8, 28.8, 28.0, 24.8, 26.7, 29.8,
#'           31.2, 20.2, 28.0, 21.3, 36.9, 41.2, 27.9, 20.6, 20.9, 20.8,
#'           25.4, 29.7, 26.3, 33.7, 29.8, 27.3, 25.9, 25.3, 30.2, 17.8,
#'           23.7, 23.9, 32.2, 34.7, 30.6, 28.3, 27.2, 23.9, 23.8, 15.0,
#'           24.3, 28.2, 20.3, 32.3, 18.5, 28.1, 22.0, 30.7, 32.4, 26.1,
#'           34.3, 30.2, 25.6, 28.1, 29.2, 40.1, 28.2, 27.7, 37.0, 32.4, 
#'           36.5, 30.1, 35.1, 28.2, 34.5, 42.1, 38.7, 15.1, 25.4, 38.7)
#' 
#' replication <- rep(c(rep(1, 10), rep(2,10), rep(3,10)), 5)
#' genotypes <- rep(paste("G", 1:10, sep= ""), 15)
#' environments <- rep(c("CB","CA", "CC", "MN","SD"), each = 30)
#' mydf1 <- data.frame(yvar, replication, genotypes, environments)
#' 
#' # Run the stability analysis
#' out <- stability(dataframe = mydf1, yvar = "yvar", genotypes = "genotypes", 
#'                  environments = "environments", replication = "replication")
#' }
#' 
#' @export
stability <- function(dataframe, yvar, genotypes, environments, replication, verbose = TRUE) {
  
  # 1. Safely extract and format data
  df <- data.frame(
    yvar = dataframe[[yvar]],
    genotypes = as.factor(dataframe[[genotypes]]),
    environments = as.factor(dataframe[[environments]]),
    replication = as.factor(dataframe[[replication]])
  )
  
  # 2. Raw Data Wireframe Plot (Store rather than force print)
  if (!requireNamespace("lattice", quietly = TRUE)) {
    warning("Package 'lattice' is required for the wireframe plot. Please install it.")
    wfd <- NULL
  } else {
    wfd <- lattice::wireframe(yvar ~ genotypes + environments, data = df, 
                              scales = list(arrows = FALSE), col = "green4", drape = TRUE)
  }
  
  # 3. Base Models
  model1 <- lm(yvar ~ genotypes + environments + environments:replication + environments:genotypes, data = df)
  modav <- anova(model1)
  
  # 4. Aggregations and Matrix Setup
  mydf <- aggregate(yvar ~ genotypes + environments, data = df, FUN = mean)
  matx_wide <- tapply(mydf$yvar, list(mydf$genotypes, mydf$environments), mean)
  
  # 5. Eberhart & Russell Parameters
  gradyt <- mean(matx_wide)
  iij <- apply(matx_wide, 2, mean) - gradyt # Environmental index
  sqiij <- sum(iij^2)
  
  YiIj <- matx_wide %*% iij
  bij <- YiIj / sqiij # Regression coefficient (stability parameter)
  
  svar <- apply(matx_wide^2, 1, sum) - ((apply(matx_wide, 1, sum)^2) / ncol(matx_wide))
  bYijIj <- bij * YiIj
  deltaij <- svar - bYijIj
  
  devtab <- data.frame(genotypes = rownames(matx_wide), svar = svar, bij = bij, 
                       YiIj = YiIj, bYijIj = bYijIj, deltaij = deltaij)
  
  # 6. Variances
  S2e <- modav$`Mean Sq`[5] 
  rps <- length(levels(df$replication))  # number of reps
  en <- length(levels(df$environments))  # number of locations / environments
  ge <- length(levels(df$genotypes))     # number of genotypes
  
  S2di <- (deltaij / (en - 2)) - (S2e / rps) # Deviation from regression
  
  # 7. ANOVA for Mean Data 
  model2 <- lm(yvar ~ genotypes + environments, data = mydf)
  amod2 <- anova(model2)
  
  # Sum of squares
  SSL <- amod2$`Sum Sq`[2]
  SSGxL <- amod2$`Sum Sq`[3]
  SSL.Linear <- (1 / ge) * (colSums(matx_wide) %*% iij)^2 / sum(iij^2) 
  SS.L.GxL.linear <- sum(bYijIj) - SSL.Linear 
  
  # 8. Consolidate Final ANOVA Table
  Df <- c(en*ge - 1, ge - 1, ge*(en - 1), 1, ge - 1, ge*(en - 2), rep(en - 2, length(deltaij)), en*ge*(rps - 1)) 
  poolerr <- modav$`Sum Sq`[5] / rps 
  SSS <- c(sum(amod2$`Sum Sq`), amod2$`Sum Sq`[1], SSL + SSGxL, SSL.Linear, SS.L.GxL.linear, sum(deltaij), deltaij, poolerr)
  MSSS <- SSS / Df
  
  FVAL <- c(NA, MSSS[2]/MSSS[6], NA, NA, MSSS[5]/MSSS[6], NA, MSSS[7:(length(MSSS)-1)]/MSSS[length(MSSS)], NA)
  PLINES <- 1 - pf(FVAL[7:(length(MSSS)-1)], Df[7], Df[length(Df)])
  pval <- c(NA, 1 - pf(FVAL[2], Df[2], Df[6]), NA, NA, 1 - pf(FVAL[5], Df[5], Df[6]), NA, PLINES, NA)
  
  anovadf <- data.frame(Df, `Sum Sq` = SSS, `Mean Sq` = MSSS, `F value` = FVAL, `Pr(>F)` = pval, check.names = FALSE)
  rownames(anovadf) <- c("Total", "Genotypes", "Env + (Gen x Env)", "Env (linear)", "Gen x Env(linear)", 
                         "Pooled deviation", rownames(matx_wide), "Pooled error") 
  class(anovadf) <- c("anova", "data.frame")
  
  # 9. Output Formatting & Plotting
  outdat <- data.frame(genotypes = devtab$genotypes, bij = devtab$bij, sdij = S2di)
  plotst <- data.frame(mydf, envindex = rep(iij, each = ge))
  
  if (verbose) {
    cat("========================================================\n")
    cat("Anova for stability analysis:", yvar, "\n")
    cat("========================================================\n")
    print(anovadf)
    
    cat("\nEberhart and Russell Model of stability (Crop Science 1966, 6:37-40)\n\n")
    print(outdat)
    cat("\n* Note: A perfectly stable genotype has bij = 1 and sdij = 0\n\n")
    
    # Print the lattice wireframe
    if (!is.null(wfd)) print(wfd)
    
    # Generate the stability scatter plot
    plot(plotst$yvar, plotst$envindex, xlab = "Trait Mean", ylab = "Stability Index", 
         pch = 16, col = "blue", main = paste("Stability Plot:", yvar))
    text(plotst$yvar, plotst$envindex, labels = plotst$genotypes, pos = 3, cex = 0.75)
  }
  
  # Return a structured list of results silently
  results <- list(ANOVA = anovadf, Means = matx_wide, scores = outdat, devtab = devtab, plot_data = plotst)   
  invisible(results) 
}