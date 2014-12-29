histlab <-
function (dataframe, classvar = "class",yvar = "yvar",  arrow_yvar, arrow_label, arrow_class, bwidth, colour = "cyan4", fill = "cyan4"){
library(ggplot2)
library(grid) # unit() is in the grid package.
library(plyr)  # Data restructuring
arrow_pos = data.frame (class = arrow_class, name = arrow_label,yvar = arrow_yvar, stringsAsFactors=FALSE)
myd <- data.frame (class = dataframe[,classvar], yvar = dataframe[,yvar])
myd <- myd[!is.na(myd$yvar),]
cat ("The rows with y variable missing are removed")
bwidth <- bwidth   # Set binwidth
Min <- floor(min(myd$yvar)/bwidth) * bwidth
Max <- ceiling(max(myd$yvar)/bwidth) * bwidth

# Function to do the counting
func <- function(df) {
   tab = as.data.frame(table(cut(df$yvar, breaks = seq(Min, Max, bwidth), right = FALSE)))
   tab$upper = Min + bwidth * (as.numeric(rownames(tab)))
   return(tab)
   }

# Apply the function to each class in myd data frame
TableOfCounts <- ddply(myd, .(class), function(df) func(df))

# Transfer counts of arrow_pos
arrow_pos$upper <- (floor(arrow_pos$yvar/bwidth) * bwidth) + bwidth
arrow_pos <- merge(arrow_pos, TableOfCounts, by = c("class", "upper"))
arrow_pos$xvar <- (arrow_pos$upper - .5 * bwidth)      # x position of the arrow is at the midpoint of the bin

arrow_pos$class=factor(as.character(arrow_pos$class),
    levels= unique (myd$class)) # Gets rid of warnings.
yvar <- NULL; xvar <- NULL; class <- NULL; Freq <- NULL; name <- NULL 
ggplot(myd, aes(x=yvar)) +
     theme_bw() +
     geom_histogram(colour=colour, fill=fill, binwidth=bwidth) +
     facet_wrap(~ class) + xlab (yvar) + 
     opts(panel.margin=unit(0, "lines")) +
     geom_text(data=arrow_pos, aes(label=name, x=xvar, y=Freq + 2), size=4) +
     geom_segment(data=arrow_pos,
                  aes(x=xvar, xend=xvar, y=Freq + 1.5, yend=Freq + 0.25),
                  arrow=arrow(length=unit(2, "mm")))
 }