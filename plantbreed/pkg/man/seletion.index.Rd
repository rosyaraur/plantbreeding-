\name{seletion.index}
\alias{seletion.index}
\title{
Construction of selection index 
}
\description{
The function implements development of selection index outlined by Smith(1936) which is based on genetic and economic worth. The detail computation procedure is outlined by Singh and Chaudhary (1985). 
}
\usage{
seletion.index(phenodf, pcovmat, gcovmat, ecovmat, exout = TRUE, selectint = 0.01)
}
\arguments{
  \item{phenodf}{
Matrix of phenotypic data
}
  \item{pcovmat}{
phenotypic covariance matrix 
}
  \item{gcovmat}{
genotypic covariance matrix 
}
  \item{ecovmat}{
matrix of economic value 
}
  \item{exout}{
Whether to produce extended output to screen 
}
  \item{selectint}{
Selection intensity 
}
}
\references{
Singh R.K., Chaudhary B.D.(1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers

Hill J.,  Becker H.C.,  Tigerstedt P.M. A. (1998) Quantitative and Ecological Aspects of Plant Breeding, Springer, 1998 - 275 pages

Lynch M., Walsh B. (1998). Genetics and Analysis of Quantitative Traits. Sinauer, Sunderland, MA

Smith H.F. (1936) A discriminant function for plant selection. Ann. Eugenicd, 7: 240-250.

}
\author{
Umesh Rosyara
}
\examples{
data(selindex)
p <- seletion.index (phenodf = selindex$phenodf, pcovmat = selindex$X, 
gcovmat = selindex$G, ecovmat = selindex$A)
print(p)

}

