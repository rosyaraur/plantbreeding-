#' Analysis of North Carolina Design I
#'
#' Performs analysis of variance and estimates variance components for the 
#' North Carolina I mating design (Comstock and Robinson, 1952) using 
#' Expected Mean Squares (EMS).
#'
#' @param dataframe A dataframe consisting of the variables for set, male, female, 
#'   progeny, and replication, along with at least one numeric response variable.
#' @param set Character string specifying the name of the column containing the set variable.
#' @param male Character string specifying the name of the column containing the male variable.
#' @param female Character string specifying the name of the column containing the female variable.
#' @param progeny Character string specifying the name of the column containing the progeny/plant variable.
#' @param replication Character string specifying the name of the column containing the replication variable.
#' @param yvar Character string specifying the name of the response variable to be analyzed.
#'
#' @return A named list containing the following components:
#' \item{model}{The fitted \code{lm} object. Use \code{anova(model)} to see the full ANOVA table.}
#' \item{var.m}{Estimated male variance component.}
#' \item{var.f}{Estimated female variance component.}
#' \item{var.A}{Estimated additive genetic variance.}
#' \item{var.D}{Estimated dominance genetic variance.}
#'
#' @references 
#' Comstock R.E., Robinson H.F. (1952). Estimation of average dominance of genes. 
#' In Heterosis, Iowa State College Press, Ames, Iowa, Chapter 30.
#' 
#' Singh R.K., Chaudhary B.D. (1985) Biometrical Methods in Quantitative Genetic Analysis.
#' 
#' Mather K., Jinks J.L. (1971). Biometrical Genetics. Chapman & Hall, London.
#' 
#' Saxton A. (2004) Genetic Analysis of Complex Traits Using SAS. SAS Institute, Inc.
#'
#' @author Umesh R. Rosyara
#'
#' @examples
#' \dontrun{
#' data(northcaro1)
#' 
#' # Using general linear model to analyze yield
#' p1 <- carolina1(dataframe = northcaro1, 
#'                 set = "set", 
#'                 male = "male", 
#'                 female = "female", 
#'                 progeny = "progeny", 
#'                 replication = "replication", 
#'                 yvar = "yield")
#' 
#' print(p1)
#' anova(p1$model)
#' p1$var.A
#' }
#' 
#' @export
carolina1 <- function(dataframe, set, male, female, progeny, replication, yvar) {
  
  # Safely subset and rename columns 
  df <- dataframe[, c(set, male, female, replication, progeny, yvar)]
  names(df) <- c("set", "male", "female", "replication", "progeny", yvar)
  
  # Vectorized factor conversion
  factor_cols <- c("set", "male", "female", "replication", "progeny")
  df[factor_cols] <- lapply(df[factor_cols], as.factor)
  
  # Ensure the response variable is numeric
  df[[yvar]] <- as.numeric(df[[yvar]])
  
  # Calculate mean
  mean.y <- mean(df[[yvar]], na.rm = TRUE)
  
  # Construct formula robustly and run the linear model
  form_str <- paste(yvar, "~ set + replication:set + male:set + female:male:set + replication:female:male:set")
  model <- lm(as.formula(form_str), data = df)
  
  cat("North Carolina 1 Design Output for: ", yvar, "\n\n")
  anva <- anova(model)
  print(anva)
  
  # Cleaned up Coefficient of Variation (CV) calculation
  cv <- sqrt(sum(model$residuals^2) / model$df.residual) * 100 / mean(model$fitted.values)
  cat("\nCV:", round(cv, 3), "%\tMean:", round(mean.y, 4), "\n")
  
  # Extract level counts directly from the cleaned dataframe
  f <- length(levels(df$female))
  r <- length(levels(df$replication))
  n <- length(levels(df$progeny)) 
  
  # Extract Mean Squares and calculate variance components (EMS method)
  ms_male <- anva["set:male", "Mean Sq"]
  ms_fem  <- anva["set:male:female", "Mean Sq"]
  ms_err  <- anva["set:replication:male:female", "Mean Sq"]
  
  var.m <- (ms_male - ms_fem) / (f * r * n)
  var.f <- (ms_fem - ms_err) / (n * r)
  
  var.A <- 4 * var.m
  var.D <- 4 * var.f - 4 * var.m
  
  # Return a properly named list
  output <- list(
    model = model,
    var.m = var.m,
    var.f = var.f,
    var.A = var.A,
    var.D = var.D
  )
  
  return(output)
}