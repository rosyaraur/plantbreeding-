manhatton.plot <- function (dataframe, SNPname, chromosome, position, pvcol, ylabel = "pvalue", pconv= "-log10", ymax = "maximum", 
    ymin = "minimum", gapbp = 500, pch = c(18, 19, 20), color = c("midnightblue", 
        "lightpink4", "blue"), line1, line2, ...)                                                         
{
    
    dat <- data.frame(dataframe[, SNPname], dataframe[, chromosome], 
        dataframe[, position], dataframe[, pvcol])
    names(dat) <- c("SNP", "chr", "pos", "pval")
   
   if(pconv == "-log10"){ 
    dat = subset(na.omit(dat[order(dat$chr, dat$pos), ]), (dat$pval > 
        0 & dat$pval <= 1))
        }
        
    if(pconv == "-log10"){ 
    dat$logp = -log10(dat$pval + 2.225074e-308)
    } else {
    dat$logp = dat$pval
    }
    mychr <- dat$chr
    nchr <- max(dat$chr)
      if (nchr > 1) {
    if (length(color) > length(unique(dat$chr))) 
        stop("Maximum number of colors allowed should not exceed to number of chromosomes:  ", 
            length(unique(dat$chr)))
    if (length(pch) > length(unique(dat$chr))) 
        stop("Maximum number of pch allowed should not exceed to number of chromosomes:  ", 
            length(unique(dat$chr)))
    chr <- dat$chr
    pos <- dat$pos
    chr = lapply(unique(chr), function(x) pos[chr == x])
    to.add = cumsum(sapply(chr, max) + gapbp)
    bp <- c(chr[[1]], unlist(lapply(2:length(chr), function(x) chr[[x]] + 
        to.add[x - 1])))
    dat$bp <- bp
    out <- vector(mode = "integer", length = length(mychr))
    uid <- sort(unique(mychr))
    n <- length(color)
    for (i in 1:n) {
        s <- seq(i, length(uid), n)
        
        out[mychr %in%  s] <- i
    }
    ymax1 <- ceiling(max(dat$logp))
      if (ymax == "maximum"){ 
        ymax <- ymax1
        } else {
        ymax <- ymax
        }
   ymin1 <- floor(min(dat$logp))
        
  if (ymin == "minimum"){ 
        ymin <- ymin1
        } else {
        ymin <- ymin
        }
       
        
    if(pconv == "-log10"){
    plot(dat$bp, dat$logp, pch = pch[out], col = color[out], 
        ylim = c(ymin, ymax), ylab = expression(-log[10](italic(p))), 
        xlab = "Chromosome", xaxt = "n", ...)
        } else {
     plot(dat$bp, dat$logp, pch = pch[out], col = color[out], 
        ylim = c(ymin, ymax), ylab = ylabel, 
        xlab = "Chromosome", xaxt = "n", ...)
        }    
    infun <- function(X) ((max(X) + min(X))/2)
    tickd <- aggregate(bp ~ chr, data = dat, FUN = infun)
    axis(1, at = tickd$bp, labels = tickd$chr, ...)
    if (line1) 
        abline(h = line1, col = "blue")
    if (line2) 
        abline(h = line2, col = "red")
    } else {
        if (length(color) > length(unique(dat$chr))) 
        stop("Maximum number of colors allowed should not exceed to number of chromosomes:  ", 
            length(unique(dat$chr)))
        if (length(pch) > length(unique(dat$chr))) 
        stop("Maximum number of pch allowed should not exceed to number of chromosomes:  ", 
            length(unique(dat$chr)))
           if(pconv == "-log10"){ 
                  dat$logp = -log10(dat$pval + 2.225074e-308)
                   } else {
                     dat$logp = dat$pval
                      }    
        chr <- dat$chr
        pos <- dat$pos
     
      if (ymax == "maximum") 
        ymax1 <- ceiling(max(dat$logp))
    if(pconv == "-log10"){
    if (ymax == "maximum"){ 
        ymax <- ymax1
        } else {
        ymax <- 8
        }
        } else {
        ymax <- ymax1
        }
    if (ymin == "minimum") 
        ymin1 <- floor(min(dat$logp))
        
   if(pconv == "-log10"){
        if (ymin == "minimum"){ 
        ymin <- ymin1
        } else {
        ymin <- 0
        }
        } else {
        ymin <- 0
        }  
        
         if(pconv == "-log10"){
        plot(dat$pos, dat$logp, pch = pch, col = color, ylim = c(ymin, ymax), ylab = expression(-log[10](italic(p))), 
        xlab = paste ("Chromosome", unique(dat$chr), sep = ""), ...)} else {
        plot(dat$pos, dat$logp, pch = pch, col = color, ylim = c(ymin, ymax), ylab = ylabel, 
        xlab = paste ("Chromosome", unique(dat$chr), sep = ""), ...)
        }
        if (line1) 
        abline(h = line1, col = "blue")
       if (line2) 
        abline(h = line2, col = "red")
    
  }
  }
 

