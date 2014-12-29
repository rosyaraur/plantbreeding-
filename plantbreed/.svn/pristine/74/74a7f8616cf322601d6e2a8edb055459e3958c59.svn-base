\name{peanut}
\alias{peanut}
\docType{data}
\title{
Peanut data from multilocation trials 
}
\description{
peanut multi-location data from genetic analysis using SAS
}
\usage{data(peanut)}
\format{
  A data frame with 590 observations on the following 5 variables.
  \describe{
    \item{\code{geno}}{genotypes - a factor with levels \code{Florman} \code{manf393} 
    \code{mf447} \code{mf478} \code{mf480} \code{mf484} \code{mf485} \code{mf487} 
    \code{mf489} \code{Tegua}}
    \item{\code{rep}}{replications}
    \item{\code{yield}}{yield - Y variable}
    \item{\code{env}}{environment }
    \item{\code{gen}}{genotypes}
  }
}
\details{
%%  ~~ If necessary, more details than the __description__ above ~~
}
\source{
Littell R.C.(2006) SAS for Mixed Models,SAS Institute, Inc.
}
\references{
Gauch H.G.(1992). Statistical analysis of regional yield trials:AMMI analysis of factorial designs. Elsevier, Amsterdam.

Gauch H.G. (2006). Statistical analysis of yield trials by AMMI and GGE. Crop Sci. 46:1488-1500.

Gauch, H.G.,  Zobel.R.W. (1996). AMMI analysis of yield trials. p.85-122. In M.S. Kang and H.G. Gauch, Jr. (ed.) Genotype-byenvironment
interaction. CRC Press, Boca Raton, FL.

Eberhart S.A.,  Russell W.A. (1966) Stability parameters for comparing varieties. Crop Sci. 6: 36-40.

Singh R.K., Chaudhary B.D.(1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers

Kang M.S.,  Aggarwal V.D., Chirwa R.M.(2006) Adaptability and stability of bean cultivars as determined via yield-stability 
   statistic and GGE biplot analysis. J. Crop Improv. 15:97-120
}
\examples{
data(peanut)
peanut$rep <- as.factor (peanut$rep)
peanut$env <- as.factor (peanut$env)

# stability analysis 
out_peanut <- stability (dataframe = peanut , yvar = "yield", genotypes = "geno",
 environments = "env", replication =  "rep")
out_peanut

# AMMI analysis 
results_p <- ammi.full(dataframe = peanut, environment = "env", genotype = "geno",
 replication = "rep", yvar = "yield")

# heatmap plot 
heatmap (results_p$means)

# plot bar plot

myd <- melt(results_p$means)
require(ggplot2)
 d <- ggplot(myd, aes(genotype, value)) + geom_bar()
 d + facet_wrap(~ environment) + theme_bw()

# plot pc scores (biplot)
 myd2 <- data.frame (results_p$pc.scrs)
 
 # genotype 
 mydgen <- myd2[myd2$category =="genotype",]
 d1 <- ggplot(mydgen, aes(PC1, PC2)) + geom_point() +
  geom_text (aes (label = row.names (mydgen)), colour = "blue", hjust=1.2, vjust=0) +
    ylab ("PC2") + xlab ("PC1") + theme_bw()
 print(d1)
 
 #environment 
  mydenv <- myd2[myd2$category =="environment",]
  d2 <- ggplot(mydenv, aes(PC1, PC2)) + geom_point() +
  geom_text (aes (label = row.names (mydenv)), colour = "red",hjust=1.2, vjust=0) + 
   ylab ("PC2") + xlab ("PC1") + theme_bw()
  print(d2) 
 
}
\keyword{datasets}
