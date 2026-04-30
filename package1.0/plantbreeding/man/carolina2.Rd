\name{carolina2}
\alias{carolina2}
\title{
Analysis of North Carolina design II  
}
\description{
The function performs analysis of North Carolina II design (Comstock and Rosbinson 1952).
}
\usage{
carolina2(dataframe, set, male, female, replication, yvar)
}
\arguments{
  \item{dataframe}{
Dataframe with the variablesevariables set, male, female, replication and other response variables 
}
  \item{set}{
Name of column with set variables 
}
  \item{male}{
Name of column with male parent information 
}
  \item{female}{
Name of column with female parent information 
}
  \item{replication}{
Name of column with replication column 
}
  \item{yvar}{
Name of response variable to be used for the analysis 
}
}
\value{
The following values as list are returned 
\item{model}{model - use anova (model) to see analysis of variables}
\item{var.m}{Male variance}
\item{var.f}{Female variance}
\item{var.mf}{Male*Female variance}
\item{var.AM}{Additive male variance}
\item{var.Af}{Additive female variance}
\item{var.D}{Dominance variance}

}
\references{
Comstock R.F., Rosbinson F.F (1952). Estimation of average dominance of genes. In Heterosis, Iowa State
College Press, Iowa City, Iowa, chapter 30.


Singh R.K., Chaudhary B.D.(1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers.


Mather K., Jinks J.L. (1971). Biometrical Genetics. Chapman & Hall, London.


Saxton A. (2004) Genetic Analysis of Complex Traits Using SAS. SAS Institute, Inc.

}
\author{
Umesh Rosyara 
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
