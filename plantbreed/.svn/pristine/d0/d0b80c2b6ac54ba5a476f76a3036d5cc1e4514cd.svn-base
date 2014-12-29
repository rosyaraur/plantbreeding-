\name{phenosim}
\alias{phenosim}
\title{
Simulation of phenotypic data 
}
\description{
Simulation of phenotypic data with supplied alpha, delta, mean and variance. 
}
\usage{
phenosim(n, p = 0.5, alpha = 10, delta = -10, sig = 4, mu = 50, plot = TRUE)
}
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
\examples{

# example 1
plt <- phenosim (n = 1000 , p = 0.4, alpha = 10, delta = -5, sig = 3, mu = 60,  plot = TRUE) 
print(plt)
hist(plt, col = "blue")

# example 2
plt1 <- phenosim (n = 1000 , p = 0.4, alpha = 0, delta = -10, sig = 3, mu = 60,  plot = TRUE) 
print(plt1)

}

