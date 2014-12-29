map.plot <- function (mapdata, chr = "chr", markname = "markname", position = "position", 
    mbar.col = c("lightseagreen"), tick.size = FALSE, tvar = NULL, 
    marklab = TRUE, poslab = TRUE) 
{
    if (tick.size == TRUE) {
        mapdata <- data.frame(chr = mapdata[, chr], markname = mapdata[, markname], 
            position = mapdata[, position], tvar = mapdata[, tvar])
        names(mapdata) <- c("chr", "markname", "position", "tvar")
    }
    if (tick.size == FALSE) {
        mapdata <- data.frame(chr = mapdata[, chr], markname = mapdata[, markname], 
            position = mapdata[, position])
        names(mapdata) <- c("chr", "markname", "position")
    }
    chr <- 1:length(unique(mapdata$chr))
    if (length(mbar.col) < length(chr)) {
        mbar.col <- rep(mbar.col, length(chr))
    }
    p.map = function(chr) {
        mapdata1 <- mapdata[mapdata$chr == chr, ]
        m <- par()$mar
        m[1] <- m[3] <- 0
        par(mar = m)
        plot(mapdata$position, mapdata$position - mapdata$position, 
            type = "n", axes = FALSE, xlab = "", ylab = paste("Chromsome: ", 
                chr, sep = ""), yaxt = "n")
        polygon(c(0, max(mapdata1$position + 0.08 * max(mapdata1$position)), 
            max(mapdata1$position) + 0.08 * max(mapdata1$position), 
            0), 0.2 * c(-0.3, -0.3, 0.3, 0.3), col = mbar.col[chr])
        if (tick.size == TRUE) {
            k = c(0.6 * (mapdata1$tvar/max(mapdata1$tvar)))
            segments(mapdata1$position, -k, mapdata1$position, 
                k, lwd = 2, col = mbar.col[chr])
        }
        else {
            segments(mapdata1$position, -0.3, mapdata1$position, 
                0.3)
        }
        if (marklab == TRUE) {
            text(mapdata1$position, -0.7, mapdata1$markname, 
                srt = 90)
        }
        if (poslab == TRUE) {
            text(mapdata1$position, 0.7, mapdata1$position)
        }
        text(-10, labels = paste("Chr", unique(mapdata1$chr)))
    }
    par(mfrow = c(length(chr), 1))
    sapply(chr, p.map)
  }
