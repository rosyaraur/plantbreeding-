\name{line.tester}
\alias{line.tester}

\title{
Line x Tester Analysis   
}
\description{
The function performs line x tester analysis as outlined by Singh and Chaudhary (1985). 
}
\usage{
line.tester(dataframe, yvar, genotypes = genotypes, replication, Lines = Lines,
 Testers, gclass = gclass)
}

\arguments{
  \item{dataframe}{
Dataframe object with genotype, replication, lines, testers, gclass and at least of Y variable 
}
  \item{yvar}{
Name of Y variable 
}
  \item{genotypes}{
Name of genotype variable 
}
  \item{replication}{
Name of replication variable 
}
  \item{Lines}{
Name of lines variable 
}
  \item{Testers}{
Names of testers variables 
}
  \item{gclass}{
Name of gclass variable 
}
}
\references{
Singh R.K., Chaudhary B.D.(1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers 
}
\author{
Umesh R. Rosyara 
}
\examples{
data(linetester)
pls <- line.tester(dataframe = linetester, yvar = "trait1",  genotypes = "genotypes", 
replication = "replication",  Lines = "Lines", Testers = "Tester", gclass = "gclass" ) 
print(pls) 
}

