\name{diallele1}
\alias{diallele1}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Analysis of Diallel data
}
\description{
Calculates general and specific combining ability and other estimates for Diallel mating design using Griffings I method (Griffing, 1956) . 
}
\usage{
diallele1(dataframe, yvar = "yvar", progeny = "progeny", male = "male",
 female = "female", replication = "replication")
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{dataframe}{
Dataframe object 
}
  \item{yvar}{
Name of yvariable to be used in analysis 
}
  \item{progeny}{
Name of progeny variable to be used in the analysis 
}
  \item{male}{
Name of male variable to be used in the analysis 
}
  \item{female}{
Name of female variable to be used in the analysis 
}
  \item{replication}{
Name of replication variable 
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
Griffing, B. 1956. Concept of general and specific combining ability in relation to diallel crossing systems. Austr. J. Biol. Sci. 9, 463-493.

Singh R.K., Chaudhary B.D.(1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers

Mather K., Jinks J.L. (1971). Biometrical Genetics. Chapman & Hall, London.

}
\author{
Umesh Rosyara 
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
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
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
