 assambly.plot <- function (data = dat, yvar = "yvar", xstart = "start", xend = "end", id = "id",  xlab = "position", ylab = "", linecol = "cyan4", lwd = 6, lend = 2) {

 dat <- data.frame (data[, yvar], data[, xstart], data [, xend], data[,"id"])
 names(dat) <- c("yvar", "start", "end", "id")
minyvar <- min(dat$yvar) + 0.07 *min(dat$yvar);  maxyvar <- max(dat$yvar) + 0.07 * max(dat$yvar); minS <- min(dat$start)+ 0.07 * min(dat$start); maxE <-  max(dat$end) + 0.07 * max(dat$end)
plot(c(0,maxE), c(0,maxyvar),type = "n",axes = FALSE,xlab = xlab,ylab = ylab)
segments(x0 = dat$start,
         y0 = dat$yvar,
         x1 = dat$end,
         y1 = dat$yvar,
         col = linecol,
         lwd = lwd,
         lend = lend)
text(x = dat$end + 0.07*maxE,y = dat$yvar,labels = dat$id,font = 1, cex = 0.75)
axis(1)
axis(1,at = c(0,maxE),labels = FALSE,tcl = 0.5)
}

