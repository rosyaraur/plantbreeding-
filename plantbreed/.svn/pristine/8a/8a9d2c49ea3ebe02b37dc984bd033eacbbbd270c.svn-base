\name{mapone}
\alias{mapone}
\docType{data}
\title{
Genetic mapping dataset  
}
\description{
This is example data for creating genetic map using onemap (Margarido et al. 2007).  Simulated F2 dataset with 250 individuals with 75 markers. 
}
\usage{data(mapone)}
\format{
"f2.onemap" object with 250 individuals with 75 markers.  There are two traits - "QT1" and "QT2". 

}
\source{
A simulated dataset 
}
\references{
Margarido GRA, Souza AP, Garcia AAF (2007) OneMap: software for genetic mapping in outcrossing species. Hereditas 144: 78-79

The following examples make use of onemap package by Margarido et al. (2007), please cite above reference if you make use of the following codes. 
}
\examples{
# load onemap package 
require(onemap)
# load the data from plantbreeding library 
data(mapone)
ls(mapone)
# to know indetail about how to read mapmaker style file into onemap  
help(read.mapmaker)

# Estimating two-point recombination fractions
tw.mapone <- rf.2pts(mapone, LOD = 2, max.rf = 0.4)

# Assigning markers to linkage groups
mark.all.mapone  <- make.seq(tw.mapone, "all")

#You can assign markers to linkage groups using the function "group".
LGs.mapone<- group (mark.all.mapone, LOD = 3, max.rf=0.5)
LGs.mapone

# estimation of marker order and map distance
# linkage group 1.
LG1.mapone <- make.seq(LGs.mapone, 1)
LG1.mapone

# using different algorithms
LG1.rcd <- rcd(LG1.mapone) # Rapid Chain Delineation
LG1.rec <- record(LG1.mapone) # order obtained using RECORD algorithm:
 
# compare different sequence
subsam <- rf.2pts(mapone)
markers <- make.seq(subsam,c(1, 2, 3,4,5))
markers.comp <- compare(markers)
markers.comp

# setting mapping function
## set.map.fun(type=c("kosambi"))

# using oder.seq function 
LG1.mapone.ord <- order.seq(input.seq=LG1.mapone, n.init = 5,  subset.search = "twopt", 
 twopt.alg = "rcd", THRES = 3, draw.try = TRUE, wait = 1, touchdown=TRUE)

# force order
LG1.mapone.final <- make.seq(LG1.mapone.ord,"force")
ripple.seq(ws=5, LG1.mapone.final)


LG1.mapone.final # to display the  map for group 1

# pefroming the task in batch mode for all
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

##write maps.list to "mapone_vs1.map" file
write.map(mapslist, "mapone_vs1.map")
}

