\name{map.fill.gplot}
\alias{map.fill.gplot}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Chromosome bar plot or LD block plot using ggplot2 
}
\description{
The function fills color between adjacent markers where color is scaled by continous variable such as linkage disequilibrium (LD block plot). The output is simar to that produced from function mapbar.plot however use ggplot2 instead of R/graphics.  
}
\usage{
map.fill.gplot(mapd = mapd, chr = "chr", label = "label", position = "position", 
filld = filld, fillcol = "fillcol", fcol1 = "blue", fcol2 = "red")
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{mapd}{
Map dataframe 
}
  \item{chr}{
Name of chromosome variable within the map dataframe  
}
  \item{label}{
Name of label variable in the map dataframe 
}
  \item{position}{
Name of map position variable within the map dataframe 
}
  \item{filld}{
Name of dataframe with phenotypic  data from n-1 intervals in each chromosomes from n markers 
}
  \item{fillcol}{
Name of variables used to fill chromosome segments 
}
  \item{fcol1}{
The first color to be used to brew color gradient within ggplot2 
}
  \item{fcol2}{
The second color to be used to brew color gradient within ggplot2 
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
 #data 1:
lab1 <- 1:10
chr <- rep(1:3, each = length (lab1))
label <- rep(lab1, 3)
position <-  rep(c(0, 1, 4, 5, 6, 8, 10,  11, 12,  13), 3)
mapd<- data.frame (chr, label, position)

# data 2
 
fillcol <- rep(rnorm(length(lab1)-1, 0.5, 0.2), 3)
chr <- rep(1:3, each = length(fillcol)/3)
 # this variable will be used to fill color in bars
 filld <- data.frame(chr, fillcol)    
 map.fill.gplot(mapd = mapd, chr = "chr", label = "label", position = "position",
   filld = filld, fillcol = "fillcol", fcol1 = "green", fcol2 = "red")  
 
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
