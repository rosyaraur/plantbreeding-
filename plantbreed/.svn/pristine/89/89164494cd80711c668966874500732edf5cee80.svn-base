\name{rcbsingle}
\alias{rcbsingle}
\docType{data}
\title{
Single location randomized complete block design data 
}
\description{
The single location randomization data of two traits is used to demostrate in calculation of broadsense hertitability and genetic correlation. 
}
\usage{data(rcbsingle)}
\format{
  A data frame with 32 observations on the following 4 variables.
  \describe{
    \item{\code{replication}}{a numeric vector}
    \item{\code{genovar}}{a numeric vector}
    \item{\code{tgw}}{a numeric vector}
    \item{\code{grw}}{a numeric vector}
  }
}
\examples{
data(rcbsingle)

# broad sense heritability 
hsq.single (dataframe = rcbsingle, yvars = "tgw", genovar = "genovar",
 replication = "replication", exout= TRUE, REML = FALSE)

# genetic correlation 

gencor.lm(dataframe = rcbsingle, yvar1 = "tgw", yvar2 = "grw", genovar = "genovar", 
replication = "replication", exout = FALSE)

out <- gencor.lm(dataframe = rcbsingle, yvar1 = "tgw", yvar2 = "grw", 
genovar = "genovar", replication = "replication", exout = TRUE)
out 

}
\keyword{datasets}
