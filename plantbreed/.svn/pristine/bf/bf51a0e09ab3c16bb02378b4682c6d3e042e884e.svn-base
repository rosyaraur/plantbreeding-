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
Gauch H.G.(1992). Statistical analysis of regional yield trials:AMMI analysis of factorial designs. Elsevier, Amsterdam.

Gauch H.G. (2006). Statistical analysis of yield trials by AMMI and GGE. Crop Sci. 46:1488-1500.

Gauch H.G.,  Zobel.R.W. (1996). AMMI analysis of yield trials. p.85-122. In M.S. Kang and H.G. Gauch, Jr. (ed.) Genotype-byenvironment
interaction. CRC Press, Boca Raton, FL.

Gower J.C., Hand D.J. (1996). Biplots. Monographs on Statistics and Applied Probability. London, UK: Chapman & Hall

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

# Example: AMMI analysis 
data(multienv)
results <- ammi.full(dataframe = multienv , environment = "environments", genotype = "genotypes",
 replication = "replication", yvar = "yield")


# plot means 
myd <- melt(results$means)
 require(ggplot2)
 d <- ggplot(myd, aes(genotype, value)) + geom_bar(fill = c("cadetblue"))
 d + facet_wrap(~ environment) + theme_bw()

# plot PCA scores 
 myd2 <- data.frame (results$pc.scrs)
 # genotype 
 mydgen <- myd2[myd2$category =="genotype",]
 d1 <- ggplot(mydgen, aes(PC1, PC2)) + geom_point() +
  geom_text (aes (label = row.names (mydgen)), colour = "blue", hjust=1.2, vjust=0) + 
   ylab ("PC2") + xlab ("PC1") + theme_bw()
 print(d1)
 
 #environment 
  mydenv <- myd2[myd2$category =="environment",]
  d2 <- ggplot(mydenv, aes(PC1, PC2)) + geom_point() +
  geom_text (aes (label = row.names (mydenv)), colour = "red",hjust=1.2, vjust=0) +  
  ylab ("PC2") + xlab ("PC1") + theme_bw()
  print(d2)
 
# heatmap plot 
heatmap (results$means, col = rev(cm.colors (10)))

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
