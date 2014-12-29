\name{rqtldata}
\alias{rqtldata}
\docType{data}
\title{
QTL mapping example data
}
\description{
The simulated dataset consists of two traits and 2 chromosomes for qtl mapping using R/qtl (Broman et al. 2003, Broman and Sen 2009). R/qtl is meta-package include several functions to create maps and qtl mapping (interval, composite interval and multiple QTL mapping). 
}
\usage{data(rqtldata)}
\format{
 The data is R/qtl of class "f2" and "cross".  
}
\source{
Simulated data 
}
\references{
Broman K.W., Sen S. (2009) A guide to QTL mapping with R/qtl. Springer

Broman K.W., Wu H., Sen S., Churchill G.A. (2003) R/qtl-QTL mapping in experimental crosses. Bioinformatics 19, 889-890.

Lander E.S., Botstein D. (1989) Mapping Mendelian factors underlying quantitative traits using RFLP linkage maps. Genetics 121, 185-199.

Haley C.S., Knott S.A. (1992) A simple regression method for mapping quantitative trait loci in line crosses using flanking markers. Heredity 69, 315-324.

Sen S., and Churchill G.A. (2001) A statistical framework for quantitative trait mapping. Genetics 159, 371-387. 

Lincoln S.E., Lander E.S. (1992) Systematic detection of errors in genetic linkage data. Genomics 14, 604-610.

Please cite Broman et al.( 2003) and Broman and Sen (2009), if you use qtl in mapping. 

}
\examples{
   data(rqtldata)
   require(qtl)
   ??qtl # for help 
   summary (rqtldata) # provide brief summary of the dataset
   # visualizing the dataset  
    plot.pheno(rqtldata, pheno.col=1, col = "blue")# plot histogram of trait 1
    plot(rqtldata)
   # graphical genotype
    geno.image(rqtldata, reorder=FALSE)
  
  # marker regression
   out.mr <- scanone(rqtldata, method="mr")
   out.mr
   mydata <- calc.genoprob(rqtldata, step=1, error.prob=0.001)
  # standard interval mapping   using EM algorithm
   out.em <- scanone(rqtldata, method="em")
   summary (out.em, threshold=3)
    plot(out.em, chr=c(1,2))
    
  # Haley-Knott regression
  mydatacross <- calc.genoprob(rqtldata, step=1, error.prob=0.001)
  out.hk <- scanone(rqtldata, method="hk")
 
 # Extended Haley-Knott regression
   mydatacross <- calc.genoprob(rqtldata, step=1, error.prob=0.001)
  out.ehk <- scanone(rqtldata, method="ehk")

 # Multiple imputation
  mydatacross <- sim.geno(rqtldata, step=1, n.draws=64, error.prob=0.001)
  out.imp <- scanone(rqtldata, method="imp")

 # Interval estimates of QTL location
 # 1.5-LOD support for chromosome 4 QTL
 lodint(out.em, 2, 1.5)
 # 95% Bayes credible intervals chromosome 4 QTL
bayesint(out.em, 2, 0.95)
# bootstrap-based confidence interval
out.boot <- scanoneboot(rqtldata, chr=2, n.boot=1000)
out.boot
plot(out.boot)
summary(out.boot)

# Multiple QTL model
# Composite interval mapping
out.cim.20 <- cim(rqtldata, n.marcovar=3, window=20)
out.cim.20

# Two-dimensional, two-QTL scans
mycrossdata <- calc.genoprob(rqtldata, step=2.5, err=0.001)
out2 <- scantwo(rqtldata, verbose=FALSE, method = "em")

# multi-dimensional, multiple-QTL scans
mq.rqtldata <- mqmaugment(rqtldata, minprob=0.001) # data augumentation
mq.rqtldata.out <- mqmscan(mq.rqtldata)
summary(mq.rqtldata.out, lod =3)
plot(mq.rqtldata.out,out.cim.20, col = c("red","blue"))
 
# there are many functions available please refer to R/qtl documentation 

}
\keyword{datasets}
