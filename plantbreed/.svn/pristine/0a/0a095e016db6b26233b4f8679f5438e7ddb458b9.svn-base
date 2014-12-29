\name{map.plot}
\alias{map.plot}

\title{
Chromosomal maps with or without scaled ticks 
}
\description{
The plot develops maps with specified maker positions and labels. The length of ticks can be constant over the map or can be scaled to other variables of interest showing property of markers (for example polymorphism indicated by minor allele frequency).   
}
\usage{
map.plot(mapdata, chr = "chr", markname = "markname", position = "position", 
mbar.col = c("lightseagreen"), tick.size = FALSE, tvar = NULL, marklab = TRUE, 
poslab = TRUE)
}

\arguments{
  \item{mapdata}{
dataframe with map information 
}
  \item{chr}{
Chromosome information 
}
  \item{markname}{
Marker name information 
}
  \item{position}{
Position of markers 
}
  \item{mbar.col}{
Color of the marker bar 
}
  \item{tick.size}{
Size of ticks 
}
  \item{tvar}{
Variable to be used as ticks 
}
  \item{marklab}{
Marker labels 
}
  \item{poslab}{
Marker position labels 
}
}
\author{
Umesh Rosyara 
}
\examples{
### Example 1
# map
nmar <- seq (1, 100, 5)
position= rep(nmar, 5)
n = length (nmar )
chr = rep(1:5, each = n )
set.seed (1234)
mapminor <- rnorm (length (chr), 0.5, 0.2)
mapdata <- data.frame (chr = chr, position = position, snpname = paste("SNP-",
 1:length (position), sep = ""), mapminor = mapminor)
 
#mapdata
# with constant tick size 
map.plot(mapdata = mapdata, chr = "chr", markname = "snpname", position = "position", 
mbar.col = c("lightseagreen"), tick.size = FALSE, tvar = FALSE,marklab = TRUE, poslab = TRUE)
    
# with tick size scaled to minor allele frequency     
map.plot(mapdata = mapdata, chr = "chr", markname = "snpname", position = "position", 
mbar.col = c("lightseagreen"), tick.size = TRUE, tvar = "mapminor", 
marklab = TRUE, poslab = TRUE)                             

#### Example 2
nmar <- seq (1, 1000, 5)
position= rep(nmar, 5)
n = length (nmar )
chr = rep(1:5, each = n )
set.seed (456)
pval <- rnorm (length (chr), 0.5, 0.5)
mapdata1 <- data.frame (CHRM = chr, position = position, snpname = paste("SNP-",
 1:length (position), sep = ""), pval = pval)
 
map.plot(mapdata = mapdata1, chr = "CHRM", markname = "snpname", position = "position", 
 tick.size = TRUE, tvar = "pval",mbar.col = c("darkblue"), marklab = FALSE, poslab = FALSE) 

}

