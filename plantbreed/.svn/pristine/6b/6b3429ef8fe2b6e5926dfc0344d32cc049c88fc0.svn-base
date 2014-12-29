\name{diversity}
\alias{diversity}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Diversity analysis 
}
\description{
This function pricipal component analysis, cluster analysis and development of heatmap plot.  
}
\usage{
diversity(dataframe, varcol = 2:length(dataframe), xvar = "genotype", 
yvarlab = "marker",dendocol = "blue4", cor = TRUE, heatcol = cm.colors(256), 
rc = rainbow(nrow(tvar),start = 0, end = 0.3),  cc = rainbow(ncol(tvar), 
start = 0, end = 0.3), method = "ward", scale = "column", ...)
  
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{dataframe}{
Name of dataframe 
}
  \item{varcol}{
Name of numerical variable column used in pricipal component analysis, cluster analysis and heatmap plot.
The default is second column to end column of the dataframe (2:length(dataframe)) 
}
  \item{xvar}{
Name of Xvar column, name of observation column 
}
  \item{yvarlab}{
Name of y variable label  
}
  \item{dendocol}{
Line colour for dendogram, default is "blue4"  
}
  \item{cor}{
%%     ~~Describe \code{cor} here~~
}
  \item{heatcol}{
colour for main area of heapmap plot 
}
  \item{rc}{
vector with row colour for heatmap 
}
  \item{cc}{
vector with column colour for heatmap  
}
  \item{method}{
the agglomeration method to be used for creating dendogram. This should be (an unambiguous abbreviation of) 
one of "ward", "single", "complete", "average", "mcquitty", "median" or "centroid".
}
  \item{keep.dendro}{
for heatmap plot: logical indicating if the dendrogram(s) should be kept as part of the result (when Rowv and/or Colv are not NA).
}
  \item{scale}{
for heatmap plot: character indicating if the values should be centered and scaled in either the row direction or the column direction, or none. 
The default is "row" if symm false, and "none" otherwise. 
}
  \item{\dots}{
Other heatmap plot parameters can be passed as argument, see help(heatmap) 
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
In addition to four plots: screeplot, biplot,dendogram and heatmap plot, the output object will be list of following components: 
\item{pca.results}{output of Pricipal component results, for detail help(prcomp) }
\item{Hclust}{output of cluster analysis, for details help(hclust)}
\item{hv}{output of heatmap plot, for details help(heatmap)}
}
\references{
%% ~put references to the literature/web site here ~
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

# default setting
data(variability)
out <- diversity(variability)

# or samething as above with detail code
out <- diversity(dataframe = variability, varcol = 2:length(variability), 
xvar = "genotype",
 yvarlab = "marker", dendocol = "blue4", cor = TRUE,heatcol = cm.colors(256), 
 RowSideColors = rainbow(100, start = 0, end = 0.3), 
 ColSideColors = rainbow(10, start = 0, end = 0.3), method = "ward", 
 scale = "column")

# some variation, using subset of markers, different clustering method    
out1 <- diversity(dataframe = variability, varcol = 2:21, xvar = "genotype", 
yvarlab = "marker", dendocol = "blue4", cor = TRUE,heatcol = cm.colors(256),
 RowSideColors = rainbow(20, start = 0, end = 0.3), ColSideColors = rainbow(10, 
 start = 0, end = 0.3), method = "single", scale = "column")

# random selected columns 
out2 <- diversity(dataframe = variability, varcol = sample(2:101, 20), 
xvar = "genotype",  yvarlab = "marker", dendocol = "black", cor = TRUE, 
heatcol = cm.colors(256), RowSideColors = rainbow(20, start = 0, end = 0.3), 
ColSideColors = rainbow(10, start = 0, end = 0.3), 
method = "ward", scale = "column")

# heatmap row and column color based on user defined categories
cc1 <- c(rep(c("red", "purple", "green", "blue", "pink"), each = 2))
rc1 <- colors()[2:21]
out3 <- diversity(dataframe = variability, varcol = 2:21, xvar = "genotype", 
yvarlab = "marker",  dendocol = "black", cor = TRUE, heatcol = heat.colors(256),
 RowSideColors = rc1,  ColSideColors = cc1, method = "ward", scale = "column")
 
# heatmap plot without side colors and dendograms, no scaling 
out4 <- diversity(dataframe = variability, Rowv = NA, Colv = NA, varcol = 2:21, 
xvar = "genotype", yvarlab = "marker", dendocol = "black", cor = TRUE, 
heatcol = topo.colors(256), method = "ward", keep.dendro = FALSE, scale = "none")

# heatmap plot without side colors and dendograms at column only, no scaling
cc2 <- c("#F0FFFF", "#00008B", "#006400", "#FF7256", "#8B0A50", "#696969", 
 "#ADFF2F", "#BEBEBE", "#8B0000", "#FFB90F") 
 
out4 <- diversity(dataframe = variability, Rowv = NA,ColSideColors = cc2, 
varcol = 2:21, xvar = "genotype", yvarlab = "marker", dendocol = "black", cor = TRUE, 
heatcol = cm.colors(256), method = "ward", keep.dendro = FALSE, scale = "none")

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
