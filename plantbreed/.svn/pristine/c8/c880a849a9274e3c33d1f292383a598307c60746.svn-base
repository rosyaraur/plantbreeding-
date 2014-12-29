\name{phenosim}
\alias{phenosim}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Simulation of phenotypic data 
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
phenosim(n, p = 0.5, alpha = 10, delta = -10, sig = 4, mu = 50, plot = TRUE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{n}{
Number of individuals simulated 
}
  \item{p}{
p value 
}
  \item{alpha}{
alpha 
}
  \item{delta}{
delta 
}
  \item{sig}{
variance 
}
  \item{mu}{
grant mean 
}
  \item{plot}{
logical variable (TRUE or FALSE) depending upon whether to plot cross or not 
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
returns vector of phenotypic values. If plot "TRUE" density plot will be displayed.  
}
\references{
Lynch M., Walsh B. (1998). Genetics and Analysis of Quantitative Traits. Sinauer, Sunderland, MA

Falconer D. S., Mackay T.F.C. (1996). Introduction to Quantitative Genetics. Fourth edition. Addison Wesley Longman, Harlow, Essex, UK.
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
plt <- phenosim (n = 1000 , p = 0.4, alpha = 10, delta = -5, sig = 3, mu = 60,  plot = TRUE) 
print(plt)
hist(plt, col = "blue")

# example 2
plt1 <- phenosim (n = 1000 , p = 0.4, alpha = 0, delta = -10, sig = 3, mu = 60,  plot = TRUE) 
print(plt1)

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
