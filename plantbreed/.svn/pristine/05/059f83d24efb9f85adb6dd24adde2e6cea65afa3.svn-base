\name{parentoffs}
\alias{parentoffs}
\docType{data}
\title{
Parent offspring regression example data   
}
\description{
The data provide example to calculate parent offspring regression data. 
}
\usage{data(parentoffs)}
\format{
  A data frame with 100 observations on the following 4 variables.
  \describe{
    \item{\code{parent1}}{parent 1}
    \item{\code{parent2}}{parent 2}
    \item{\code{midparent}}{mid parent value}
    \item{\code{offspring}}{offspring}
  }
}
\references{
Allard R.W.(1999) Principles of Plant Breeding, John Wiley and Sons, May 10, 1999 - 254 pages

Sleper D.A.(2006) Poehlman J.M. Breeding Field Crops, Blackwell Pub., Jul 25, 2006 - 424 pages

Falconer D. S., Mackay T.F.C. (1996). Introduction to Quantitative Genetics. Fourth edition. Addison Wesley Longman, Harlow, Essex, UK.

Singh R.K., Chaudhary B.D.(1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers
}
\examples{
data(parentoffs)

#parent offspring regression
model <- lm(parentoffs$offspring ~ parentoffs$midparent)
heritability <- coef(model)[2]
heritability

#plotting
par(fig=c(0,0.8,0,0.8))
plot(parentoffs$midparent, parentoffs$offspring, xlab="Mid parent value", ylab= "Offspring", 
col = "cadetblue", pch= 19)
abline(model, col = "red")


par(fig=c(0,0.8,0.55,1), new=TRUE)
boxplot(parentoffs$midparent, horizontal=TRUE, col = "red", axes=FALSE)
par(fig=c(0.65,1,0,0.8),new=TRUE)

boxplot(parentoffs$offspring, col = "blue", axes=FALSE)
mtext(paste("Parent ofspring regression \n heritability =  ", round(heritability,2), sep = ""),
 side=3, outer=TRUE, line=-3)

# bootstrap analysis of the heritability (regression coefficient)
# Need to install package boot 
require(boot)
hsq.function <- function(data, i){
             d <- data[i,]
	         fit <- lm(d$offspring ~ d$midparent, data=d)
                 return(coef(fit)[2])
}
boot.results<- boot(parentoffs, hsq.function, R=1000)
boot.results
plot(boot.results)
}
\keyword{datasets}
