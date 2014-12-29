plotgen <-
function (dataframe, classvar, phenovar, selint = 0.1){
require(ggplot2)
require(plyr)
x <- NULL
y <- NULL
q80 <- NULL
mn <- NULL
V1 <- NULL

mydf <- data.frame (classvar = dataframe[,classvar],x = dataframe[,phenovar]) 
labeld <- ddply(mydf, .(classvar), NROW)
 show(labels)
mydf$classvar <- factor(mydf$classvar)
qn = 1-selint
mydf <- ddply(mydf,.(classvar),.fun = function(x){
    tmp <- density(x$x)
    x1 <- tmp$x
    y1 <- tmp$y
    q80 <- x1 >= quantile(x$x,qn)
    data.frame(x=x1,y=y1,q80=q80)
})

#Separate data frame for the means
mydfMean <- ddply(mydf,.(classvar),summarise,mn = mean(x))
labels <- ddply(dataframe, .(classvar), NROW)

pl <- ggplot(mydf,aes(x = x)) +
    facet_grid(classvar ~ .) +
    geom_line(aes(y = y), lty = 1) +
    geom_ribbon(data = subset(mydf,q80),aes(ymax = y),ymin = 0, fill = "green4") +
    geom_vline(data = mydfMean,aes(xintercept = mn),colour = "blue4", lty = 2) +  theme_bw() + opts(panel.margin=unit(0 , "lines")) +
    opts(title="Density distribution")
pl  + geom_text(data=labeld, aes(label=paste("n =", V1)), x=5, y=0,hjust=0, vjust=0)
    
}
