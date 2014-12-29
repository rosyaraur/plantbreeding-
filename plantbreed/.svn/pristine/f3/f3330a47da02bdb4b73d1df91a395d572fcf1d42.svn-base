\name{northcaro1}
\alias{northcaro1}
\docType{data}
\title{
North Carolia Design I
}
\description{
Data for analysis of north Carolina design I (Comstock and Rosbinson 1952).  
}
\usage{data(northcaro1)}
\format{
  A data frame with 72 observations on the following 6 variables.
  \describe{
    \item{\code{set}}{set}
    \item{\code{male}}{male}
    \item{\code{female}}{female}
    \item{\code{progeny}}{progeny}
    \item{\code{replication}}{replication}
    \item{\code{yield}}{yield - Y variable}
  }
}
\details{
%%  ~~ If necessary, more details than the __description__ above ~~
}
\source{
Singh R.K., Chaudhary B.D.(1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers
}
\references{
Comstock R.F., Rosbinson F.F (1952). Estimation of average dominance of genes. In Heterosis, Iowa State
College Press, Iowa City, Iowa, chapter 30.

Singh R.K., Chaudhary B.D.(1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers

Mather K., Jinks J.L. (1971). Biometrical Genetics. Chapman & Hall, London.

Saxton A. (2004) Genetic Analysis of Complex Traits Using SAS. SAS Institute, Inc.
}
\examples{
data(northcaro1)
# using general linear model
p1 <- carolina1(dataframe = northcaro1, set = "set", male = "male", female = "female", 
progeny = "progeny", replication = "replication", yvar = "yield", REML = FALSE )
print(p1)

anova(p1[[1]]) # anova 

p1[[1]]$coefficients  ## coefficients  

p1$var.m # male variance 
p1$ var.f # femal variance 
p1$ var.A # variance additive 
p1$ var.D # variance dominance 

# using REML estimation
require(lme4) 
p2 <- carolina1(dataframe = northcaro1, set = "set", male = "male", female = "female", 
progeny = "progeny", replication = "replication", yvar = "yield", REML = TRUE )
print(p2)


}
\keyword{datasets}
