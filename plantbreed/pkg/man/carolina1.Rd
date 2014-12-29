\name{carolina1}
\alias{carolina1}
\title{
Analysis of North Carolina Design I
}
\description{
The function performs analysis of North Carolina I design (Comstock and Rosbinson 1952).
}
\usage{
carolina1(dataframe, set, male, female, progeny, replication, yvar)
}
\arguments{
  \item{dataframe}{
Dataframe sould consist of variables set, male, female, progeny and replication 
along with at least one y variable (yvar) 
}
  \item{set}{
name of numeric variable for set 
}
  \item{male}{
name of numeric variable with male 
}
  \item{female}{
name of numeric variable with female 
}
  \item{progeny}{
name of numeric variable with progeny 
}
  \item{replication}{
name of numeric variable with replication 
}
  \item{yvar}{
name of name of y variable to be analyzed
}
}
\value{
The following values as list are returned 
\item{model}{model - use anova (model) to see analysis of variables}
\item{`variance male`}{Male variance}
\item{`BULP estimates`}{BLUP estimates}
\item{`variance female`}{Female variance}
\item{`additive variance`}{Additive variance}
\item{`dominance variance`}{Dominance variance}
\item{`female:male:set:replication`}{female:male:set:replication}
\item{`female:male:set`}{female:male:set}
\item{`male:set`}{male:set}
\item{`set:replication`}{set:replication}
           
}
\references{
Comstock R.F., Rosbinson F.F (1952). Estimation of average dominance of genes. In Heterosis, Iowa State
College Press, Iowa City, Iowa, chapter 30.

Singh R.K., Chaudhary B.D.(1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers

Mather K., Jinks J.L. (1971). Biometrical Genetics. Chapman & Hall, London.

Saxton A. (2004) Genetic Analysis of Complex Traits Using SAS. SAS Institute, Inc.
}
\author{
Umesh R. Rosyara
}
\examples{
data(northcaro1)
# using general linear model
p1 <- carolina1(dataframe = northcaro1, set = "set", male = "male", female = "female", 
progeny = "progeny", replication = "replication", yvar = "yield")
print(p1)

anova(p1[[1]]) # anova 

p1[[1]]$coefficients  ## coefficients  

p1$var.m # male variance 
p1$ var.f # femal variance 
p1$ var.A # variance additive 
p1$ var.D # variance dominance 


}
