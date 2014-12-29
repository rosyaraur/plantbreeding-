\name{variability}
\alias{variability}
\docType{data}
\title{
Example data for plotting genetic diversity 
}
\description{
Ten genotypes were characterized by 100 markers. This data will be used to demonstrate some R functionalities to perform diversity analysis and plotting. 
}
\usage{data(variability)}
\format{
  A data frame with 10 observations on the following 101 variables.
  \describe{
    \item{\code{genotype}}{a numeric vector}
    \item{\code{MR1}}{Marker 1 to }
    \item{\code{MR100}}{Marker 100}
  }
}
\details{
%%  ~~ If necessary, more details than the __description__ above ~~
}
\source{
Simulated data 
}
\references{
%%  ~~ possibly secondary sources and usages ~~
}
\examples{
data(variability)
attach(variability) 
lf <- paste ("MR",1:100, sep='' , collapse = " + ")
formula <- as.formula(paste("genotype", lf,  sep = " ~"))

# cluster analysis
HClust.2 <- hclust(dist(model.matrix(formula, variability)) , method= "ward")
plot(HClust.2, main= "Cluster Dendrogram for Solution HClust.2",
xlab= "Observation Number in Data Set variability", sub="Method=ward; Distance=euclidian")

# Calculate probability of cluster in dendogram using bootstrap method
# transposing the dataset 
tvariability = data.frame(t(variability)[-1,])
names(tvariability) <- c(paste ("GEN",1:10, sep='' ) )

# the following commands need pvclust package need to be installed first 
require(pvclust)
plot(result <- pvclust(tvariability, method.dist="cor", method.hclust ="average", nboot=100))
pvrect(result, alpha=0.90)

# heat map plot with dendogram at margin, the following scripts need garphics and grDevices installed 
tvar <- as.matrix(tvariability) ; 
require(graphics); 
require(grDevices)
rc <- rainbow(nrow(tvar), start=0, end=.3)
cc <- rainbow(ncol(tvar), start=0, end=.3)
hv <- heatmap(tvar, col = heat.colors(20), scale="column", RowSideColors = rc, 
ColSideColors = cc, margins=c(5,10), xlab = "Genotypes", ylab= " Markers", 
main = " Heat map plot of variability data")

}
\keyword{datasets}
