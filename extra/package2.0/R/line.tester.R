#' Line x Tester Analysis
#'
#' @description
#' The function performs line x tester analysis as outlined by Singh and Chaudhary (1985). 
#' It partitions the treatment sum of squares into parents, crosses, and parent vs. crosses, 
#' and further calculates General Combining Ability (GCA), Specific Combining Ability (SCA), 
#' and various genetic variance components.
#'
#' @param dataframe A data frame object containing the dataset.
#' @param yvar Character string for the name of the dependent/response variable (trait).
#' @param genotypes Character string for the name of the genotype variable.
#' @param replication Character string for the name of the replication variable.
#' @param Lines Character string for the name of the lines variable.
#' @param Testers Character string for the name of the testers variable.
#' @param gclass Character string for the name of the generation class variable (used to subset Parents, e.g., "P").
#'
#' @return A list containing the following components:
#' \itemize{
#'   \item \code{ANOVA}: Analysis of Variance (ANOVA) table for the Line x Tester design.
#'   \item \code{GC.Lines}: Data frame containing General Combining Ability (GCA) effects, standard errors, and SE differences for Lines.
#'   \item \code{GC.tester}: Data frame containing General Combining Ability (GCA) effects, standard errors, and SE differences for Testers.
#'   \item \code{SCA.mat}: Matrix of Specific Combining Ability (SCA) effects for Line x Tester crosses.
#'   \item \code{Covariance}: List of genetic components including covariance (Line, Tester, Average) and variance estimates (Additive, Dominance, SCA).
#'   \item \code{contribution}: List showing the proportional contribution (%) of lines, testers, and their interaction to the total sum of squares for crosses.
#' }
#'
#' @references
#' Singh, R.K., and Chaudhary, B.D. (1985). Biometrical Methods in Quantitative Genetics Analysis. Kalyani Publishers.
#'
#' @author Umesh R. Rosyara (Refactored and optimized)
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Assuming 'linetester' dataset is loaded in your environment
#' data(linetester)
#' 
#' pls <- line.tester(
#'   dataframe = linetester, 
#'   yvar = "trait1",  
#'   genotypes = "genotypes", 
#'   replication = "replication",  
#'   Lines = "Lines", 
#'   Testers = "Tester", 
#'   gclass = "gclass" 
#' )
#' 
#' print(pls)
#' }
line.tester <- function(dataframe, yvar, genotypes, replication, Lines, Testers, gclass) {
  
  # 1. Safely extract and rename required columns
  df <- dataframe[, c(yvar, genotypes, replication, Lines, Testers, gclass)]
  names(df) <- c("yvar", "genotypes", "replication", "Lines", "Tester", "gclass")
  
  # 2. Convert grouping variables to factors
  df$genotypes <- as.factor(df$genotypes)
  df$gclass <- as.factor(df$gclass)
  df$Lines <- as.factor(df$Lines)
  df$Tester <- as.factor(df$Tester)
  df$replication <- as.factor(df$replication)
  
  # Helper function to count non-NA values
  countN <- function(v) { 
    sum(!is.na(v)) - sum(is.na(v)) 
  }
  
  # 3. Base ANOVA for treatments
  md1 <- lm(yvar ~ genotypes + replication, data = df)
  anvout <- anova(md1)
  
  # Store core counts to keep formulas clean
  r <- nlevels(df$replication)
  l <- nlevels(df$Lines)
  t <- nlevels(df$Tester)
  
  # 4. Treatment sums of square partitioning
  # Crosses
  data1 <- aggregate(yvar ~ Lines + Tester, data = df, sum)
  CF1 <- sum(data1$yvar)^2 / (countN(data1$yvar) * r)
  sscross <- (sum((data1$yvar)^2) / r) - CF1
  
  # Parents
  data2 <- subset(df, gclass == "P")
  data3 <- aggregate(yvar ~ genotypes, data = data2, sum)
  CF2 <- sum(data3$yvar)^2 / (countN(data3$yvar) * r)
  ssparent <- (sum((data3$yvar)^2) / r) - CF2
  
  # Extract safely using row names instead of hardcoded indices
  SSTr <- anvout["genotypes", "Sum Sq"]
  sspr.css <- SSTr - ssparent - sscross
  
  # 5. Line x Tester analysis
  data4 <- aggregate(yvar ~ Lines, data = data1, sum)
  ssline <- (sum((data4$yvar)^2) / (r * t)) - CF1
  
  data5 <- aggregate(yvar ~ Tester, data = data1, sum)
  sstester <- (sum((data5$yvar)^2) / (r * l)) - CF1
  
  sslinXtest <- sscross - ssline - sstester
  
  # Degrees of freedom and Sum of Squares extraction
  repdf <- r - 1
  trtdf <- nlevels(df$genotypes) - 1
  parentdf <- (nrow(data2) / r) - 1
  prvscrdf <- 1
  crossdf <- trtdf - parentdf - prvscrdf
  Linedf <- l - 1
  Testerdf <- t - 1
  lintestdf <- Linedf * Testerdf
  
  errordf <- anvout["Residuals", "Df"]
  totaldf <- sum(anvout$Df)
  Df <- c(repdf, trtdf, parentdf, prvscrdf, crossdf, Linedf, Testerdf, lintestdf, errordf, totaldf)
  
  repssq <- anvout["replication", "Sum Sq"]
  trtssq <- anvout["genotypes", "Sum Sq"]
  errorsq <- anvout["Residuals", "Sum Sq"]
  
  ssq <- c(repssq, trtssq, ssparent, sspr.css, sscross, ssline, sstester, sslinXtest, errorsq)
  ssq <- c(ssq, sum(ssq))
  
  msq <- c(ssq[1:9] / Df[1:9], NA) 
  Fval <- c(msq[1:5] / msq[9], msq[6:7] / msq[8], msq[8] / msq[9], NA, NA)   
  pval <- c(1 - pf(Fval[1:5], Df[1:5], errordf), 
            1 - pf(Fval[6:7], Df[6:7], lintestdf), 
            1 - pf(Fval[8], Df[8], errordf), NA, NA)
  
  anovadf <- data.frame(Df, `Sum Sq` = ssq, `Mean Sq` = msq, `F value` = Fval, `Pr(>F)` = pval, check.names = FALSE)
  rownames(anovadf) <- c("replication", "treatments", "parents", "parents vs cross", "cross", "Lines", "tester", "line x tester", "error", "total") 
  class(anovadf) <- c("anova", "data.frame") 
  
  cat("Analysis of variance:", yvar, "\n\n")
  print(anovadf)
  
  # 6. Estimation of GCA effects
  cat("\nGeneral combining ability test:", yvar, "\n\nLines\n\n")  
  
  cfac <- sum(data4$yvar) / (r * t * l)
  gcavec <- (data4$yvar / (t * r)) - cfac
  data7 <- aggregate(yvar ~ Lines, data = df, mean)
  
  errgl <- sqrt(msq[9] / (t * r))
  errgldf <- sqrt(2 * msq[9] / (t * r))
  gcline <- data.frame(Lines = data4$Lines, mean = data7$yvar, gca = gcavec, `Standard error` = errgl, `SE difference` = errgldf, check.names = FALSE)
  print(gcline) 
  
  cat("\nTesters\n\n")   
  gcavect <- (data5$yvar / (l * r)) - cfac 
  data8 <- aggregate(yvar ~ Tester, data = df, mean)
  
  errglt <- sqrt(msq[9] / (l * r))
  errgltdf <- sqrt(2 * msq[9] / (l * r))
  gclinet <- data.frame(Testers = data5$Tester, mean = data8$yvar, gca = gcavect, `Standard error` = errglt, `SE difference` = errgltdf, check.names = FALSE)
  print(gclinet)
  
  # 7. Estimation of SCA effects (Corrected Matrix Math)
  cat("\nSCA matrix\n\n")  
  
  z1 <- tapply(data1$yvar, list(data1$Lines, data1$Tester), sum)
  
  mat_r <- z1 / r
  row_sub <- rowSums(z1) / (t * r)
  col_sub <- colSums(z1) / (l * r)
  grand_add <- sum(z1) / (l * t * r)
  
  scamat <- sweep(mat_r, 1, row_sub, "-")
  scamat <- sweep(scamat, 2, col_sub, "-")
  scamat <- scamat + grand_add
  
  print(scamat) 
  
  # 8. Genetic components
  CovHSline <- (msq[6] - msq[8]) / (t * r)   
  CovHStester <- (msq[7] - msq[8]) / (l * r)
  
  frac <- 1 / (r * ((2 * l * t) - l - t))
  fr2_avg <- ((l - 1) * msq[6]) + ((t - 1) * msq[7])
  CovHSavg <- frac * ((fr2_avg / (l + t - 2)) - msq[8]) 
  
  fr1_fs <- ((msq[6] - msq[9]) + (msq[7] - msq[9]) + (msq[8] - msq[9])) / (3 * r) 
  fr2_fs <- ((6 * r * CovHSavg) - (r * (l + t) * CovHSavg)) / (3 * r)  
  CovFS <- fr1_fs + fr2_fs
  
  VarAF0 <- CovHSavg / 0.25
  VarAF1 <- CovHSavg / 0.50
  
  VarSCA <- (msq[8] - msq[9]) / r
  varDF0 <- 4 * VarSCA
  varDF1 <- VarSCA   
  
  cat("\nGenetic components:\n\n")
  cat("Covariance (Line):", CovHSline, "\n")
  cat("Covariance (Tester):", CovHStester, "\n")
  cat("Covariance (Average):", CovHSavg, "\n")
  cat("Covariance (FS)/ variance GCA:", CovFS, "\n")
  cat("Additive variance with F = 0:", VarAF0, "\n")
  cat("Additive variance with F = 1:", VarAF1, "\n")  
  cat("Dominance variance with F = 0:", varDF0, "\n")
  cat("Dominance variance with F = 1:", varDF1, "\n") 
  cat("Variance (SCA):", VarSCA, "\n\n")
  
  covlist <- list(CovHSline = CovHSline, CovHStester = CovHStester, CovHSavg = CovHSavg, 
                  CovFS = CovFS, VarAF0 = VarAF0, varDF1 = varDF1)     
  
  # 9. Proportion of contribution
  contline <- (ssq[6] * 100) / ssq[5]
  conttester <- (ssq[7] * 100) / ssq[5]
  contlinextester <- (ssq[8] * 100) / ssq[5]
  
  cat("Proportion of contribution from lines, tester and lines x tester:\n\n")
  cat("Contribution from lines:", contline, "\n") 
  cat("Contribution from tester:", conttester, "\n") 
  cat("Contribution from line x tester:", contlinextester, "\n")
  
  contib <- list(lines = contline, testers = conttester, linextester = contlinextester) 
  results <- list(ANOVA = anovadf, GC.Lines = gcline, GC.tester = gclinet, SCA.mat = scamat, Covariance = covlist, contribution = contib)   
  
  invisible(results)   
}