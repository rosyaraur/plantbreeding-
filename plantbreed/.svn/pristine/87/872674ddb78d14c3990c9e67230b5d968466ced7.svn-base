\name{rowcoldata}
\alias{rowcoldata}
\docType{data}
\title{
Analysis of Row Column Experimental Design Data 
}
\description{
The data us example of row-column augmented design.  
}
\usage{data(rowcoldata)}
\format{
  A data frame with 75 observations on the following 4 variables.
  \describe{
    \item{\code{rows}}{a numeric vector}
    \item{\code{columns}}{a numeric vector}
    \item{\code{genotypes}}{gentypes 50 + 5 checks }  
    \item{\code{yield}}{yield - a numeric vector}
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
data(rowcoldata)
outp <- aug.rowcol(dataframe = rowcoldata, rows = "rows", columns = "columns", 
genotypes = "genotypes", yield = "yield")
outp$ANOVA # analysis of variance 
outp$Adjustment # adjusted values 

# calculation of means
stab <- aggregate( yield ~ genotypes, data=rowcoldata, FUN= mean)
hist(stab$yield, col = "cadetblue", xlab = "Grain Yield", 
main = "Mean yields from Augmented Yield Trial")

}
\keyword{datasets}
