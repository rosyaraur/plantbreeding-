\name{manhatton.plot}
\alias{manhatton.plot}

\title{
Manhattan plot of p-values 
}
\description{
The function develops Mahnattan plot of p-values scaled to -log10(p).  If polar type of Manhattan plot is desired use the function manhatton.circos. Manhattan plot (Gibson 2010) are popular in plotting association mapping results, however can be used to plot other results genome-wide. 
}
\usage{
manhatton.plot(dataframe, SNPname, chromosome, position, pvcol, ymax = "maximum",
 ymin = "minimum", gapbp = 500, pch = c(18, 19, 20), color = c("midnightblue", 
 "lightpink4", "blue"), line1, line2)
}

\arguments{
  \item{dataframe}{
dataframe with SNP name (SNPname), chromosome, physical position (position), p-value columns. 
}
  \item{SNPname}{
Name of variable consisting of SNP name - (eg. "SNPN")
}
  \item{chromosome}{
Name of variable column consisting of chromosome - ( eg. "chr")
}
  \item{position}{
Name of variable column consisting of physical position of SNPs - (eg. "physicaldis")
}
  \item{pvcol}{
Name of p-value column to be used for plotting, dataframe can consists of multiple p-value column, can be plotted one by one. 
Note that p-value should not contain zero or Inf or NaNs  
}
  \item{ymax}{
Maximum value to be plotted in Y axis, if ymax is less than 8, the plot will set the maximum to 8 otherwise user defined maximum.   
}
  \item{ymin}{
Minimum value to be plotted in X axis. 
}
  \item{gapbp}{
Gap between two adjecent chromsomome for plotting. Should be specified to scale of distances provided for X axis (ie. base pair). The default value is 500.  
}
  \item{pch}{
The list of symbol type used to plot in the plot, maximum allowed is equal to number of chrosomomes plotted. If the number is less than total number of chromosomes, the pch is recycled till end.
} 
  \item{color}{
The list of color type used to plot in the plot, maximum allowed is equal to number of chrosomomes plotted. 
If the number is less than total number of chromosomes, the color is recycled till end.
The number of color should be equal to number of pch. 
}
  \item{line1}{
Value at the point where you need to Horizental threshold line 1. NULL for no line 
}
  \item{line2}{
Value at the point where you need to Horizental threshold line 2. NULL for no line 
}
}
\details{
Most of plot prameters (not conflicting with specified here) can be applied to plot.   
}
\value{
Produce Manhattan plot 

}
\author{
Umesh Rosyara 
}
\examples{

# Example 1
data12 <- data.frame (snp = 1: 2000*20 , chr = c(rep(1:20, each = 2000)), 
pos= rep(1:2000, 20), pval= rnorm(2000*20, 0.001, 0.005))

manhatton.plot(dataframe = data12, SNPname = "snp", chromosome = "chr", 
position = "pos", pvcol = "pval",ymax = "maximum", ymin = 0,  gapbp = 500, 
color=c("hotpink3","dodgerblue4"), line1 = 3, line2 = 5, pch = c(1,20) )

manhatton.plot(dataframe = data12, SNPname = "snp", chromosome = "chr", position = "pos",
 pvcol = "pval",ymax = 10, ymin = 2,  gapbp = 500, color=c("dodgerblue4"), 
 line1 = 3, line2 = 5, pch = 20 )
   
manhatton.plot(dataframe = data12, SNPname = "snp", chromosome = "chr", position = "pos", 
pvcol = "pval",ymax = "maximum", ymin = 0,  gapbp = 500, 
color=c("midnightblue", "lightpink4", "blue"),
 line1 = 3, line2 = 5, pch = c("*", "+", "a") )
 
manhatton.plot(dataframe = data12, SNPname = "snp", chromosome = "chr", position = "pos", 
pvcol = "pval",ymax = "maximum", ymin = 0,  gapbp = 500, color= "cadetblue", 
line1 = 3, line2 = 5, pch = 19)

# all different color and pch example 
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", 
"#F0E442", "#0072B2", "#D55E00", "#CC79A7","#CD661D", "#FF00FF","#8B6508",
 "#D2691E","#008B00", "#8B1A1A",  "#8B3A62", "#8B864E", "#3CB371", "#8B5742",
  "#8B5A00", "#36648B")
                                                                                                                                                                       
manhatton.plot(dataframe = data12, SNPname = "snp", chromosome = "chr", position = "pos",
 pvcol = "pval",ymax = "maximum", ymin = 0,  gapbp = 500, color= cbPalette, 
 line1 = 3, line2 = 5, pch = 1:20)

# Example 2
set.seed(123)
data22 <- data.frame (snp = 1: 20000*5 , chr = c(rep(1:5, each = 20000)), 
pos= rep(1:20000, 5), pval1= rnorm(20000*5, 0.2, 0.3), 
pval2 = rnorm(20000*5, 0.2, 0.3) )
# the above simulation produce negative values so the following will replace 
# negative values with NA
data22$pval1[data22$pval1 < 0] <- NA
# removal of negative values 
dat2 <- data22[!is.na(data22$pval1),]
 
op <- par(mfrow=c(2,1), cex.axis = 0.75, font = 1, family = "serif")
par(op)
manhatton.plot(dataframe = dat2, SNPname = "snp", chromosome = "chr", position = "pos",
 pvcol = "pval1", line1 = 4, line2 = 8, ymax = "maximum", ymin = 0, gapbp = 2000)
title(main = "Mahattan plot of results for trait1", sub = "Method: Linear mixed model")

manhatton.plot(dataframe = dat2, SNPname = "snp", chromosome = "chr", position = "pos",
 pvcol = "pval2", line1 = 4, line2 = 8, ymax = "maximum", ymin = 0)
title(main = "Mahattan plot of results for trait2", sub = "Method: Linear mixed model")
 
}

