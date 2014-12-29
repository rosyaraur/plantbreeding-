\name{plotwith.map}
\alias{plotwith.map}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Chromosomal maps with or without scaled ticks 
}
\description{
The plot develops single chromsome map with specified maker positions and labels. 
In addoton to map, aligned scatter plot will be produced for addition variable (such as LOD score, 
minor allele frequency). The scatter plot can have points or lines or area as user specified. 
   
}
\usage{
plotwith.map(mapdata, ydata, yvar, position, marker, type = "l", ycol = "blue4", 
mbar.col = "gray20", ylab = "", cex.lab = 1, chr.lab = 1, ...) 
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{mapdata}{
dataframe with map information 
}
  \item{ydata}{
dataframe with information for y variable (such as LOD score, minor allele frequency) 
}
  \item{marker}{
name of marker column in mapdata  
}
  \item{position}{
name of column with position of markers in mapdata 
}
  \item{yvar}{
name of yvar column in ydata  
}
  \item{type}{
type of additional information plot (type used in graphical parameters from R/base). Use  
"p" for points, "l" for lines,"b" for both,"h" for ‘histogram’ like (or ‘high-density’) vertical lines. 

}
  \item{ycol}{
Y variable colour  
}
  \item{mbar.col}{
Map bar colour 
}
  \item{ylab}{
Y axis label 
}
  \item{cex.lab}{
The magnification to be used for x and y labels relative to the current setting of cex, in scatter plot
}
  \item{chr.lab}{
The magnification to be used for x and y labels relative to the current setting of cex, in map plot 
}
  \item{...}{
More graphical parameters can be passed to the scatter plot, help(par)
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
The plot return a plot where map is combined with scatter of line plot. 
%% ...
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
# Example 1 
#minor allele frequency
position= seq(1, 100, 0.1)
mapminor <- data.frame (position, minorallele = rnorm(length(position), 0.5, 0.2))

# map
position= seq (1, 100, 5)
mapdata <- data.frame (position, snpname = paste("SNP-1-", position, sep = ""))

plotwith.map(mapdata = mapdata, ydata = mapminor, yvar = "minorallele", 
position = "position", marker = "snpname", type = "l", ycol = "blue4", 
mbar.col = "gray20", ylab = "Minor Alele Frequency")

plotwith.map(mapdata = mapdata, ydata = mapminor, yvar = "minorallele",
 position = "position", marker = "snpname", type = "p", pch = "+", 
 ycol = "red4", mbar.col = "gray20", ylab = "Minor Alele Frequency")

plotwith.map(mapdata = mapdata, ydata = mapminor,yvar = "minorallele", 
position = "position", marker = "snpname", type = "b", pch = 19, ycol = "red4", 
mbar.col = "gray20", ylab = "Minor Alele Frequency")

plotwith.map(mapdata = mapdata, ydata = mapminor, yvar = "minorallele", 
position = "position", marker = "snpname", type = "h", pch = 19, ycol = "pink", 
mbar.col = "gray20", ylab = "Minor Alele Frequency")

plotwith.map(mapdata = mapdata, ydata = mapminor,yvar = "minorallele", 
position = "position", marker = "snpname", type = "c", pch = 19, 
ycol = "cadetblue", mbar.col = "gray20", ylab = "Minor Alele Frequency")

plotwith.map(mapdata = mapdata, ydata = mapminor,yvar = "minorallele", 
position = "position", marker = "snpname", type = "o", pch = 19, ycol = "darkgreen", 
mbar.col = "gray20", ylab = "Minor Alele Frequency", cex.lab = 3, chr.lab = 3)


}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
