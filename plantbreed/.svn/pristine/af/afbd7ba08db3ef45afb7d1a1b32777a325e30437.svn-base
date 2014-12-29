plotwith.map <- function (mapdata, ydata, yvar, position, marker, type = "l", ycol = "blue4", mbar.col = "gray20", ylab = "", cex.lab = 1, chr.lab = 1, ...) {
mapdata <- data.frame (position = mapdata[,position], marker = mapdata[,marker])
ydata <-  data.frame (position = ydata[,position], yvar = ydata[,yvar])
# plotting
# Split the plot area in two
layout(matrix(c(1,1,2),ncol=1))
# Reduce the margins for the second plot
mt <- par()$mar
mt[1] <- 0
mt[3] <- 0.5
par(mar=mt)
# First plot
plot(ydata$position, ydata$yvar, type=type, las=1, col = ycol, ylab = ylab, xaxt='n', ...)
axis(side =1, labels=F, at = mapdata$position, col.ticks = "gray10", cex.lab = cex.lab)
# Reduce the margins for the second plot
m <- par()$mar
m[1] <- m[3] <- 0
par(mar=m)
# Set the limits of the second plot
plot(ydata$position,ydata$position-ydata$position, type="n", axes=FALSE, xlab="", ylab="", yaxt="n" )

# Add the rectangle, the segments and the text.
polygon(
  c(0,max(mapdata$position + 0.08 * max(mapdata$position)),max(mapdata$position)+  0.08 * max(mapdata$position),0),
  .2*c(-0.3,-0.3,0.3,0.3),
  col= mbar.col
)
segments(mapdata$position, -.3, mapdata$position, .3 )
text(mapdata$position, -.7, mapdata$marker, srt = 90, cex.lab = chr.lab)
text(mapdata$position,  .7, mapdata$position,cex.lab = chr.lab )
}

