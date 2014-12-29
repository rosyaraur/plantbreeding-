\name{mapbar.plot}
\alias{mapbar.plot}
\title{
Chromosome bar plot or LD block plot 
}
\description{
The plot is useful to plot map where each interval is filled with different color scaled to user specified variables such as linkage disequilibiriumdisequilibrium. For example we can plot linkage disequilibrium information between adjecent markers to identify linkage blocks.  
}
\usage{
mapbar.plot(mapdat = mapdat, chr = "chr", position = "position", label = "label", 
colorpalvec = heat.colors, size = 10, filld = filld, chr1 = "chr1", fillcol = "fillcol")
}
\arguments{
  \item{mapdat}{
Map dataframe 
}
  \item{chr}{
Name of chromsome variable in the map dataframe 
}
  \item{position}{
Name of variable for position in map dataframe 
}
  \item{label}{
Name of label variable in map dataframe 
}
  \item{colorpalvec}{
The colors to be used for filling - the default is heat.colors. User can develop own color scaling using color brewer or use other build-in color pallettes. 
}
  \item{size}{
Size of color vector - number of colors in the scale 
}
  \item{filld}{
Dataframe with color filling information 
}
  \item{chr1}{
Name for chromsome in the dataframe filld 
}
  \item{fillcol}{
Name of variable in dataframe for filling colors (for example linkage disequibrium)  -  for n markers n-1 colors correspondng to the interval plotting should provided. 
}
}
\details{
The bar size can be changed by changing dimension of plot are (reduced heigh smaller bar, increased heigh larger bar) 
}
\author{
Umesh Rosyara 
}
\examples{
 #Example:
 
 #data 1: map data 
lab1 <- paste("SNP_", 1:30, sep = "")
mapdat <- data.frame (chr = rep(1:3, each = length (lab1)/3), label= lab1, 
position= c(0, 1, 4, 5, 6, 8, 10,  11, 12,  13,
            0, 4, 5, 9, 12, 18, 20, 21, 22,  33,
            0, 2, 6, 9, 12, 14, 18,  21, 24,  28 ))
# positions must start from zero 
 # data 2 filling avariable data 
fillcol <-rnorm(3*(length(lab1)-1), 0.5, 0.2)
filld <- data.frame(chr1 = rep(1:3, each = length(fillcol)/3), fillcol)
 
   
 mapbar.plot (mapdat = mapdat, chr = "chr" ,position = "position",label = "label",
  colorpalvec = heat.colors, size = 10, filld = filld, chr1 = "chr1") 
  
 # Brewing own color palette 
 colvec1 <- colorRampPalette(c("red", "yellow", "green")) 
  mapbar.plot (mapdat = mapdat, chr = "chr" ,position = "position",label = "label",
   colorpalvec = colvec1, size = 10, filld = filld, chr1 = "chr1")
   
 # using build in color brewer                          
mapbar.plot (mapdat = mapdat, chr = "chr" ,position = "position",label = "label",
 colorpalvec = cm.colors, size = 20, filld = filld, chr1 = "chr1")                      
 }
