\name{assambly.plot}
\alias{assambly.plot}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Assembly plot 
}
\description{
The function develops assambly plot of Displaying multiple assambled line segments such as plotting of chrosmomechromosome or genome segments. 

X axis consists of distance whereas Y axis consists of serial number for fragments (scaffold) or even quantitative data (if required). 

Both start point and end point for drawing lines need to be supplied.  
}
\usage{
assambly.plot(data = dat, yvar = "yvar", xstart = "start", xend = "end", id = "id",
 xlab = "position", ylab = "", linecol = "cyan4", lwd = 6, lend = 2)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{data}{
Dataframe 
}
  \item{yvar}{
The Y axis object - normally serial number otherwise any quantitative data 
}
  \item{xstart}{
Name of variable with start point for the segrementssegments 
}
  \item{xend}{
Name of variable with end points for the segments 
}
  \item{id}{
ID variable for the segments (for example fragment names)
}
  \item{xlab}{
Label on X axis for example physical position, defualtdefault is position 
}
  \item{ylab}{
Label of Y axis, default is none 
}
  \item{linecol}{
Color of line, default is cyan4 
}
  \item{lwd}{
Width of line (see graphical par in R / graphics) 
}
  \item{lend}{
End style of line (see graphical par in R / graphics)
}
}
\author{
Umesh Rosyara 
}

\examples{
#Example data 
dat <- data.frame(yvar = c(1:10),id = paste ("Frag-", 1:10, sep= ""), 
start = c(1,3,4 ,5, 8, 9, 12, 13, 15, 20),
end = c(5,9,6 ,15, 19, 11, 13, 19, 20, 25))

# two assambly plot in shame window 
par(mfrow= c(2,1))

 assambly.plot (data = dat, yvar = "yvar", xstart = "start", xend = "end", 
 id = "id", xlab = "position",  ylab = "", linecol = "cyan4", lwd = 6, lend = 2)
 abline ( v = 15,  col = "pink4")

  assambly.plot (data = dat, yvar = "yvar", xstart = "start", xend = "end", 
  id = "id", xlab = "position",  ylab = "Fragments", 
  linecol = "red", lwd = 4, lend = 2)

  abline ( h = 5, col = "pink4")

}

