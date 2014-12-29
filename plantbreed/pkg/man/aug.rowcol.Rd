\name{aug.rowcol}
\alias{aug.rowcol}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Analysis of Augmented row and column design 
}
\description{
The function implements analysis of augmented random row and column design.  
}
\usage{
aug.rowcol(dataframe, rows, columns, genotypes, yield)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{dataframe}{
dataframe object with at least columns with information of rows, columns, genotypes / entries/ varieties / or treatments and yield (yvariable) 
}
  \item{rows}{
name of numbericnumeric variable with rows number 
}
  \item{columns}{
name of numeric variable with column number 
}
  \item{genotypes}{
name of column with with treatments / genotypes (factor)   
}
  \item{yield}{
name of column with yield or any y variable 
}
}
\value{
\item{ANOVA}{Analysis of Variance Table}
\item{Adjustment }{Original and Adjusted Phenotypic value}
\item{se_check}{Difference between check means}
\item{se_within }{Difference adjusted yield of two genotypes / varitiesvarieties / entries in same row or column}
\item{se_diff }{Difference between two genotypes / varieties / entries in different rows or blocks}
\item{se_geno_check}{Difference between two genotypes / varieties / entries and a check mean}
}
\author{
Umesh Rosyara
}

\examples{
# example 1
data(rowcoldata)
outp <- aug.rowcol(dataframe = rowcoldata, rows = "rows", columns = "columns", 
genotypes = "genotypes", yield = "yield")

outp$ANOVA # analysis of variance 
outp$Adjustment # adjusted values 

# calculation of means
stab <- aggregate( yield ~ genotypes, data=rowcoldata, FUN= mean)

hist(stab$yield, col = "cadetblue", xlab = "Grain Yield", 
main = "Mean yields from Augmented Yield Trial")

}

