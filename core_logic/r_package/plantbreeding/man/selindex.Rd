\name{selindex}
\alias{selindex}
\docType{data}
\title{
Data for selection index 
}
\description{
The data illustrates development of selection index outlined by Smith(1936) as outlined in Singh and Chaudhary (1985) using function selection.index. 
}
\usage{data(selindex)}
\format{
The data is list of threee matrix and a phenotypic dataframe. 

 $ X      : phenotypic covariance matrix 
 $ G      : genotypic covariance matrix 
 $ A      : economic covariance matrix 
 $ phenodf:'data.frame':	8 obs. of  5 variables:
  ..$ parents: parents 
  ..$ trait1 : trait 1
  ..$ trait2 : trait 2
  ..$ trait3 : trait 3
  ..$ trait4 : trait 4
}
\details{
List of X, G, A, phenodf 
}
\references{
Singh R.K., Chaudhary B.D.(1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers

Hill J.,  Becker H.C.,  Tigerstedt P.M. A. (1998) Quantitative and Ecological Aspects of Plant Breeding, Springer, 1998 - 275 pages

Lynch M., Walsh B. (1998). Genetics and Analysis of Quantitative Traits. Sinauer, Sunderland, MA

}
\examples{
data(selindex)
p <- seletion.index (phenodf = selindex$phenodf, pcovmat = selindex$X, 
gcovmat = selindex$G, ecovmat = selindex$A)
print(p)
}
\keyword{datasets}
