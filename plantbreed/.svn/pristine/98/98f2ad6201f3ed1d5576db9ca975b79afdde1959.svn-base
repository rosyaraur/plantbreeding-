\name{plotgen}
\alias{plotgen}

\title{
Plot genetic gain 
}
\description{
The function plots response to selection and genetic gain over generations. 
}
\usage{
plotgen(dataframe, classvar, phenovar, selint = 0.1)
}
\arguments{
  \item{dataframe}{
dataframe object 
}
  \item{classvar}{
factor column with generation class - for example: "F2", "F3" etc .. 
}
  \item{phenovar}{
phenotypic data column
}
  \item{selint}{
selection intensity applied 
}
}
\references{
Allard R.W.(1999) Principles of Plant Breeding, John Wiley and Sons, May 10, 1999 - 254 pages

Sleper D.A.(2006) Poehlman J.M. Breeding Field Crops, Blackwell Pub., Jul 25, 2006 - 424 pages

Hill J.,  Becker H.C.,  Tigerstedt P.M. A. (1998) Quantitative and Ecological Aspects of Plant Breeding, Springer, 1998 - 275 pages

Lynch M., Walsh B. (1998). Genetics and Analysis of Quantitative Traits. Sinauer, Sunderland, MA

Falconer D. S., Mackay T.F.C. (1996). Introduction to Quantitative Genetics. Fourth edition. Addison Wesley Longman, Harlow, Essex, UK.

Mather K., Jinks J.L. (1971). Biometrical Genetics. Chapman & Hall, London.
}
\author{
Umesh R. Rosyara 
}
\examples{
set.seed (1234)
require(ggplot2)
mydf1 <-  data.frame (class = c(rep ("F2", 1000), rep("F3", 100)), 
yield = c(rnorm (1000, 50, 20),rnorm (50, 65, 5),rnorm (50, 25, 5)))

plotgen(dataframe = mydf1, classvar = "class", phenovar = "yield", selint = 0.1) 

}

