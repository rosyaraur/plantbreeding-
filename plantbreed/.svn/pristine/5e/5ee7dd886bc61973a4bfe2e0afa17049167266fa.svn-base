\name{respdataf}
\alias{respdataf}
\docType{data}
\title{
Example data to visualize response to selection and heritability  
}
\description{
Example data to visualize response to selection and heritability  
}
\usage{data(respdataf)}
\format{
  A data frame with 4000 observations on the following 3 variables.
  \describe{
    \item{\code{iid}}{a numeric vector}
    \item{\code{traitF2}}{a numeric vector}
    \item{\code{traitF3}}{a numeric vector}
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
data(respdataf)
F3s <- subset(respdataf, traitF2 >=65)  # selected lines from F2 that meet criteria
SDiff = mean(F3s$traitF2 ) - mean(respdataf$traitF2 )
traitF3v <- respdataf$traitF3
F3sv <- F3s$traitF3
F3rv <- sample(traitF3v, length(F3sv)) # random selection of equal number of progeny

# hertiability and genetic gain 
hsqr = (mean(F3sv) - mean(F3rv))/ SDiff # heritability
hsqr
geneticgain = mean(F3sv) - mean(respdataf$traitF2) # genetic gain 
geneticgain

# plotting the generation density and selected fractions
plot(density(respdataf$traitF2),xlim=c(0,100), main = paste("F2 and F3 distributions"))

dens <- density(respdataf$traitF2)
x1 <- min(which(dens$x >= 65))
x2 <- max(which(dens$x <  100))
with(dens, polygon(x=c(x[c(x1,x1:x2,x2)]), y= c(0, y[x1:x2], 0), col="green"))
abline(v= mean(respdataf$traitF2),  col = "black", lty = 1)
lines(density(respdataf$traitF3),lty=2, col= "blue")
abline(v= mean(respdataf$traitF3),  col = "blue", lty = 2)
lines(density(F3sv),lty=5, col = "green4")
abline(v= mean(F3sv),  col = "green4", lty = 5)

legend(73, 0.03, c("F2", "F3 not selected", "F3 from selected F2"), 
col = c("black","blue","green4"), text.col = c("black","blue","green4"),
 lty = c(1, 2, 5), bg = 'gray90')
}
\keyword{datasets}
