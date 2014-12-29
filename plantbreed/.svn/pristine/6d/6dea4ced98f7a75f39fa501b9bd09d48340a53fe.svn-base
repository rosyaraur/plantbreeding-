\name{adesign}
\alias{adesign}
\title{
Design  Augmented Block Design experiment}
\description{
The function generates randomized plans for augmented block design.  
}
\usage{
adesign(checks, newtrt, block.size = block.size, r, seed = 999)
}
\arguments{
  \item{checks}{
A vector with names of checks to be included in the experiment 
}
  \item{newtrt}{
A vector with names of new treatments to be included in the experiment 
}
  \item{block.size}{
A vector of block size (maximum number of entries allowed in the each block consequetively)
}
  \item{r}{
total number of replications (single number) 
}
  \item{seed}{
Random seed 
}
}
\details{
block.size and r can not be zero or NA. Total of block size should be equal to number of checks x r + number of new treatments.  
}
\value{
Returns dataframe with randomization with plot number, blocks and treatments
}
\references{
Mead, R. 1997.  Design of plant breeding trials.  In Statistical Methods for Plant Variety
Evaluation. eds. Kempton and Fox. Chapman and Hall. London.  
}
\author{
Umesh R. Rosyara
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
 \code{\link{augblock}}
}
\examples{
## example 1 
ntrt = paste ("EL", 1:60, sep= "")
checks = c("A", "B", "C", "D", "E", "F")
bsize = c(20, 12, 16, 16, 10, 22)
ado <- adesign (checks = checks, newtrt = ntrt, block.size = bsize, r = 6,  seed = 3246)
print(ado)

# example 2
checks1 = c("Rampur", "Elice", "Lansing", "Glover")
newtrt1 = c("SD101", "SD102", "SD302", "MN102", "MI6789", "KS2034","SD134", "SD402", "SD4342",
 "MN232", "MI69", "KS234",  "SD451", "SD892", "SD212", "MN344", "MI649", "KS336",
 "SD345", "SD425", "SD5662", "MN892", "MI902", "KS4",  "SD333", "SD1212", "SD021", 
 "MN223L", "MI69n", "KS2123","SD145", "SDJ1", "SD4234", "MN90", "MI4567", "KS956",
"SD9901", "SD6602", "SD2202", "MN4402", "MI892", "KS2421","SD400", "SD4029", "SD987",
 "MN2333", "MI690", "KS214")
r1 = 4                           
block.size1 = c(16, 16, 16, 16)
print(EX2 <- auugmentdesign (checks = checks1, newtrt = newtrt1, 
block.size = block.size1, r = r1,  seed = 124)) 
}
\keyword{~kwd1}
\keyword{~kwd2}
