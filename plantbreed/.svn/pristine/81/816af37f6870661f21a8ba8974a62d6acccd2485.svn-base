\name{AUDPC.cal}
\alias{AUDPC.cal}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Calculation of Area Under Disease / Pest Progress Curve 
}
\description{
The function calculates area under disease / pest progress curve (Jeger and Viljanen-Rollinson 2001; Madden et al. 2007).
The area under the disease / pest progress curve (AUDPC) is a useful quantitative summary of disease or pest intensity over time.
The trapezoidal method is the most frequently used method for estimating the AUDPC.This method discretize the time in different units(hours, days, weeks, months, or years)
and then calculate the average disease or pest intensity between each pair of adjacent time points which are summed over time intervals (Madden et al. 2007).   
}
\usage{
AUDPC.cal(reading.dates, severity.data)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{reading.dates}{
Vector disease reading dates 
}
  \item{severity.data}{
Matrix of severity data, first column is ID of the individuals  
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
Jeger M.J.,  Viljanen-Rollinson S.L.H. (2001) The use of the area under the disease-progress curve (AUDPC) to assess quantitative disease resistance in crop cultivars, Theor Appl Genet 102:32-40


Madden  L.V., Hughes, G., van den Bosch, F. (2007) The study of plant disease epidemics. The American Phytopathological Society, APS Press St. Paul, Minnesota.

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
# Example 
reading.dates <- as.Date(c("2012-02-13","2012-02-20","2012-02-28"))

mydat <- data.frame (ID = c("A", "B", "C", "D"), Date1 = c(1:4), Date2 = c(5:8),
 Date3 = c(11:14))

cd <- AUDPC.cal (reading.dates, mydat)
print(cd)

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
