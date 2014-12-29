\name{onemap2mapchart}
\alias{onemap2mapchart}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Convert onemap map output to Marchart readable *mct" format 
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
onemap2mapchart(mapfile, outprefix = ".")
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{mapfile}{
Name of mapfile outputed by write.map function 
}
  \item{outprefix}{
Prefix of output mapchart file 
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
Margarido GRA, Souza AP, Garcia AAF (2007) OneMap: software for genetic mapping in outcrossing species. Hereditas 144: 78-79

Voorrips, R.E., 2002. MapChart: Software for the graphical presentation of linkage maps and QTLs. The Journal of Heredity 93 (1): 77-78.
http://www.biometris.wur.nl/uk/Software/MapChart/

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
data(mapone)
require(onemap)
twpt<-rf.2pts(mapone)
lgrp <-group(make.seq(twpt, "all"))

mapslist<-vector("list", lgrp$n.groups)

for(i in 1:lgrp$n.groups){
    ##create linkage group i
    LGcur <- make.seq(lgrp,i)
    ##ordering
    mapcur<-order.seq(LGcur, subset.search = "sample")
    ##assign the map of the i-th group to the maps.list
    mapslist[[i]]<-make.seq(mapcur, "force")
  }
write.map(mapslist, "mapone.map")


}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
