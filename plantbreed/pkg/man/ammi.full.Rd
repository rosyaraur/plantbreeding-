\name{ammi.full}
\alias{ammi.full}

\title{
Additive Main Effects and Multiplicative Interaction (AMMI) analysis  
}
\description{
The function implements Additive Main Effects and Multiplicative Interaction (AMMI) analysis for multiple evironmentenvironment replicated data.  AMMI analysis (Gauch 1992) is one of popular tool in GE analysis and particularly effective for depicting adaptive responses. In this process, after genotype and environment main effects in the model, the interaction is retained as multiplicative term in the statistically significant GE-interaction principal-component (PC) axes. 

The results of AMMI can be visualized as biplot (Gower and Hand 1996). 
}
\usage{
ammi.full(dataframe, environment, genotype, replication, yvar)
}
\arguments{
  \item{dataframe}{
dataframe objet 
}
  \item{environment}{
Name of environment (location or year) variable 
}
  \item{genotype}{
Name of genotype variable 
}
  \item{replication}{
Name of replication variable 
}
  \item{yvar}{
Name of Y variable to be used in the analysis 
}
}
\references{
Gauch H.G.(1992). Statistical analysis of regional yield trials:AMMI analysis of factorial designs. Elsevier, Amsterdam.

Gauch H.G. (2006). Statistical analysis of yield trials by AMMI and GGE. Crop Sci. 46:1488-1500.

Gauch H.G.,  Zobel.R.W. (1996). AMMI analysis of yield trials. p.85-122. In M.S. Kang and H.G. Gauch, Jr. (ed.) Genotype-byenvironment
interaction. CRC Press, Boca Raton, FL.

Gower J.C., Hand D.J. (1996). Biplots. Monographs on Statistics and Applied Probability. London, UK: Chapman & Hall

}
\author{
Umesh Rosyara 
}
\examples{

# Example: AMMI analysis 
data(multienv)
results <- ammi.full(dataframe = multienv , environment = "environments", genotype = "genotypes",
 replication = "replication", yvar = "yield")
print(results)


}
