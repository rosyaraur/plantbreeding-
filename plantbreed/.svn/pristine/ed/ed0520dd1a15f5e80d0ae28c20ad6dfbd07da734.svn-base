plotblock <- function (label,plotn,  nrow, ncol, g.col = 0.49, g.row = 0.45, l.pos = -0.2, fill = "azure2", h = c(0,360), psize = 3, lsize = 3){
if (length (label) != length (plotn)) {
           warning ("number of label must be equal to total plot number")
           }
totolp <- nrow * ncol
if (length (plotn) != totolp) {
           warning ("Number of nrow x ncol must be equal to number of plots (plotn)")
           }
if (g.col < 0) {
           warning ("g.col value less than 0, the value of g.col must be in between 0.0  to 0.49")
           }
if (g.col > 0.49) {
           warning ("g.col value greater than 0.49, the value must be in between 0.0  to 0.49")
           }
if (g.row < 0) {
           warning ("g.row value less than 0, the value of g.col must be in between 0.0  to 0.49")
           }
if (g.row > 0.49) {
           warning ("g.row value greater than 0.49, the value must be in between 0.0  to 0.49")
           }
if (l.pos == 0) {
           warning ("l.pos is equal to 0, plot number and treatment label overlap")
           }
if (l.pos < -0.3) {
           warning ("l.pos greater than -0.3 not suggested")
           }
if (l.pos > 0.3) {
           warning ("l.pos greater than 0.3 not suggested")
           }
library(ggplot2);
cblocks <- expand.grid(  x = 1: ncol, y = 1:nrow)
cblocks$label <-label 
cblocks$plotn <-  plotn
cblocks$g.col <-  g.col
cblocks$g.row <-  g.row
cblocks$l.pos <-  l.pos
cblocks$lsize <-  lsize
cblocks$psize <-  psize
if (fill == "treatment") {
x <- NULL
y <- NULL 
p <- ggplot(cblocks) +  geom_rect(aes(xmin=x-g.col, xmax=x + g.col, ymin=y - g.row, ymax=y + g.row, fill = label)) + scale_fill_hue("Treatment", h=h)
p2 <- p + geom_text(aes(label=label, x=x, y=y, size = lsize)) + geom_text(aes(label=plotn, x=x, y=y+l.pos, colour = "red", size = psize))+ scale_y_continuous(breaks=seq(0, ncol, 1)) + xlab("") + ylab("blocks") + theme_bw()
p2 +  opts(legend.position = "none")
} else {
x <- NULL; rm(x)
y <- NULL; rm(y)
p <- ggplot(cblocks) +  geom_rect(aes(xmin=x-g.col, xmax=x + g.col, ymin=y - g.row, ymax=y + g.row), fill= fill)
p2 <- p + geom_text(aes(label=label, x=x, y=y), size = lsize) + geom_text(aes(label=plotn, x=x, y=y+l.pos, colour = "red"), size = psize)+ scale_y_continuous(breaks=seq(0, ncol, 1)) + xlab("") + ylab("blocks") + theme_bw()
p2 +  opts(legend.position = "none")
}
}

