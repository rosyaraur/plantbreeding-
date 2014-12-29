\name{fulldial}
\alias{fulldial}
\docType{data}
\title{
Full 8 x 8 diallel  data 
}
\description{
Data for a full 8 x 8 diallel for grain yield from Singh and Chaudhary (1979) 

}
\usage{data(fulldial)}
\format{
  A data frame with 256 observations on the following 7 variables.
  \describe{
    \item{\code{FAMILY}}{Name of family}
    \item{\code{TRT}}{Treatments i.e. genotype}
    \item{\code{FAMQC}}{FAMQC}
    \item{\code{MALE}}{Male}
    \item{\code{FEMALE}}{Female}
    \item{\code{REP}}{Replication}
    \item{\code{YIELD}}{Grain yield}
  }
}
\details{
%%  ~~ If necessary, more details than the __description__ above ~~
}
\source{
Singh R.K., Chaudhary B.D.(1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers
}
\references{
Griffing, B. 1956. Concept of general and specific combining ability in relation to diallel crossing systems. Austr. J. Biol. Sci. 9, 463-493.

Singh R.K., Chaudhary B.D.(1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers

Mather K., Jinks J.L. (1971). Biometrical Genetics. Chapman & Hall, London.

}
\examples{
data(fulldial) 
 out <-diallele1(dataframe = fulldial, male = "MALE", female = "FEMALE",  
 progeny = "TRT", replication = "REP", yvar = "YIELD" )

print(out) 
out$anvout # analysis of variance 
out$anova.mod1 # analysis of variance for GCA and SCA effects 

out$components.model1 # model1 GCA, SCA and reciprocal components 
out$gca.effmat # GCA effects
out$sca.effmat # SCA effect matrix 
out$reciprocal.effmat # reciprocal effect matrix 

out$varcompare  # SE for comparisions 
out$anovadf.mod2   # ANOVA for model 2
out$varcomp.model2  # variance components for model 2

}
\keyword{datasets}
