\name{multloc}
\alias{multloc}
\docType{data}
\title{
Multi-location data 
}
\description{
The multi-location data from SAS for mixed model package 
}
\usage{data(multloc)}
\format{
  A data frame with 108 observations on the following 7 variables.
  \describe{
    \item{\code{obs}}{observations}
    \item{\code{Location}}{Locations: \code{A} \code{B} \code{C} \code{D} \code{E} \code{F} \code{G} \code{H} \code{I}}
    \item{\code{Block}}{Blocks: a factor with levels \code{1} \code{2} \code{3}}
    \item{\code{Trt}}{Treatments: a factor with levels \code{1} \code{2} \code{3} \code{4}}
    \item{\code{Adj}}{Adj: a numeric vector}
    \item{\code{Fe}}{Fe: a numeric vector}
    \item{\code{Grp}}{Groups}}
  }
\source{
Littel, R. C., Milliken, G. A., Stroup, W. W., and Wolfinger, R. D. (1996), SAS System for Mixed Models, SAS Institute (Data Set 2.8.1).
}
\references{
Gauch H.G.(1992). Statistical analysis of regional yield trials - AMMI analysis of factorial designs. Elsevier, Amsterdam.

Gauch H.G. (2006). Statistical analysis of yield trials by AMMI and GGE. Crop Sci. 46:1488-1500.

Gauch, H.G.,  Zobel.R.W. (1996). AMMI analysis of yield trials. p.85-122. In M.S. Kang and H.G. Gauch, Jr. (ed.) Genotype-byenvironment
interaction. CRC Press, Boca Raton, FL.

Eberhart S.A.,  Russell W.A. (1966) Stability parameters for comparing varieties. Crop Sci. 6: 36-40.

Singh R.K., Chaudhary B.D.(1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers

Kang M.S.,  Aggarwal V.D., Chirwa R.M.(2006) Adaptability and stability of bean 
cultivars as determined via yield-stability statistic and GGE biplot analysis. J. Crop Improv. 15:97-120

}
\examples{
# stability analysis 
data(multloc)
out <- stability (dataframe = multloc , yvar = "Adj", genotypes = "Trt",
 environments = "Location", replication =  "Block")
print(out)
# AMMI analysis 
results <- ammi.full(dataframe = multloc , environment = "Location", genotype = "Trt",
 replication = "Block", yvar = "Adj")
print(results)

}

