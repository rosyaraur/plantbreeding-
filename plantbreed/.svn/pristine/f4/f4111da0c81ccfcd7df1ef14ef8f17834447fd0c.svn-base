\name{manhatton.circos}
\alias{manhatton.circos}
\title{
Polar and Cartesian Manhattan plots 
}
\description{
This function plots polar or Cartesian Manhattan plots. Different variations can be obtained by changing color or point type. 
}
\usage{
manhatton.circos(dataframe, SNPname, chromosome, position, pvcol, colour = "seablue", 
ymax = "maximum", ymin = "minimum", gapbp = 1000, type = "polar", geom = "point")
}
\arguments{
  \item{dataframe}{
Name of dataframe 
}
  \item{SNPname}{
Name of column with SNP name 
}
  \item{chromosome}{
Name of column with chromosome 
}
  \item{position}{
Name of column with physical / genetic positions 
}
  \item{pvcol}{
Name of column with p-value 
}
  \item{colour}{
Colour 
}
  \item{ymax}{
Upper limit to y axis (i.e. -log10 p value)
}
  \item{ymin}{
Lower limit to y axis (i.e. -log10 p value)
}
  \item{gapbp}{
Gap between consequtive groups, 0 if no gap is required  
}
  \item{type}{
Value "polar" is polar plot need to be produced, "regular" if regular catisian plot 
}
  \item{geom}{
type of geom to be plotted - example "point" (conventional) and "line" for line 
}
}
\author{
Umesh Rosyara 
}
\examples{

data12 <- data.frame (snp = 1: 2000*20 , chr = c(rep(1:20, each = 2000)), 
pos= rep(1:2000, 20), pval= rnorm(2000*20, 0.001, 0.005))

manhatton.circos(dataframe = data12, SNPname = "snp", chromosome = "chr",
 position = "pos", pvcol = "pval",ymax = "maximum", ymin = 0, gapbp = 500,
 type = "polar", colour = "multicolor", geom = "area")
 
manhatton.circos(dataframe = data12, SNPname = "snp", chromosome = "chr", position = "pos",
 pvcol = "pval",ymax = "maximum", ymin = 0, gapbp = 1000,
 type = "polar", colour = "multicolor" , geom = "point")
 
 manhatton.circos(dataframe = data12, SNPname = "snp", chromosome = "chr", 
 position = "pos", pvcol = "pval",ymax = "maximum", ymin = 0, gapbp = 1000,
 type = "polar", colour = "multicolor" , geom = "line")
 
  manhatton.circos(dataframe = data12, SNPname = "snp", chromosome = "chr", 
  position = "pos", pvcol = "pval",ymax = "maximum", ymin = 0, gapbp = 1000,
 type = "polar", colour = "multicolor" , geom = "jitter")    #
 
manhatton.circos(dataframe = data12, SNPname = "snp", chromosome = "chr", 
   position = "pos", pvcol = "pval",ymax = "maximum", ymin = 0, gapbp = 1000,
 type = "polar", colour = "multicolor" , geom = "path")
 
 manhatton.circos(dataframe = data12, SNPname = "snp", chromosome = "chr", position = "pos", 
    pvcol = "pval",ymax = "maximum", ymin = 0, gapbp = 1000,
 type = "polar", colour = "multicolor" , geom = "step")
 
manhatton.circos(dataframe = data12, SNPname = "snp", chromosome = "chr", position = "pos",
      pvcol = "pval",ymax = "maximum", ymin = 0, gapbp = 1000,
 type = "polar", colour = "multicolor" , geom = c("line","point"))
 
manhatton.circos(dataframe = data12, SNPname = "snp", chromosome = "chr", position = "pos", 
      pvcol = "pval",ymax = "maximum", ymin = 0, gapbp = 1000,
 type = "regular", colour = "multicolor" , geom = c("line","point"))


}

