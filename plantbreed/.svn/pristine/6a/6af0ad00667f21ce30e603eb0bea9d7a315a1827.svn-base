\name{aug.rcb}
\alias{aug.rcb}
\title{
Analysis of augmented random block design 
}
\description{
The function implements analysis of augmented random block design.  The function assumes that checks (controls) are replicated r times making complete blocks while other treatments (new treatments) are unreplicated. Once the desired block size is determined, 
the checks are completely randomized making complete blocks and remaining plots / experimental units are also completely randomized however new treatments are unreplicated. 
}
\usage{
aug.rcb(dataframe, genotypes, block, yvar)
}

\arguments{
  \item{dataframe}{
Dataframe object with at least variable containing genotypes, blocks and one response variable to be analyzed 
}
  \item{genotypes}{
Name of column consisting of genotype or treatments (use "nameofcolumn" format) 
}
  \item{block}{
Name of column consisting of block (use "nameofblock" format) 
}
  \item{yvar}{
Name of response variable column (use "yvar" format)
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
A list consisting of the following items :
\item{anova}{Analysis of variance object}
\item{adjusted_values}{dataframe Table with raw and adjusted values}
\item{se_check}{Difference between check means}
\item{se_within}{Difference adjusted yield of two varitiesvarieties / entries in same block}
\item{SE_siff}{Difference between two varieties / entries in different blocks}
\item{se_geno}{Difference between two varieties /entries and a check mean}
}


\references{
%% ~put references to the literature/web site here ~
}
\author{
Umesh R. Rosyara 
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{

# Example 
data(augblock)
out <- aug.rcb(dataframe = augblock, genotypes = "var", block = "blk", yvar = "gw")
out$anova  # analysis of variance 
out$adjusted_values # yield observed and expected value table  

# calculation of means
stab <- aggregate( gw ~ var, data=augblock, FUN= mean)

hist(stab$gw, col = "cadetblue", xlab = "Grain Yield", 
main = "Mean yields from Augmented Yield Trial")

}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
