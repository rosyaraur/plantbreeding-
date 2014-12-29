\name{multienv}
\alias{multienv}
\docType{data}
\title{
Multi- evironment data 
}
\description{
Simulated Multi- evironment data for stability and Additive Main Effects and Multiplicative Interaction (AMMI) analysis.
}
\usage{data(multienv)}
\format{
  A data frame with 150 observations on the following 4 variables.
  \describe{
    \item{\code{yield}}{yield - Y variable}
    \item{\code{replication}}{replication}
    \item{\code{genotypes}}{genotype: \code{G1} \code{G10} \code{G2} \code{G3} \code{G4} \code{G5} \code{G6} \code{G7} \code{G8} \code{G9}}
    \item{\code{environments}}{environments: \code{CA} \code{CB} \code{CC} \code{MN} \code{SD}}
  }
}
\references{
Gauch H.G.(1992). Statistical analysis of regional yield trials:AMMI analysis of factorial designs. Elsevier, Amsterdam.

Gauch H.G. (2006). Statistical analysis of yield trials by AMMI and GGE. Crop Sci. 46:1488-1500.

Gauch, H.G.,  Zobel.R.W. (1996). AMMI analysis of yield trials. p.85-122. In M.S. Kang and H.G. Gauch, Jr. (ed.) 
Genotype x byenvironment interaction. CRC Press, Boca Raton, FL.

Eberhart S.A.,  Russell W.A. (1966) Stability parameters for comparing varieties. Crop Sci. 6: 36-40.

Singh R.K., Chaudhary B.D.(1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers

Kang M.S.,  Aggarwal V.D., Chirwa R.M.(2006) Adaptability and stability of bean cultivars as determined via yield-stability 
statistic and GGE biplot analysis. J. Crop Improv. 15:97-120

}
\examples{
# stability analysis 
data(multienv)
out <- stability (dataframe = multienv , yvar = "yield", genotypes = "genotypes",
 environments = "environments", replication =  "replication")
out
# AMMI analysis 
results <- ammi.full(dataframe = multienv , environment = "environments",
 genotype = "genotypes", replication = "replication", yvar = "yield")
print(results)

}

