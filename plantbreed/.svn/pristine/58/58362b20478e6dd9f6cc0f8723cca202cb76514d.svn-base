\name{wintwheat}
\alias{wintwheat}
\docType{data}
\title{
Winter wheat data  from mixed model data SAS 
}
\description{
inter wheat data  from mixed model data SAS 
}
\usage{data(wintwheat)}
\format{
  A data frame with 60 observations on the following 3 variables.
  \describe{
    \item{\code{Variety}}{a factor with levels \code{1} \code{10} \code{2} \code{3} \code{4} \code{5} \code{6} \code{7} \code{8} \code{9}}
    \item{\code{Yield}}{a numeric vector}
    \item{\code{Moisture}}{a numeric vector}
  }
}
\source{
Littell R.C.(2006) SAS for Mixed Models,SAS Institute, Inc.
}
\examples{
data(wintwheat)
par(mfrow = c(1,4))
 hist(wintwheat$Yield)
 qqnorm(wintwheat$Yield)
qqline( wintwheat$Yield)
 boxplot(wintwheat$Yield); 
boxplot (wintwheat$Yield ~ wintwheat$Variety) 

#ANOVA 
model<-aov(Yield~Variety,data=wintwheat)
plot (model)# Check assumption of anova
plot.design (wintwheat$Yield~ wintwheat$Variety)# Effect sizes graphically  
model.tables (model, "means", se=TRUE)# Standard error of means
summary.lm (aov (model))# Another-way to see effect size 

# mean comparisons 
# Tukey test 
modelTukey=TukeyHSD(model,"Variety",ordered = TRUE)
modelTukey

}
\keyword{datasets}
