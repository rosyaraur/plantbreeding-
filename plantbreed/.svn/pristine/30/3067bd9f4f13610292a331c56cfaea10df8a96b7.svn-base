\name{balincom}
\alias{balincom}
\docType{data}
\title{
Data from a balanced incomplete block design
}
\description{
Data from a balanced incomplete block design
}
\usage{data(balincom)}
\format{
  A data frame with 24 observations on the following 5 variables.
  \describe{
    \item{\code{Block}}{a factor with levels \code{1} \code{2} \code{3} \code{4} \code{5} \code{6} \code{7} \code{8}}
    \item{\code{Treatment}}{a factor with levels \code{1} \code{2} \code{3} \code{4}}
    \item{\code{y}}{a numeric vector}
    \item{\code{x}}{a numeric vector}
    \item{\code{Grp}}{a factor with levels \code{13} \code{24}}
  }
}
\references{
Littel, R. C., Milliken, G. A., Stroup, W. W., and Wolfinger, R. D. (1996), SAS System for Mixed Models, SAS Institute (Data Set 5.4)
}
\examples{
data(balincom)
str(balincom)
# analysis of variance using mixed model 
require("lme4")
print(mod1Bal <- lmer(y ~ Treatment * x + (1 | Block), balincom))
print(anova(mod1Bal))     

# with Grp in the model 
print(mod2Bal <- lmer(y ~ Treatment + x : Grp + (1 | Block), balincom))
print(anova(mod2Bal))
    
}

