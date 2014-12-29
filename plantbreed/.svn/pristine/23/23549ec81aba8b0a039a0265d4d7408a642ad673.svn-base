\name{onemap2mapchart}
\alias{onemap2mapchart}
\title{
Convert onemap map output to Marchart readable *mct" format 
}
\description{
Convert onemap map output to Marchart readable *mct" format 
}
\usage{
onemap2mapchart(mapfile, outprefix = ".")
}

\arguments{
  \item{mapfile}{
Name of mapfile outputed by write.map function 
}
  \item{outprefix}{
Prefix of output mapchart file 
}
}
\references{
Margarido GRA, Souza AP, Garcia AAF (2007) OneMap: software for genetic mapping in outcrossing species. Hereditas 144: 78-79

Voorrips, R.E., 2002. MapChart: Software for the graphical presentation of linkage maps and QTLs. 
The Journal of Heredity 93 (1): 77-78.

}
\author{
Umesh Rosyara
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

