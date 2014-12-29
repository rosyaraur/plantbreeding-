\name{kinassocd}
\alias{kinassocd}
\docType{data}
\title{
Association mapping population data with pedigree information  
}
\description{
%%  ~~ A concise (1-5 lines) description of the dataset. ~~
}
\usage{data(kinassocd)}
\format{
'data.frame':   115 obs. of  1007 variables:

 ..$ id      : Id of the indivudals
 
 ..$ dadid   : Father (parent 1) ID
 
 ..$ momid   : Mother (parent 2) ID
 
 ..$ sex     : 1 for Male, 2 for female 
 
 ..$ trait1  : trait values 
 
 ..$ covtrait: covariate trait
 
 ..$ status  : status - binomial variable 0 (resistant), 1 (susceptiple)
  
 ..$ SNP1    : SNP genotype ( AA, AB and BB classes)
 
      ............... so on 
      
  ..$ SNP 2 to SNP 1003: SNP genotype (AA, AB and BB respectively)
     
}
\details{
%%  ~~ If necessary, more details than the __description__ above ~~
}
\source{
Simulated dataset 
}
\references{
Atkinson B, Therneau T (2009) kinship: mixed-effects Cox models, sparse matrices, and modeling data from large pedigrees The Comprehensive R Archive Network
}
\examples{
data(kinassocd)
out <- assoc.kin (dataframe = kinassocd,  yvar = "trait1", xvars = 8:length(kinassocd),
 id = "id", dadid = "dadid", momid = "momid", sex = "sex", model = "DOM")

# map 
CHR <- c(rep(1, 250), rep(2, 250), rep(3, 250), rep(4, 250))
BP <- rep (1:250,4)
results <- data.frame (out, CHR,BP) 

manhatton.plot(dataframe = results, SNPname = "markers", chromosome = "CHR", 
position = "BP", pvcol = "pvalue", ymax = "maximum", ymin = "minimum", 
gapbp = 50, pch = c(19, 20), color = c("midnightblue", "lightpink4"), line1 = 1,
 line2 = 2)

manhatton.circos(dataframe = results, SNPname = "markers", chromosome = "CHR",
 position = "BP",  pvcol = "pvalue",ymax = "maximum", ymin = 0, gapbp = 50,
 type = "polar", colour = "multicolor", geom = "point")
 
manhatton.circos(dataframe = results, SNPname = "markers", chromosome = "CHR",
 position = "BP", pvcol = "pvalue",ymax = "maximum", ymin = 0, gapbp = 50,
 type = "polar", colour = "multicolor", geom = "line") 
 
 manhatton.circos(dataframe = results, SNPname = "markers", chromosome = "CHR", 
 position = "BP",   pvcol = "pvalue",ymax = "maximum", ymin = 0, gapbp = 50,
 type = "regular", colour = "multicolor", geom = "line") 
 
  manhatton.circos(dataframe = results, SNPname = "markers", chromosome = "CHR", 
  position = "BP", pvcol = "pvalue",ymax = "maximum", ymin = 0, gapbp = 50,
 type = "regular", colour = "multicolor", geom = "point")

}
\keyword{datasets}
