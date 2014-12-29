map.fill.gplot <- function(mapd = mapd, chr = "chr", label = "label", position = "position",  filld = filld, fillcol = "fillcol", fcol1 = "blue", fcol2 = "red"){
require(ggplot2)
mapd <- data.frame (mapd[,chr], mapd[,label], mapd[,position])
names (mapd) <- c("chr", "label", "position")
deltas  <- NULL
filld <- data.frame (filld[, chr], filld[, fillcol])
names (filld) <- c("chr", "fillcol")

library(plyr)
mapd$chr <- factor(mapd$chr)
gData <- ddply(mapd, .(chr), function(x){
  data.frame(deltas = diff(x$position), label = paste(head(x$label, -1), sep = ""))
})

require(ggplot2)
gData$FillCol <- rnorm(nrow(gData))
p <- ggplot(gData, aes(x = chr, y = deltas, fill = fillcol, label = label, width=.1)) + geom_bar(stat = "identity") +
coord_flip() + scale_fill_gradient(low = fcol1, high = fcol2) + geom_text(position = "stack", angle = 90, hjust=5) + ylab("Position") + xlab("Group") + theme_bw()

p + opts(legend.position="left",
        panel.background=theme_blank(),panel.border=theme_blank(),panel.grid.major=theme_blank(),
        panel.grid.minor=theme_blank(),plot.background=theme_blank())



 }