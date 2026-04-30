\name{plantbreeding-package}
\alias{plantbreeding-package}
\alias{plantbreeding}
\docType{package}
\title{
Analysis of data from plant breeding and genetics experiments 
}
\description{
Plant breeding is science of altering the genetics of plants in order to create desired characteristics for food, energy, medicine, industry and environmental purposes in cultivars. Plant breeding is interdisciplinary applied science involve application of diverse disciplines including genetics, statistics, plant pathology, entomology, plant physiology and other  agricultural and biological sciences.
 Data analysis and visualization is very important in plant breeding research area and this package is developed with objective of analysis of conventional and molecular data using different functions implemented in the robust R statistical analysis environment. 
 In addition to development of new functions, examples are provided with analysis command to demonstrate how R can be used in analysis and visualization of data from plant breeding and genetics experiments. 
This adds-on package contains functionality for analysis and visualization data from plant breeding experiments. Analysis includes both conventional quantitative genetics as well as molecular breeding tools. The library also consists of example datasets and codes to perform different analysis relevant to plant breeders depending upon other R packages. 


}
\details{
\tabular{ll}{
Package: \tab plantbreeding\cr
Type: \tab Package\cr
Version: \tab 1.1\cr
Date: \tab 2014-12-14\cr
License: \tab GPL (>= 2)\cr
}


The package contains different functionalities relevant to analysis of data from both conventional and molecular plant breeding and genetics experiments. The functionalities include analysis of designs specific to plant breeding needs such as  Augmented block designs,  Genotype x Environment and stability , variance component and combining ability estimations (eg. Diallel analysis, North Carolina designs, LinexTester), Heritability and Genetic correlation estimation, selection index. Beside classical breeding tools functionalities and examples provide different molecular analysis tools such as genetic  map construction, - QTL mapping, association mapping and genomic selection. There are other relevant utilities relevant to handling of moderate to large datasets. Also the package includes functions for visualization of population and genetic gain under selection as well as genome or chromosome wide visualization tools fitted to needs of molecular breeding tools. General R functions are also integrated with to guide new user who have limited experience of using R.  

}
\author{
Umesh R Rosyara

Maintainer: Umesh Rosyara <rosyara@msu.edu>, <rosyaraur@gmail.com>
}
\references{
Allard R.W.(1999) Principles of Plant Breeding, John Wiley and Sons, May 10, 1999 - 254 pages

Sleper D.A.(2006) Poehlman J.M. Breeding Field Crops, Blackwell Pub., Jul 25, 2006 - 424 pages

Hill J.,  Becker H.C.,  Tigerstedt P.M. A. (1998) Quantitative and Ecological Aspects of Plant Breeding, Springer, 1998 - 275 pages

Lynch M., Walsh B. (1998). Genetics and Analysis of Quantitative Traits. Sinauer, Sunderland, MA

Falconer D. S., Mackay T.F.C. (1996). Introduction to Quantitative Genetics. Fourth edition. Addison Wesley Longman, Harlow, Essex, UK.

Mather K., Jinks J.L. (1971). Biometrical Genetics. Chapman & Hall, London.

Sorensen D., Gianola D.(2002). Likelihood, Bayesian, and MCMC Methods in Quantitative Genetics. Springer 739 pp.

Singh R.K., Chaudhary B.D.(1985) Biometrical Methods in Quantitative Genetics Analysis, Kalyani Publishers

Saxton A. (2004) Genetic Analysis of Complex Traits Using SAS. SAS Institute, Inc.

Littell R.C.(2006) SAS for Mixed Models,SAS Institute, Inc.

Broman K.W., Sen S. (2009) A Guide to QTL Mapping with R/qtl. SBH/Statistics for Biology and Health. Springer 

Wickham H. (2009)  ggplot: Elegant Graphics for Data Analysis. Use R. Springer.

Sarkar D. (2008) Lattice: Multivariate Data Visualization with R. Springer, New York

}
\keyword{ package }
\seealso{
 \code{\link[onemap:onemap-package]{onemap}} 

\code{\link[qtl:qtl-package]{qtl}} 

\code{\link[agricolae:agricolae-package]{agricolae}}

}

\examples{

# load the package 
library(plantbreeding)
require (plantbreeding)

# seek help about the package 
help(plantbreeding)
library(help = plantbreeding)

# list of dataset in the package 
data(package="plantbreeding") 

# list all objects in the package 
ls("package:plantbreeding")

# load a dataset from the library - for example dataset nassociation  
data (nassociation)

# seek help on particular function, example map.plot  
help (map.plot)
?map.plot 

# example of applying a function 


# Example 1 : Diallele analysis 
require(plantbreeding)
data(fulldial) 
 out <-diallele1(dataframe = fulldial, male = "MALE", female = "FEMALE",  
 progeny = "TRT", replication = "REP", yvar = "YIELD" )
print(out) 
out$anvout # analysis of variance 
out$anova.mod1 # analysis of variance for GCA and SCA effects 
out$components.model1 # model1 GCA, SCA and reciprocal components 
out$gca.effmat # GCA effects
out$sca.effmat # SCA effect matrix
heatmap(out$sca.effmat, labRow = rownames(out$sca.effmat) ,
labCol = colnames(out$sca.effmat)) # heatmap plot of SCA matrix 
out$reciprocal.effmat # reciprocal effect matrix 


# Example 2: Stability, AMMI analysis 
# stability analysis 
require(plantbreeding)
data(multienv)
out <- stability (dataframe = multienv , yvar = "yield", genotypes = "genotypes", 
environments = "environments", replication =  "replication")
print(out)

# AMMI analysis 
results <- ammi.full(dataframe = multienv , environment = "environments", genotype = "genotypes", 
replication = "replication", yvar = "yield")
print(results)


# Example 3 : Analysis of Augumented row column block designs 
data(rowcoldata)
outp <- aug.rowcol(dataframe = rowcoldata, rows = "rows", columns = "columns",
 genotypes = "genotypes", yield = "yield")
outp$ANOVA # analysis of variance 
outp$Adjustment # adjusted values



#### Example 4: Mahattan plots for association mapping results 
set.seed (1234) 
data12 <- data.frame (snp = 1: 2000*20 , chr = c(rep(1:20, each = 2000)), pos= rep(1:2000, 20), 
pval= rnorm(2000*20, 0.001, 0.005))
manhatton.plot(dataframe = data12, SNPname = "snp", chromosome = "chr", position = "pos",
 pvcol = "pval",ymax = "maximum", ymin = 0, gapbp = 500, color=c("hotpink3","dodgerblue4"), 
 line1 = 3, line2 = 5, pch = c(1,20) ) 
   
}
