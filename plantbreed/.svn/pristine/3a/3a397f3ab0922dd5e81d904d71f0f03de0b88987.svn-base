\name{augblock}
\alias{augblock}
\docType{data}
\title{
Augmented block data 
}
\description{
The example dataset for Augmented randomized block design 
}
\usage{data(augblock)}
\format{
  A data frame with 78 observations on the following 4 variables.
  \describe{
    \item{\code{var}}{a factor}
    \item{\code{blk}}{a numeric vector - blocks}
    \item{\code{trt}}{a numeric vector - treatments}
    \item{\code{gw}}{a numeric vector - grain weight}
  }
}
\details{
%%  ~~ If necessary, more details than the __description__ above ~~
}
\source{
%%  ~~ reference to a publication or URL from which the data were obtained ~~
}
\references{
%%  ~~ possibly secondary sources and usages ~~
}
\examples{
data(augblock)
out <- aug.rcb(dataframe = augblock, genotypes = "var", block = "blk", yvar = "gw")
out$anova  # analysis of variance 
out$adjusted_values # yield observed and expected value table  

# calculation of means
stab <- aggregate( gw ~ var, data=augblock, FUN= mean)

hist(stab$gw, col = "cadetblue", xlab = "Grain Yield",
 main = "Mean yields from Augmented Yield Trial")

}
\keyword{datasets}
