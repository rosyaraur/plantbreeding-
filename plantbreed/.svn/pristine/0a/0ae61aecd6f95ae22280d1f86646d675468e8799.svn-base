manhatton.circos <- function (dataframe, SNPname, chromosome, position, pvcol,colour = "seablue", ymax = "maximum",
    ymin = "minimum", gapbp = 1000,type = "polar", geom = "point")
{
     require(ggplot2)
    dat <- data.frame(dataframe[, SNPname], dataframe[, chromosome],
        dataframe[, position], dataframe[, pvcol])
    names(dat) <- c("SNP", "chr", "pos", "pval")
    dat = subset(na.omit(dat[order(dat$chr, dat$pos), ]), (dat$pval >
        0 & dat$pval <= 1))
     logp <- NULL; rm(logp)
    dat$logp = -log10(dat$pval + 2.225074e-308)
    mychr <- dat$chr
    nchr <- max(mychr)
    if (nchr > 1) {
    chr <- dat$chr
    pos <- dat$pos
    chr = lapply(unique(chr), function(x) pos[chr == x])
    to.add = cumsum(sapply(chr, max) + gapbp)
    bp <- c(chr[[1]], unlist(lapply(2:length(chr), function(x) chr[[x]] +
        to.add[x - 1])))
    dat$bp <- bp
    out <- vector(mode = "integer", length = length(mychr))
    uid <- sort(unique(mychr))
     if (ymax == "maximum")
        ymax <- ceiling(max(dat$logp))
    if (ymax < 5)
        ymax <- 5
    if (ymin == "minimum")
        ymin <- floor(min(dat$logp))
    if (ymin > 5)
        ymin <- 5
      infun <- function(X) ((max(X) + min(X))/2)
      tickd <- aggregate(bp ~ chr, data = dat, FUN = infun)
    if (type == "polar" ){
       if (colour == "multicolor") {
     p1 <- qplot(x = bp,y = logp, data=dat,colour = factor(chr),  geom = geom)  + ylab (expression(-log[10](italic(p)))) +  xlab ("Chromosome") +
         scale_x_continuous(limits=c(min(bp),gapbp + max(bp))) + opts(legend.position = "none") +
         scale_y_continuous(limits=c(ymin,ymax)) + coord_polar()  + scale_x_continuous(labels = tickd$chr, breaks = tickd$bp, limits=c(min(bp),gapbp + max(bp))) + theme_bw()
           print(p1)} else {
          p1 <- qplot(x = bp,y = logp, data=dat, geom = geom)  + ylab (expression(-log[10](italic(p)))) +  xlab ("Chromosome") +
         scale_x_continuous(limits=c(min(bp),gapbp + max(bp))) +  opts(legend.position = "none") +
         scale_y_continuous(limits=c(ymin,ymax)) + coord_polar()  + scale_x_continuous(labels = tickd$chr, breaks = tickd$bp, limits=c(min(bp),gapbp + max(bp))) + theme_bw()
           print(p1)
           }
           }
      if (type == "regular") {
          if (colour == "multicolor") {
          p1 <- qplot(x = bp,y = logp, data=dat,colour = factor(chr), geom = geom)  + ylab (expression(-log[10](italic(p)))) +  xlab ("Chromosome") +
         scale_x_continuous(limits=c(min(bp),gapbp + max(bp))) +  opts(legend.position = "none") +
         scale_y_continuous(limits=c(ymin,ymax)) +  scale_x_continuous(labels = tickd$chr, breaks = tickd$bp, limits=c(min(bp),max(bp))) + theme_bw()
           print(p1)} else {
           p1 <- qplot(x = bp,y = logp, data=dat,colour = colour,  geom = geom)  + ylab (expression(-log[10](italic(p)))) +  xlab ("Chromosome") +
         scale_x_continuous(limits=c(min(bp),gapbp + max(bp))) +  opts(legend.position = "none") +
         scale_y_continuous(limits=c(ymin,ymax)) +  scale_x_continuous(labels = tickd$chr, breaks = tickd$bp, limits=c(min(bp),max(bp))) + theme_bw()
           print(p1)
          }
    }
    } else {
        dat$logp = -log10(dat$pval + 2.225074e-308)
        chr <- dat$chr
        pos <- dat$pos
        if (ymax == "maximum")
        ymax <- ceiling(max(dat$logp))
        if (ymax < 5)
        ymax <- 5
        if (ymin == "minimum")
            ymin <- floor(min(dat$logp))
        if (ymin > 5)
             ymin <- 5
    if (type == "polar" ){
       if (colour == "multicolor") {
       p1 <- qplot(x = bp,y = logp, data=dat,colour = factor(chr),  geom = geom)  + ylab (expression(-log[10](italic(p)))) +  xlab ("Chromosome") +
         scale_x_continuous(limits=c(min(bp),gapbp + max(bp))) +
         scale_y_continuous(limits=c(ymin,ymax)) + coord_polar()  + scale_x_continuous(labels = tickd$chr, breaks = tickd$bp, limits=c(min(bp),gapbp + max(bp))) + theme_bw() + opts(legend.position = "none")
           print(p1)} else {
          p1 <- qplot(x = bp,y = logp, data=dat, geom = geom)  + ylab (expression(-log[10](italic(p)))) +  xlab ("Chromosome") +
         scale_x_continuous(limits=c(min(bp),gapbp + max(bp))) + opts(legend.position = "none") +
         scale_y_continuous(limits=c(ymin,ymax)) + coord_polar()  + scale_x_continuous(labels = tickd$chr, breaks = tickd$bp, limits=c(min(bp),gapbp + max(bp))) + theme_bw()
           print(p1)
           }
           }
      if (type == "regular") {
          if (colour == "multicolor") {
          p1 <- qplot(x = bp,y = logp, data=dat,colour = factor(chr), geom = geom)  + ylab (expression(-log[10](italic(p)))) +  xlab ("Chromosome") +
         scale_x_continuous(limits=c(min(bp),gapbp + max(bp))) + opts(legend.position = "none") +
         scale_y_continuous(limits=c(ymin,ymax)) +  scale_x_continuous(labels = tickd$chr, breaks = tickd$bp, limits=c(min(bp),max(bp))) + theme_bw()
           print(p1)} else {
           p1 <- qplot(x = bp,y = logp, data=dat,colour = colour, geom = geom)  + ylab (expression(-log[10](italic(p)))) +  xlab ("Chromosome") +
         scale_x_continuous(limits=c(min(bp),gapbp + max(bp))) + opts(legend.position = "none") +
         scale_y_continuous(limits=c(ymin,ymax)) +  scale_x_continuous(labels = tickd$chr, breaks = tickd$bp, limits=c(min(bp),max(bp))) + theme_bw()
           print(p1)
          }
  }
  }
  }