\name{rqtl2mapchart}
\alias{rqtl2mapchart}

\title{
Convert R/qtl object to mapchart 
}
\description{
The function converts R/qtl (Broman and Sen 2009) object to mapchart file (Voorrips, 2002). Mapchart is one of popular free (license can be requested) software. 
}
\usage{
rqtl2mapchart(crossobj,outobj=, trait = "1", chr = c(1, 2, 3))
}
\arguments{
  \item{crossobj}{
R/qtl cross object 
}
  \item{outobj}{
R/qtl output object 
}
  \item{trait}{
Trait name to be used to produce mapchart chart  
}
  \item{chr}{
Chromosomes  to be plotted for QTL, those chromosomes  with QTL present 
}
}
\references{
Broman K.W., Sen S. (2009) A Guide to QTL Mapping with R/qtl. SBH/Statistics for Biology and Health. Springer 

Voorrips, R.E., 2002. MapChart: Software for the graphical presentation of linkage maps and QTLs. The Journal of Heredity 93 (1): 77-78.
http://www.biometris.wur.nl/uk/Software/MapChart/
}
\author{
Umesh Rosyara 
}
\examples{

#example 1
require(qtl)
data(hyper)
hyper <- calc.genoprob(hyper, step=2.5)
out.em <- scanone(hyper, method="em")
rqtl2mapchart(crossobj = hyper,outobj=out.em, trait = "obs", chr = c(1, 2, 5, 9))
#Example 2
   data(rqtldata)
   mydata <- calc.genoprob(rqtldata, step=1, error.prob=0.001)
  # standard interval mapping   using EM algorithm
   out.em <- scanone(rqtldata, method="em")
     summary (out.em, threshold=3)
    plot(out.em, chr=c(1,2))
    rqtl2mapchart (rqtldata,out.em, trait = "obs", chr = c(1))
    getwd() # the output file will be in the working directory 
 }

