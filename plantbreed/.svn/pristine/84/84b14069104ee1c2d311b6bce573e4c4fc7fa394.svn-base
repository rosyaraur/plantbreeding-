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
    \item{\code{MR1}}{a numeric vector}
    \item{\code{MR2}}{a numeric vector}
    \item{\code{MR3}}{a numeric vector}
    \item{\code{MR4}}{a numeric vector}
    \item{\code{MR5}}{a numeric vector}
    \item{\code{MR6}}{a numeric vector}
    \item{\code{MR7}}{a numeric vector}
    \item{\code{MR8}}{a numeric vector}
    \item{\code{MR9}}{a numeric vector}
    \item{\code{MR10}}{a numeric vector}
    \item{\code{MR11}}{a numeric vector}
    \item{\code{MR12}}{a numeric vector}
    \item{\code{MR13}}{a numeric vector}
    \item{\code{MR14}}{a numeric vector}
    \item{\code{MR15}}{a numeric vector}
    \item{\code{MR16}}{a numeric vector}
    \item{\code{MR17}}{a numeric vector}
    \item{\code{MR18}}{a numeric vector}
    \item{\code{MR19}}{a numeric vector}
    \item{\code{MR20}}{a numeric vector}
    \item{\code{MR21}}{a numeric vector}
    \item{\code{MR22}}{a numeric vector}
    \item{\code{MR23}}{a numeric vector}
    \item{\code{MR24}}{a numeric vector}
    \item{\code{MR25}}{a numeric vector}
    \item{\code{MR26}}{a numeric vector}
    \item{\code{MR27}}{a numeric vector}
    \item{\code{MR28}}{a numeric vector}
    \item{\code{MR29}}{a numeric vector}
    \item{\code{MR30}}{a numeric vector}
    \item{\code{MR31}}{a numeric vector}
    \item{\code{MR32}}{a numeric vector}
    \item{\code{MR33}}{a numeric vector}
    \item{\code{MR34}}{a numeric vector}
    \item{\code{MR35}}{a numeric vector}
    \item{\code{MR36}}{a numeric vector}
    \item{\code{MR37}}{a numeric vector}
    \item{\code{MR38}}{a numeric vector}
    \item{\code{MR39}}{a numeric vector}
    \item{\code{MR40}}{a numeric vector}
    \item{\code{MR41}}{a numeric vector}
    \item{\code{MR42}}{a numeric vector}
    \item{\code{MR43}}{a numeric vector}
    \item{\code{MR44}}{a numeric vector}
    \item{\code{MR45}}{a numeric vector}
    \item{\code{MR46}}{a numeric vector}
    \item{\code{MR47}}{a numeric vector}
    \item{\code{MR48}}{a numeric vector}
    \item{\code{MR49}}{a numeric vector}
    \item{\code{MR50}}{a numeric vector}
    \item{\code{MR51}}{a numeric vector}
    \item{\code{MR52}}{a numeric vector}
    \item{\code{MR53}}{a numeric vector}
    \item{\code{MR54}}{a numeric vector}
    \item{\code{MR55}}{a numeric vector}
    \item{\code{MR56}}{a numeric vector}
    \item{\code{MR57}}{a numeric vector}
    \item{\code{MR58}}{a numeric vector}
    \item{\code{MR59}}{a numeric vector}
    \item{\code{MR60}}{a numeric vector}
    \item{\code{MR61}}{a numeric vector}
    \item{\code{MR62}}{a numeric vector}
    \item{\code{MR63}}{a numeric vector}
    \item{\code{MR64}}{a numeric vector}
    \item{\code{MR65}}{a numeric vector}
    \item{\code{MR66}}{a numeric vector}
    \item{\code{MR67}}{a numeric vector}
    \item{\code{MR68}}{a numeric vector}
    \item{\code{MR69}}{a numeric vector}
    \item{\code{MR70}}{a numeric vector}
    \item{\code{MR71}}{a numeric vector}
    \item{\code{MR72}}{a numeric vector}
    \item{\code{MR73}}{a numeric vector}
    \item{\code{MR74}}{a numeric vector}
    \item{\code{MR75}}{a numeric vector}
    \item{\code{MR76}}{a numeric vector}
    \item{\code{MR77}}{a numeric vector}
    \item{\code{MR78}}{a numeric vector}
    \item{\code{MR79}}{a numeric vector}
    \item{\code{MR80}}{a numeric vector}
    \item{\code{MR81}}{a numeric vector}
    \item{\code{MR82}}{a numeric vector}
    \item{\code{MR83}}{a numeric vector}
    \item{\code{MR84}}{a numeric vector}
    \item{\code{MR85}}{a numeric vector}
    \item{\code{MR86}}{a numeric vector}
    \item{\code{MR87}}{a numeric vector}
    \item{\code{MR88}}{a numeric vector}
    \item{\code{MR89}}{a numeric vector}
    \item{\code{MR90}}{a numeric vector}
    \item{\code{MR91}}{a numeric vector}
    \item{\code{MR92}}{a numeric vector}
    \item{\code{MR93}}{a numeric vector}
    \item{\code{MR94}}{a numeric vector}
    \item{\code{MR95}}{a numeric vector}
    \item{\code{MR96}}{a numeric vector}
    \item{\code{MR97}}{a numeric vector}
    \item{\code{MR98}}{a numeric vector}
    \item{\code{MR99}}{a numeric vector}
    \item{\code{MR100}}{a numeric vector}
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
