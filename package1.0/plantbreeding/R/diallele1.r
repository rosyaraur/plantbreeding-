#' Analysis of Diallel data
#'
#' Calculates general and specific combining ability and other estimates for 
#' Diallel mating design using Griffing's Method I (parents, F1s, and reciprocals) 
#' (Griffing, 1956). 
#'
#' @param dataframe A data.frame containing the diallel data.
#' @param yvar Character string representing the name of the trait/response variable.
#' @param progeny Character string representing the progeny/cross variable.
#' @param male Character string representing the male parent variable.
#' @param female Character string representing the female parent variable.
#' @param replication Character string representing the replication/block variable.
#' @param verbose Logical. If TRUE (default), prints ANOVA tables and components to the console.
#'
#' @return A list containing ANOVA tables, variance components, and effect matrices 
#'   for Model I (fixed) and Model II (random).
#' @author Umesh Rosyara (Refactored)
#' @references
#' Griffing, B. 1956. Concept of general and specific combining ability in relation to diallel crossing systems. Austr. J. Biol. Sci. 9, 463-493.
#' 
#' Singh R.K., Chaudhary B.D. (1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers
#' 
#' Mather K., Jinks J.L. (1971). Biometrical Genetics. Chapman & Hall, London.
#' @export
#' @examples
#' \dontrun{
#' data(fulldial) 
#' out <- diallele1(dataframe = fulldial, male = "MALE", female = "FEMALE",  
#'                  progeny = "TRT", replication = "REP", yvar = "YIELD")
#' print(out$anova.mod1)
#' }
diallele1 <- function(dataframe, yvar = "yvar", progeny = "progeny", 
                      male = "male", female = "female", 
                      replication = "replication", verbose = TRUE) {
  
  # 1. Input Validation and Data Preparation
  req_cols <- c(yvar, progeny, male, female, replication)
  if (!all(req_cols %in% colnames(dataframe))) {
    stop("One or more specified columns are not found in the dataframe.")
  }
  
  # Work on a clean subset to avoid modifying the global environment or large objects
  df <- dataframe[, req_cols]
  df[[progeny]]     <- as.factor(df[[progeny]])
  df[[male]]        <- as.factor(df[[male]])
  df[[female]]      <- as.factor(df[[female]])
  df[[replication]] <- as.factor(df[[replication]])
  df[[yvar]]        <- as.numeric(df[[yvar]])
  
  mean.y <- mean(df[[yvar]], na.rm = TRUE)
  
  # 2. Initial Analysis of Variance (Treatments)
  formula_str <- paste(yvar, "~", progeny, "+", replication)
  md1 <- lm(as.formula(formula_str), data = df)
  anvout <- anova(md1)
  
  if (verbose) {
    cat("Diallel analysis for trait:", yvar, "\n")
    cat("...........................\n\n")
    print(anvout)
    
    if (anvout["progeny", "Pr(>F)"] > 0.05) {
      cat("\nNote: Progeny effect is not significant at 0.05 p-threshold\n")
    } else if (anvout["progeny", "Pr(>F)"] > 0.01) {
      cat("\nNote: Progeny effect is not significant at 0.01 p-threshold\n")
    }
  }
  
  # 3. Create the Male x Female Matrix using tapply (More robust than aggregate 'c')
  # This creates a square matrix of means. tapply automatically sorts factors alphabetically, 
  # ensuring rows and columns align perfectly for matrix math.
  myMatrix <- tapply(df[[yvar]], list(df[[male]], df[[female]]), mean, na.rm = TRUE)
  
  if (nrow(myMatrix) != ncol(myMatrix)) {
    stop("The number of male and female parents do not match. Matrix is not square.")
  }
  
  n <- nrow(myMatrix) # number of parents
  
  # 4. Sums of Squares Calculations
  acon <- sum((1 / (2 * n)) * ((rowSums(myMatrix) + colSums(myMatrix))^2))
  ssgca <- acon - (2 / (n^2)) * (sum(myMatrix)^2)
  sssca <- sum((1 / 2) * (myMatrix * (myMatrix + t(myMatrix)))) - acon + (1 / (n^2)) * (sum(myMatrix)^2)
  ssrecp <- ((1 / 4) * sum((myMatrix - t(myMatrix))^2))
  
  r <- nlevels(df[[replication]])
  MSEAD <- anvout["Residuals", "Mean Sq"] / r
  
  # 5. Combining Ability ANOVA - Model I (Fixed)
  Df <- c((n - 1), (n * (n - 1) / 2), (n * (n - 1) / 2), anvout["Residuals", "Df"])
  SSS <- c(ssgca, sssca, ssrecp)
  ssq <- c(SSS, anvout["Residuals", "Sum Sq"] / r)
  
  MSSS <- SSS / Df[1:3]
  MSSS1 <- c(MSSS, MSEAD)
  FVAL <- c(MSSS1[1:3] / MSEAD, NA)
  pval <- c(1 - pf(FVAL[1:3], Df[1:3], Df[4]), NA) # Fixed Df indexing bug here
  
  anovadf.mod1 <- data.frame(Df, `Sum Sq` = ssq, `Mean Sq` = MSSS1, 
                             `F value` = FVAL, `Pr(>F)` = pval, 
                             check.names = FALSE)
  rownames(anovadf.mod1) <- c("GCA", "SCA", "Reciprocal", "Error")
  class(anovadf.mod1) <- c("anova", "data.frame")
  
  if (verbose) {
    cat("\nAnova for combining ability - Model I (Fixed)\n")
    print(anovadf.mod1)
  }
  
  # Genetic Components - Model I
  GCAcomp <- (MSSS[1] - MSEAD) / (2 * n)
  SCAcomp <- (MSSS[2] - MSEAD)
  RCAcomp <- (MSSS[3] - MSEAD) / 2
  GCARCAratio <- GCAcomp / SCAcomp
  
  components.model1 <- list(GCAcomp = GCAcomp, SCAcomp = SCAcomp, 
                            RCAcomp = RCAcomp, GCRCAratio = GCARCAratio)
  
  if (verbose) {
    cat("\nComponents: Model 1\n")
    cat("GCA :", GCAcomp, "\n")
    cat("SCA :", SCAcomp, "\n")
    cat("Reciprocal:", RCAcomp, "\n")
    cat("GCA to SCA ratio:", GCARCAratio, "\n") # Fixed typo in string "RCA" -> "SCA"
  }
  
  # 6. GCA, SCA, and Reciprocal Effects Matrices
  gcaeff <- ((1 / (2 * n)) * (rowSums(myMatrix) + colSums(myMatrix))) - ((1 / (n^2)) * (sum(myMatrix)))
  scaeff <- ((1 / 2) * (myMatrix + t(myMatrix))) - 
    ((1 / (2 * n)) * (rowSums(myMatrix) + colSums(myMatrix) + colSums(t(myMatrix)) + rowSums(t(myMatrix)))) + 
    ((1 / (n^2)) * (sum(myMatrix)))
  recieff <- 0.5 * (myMatrix - t(myMatrix))
  
  # Variances: standard error and critical differences
  varcompare <- list(
    var.gi = ((n - 1) / (2 * n^2)) * MSEAD,
    var.sii = (((n - 1)^2) / n^2) * MSEAD,
    var.sij = (1 / (2 * n^2)) * ((n^2) - 2 * n + 2) * MSEAD,
    var.rij = 0.5 * MSEAD,
    var.gi_gj = (1 / n) * MSEAD,
    var.sij_sji = ((2 * (n - 2)) / n) * MSEAD,
    var.sii_sij = ((3 * n - 2) / (2 * n)) * MSEAD,
    var.sii_sjk = ((3 * (n - 2)) / (2 * n)) * MSEAD,
    var.sij_sik = ((n - 1) / n) * MSEAD,
    var.sij_skl = ((n - 2) / n) * MSEAD,
    var.rij_rkl = MSEAD
  )
  
  # 7. Combining Ability ANOVA - Model II (Random)
  FVAL1 <- c(MSSS1[1] / MSSS1[2], MSSS1[2:3] / MSEAD, NA)
  pval1 <- c(1 - pf(FVAL1[1], Df[1], Df[2]), 1 - pf(FVAL1[2:3], Df[2:3], Df[4]), NA)
  
  anovadf.mod2 <- data.frame(Df, `Sum Sq` = ssq, `Mean Sq` = MSSS1, 
                             `F value` = FVAL1, `Pr(>F)` = pval1, 
                             check.names = FALSE)
  rownames(anovadf.mod2) <- c("GCA", "SCA", "Reciprocal", "Error")
  class(anovadf.mod2) <- c("anova", "data.frame")
  
  if (verbose) {
    cat("\nAnova for combining ability - Model II (Random)\n")
    print(anovadf.mod2)
  }
  
  # Genetic components estimates - Model II
  sigmasq.g <- (1 / (2 * n)) * (MSSS1[1] - (((MSEAD + n * (n - 1) * MSSS1[2])) / (n^2 - n + 1)))
  sigmasq.s <- ((n^2) / (2 * (n^2 - n + 1))) * (MSSS1[2] - MSEAD)
  sigmasq.r <- 0.5 * (MSSS1[3] - MSEAD)
  sigmasq.error <- MSEAD
  sigmasq.A <- 2 * sigmasq.g
  sigmasq.D <- sigmasq.s
  gca.scaratio <- sigmasq.g / sigmasq.s
  
  if (verbose) {
    cat("\nComponents: Model 2\n")
    cat("GCA (sigma^2 g) :", sigmasq.g, "\n")
    cat("SCA (sigma^2 s) :", sigmasq.s, "\n")
    cat("Reciprocal (sigma^2 r):", sigmasq.r, "\n")
    cat("GCA to SCA ratio:", gca.scaratio, "\n\n")
  }
  
  varcomp.model2 <- list(sigmasq.g = sigmasq.g, sigmasq.s = sigmasq.s, 
                         sigmasq.r = sigmasq.r, sigmasq.error = sigmasq.error,
                         sigmasq.A = sigmasq.A, sigmasq.D = sigmasq.D, 
                         gca.scaratio = gca.scaratio)
  
  # 8. Return comprehensive list
  results <- list(
    anvout = anvout, 
    anova.mod1 = anovadf.mod1,
    components.model1 = components.model1, 
    gca.effmat = gcaeff, 
    sca.effmat = scaeff,
    reciprocal.effmat = recieff, 
    varcompare = varcompare,
    anovadf.mod2 = anovadf.mod2,
    varcomp.model2 = varcomp.model2
  )
  
  # Assign a custom class for potential future method dispatch (e.g., plot(), summary())
  class(results) <- "diallel1"
  return(invisible(results))
}