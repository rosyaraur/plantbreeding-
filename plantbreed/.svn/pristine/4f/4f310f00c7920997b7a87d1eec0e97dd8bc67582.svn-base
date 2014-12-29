histlab <-
function (dataframe, classvar = "class",arrow_yvar = "arrow_yvar",  arrow_yvar, arrow_label, arrow_class, bwidth, colour = "cyan4", fill = "cyan4"){
library(ggplot2)
library(grid) # unit() is in the grid package.
library(plyr)  # Data restructuring
mxvar <- NULL
Freqs <- NULL
class <- NULL

arrow_pos = data.frame (class = arrow_class, arrow_label = arrow_label,arrow_yvar = arrow_yvar, stringsAsFactors=FALSE)
myd <- data.frame (class = dataframe[,classvar], arrow_yvar = dataframe[,arrow_yvar])
myd <- myd[!is.na(myd$arrow_yvar),]
cat ("The rows with y variable missing are removed")
bwidth <- bwidth   # Set binwidth
Min <- floor(min(myd$arrow_yvar)/bwidth) * bwidth
Max <- ceiling(max(myd$arrow_yvar)/bwidth) * bwidth

# Function to do the counting
func <- function(df) {
   tab = as.data.frame(table(cut(df$arrow_yvar, breaks = seq(Min, Max, bwidth), right = FALSE)))
   tab$upper = Min + bwidth * (as.numeric(rownames(tab)))
   return(tab)
   }

# Apply the function to each class in myd data frame
TableOfCounts <- ddply(myd, .(class), function(df) func(df))

# Transfer counts of arrow_pos
arrow_pos$upper <- (floor(arrow_pos$arrow_yvar/bwidth) * bwidth) + bwidth
arrow_pos <- merge(arrow_pos, TableOfCounts, by = c("class", "upper"))
arrow_pos$mxvar <- (arrow_pos$upper - .5 * bwidth)      # x position of the arrow is at the midpoint of the bin

arrow_pos$class=factor(as.character(arrow_pos$class),
    levels= unique (myd$class)) # Gets rid of warnings.

ggplot(myd, aes(x=arrow_yvar)) +
     theme_bw() +
     geom_histogram(colour=colour, fill=fill, binwidth=bwidth) +
     facet_wrap(~ class) + xlab (arrow_yvar) + 
     opts(panel.margin=unit(0, "lines")) +
     geom_text(data=arrow_pos, aes(label=arrow_label, x=mxvar, y=Freqs + 2), size=4) +
     geom_segment(data=arrow_pos,
                  aes(x=mxvar, xend=mxvar, y=Freqs + 1.5, yend=Freqs + 0.25),
                  arrow=arrow(length=unit(2, "mm")))
 }
