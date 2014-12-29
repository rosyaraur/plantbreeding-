\name{plotblock}
\alias{plotblock}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Plot complete block designs 
}
\description{
The function create map (graph) for plot layout of complete block designs 
}
\usage{
plotblock(label,plotn,  nrow, ncol, g.col = 0.49, g.row = 0.45, l.pos = -0.2,
 fill = "azure2", h = c(0,360), psize = 3, lsize = 3)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{label}{
Vector with label for each plot (name of treatments)
}
  \item{plotn}{
Vector with plot number 
}
  \item{nrow}{
Number of rows (plots per plots)
}
  \item{ncol}{
Number of column (number of blocks)
}
  \item{g.col}{
gap between two columns (a value between 0.0 and 0.5 (0.5 being no gap), 
option depend upon the output plot window size and shape  
}
  \item{g.row}{
gap between two rows (a value between 0.0 and 0.5 (0.5 being no gap), 
option depend upon the output plot window size and shape
}
  \item{l.pos}{
determines whether the plot levels in comparision to treatment levels.
The suggessted value -0.3 to -0.1 or 0.3 to 0.1 
negative value puts level below the name of treatments
positive values places the plot name above the name of treaments. 
}
  \item{fill}{
Color need to filled in plot areas, if value is "Treatment", then each treatment will have different color depending upon hue defined by h  
}
  \item{h}{
hue value for color, 0 to 360, applicable when fill = "Treatment" 
}
  \item{psize}{
 size of plot number text  
}
  \item{lsize}{
size of label size text  
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
# example 1
genotypes = paste ("EL", 1:20, sep= "")
treatment <- c(sample(genotypes), sample(genotypes), sample(genotypes),
sample( genotypes), sample(genotypes))
plot.number = 1:length (treatment)
dev.new(width= 12, height= 6)
plotblock(label = treatment, plotn = plot.number,  nrow = 5 , 
ncol = length (genotypes), g.col = 0.49, g.row = 0.49, fill = "azure2", l.pos = -0.2)

# color coded 
plotblock(label = treatment, plotn = plot.number,  nrow = 5 , ncol = length (genotypes),
 g.col = 0.49, g.row = 0.49, fill = "treatment", l.pos = -0.2, h = c(0, 200))

plotblock(label = treatment, plotn = plot.number,  nrow = 5 , ncol = length (genotypes), 
g.col = 0.49, g.row = 0.49, fill = "treatment", l.pos = -0.2, h = c(90, 180))

plotblock(label = treatment, plotn = plot.number,  nrow = 5 , ncol = length (genotypes),
 g.col = 0.49, g.row = 0.45, fill = "gray80", l.pos = 0.2)
 
plotblock(label = treatment, plotn = plot.number,  nrow = 5 , ncol = length (genotypes),
 g.col = 0.49, g.row = 0.49, fill = "gray80", l.pos = 0.2)
 
plotblock(label = treatment, plotn = plot.number,  nrow = 5 , ncol = length (genotypes),
 g.col = 0.45, g.row = 0.45, fill = "antiquewhite", l.pos = 0.2)
 
plotblock(label = treatment, plotn = plot.number,  nrow = 5 , ncol = length (genotypes), 
g.col = 0.45, g.row = 0.45, fill = "cornsilk", l.pos = 0.2)

plotblock(label = treatment, plotn = plot.number,  nrow = 5 , ncol = length (genotypes),
 g.col = 0.45, g.row = 0.49, fill = "cadetblue1", l.pos = 0.2)

# example 2

# randomization 
set.seed(1) 
ntrt = LETTERS[seq( from = 1, to = 10 )]                            
repl <- rep (1:4, each = length (ntrt))
nsam = as.vector(replicate(4, sample(ntrt)))
plot.number <- 1:length (nsam)
newd <- data.frame (repl, nsam, plot.number)

plotblock(label = nsam, plotn = plot.number,  nrow = 4 , ncol = length (ntrt),
 g.col = 0.49, g.row = 0.49, fill = "azure2", l.pos = -0.2)

}
\keyword{}
\keyword{}% __ONLY ONE__ keyword per line
