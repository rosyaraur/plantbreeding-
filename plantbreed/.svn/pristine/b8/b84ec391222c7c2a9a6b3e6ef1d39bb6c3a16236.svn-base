\name{histlab}
\alias{histlab}
\title{
Plotting histograms with labelled with arrows
}
\description{
The function generates one or multiple faceted histograms where arrows can be added to certain frequency class defined by user.
This graph is useful to identify certain individual belongs to. For example, position on X where parents of population belong to.
One or multiple arrows can be added to histogram.    
}
\usage{
histlab(dataframe, classvar = "class", yvar = "yvar", arrow_yvar, arrow_label, 
arrow_class, bwidth, colour = "cyan4", fill = "cyan4")
}
\arguments{
  \item{dataframe}{
Dataframe with at least class variable and y variable column (whose frequency distribution need to be plotted). 
}                                     
  \item{classvar}{
Class variable (for example population name) is required (even with single class variable mention a single name in the class variable column)  
}
  \item{yvar}{
Name of Y variable (whose frequency distribution need to be plotted) 
}
  \item{arrow_yvar}{
Y variable vector that whose position in histogram need to be potted with an arrow  
}
  \item{arrow_label}{
Label for vector whose position in histogram is potted with an arrow  
}
  \item{arrow_class}{
Class variable vector whose position in histogram is potted with an arrow
}
  \item{bwidth}{
Bin width for the histogram 
}
  \item{colour}{
Color for lines of the histogram 
}
  \item{fill}{
Colour need to be filled in the histogram. 
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
The function produce histograms. 
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
Umesh R Rosyara 
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
set.seed(123)
myd <- data.frame (class = rep(1:4, each = 100), yvar = rnorm(400, 50, 30))

# arrow label
class = c(2,3,3,4,4)
name = c  ("geno4", "P3", "P1", "P2", "S1")
yvar = c(104.0, 8.5,80.0,40.0, 115.0)

histlab(dataframe = myd, classvar = "class", yvar = "yvar", arrow_yvar = yvar, 
arrow_label = name, arrow_class = class,  bwidth = 20, colour = "blue", fill = "red")
  
# example 2
set.seed(123)
breedpop <- data.frame (population = rep(paste( "Pop", 1:3,sep = "-"), each = 100), 
yvar = rnorm(300, 50, 30))

# arrow label
population = c("Pop-1", "Pop-1", "Pop-2", "Pop-2","Pop-3", "Pop-3" )
parents = c  ("Res101", "Suc102", "P1", "P2", "L101-3-2","L101-3-3")
yvar1 = c(0, 80, 14, 75, 14, 75)

histlab(dataframe = breedpop, classvar = "population", yvar = "yvar", 
arrow_yvar = yvar1, arrow_label = parents, arrow_class = population,
  bwidth = 20, colour = "green", fill = "lightseagreen")

# example 3, single population
set.seed(123)
pop2 <- data.frame (population = rep ("RxL", 500), yvar2 = rnorm(500, 0, 1))

# arrow label
population = c("RxL", "RxL" )
parents = c  ("line1", "line2")
yvar2 = c(0.5, 1.5)

histlab(dataframe = pop2, classvar = "population", yvar = "yvar2", arrow_yvar = yvar2,
 arrow_label = parents, arrow_class = population,  bwidth = 0.1, colour = "salmon", 
 fill = "lightsalmon")
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{}
\keyword{}% __ONLY ONE__ keyword per line
