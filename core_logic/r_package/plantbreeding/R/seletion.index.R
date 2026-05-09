#' @title Calculate Selection Index
#' 
#' @description 
#' The function illustrates the development of the selection index outlined by Smith (1936) 
#' and further described in Singh and Chaudhary (1985).
#'
#' @param phenodf A phenotypic data frame. The first column is assumed to be identifiers (e.g., parents) and is excluded from calculations.
#' @param pcovmat Phenotypic covariance matrix (\code{X}).
#' @param gcovmat Genotypic covariance matrix (\code{G}).
#' @param ecovmat Economic weight matrix or vector (\code{A}).
#' @param exout Logical. Included for backward compatibility; determines if outliers are excluded (currently inactive). Default is \code{TRUE}.
#' @param selectint Numeric. The proportion of the population to be selected. Default is \code{0.01} (1% selection intensity).
#' @param verbose Logical. If \code{TRUE}, prints intermediate equations and matrices to the console. Default is \code{TRUE}.
#'
#' @return A list containing the following components:
#' \itemize{
#'   \item \code{bis}: A data frame of the calculated selection index coefficients.
#'   \item \code{pmat}: The phenotypic matrix used in calculations (excluding the ID column).
#'   \item \code{selectdf}: The original phenotypic data frame appended with the calculated selection criterion.
#'   \item \code{exp.ggain}: The expected genetic gain.
#' }
#' 
#' @references 
#' Singh R.K., Chaudhary B.D. (1985). Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers.
#' 
#' Hill J., Becker H.C., Tigerstedt P.M.A. (1998). Quantitative and Ecological Aspects of Plant Breeding, Springer, 275 pages.
#' 
#' Lynch M., Walsh B. (1998). Genetics and Analysis of Quantitative Traits. Sinauer, Sunderland, MA.
#'
#' @examples
#' \dontrun{
#' #' # The selindex data can be reconstructed using the following code:
#' X <- matrix(c(44.412,  0.238,  0.027,  93.128,
#'                0.238,  0.427, -0.193,   0.673,
#'               -0.027, -0.193,  0.094,  -0.428,
#'               93.128,  0.673, -0.428, 224.099), 
#'             nrow = 4, byrow = TRUE)
#' 
#' G <- matrix(c(33.575,  0.080, -0.006,  68.123,
#'                0.080,  0.238, -0.033,   0.468,
#'               -0.006, -0.033,  0.084,  -0.764,
#'               68.123,  0.468, -0.764, 205.144), 
#'             nrow = 4, byrow = TRUE)
#'             
#' A <- matrix(c(1, 1, 1, 1), nrow = 4)
#' 
#' phenodf <- data.frame(
#'   parents = paste0("IND", 1:8),
#'   trait1  = c(41.90, 42.80, 37.30, 41.15, 32.50, 52.75, 34.90, 46.75),
#'   trait2  = c(20.30, 19.95, 18.73, 20.30, 20.25, 19.73, 20.23, 20.03),
#'   trait3  = c(3.90, 3.65, 4.60, 4.30, 4.10, 4.38, 4.28, 4.15),
#'   trait4  = c(85.68, 98.25, 74.58, 91.63, 54.13, 100.38, 90.98, 82.03)
#' )
#' 
#' selindex <- list(X = X, G = G, A = A, phenodf = phenodf)
#' data(selindex)
#' p <- selection.index(phenodf = selindex$phenodf, 
#'                      pcovmat = selindex$X, 
#'                      gcovmat = selindex$G, 
#'                      ecovmat = selindex$A)
#' print(p)
#' }
#' @export
selection.index <- function(phenodf, pcovmat, gcovmat, ecovmat, exout = TRUE,
                            selectint = 0.01, verbose = TRUE) {
  
  # Calculate selection intensity (zv) dynamically based on the normal distribution
  # Note: A selectint of 0.10 yields ~1.76. 
  zv <- dnorm(qnorm(1 - selectint)) / selectint
  
  # Calculate index coefficients (b)
  bmat <- solve(pcovmat) %*% gcovmat %*% ecovmat
  
  # Format b values into a data frame
  bdatf <- data.frame(traits = names(phenodf)[-1], bi = as.vector(bmat))
  
  if (verbose) {
    cat("b values for selection index equations\n\n")
    print(bdatf)
    cat("\n")
  }
  
  # Extract phenotypic matrix (ignoring the first ID column)
  pmat <- as.matrix(phenodf[, -1])
  
  if (verbose) {
    cat("Phenotypic matrix\n\n")
    print(pmat)
    cat("\n")
  }
  
  # Calculate selection criteria
  selcriterion <- pmat %*% bmat
  selectdf <- data.frame(phenodf, selcriterion = as.vector(selcriterion))
  
  if (verbose) {
    cat("Phenotypic values and selection criterion\n\n")
    print(selectdf)
    cat("\n")
  }
  
  # Expected genetic gain
  W1 <- matrix(gcovmat %*% bmat, nrow = 1)
  W <- sum(W1 %*% ecovmat)
  
  bmatj <- matrix(bmat, nrow = 1)
  VP1 <- bmatj %*% pcovmat
  VP <- VP1 %*% bmat
  
  # Calculate final expected gain
  dgain <- as.numeric((zv * W) / sqrt(VP))
  
  if (verbose) {
    cat("Expected genetic gain :", dgain, "\n\n")
  }
  
  return(list(
    bis = bdatf, 
    pmat = pmat, 
    selectdf = selectdf, 
    exp.ggain = dgain
  ))
}
