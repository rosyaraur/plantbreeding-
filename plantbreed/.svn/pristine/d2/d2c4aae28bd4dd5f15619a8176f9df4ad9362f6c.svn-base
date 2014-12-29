\name{onfarm}
\alias{onfarm}
\docType{data}
\title{
Data from on farm experiments 
}
\description{
Simulated data from on-farm experiments to demonstrate application of mixed model to analyze data from on-farm experiments.   
}
\usage{data(onfarm)}
\format{
  A data frame with 200 observations on the following 5 variables.
  \describe{
    \item{\code{year}}{year - a factor with levels \code{1} \code{2}}
    \item{\code{village}}{vilage - a factor with levels \code{1} \code{2} \code{3} \code{4}}
    \item{\code{farm}}{farm - a factor with levels \code{1} \code{2} \code{3} \code{4} \code{5}}
    \item{\code{genotype}}{genotype - a factor with levels \code{1} \code{2} \code{3} \code{4} \code{5}}
    \item{\code{trait1}}{trait 1 - Y variable }
  }
}
\source{
Simulated data set 
}
\examples{
data(onfarm)
require(lme4)
# analysis using lme4, REML criterion used instead of log-likelihood 
require(lme4) 
modelf <- lmer(trait1 ~ (year + village + genotype)^3 + (year + village +
 genotype|farm:village), data= onfarm, REML = TRUE)# full model 
 
anova(modelf)
modelr = lmer(trait1 ~ year+village+year:village+(1|farm:village:year)+ genotype,
 data=onfarm, REML = TRUE) 
 # reduced model without genotype:year,  genotype:village, genotype:year:village
anova(modelr)
anova(modelf, modelr)# comparison of two models 

}
\keyword{datasets}
