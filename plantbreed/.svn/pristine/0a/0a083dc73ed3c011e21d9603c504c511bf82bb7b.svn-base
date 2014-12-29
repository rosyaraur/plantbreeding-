\name{hsq.single}
\alias{hsq.single}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Broad sense Mixed model analysis of Heritability estimation   
}
\description{
Mixed model analysis of Heritability from single replicated RCB experiment using general linear model (Singh and Chaudhary 1985) or using restricted (or residual, or reduced) maximum likelihood method (Saxton 2004). 
}
\usage{
hsq.single(dataframe, yvars, genovar, replication, exout = F, REML = F)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{dataframe}{
dataframe object 
}
  \item{yvars}{
name of Y variable used in the model 
}
  \item{genovar}{
name of genotype variable used in the analysis 
}
  \item{replication}{
name of replication variable used in the analysis 
}
  \item{exout}{
logical variable (TRUE or FALSE), depending upon whether extended output is to be printed to screen 
}
  \item{REML}{
logical variable (TRUE or FALSE), depending upon whether REML be used to fit the model
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
Depending upon REML (REML = TRUE or REML = FALSE) and extensive output (exout = TRUE or exout = FALSE), different output are returned. 

When REML = FALSE 
\item{model }{The model}
\item{hertiability }{Heritability}

When REML = TRUE 

\item{hertiability }{Heritability}
\item{genovar}{Genotypic variance}
\item{totalvar}{Total variance}
\item{randomeffects}{Random effects}

When exout is FALSE only heritability is returned. 

}
\references{
Singh R.K., Chaudhary B.D.(1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers

Saxton A. (2004) Genetic Analysis of Complex Traits Using SAS. SAS Institute, Inc.

Littell R.C.(2006) SAS for Mixed Models,SAS Institute, Inc.
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
data (rcbsingle)
p1 <- hsq.single (dataframe = rcbsingle, yvars = "tgw", genovar = "genovar",
 replication = "replication", exout= TRUE, REML = FALSE)
print(p1) 
anova(p1$model)

otGrw <- hsq.single (dataframe = rcbsingle, yvars = "grw", genovar = "genovar", 
replication = "replication", exout= TRUE, REML = FALSE)
print (otGrw)  
anova(otGrw$model)

p2 <- hsq.single (dataframe = rcbsingle, yvars = "tgw", genovar = "genovar", 
replication = "replication", exout= TRUE, REML = TRUE)
print(p2)


# do not work ??
hsq.single (dataframe = rcbsingle, yvars = "grw", genovar = "genovar", 
replication = "replication", exout= FALSE, REML = TRUE)

hsq.single (dataframe = rcbsingle, yvars = "tgw", genovar = "genovar", 
replication = "replication", exout= FALSE, REML = FALSE)

hsq.single (dataframe = rcbsingle, yvars = "grw", genovar = "genovar", 
replication = "replication", exout= TRUE, REML = TRUE)


}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
