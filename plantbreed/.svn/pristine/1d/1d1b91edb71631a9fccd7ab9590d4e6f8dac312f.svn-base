\name{gencor.lm}
\alias{gencor.lm}
\title{
Computing genetic correlation using linear model from single site replicated experiments 
}
\description{
The genetic correlation between two traits is calculated by fitting linear model as outlined by Singh and Chaudhary (1985).  
}
\usage{
gencor.lm(dataframe, yvar1, yvar2, genovar, replication = replication, exout = F)
}
\arguments{
  \item{dataframe}{
}
  \item{yvar1}{
name of first Y variable 
}
  \item{yvar2}{
name of second Y variable 
}
  \item{genovar}{
name of genotype variable 
}
  \item{replication}{
name of replication variable 
}
  \item{exout}{
logical if extended output should be provided 
}
}
\value{
The result consists of a list of following components:
\item{genetic.corr }{Genetic correlation}
\item{modelV1 }{linear model for variable 1}
\item{modelV2 }{linear model for variable 2}
\item{modelV1V2 }{linear model for variable 1 and 2}
}
\references{
Singh R.K., Chaudhary B.D.(1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers

Falconer D. S., Mackay T.F.C. (1996). Introduction to Quantitative Genetics. Fourth edition. Addison Wesley Longman, Harlow, Essex, UK.
}
\author{
Umesh R Rosyara 
}
\examples{
# mydata 
mydf <- data.frame (replication = rep(1:4,times = 8), genovar = rep(1:8,each = 4), 
tgw = c(39,40,38,39, 37,36,36,37,45,46,46,47, 43,44,42,41,41, 40, 
42, 41, 42,45,43,45,43,43,42,43,42,40,43,41), grw = c(104.9,84.3,77.0,76.5,  88.0, 
106.5, 89.8,108.7, 80.0,71.3,77.5,69.5, 80.8,106.5,83.3, 95.9,   
60.0,52.5,53.0,51.0, 96.4,98.8,99.1,107.2, 91.4,99.7,83.3,89.5, 91.8,84.8,70.0,81.5))

ot <- gencor.lm(dataframe = mydf, yvar1 = "tgw", yvar2 = "grw", genovar = "genovar",
 replication = "replication", exout = FALSE) 
print (ot) 

# with extended output printed to screen and output saved  
ct <- gencor.lm(dataframe = mydf, yvar1 = "tgw", yvar2 = "grw", genovar = "genovar",
 replication = "replication", exout = TRUE)  
print(ct)
anova(ct$modelV1) # analysis variance of variable 1
anova(ct$modelV2) # analysis of variance of variable 2
anova(ct$modelV1V2) # analysis of variance of variable 1 and variable 2 
}

