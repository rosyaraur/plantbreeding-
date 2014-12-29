mapbar.plot <- function (mapdat = mapdat, chr = "chr" , position = "position",label = "label" , colorpalvec = heat.colors, size = 10,
                        filld = filld, chr1 = "chr1", fillcol = "fillcol") {
mapdat <- data.frame (mapdat[,chr], mapdat[,position], mapdat[, label])
names(mapdat) <- c("chr", "position", "label")

filld <- data.frame (filld[,chr1], filld [, fillcol])
names(filld) <- c("chr1", "fillcol")

mapbar.fill <- function(chr) {

    mapdat1 <- mapdat[mapdat$chr == chr,]
    filld1 <- filld[filld$chr1 == chr1,]
    #colorpalvec <- colorRampPalette(c(col1, col2))
    #show(colorpalvec)
    xlab1 = c(paste ("GR-", chr, sep = ""))
    #plot(mapdat$position,mapdat$position-mapdat$position, type="n",
       #axes=FALSE,xlab="", ylab=paste ("Chromsome: ",chr,sep = ""), yaxt="n"
    #)
    barplot(as.matrix(diff(mapdat1$position)), horiz=T,
            col=colorpalvec(size)[size* filld$fillcol],
            axes=F, ylab="", xlim = c(min(mapdat$position), max(mapdat$position)))
    mtext (xlab1, side = 2, cex = 1, col = "blue")
    axis(1, labels=mapdat1$label, at=mapdat1$position)
    axis(3, labels=mapdat1$position, at=mapdat1$position)
}

#x11(width=15, height=4, pointsize=12)
dev.new(width=15, height=8)
layout(matrix(c(2,0,1,3),2,2,byrow=TRUE), c(3,1), c(1,3), TRUE)
par(mfrow = c(4, 1),las=2)
#par(mar = c(2.5, 1.5, 2.5, 1.5))
#par(mar = c(5.5, 5.5, 5.5, 5.5), oma = c(0.5, 0.5, 0.5, 0.5))
 sapply(unique(mapdat$chr),function(x) mapbar.fill(x))
 }