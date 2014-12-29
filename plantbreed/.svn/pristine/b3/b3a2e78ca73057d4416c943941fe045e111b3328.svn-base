polar.genome <- function (mapdataframe, mapsubset, groupvar = "group", position = "position", gapbp = 10, pt.pch = 19, sub.pch = 17, pt.size = 4, sub.size = 6 ){
 
mapdataframe <- data.frame (mapdataframe[, groupvar], mapdataframe[, position])
names(mapdataframe) <- c("group", "position")

mapsubset <- data.frame (mapsubset[, groupvar], mapsubset[,position])
names(mapsubset) <- c("group", "position")
cbp <- NULL
cbp_new <- NULL
 
#mapdataframe$cpos <- cumsum (mapdataframe$pos)   
mapsubset$pos1 <- mapsubset$position
df3 <- merge (mapdataframe, mapsubset, by = c("group", "position"), all = TRUE)
gapbp <- gapbp # gap between chromsomes 
group <- df3$group
pos <- df3$position
group = lapply(unique(group), function(x) pos[group == x])
to.add = cumsum(sapply(group, max) + gapbp)
bp <- c(group[[1]], unlist(lapply(2:length(group), function(x) group[[x]] + 
            to.add[x - 1])))
df3$cbp <- bp

df3$cbp_new <- df3$cbp * df3$pos1/df3$pos1
mxmdf <- max(df3$cbp)
 
require(ggplot2)
cx <- ggplot(df3, aes(y = c(2), x = cbp)) 
cx2 <- cx +  geom_point(aes(color = factor(group)), size = pt.size, pch = pt.pch) + geom_point(aes(y = c(1.5), x = cbp_new , color = factor(group)), size = sub.size, pch = sub.pch)+ 
geom_line(aes(x = cbp, y = c(1)), color = "lavender", size = 2) + 
geom_line(aes(x = cbp, y = c(1.8)), color = "honeydew",  size = 5) + geom_line(aes(x = cbp, y = c(1.35)), color = "lavenderblush", size = 2) +
scale_y_continuous(limits=c(0,2), breaks = c(0,1,2)) +
scale_x_continuous(labels = df3$position, breaks = df3$cbp, limits = c(0,mxmdf)) + coord_polar() +
opts(panel.grid.major = theme_line(colour = "grey"), 
panel.grid.minor = theme_line(colour = "grey", linetype = "dashed"), 
panel.background = theme_rect(colour = "white"), axis.ticks = theme_blank(), axis.title.y=theme_blank(), axis.text.y=theme_blank())

print(cx2) 
}  

