\name{popvisd}
\alias{popvisd}
\docType{data}
\title{
Multiple population dataset  
}
\description{
Example multiple population dataset for frequency distribution visualization.  
}
\usage{data(popvisd)}
\format{
  A data frame with 3000 observations on the following 3 variables.
  \describe{
    \item{\code{population}}{populations:  \code{L100 x L134} \code{L189 x L564} \code{L452 x L564}}
    \item{\code{trait1}}{trait 1 - a numeric vector}
    \item{\code{trait2}}{trait 2 - a numeric vector}
  }                      
}
\source{
Simulated dataset 
}
\references{
Wickham H. (2009)  ggplot: Elegant Graphics for Data Analysis. Use R. Springer.

Sarkar D. (2008) Lattice: Multivariate Data Visualization with R. Springer, New York
}
\examples{
data(popvisd)
require(lattice)
histogram(~ trait1|factor(population), data= popvisd, nint = 10,
          xlab = "trait1(measuring unit)", type = "density",
          panel = function(x, ...) {
              panel.histogram(x, col = "cadetblue",...)
              panel.mathdensity(dmath = dnorm, col = "red",
                                args = list(mean=mean(x),sd=sd(x)))
          } )
# similar histpgram using ggplot2
require(ggplot2)
qplot( trait1, data = popvisd, geom = "histogram", fill= population)+ theme_bw()

}
\keyword{datasets}
