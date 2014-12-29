\name{northcaro2}
\alias{northcaro2}
\docType{data}
\title{
North Carolina Design II
}
\description{
Example data for analysis of North Carolina design II (Comstock and Rosbinson 1952).  
}
\usage{data(northcaro2)}
\format{
  A data frame with 300 observations on the following 9 variables.
  \describe{
    \item{\code{Loc}}{Loc}
    \item{\code{set}}{Set}
    \item{\code{rep}}{replication}
    \item{\code{female}}{femail}
    \item{\code{male}}{male}
    \item{\code{plrv}}{plrv}
    \item{\code{yield}}{yield}
    \item{\code{tuber}}{tuber}
    \item{\code{weight}}{weight}
  }
}
\details{
%%  ~~ If necessary, more details than the __description__ above ~~
}
\source{
%%  ~~ reference to a publication or URL from which the data were obtained ~~
}
\references{
Comstock R.F., Rosbinson F.F (1952). Estimation of average dominance of genes. In Heterosis, Iowa State
College Press, Iowa City, Iowa, chapter 30.

Singh R.K., Chaudhary B.D.(1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers

Mather K., Jinks J.L. (1971). Biometrical Genetics. Chapman & Hall, London.

Saxton A. (2004) Genetic Analysis of Complex Traits Using SAS. SAS® Institute, Inc.
}
\examples{
 data(northcaro2)
 # for trait yield 
myo <- carolina2(dataframe = northcaro2, set = "set", male = "male", female = "female", 
replication = "rep", yvar = "yield")
anova(myo$model) # anova 
myo$var.m
myo$var.f
myo$var.mf
myo$var.Af
myo$var.D

# for trait tuber  
tum <- carolina2(dataframe = northcaro2, set = "set", male = "male", female = "female",
 replication = "rep", yvar = "tuber")
anova(tum$model) 
anova(tum$model) # anova 
tum$var.m
tum$var.f
tum$var.mf
tum$var.Af
tum$var.D

}
\keyword{datasets}
