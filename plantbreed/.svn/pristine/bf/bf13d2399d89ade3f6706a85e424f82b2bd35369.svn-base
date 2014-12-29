\name{polar.genome}
\alias{polar.genome}

\title{
Circular (polar) genome plot  
}
\description{
Circular (polar) genome plot with markers represented in points outer circle and the genes / qtl positions identified in inner circle.  
}
\usage{
polar.genome(mapdataframe, mapsubset, groupvar = "group", position = "position", 
gapbp = 10, pt.pch = 19, sub.pch = 17, pt.size = 4, sub.size = 6)
}

\arguments{
  \item{mapdataframe}{
Map dataframe, with group (chromosome), position (physical or genetic position) 
}
  \item{mapsubset}{
Subset of map dataframe with only exactly same columns in mapdataframe, however the position of each QTL / genes is indicated 
}
  \item{groupvar}{
Name of group (chromosome) variable (same for both mapdataframe and mapsubset) 
}
  \item{position}{
Name of position (chromosome) variable (same for both mapdataframe and mapsubset)
}
  \item{gapbp}{
Gap between adjecent groups 
}
  \item{pt.pch}{
Pch for marker circle 
}
  \item{sub.pch}{
Pch for qtl or gene circle 
}
  \item{pt.size}{
Size of pch for marker circle 
}
  \item{sub.size}{
Size of pch for qtl / gene circle 
}
}
\author{
Umesh Rosyara 
}
\examples{
gr1 <- c(1, 5, 15, 20, 30, 40)
gr2 <- c(1, 15, 25, 30, 40)
gr3 <- c(1, 5, 10, 25, 40, 60, 80)

mapdataframe <- data.frame (group = c(rep(1, length(gr1)),
 rep(2, length(gr2)), rep(3, length(gr3))), position = c(gr1, gr2, gr3))
 
mapsubset <- data.frame (group = c(1,1,2,2, 3,3,3, 3), 
position = c(25, 35, 5, 35, 8, 50, 65, 75))


polar.genome(mapdataframe = mapdataframe, mapsubset = mapsubset, groupvar = "group",
 position = "position", gapbp = 10, pt.pch = 17, sub.pch = 19, pt.size = 4, sub.size = 6 )

                                                                        
}

