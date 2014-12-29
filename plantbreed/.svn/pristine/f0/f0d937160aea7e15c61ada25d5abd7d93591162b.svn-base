\name{assoc.kin}
\alias{assoc.kin}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Linear Mixed Model Association Mapping using Kinship or Relatedness matrix 
}
\description{
The function can used for linear mixed model based association mapping. Kinship matrix be calculated and can fitted.
Also user can apply own relatedness matrix (eg. calculated from marker data using other functions). Also covariate variable can be fitted.  
}
\usage{
assoc.kin(dataframe, yvar, xvars, id = "id", dadid = "dadid", momid = "momid", 
sex = "sex", kmats = "calculate", kmatrix = NA, covariate = FALSE, cvar,
 model = "ADD")
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{dataframe}{
Name of dataframe with all data. The required columns are id, dadid, momid, sex, yvar. The covariate (cvar) is optional. 
}
  \item{yvar}{
Name of y variable 
}
  \item{xvars}{
vector of names of x variables (SNPs) (eg. c("SNP1", "xLoci12", "SNP1-3-4")) or column number (for example - c(6, 8, 10) or 6:100, or 6:length(dataframe))
}
  \item{id}{
Name of individual ID variable 
}
  \item{dadid}{
Name of father / parent 1 variable 
}
  \item{momid}{
Name of mother / parent 2 variable 
}
  \item{sex}{
Name of sex variable 
}
  \item{kmats}{
two value "calculate" to calculate kinship (k matrix) from the pedigree data or "user" when the user supply own k matrix  
}
  \item{kmatrix}{
name of kinship matrix object, if kmats = "user" else NA 
}
  \item{covariate}{
logical (TRUE or FALSE), when covariates are present  
}
  \item{cvar}{
Name of covariate variable, when covariate = TRUE  
}
  \item{model}{
Whether to fit additive model - "ADD", or dominance - "DOM" or regular anova - "NONE"
}
}
\details{
There are two issues 
(1) The K matrix that user-supplied variance matrix is positive definite (SPD). 
It has been observed that IBD matrices produced by some software are not strictly SPD.
 Sometimes models with these matrices still work (throughout the iteration path, 
 the weighted sum of variance matrices was always SPD) and sometimes they don't. 
 In the latter case, messages about taking the log of negative numbers will occur,
  and the results of the fit are not necessarily trustworthy.
(2) the funtion rescale supplied variance matrices so as to have a diagonal of 1.0.  
  
}
\value{
The function output  a dataframe with markers, pvalue (for SNPs) and cprob (for covariate), if covariate is fitted in the model.  

}
\references{
Atkinson B, Therneau T (2009) kinship: mixed-effects Cox models, sparse matrices, and modeling data from large pedigrees.
The Comprehensive R Archive Network

}
\author{
Umesh Rosyara 
}
\note{
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
# simulating pedigree dataset
id <- 1:115
dadid <- c(rep(0, 20), rep(1, 5), rep(3, 5), rep(5, 5), rep(7, 10), rep(9, 10), 
rep(11, 10), rep(13, 10), rep(15, 10), rep(17, 10), rep(19, 10), rep(19, 10))
momid <- c(rep(0, 20), rep(2, 5), rep(4, 5), rep(6, 5), rep(8, 10), rep(10, 10),
 rep(12, 10), rep(14, 10), rep(16, 10), rep(18, 10), rep(20, 10), rep(20, 10) )
ped <- data.frame(id, dadid, momid)
srp= c(1,2); sex <- c(rep(srp,57), 1) # sex variable



# simulated (random) trait and marker genotype dataset
set.seed(3456)
id <- c(1:115)
dat <- sample(c("AA","AB","BB"), 115000, replace = TRUE)
snpmat<- data.frame(matrix(dat, ncol = 1000))
names(snpmat) <- c(paste ("SNP",1:1000, sep='' ))
trait1 <- rnorm(115, 30, 5)
covtrait <- rnorm(115, 25, 3)
status <- sample (c(1,0), 115, replace = TRUE)
snpdata <- data.frame(ped, sex = sex, trait1, covtrait, status, snpmat) 

 assoc.kin (dataframe = snpdata,  yvar = "trait1", xvars = 8:100, id = "id", 
 dadid = "dadid", momid = "momid", sex = "sex", model = "ADD")
 
 # dominance model 
 assoc.kin (dataframe = snpdata,  yvar = "trait1", xvars = 8:100, id = "id", 
 dadid = "dadid", momid = "momid", sex = "sex", model = "DOM")
 
  # none 
 assoc.kin (dataframe = snpdata,  yvar = "trait1", xvars = 8:100, id = "id", 
 dadid = "dadid", momid = "momid", sex = "sex", model = "NONE")
 
 assoc.kin (dataframe = snpdata,  yvar = "trait1", xvars = 8:100, id = "id", 
 dadid = "dadid", momid = "momid", sex = "sex", kmats = "calculate")
 out <- assoc.kin(dataframe = snpdata, yvar = "trait1", xvars = 8:83, id = "id",
  dadid = "dadid", momid = "momid", sex = "sex", kmats = "calculate", 
  covariate = TRUE, cvar = "covtrait")
 
 # own kinship matrix 
# creating pedigree object
require(kinship)
fam1.ped<-pedigree(id=id,dadid=dadid, momid= momid, sex= sex)
cfam <- makefamid(ped$id,ped$momid, ped$dadid)
ownkmat <- makekinship(cfam, ped$id, ped$momid, ped$dadid)# kinship matrix
  
## out <- assoc.kin(dataframe = snpdata, yvar = "trait1", xvars = 8:83, id = "id", 
## dadid = "dadid", momid = "momid", sex = "sex", kmats = "user", kmatrix = ownkmat,
  ## covariate = TRUE, cvar = "covtrait")
}  

\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
