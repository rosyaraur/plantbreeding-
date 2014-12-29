\name{linetester}
\alias{linetester}
\docType{data}
\title{
Line x Tester analysis data 
}
\description{
The line x tester analysis dataset is taken from Single and Chaudhari and Singh (1985).
}
\usage{data(linetester)}
\format{
  A data frame with 92 observations on the following 6 variables.
  \describe{
    \item{\code{genotypes}}{genotypes and parents \code{1} \code{1x6} \code{1x7} \code{1X8} \code{2} \code{2x6} \code{2x7} \code{2X8} \code{3} \code{3x6} \code{3X7} \code{3x8} \code{4} \code{4x6} \code{4x7} \code{4x8} \code{5} \code{5x6} \code{5x7} \code{5x8} \code{6} \code{7} \code{8}}
    \item{\code{gclass}}{codes to show whether is parent (P) or children (C), a factor with levels \code{C} \code{P}}
    \item{\code{Lines}}{Lines}
    \item{\code{Tester}}{Tester}
    \item{\code{replication}}{Replication}
    \item{\code{trait1}}{trait 1 - Y variable}
  }
}
\source{
Singh R.K., Chaudhary B.D.(1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers
}
\examples{
data(linetester)
pls <- line.tester(dataframe = linetester, yvar = "trait1",  genotypes = "genotypes",
 replication = "replication",  Lines = "Lines", Testers = "Tester", gclass = "gclass" ) 
print(pls) 
}
\keyword{datasets}
