\name{stability}
\alias{stability}

\title{
Stability analysis based on Eberhart and Russell (1966) model  
}
\description{
The function implements the Eberhart and Russell (1966) model for stability analysis. 
}
\usage{
stability(dataframe, yvar, genotypes, environments, replication)
}

\arguments{
  \item{dataframe}{
dataframe with Y variables, genotype, environment, and replication  
}
  \item{yvar}{
Name of Y variable 
}
  \item{genotypes}{
Name of genotype variable 
}
  \item{environments}{
Name of environments variable 
}
  \item{replication}{
Name of replication variable 
}
}
\references{
Eberhart S.A.,  Russell W.A. (1966) Stability parameters for comparing varieties. Crop Sci. 6: 36-40.

Singh R.K., Chaudhary B.D.(1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers
}
\author{
Umesh R Rosyara 
}
\examples{
yvar <- c( 36.4, 40.0, 32.4, 33.5, 41.3, 27.9, 38.5, 38.6, 41.6, 22.6,
           41.3, 38.9, 30.9, 40.1, 43.6, 36.3, 43.0, 29.6, 34.4, 35.1,
           51.7, 37.1, 25.5, 47.4, 39.5, 36.1, 40.6, 28.6, 32.8, 33.0,
           22.6, 42.6, 52.8, 20.3, 38.3, 39.4, 36.5, 31.7, 22.8, 33.2,
           39.4, 28.2, 45.8, 28.6, 35.4, 36.5, 37.4, 21.0, 25.4, 28.3,
           30.2, 29.5, 32.9, 29.5, 47.6, 40.3, 30.8, 30.1, 34.5, 35.8,
           21.8, 27.1, 28.6, 25.5, 28.5, 24.5, 27.1, 25.4, 22.4, 32.4,
           26.4, 27.7, 36.8, 21.5, 29.6, 31.5, 25.8, 17.3, 24.3, 24.3,
           22.6, 17.7, 35.5, 32.8, 25.8, 28.8, 28.0, 24.8, 26.7, 29.8,
           31.2, 20.2, 28.0, 21.3, 36.9, 41.2, 27.9, 20.6, 20.9, 20.8,
           25.4, 29.7, 26.3, 33.7, 29.8, 27.3, 25.9, 25.3, 30.2, 17.8,
           23.7, 23.9, 32.2, 34.7, 30.6, 28.3, 27.2, 23.9, 23.8, 15.0,
           24.3, 28.2, 20.3, 32.3, 18.5, 28.1, 22.0, 30.7, 32.4, 26.1,
           34.3, 30.2, 25.6, 28.1, 29.2, 40.1, 28.2, 27.7, 37.0, 32.4, 
           36.5, 30.1, 35.1, 28.2, 34.5, 42.1, 38.7, 15.1, 25.4, 38.7 )

          
replication <- c( rep(c(rep(1, 10), rep(2,10), rep(3,10)),5))
genotypes <- c(rep(paste("G", 1:10, sep= ""), 15))
environments <- c(rep(c("CB","CA", "CC", "MN","SD"), each = 30))
mydf1 <- data.frame (yvar, replication, genotypes, environments)

out <- stability (dataframe = mydf1 , yvar = "yvar", genotypes = "genotypes", 
environments = "environments", replication =  "replication")
# print out 
out 
}

