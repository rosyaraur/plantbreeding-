graphicalgeno <-
function (dataframe = dataframe, group = "group", position = "position", yvar = "yvar", ycat = "ycat",namevar = "namevar",subset = TRUE,
           subsetdata = datas, panel.margin = 0.1 , strip.background = "lightpink", filllow = "white", fillhigh = "darkgreen",textlab = TRUE,
           textcolor = "blue", chr.arrange = "LR"){
           require(ggplot2)
           dataframe <- data.frame (dataframe[,namevar], dataframe[,position], dataframe[,yvar], dataframe[,ycat], dataframe[,group])
           names(dataframe) <- c("namevar", "position", "yvar", "ycat", "group")
           if (textlab == FALSE) {
           if(subset == TRUE) {
           subsetdata <- data.frame (subsetdata[,namevar], subsetdata[,position], subsetdata[,yvar], subsetdata[,ycat], subsetdata[,group])
           names(subsetdata) <- c("namevar", "position", "yvar", "ycat", "group")
           if (chr.arrange == "LR") {
            p <- ggplot(dataframe,aes(y=namevar,x=position)) + facet_wrap(~group,scales = "free_x",  nrow = 1, ncol = length (unique(dataframe$group))) +
            geom_blank() +  geom_tile(data = datas,aes(fill = yvar))  +
            labs(x = NULL,y = NULL)   + scale_fill_gradient(low = filllow, high = fillhigh) + theme_bw()
             p1 <- p + opts(panel.margin = unit(panel.margin, "lines"), strip.background = theme_rect(fill = strip.background))
             print(p1)
             }
            if (chr.arrange == "TB") {
             p <- ggplot(dataframe,aes(y=namevar,x=position)) + facet_wrap(~group,scales = "free_x",  ncol = 1, nrow = length (unique(dataframe$group))) +
            geom_blank() +  geom_tile(data = datas,aes(fill = yvar))  +
            labs(x = NULL,y = NULL)   + scale_fill_gradient(low = filllow, high = fillhigh) + theme_bw()
             p1 <- p + opts(panel.margin = unit(panel.margin, "lines"), strip.background = theme_rect(fill = strip.background))
             print(p1)
             }
             if (chr.arrange == "DF"){
             p <- ggplot(dataframe,aes(y=namevar,x=position)) + facet_wrap(~group, scales = "free_x") +
            geom_blank() +  geom_tile(data = datas,aes(fill = yvar)) +
            labs(x = NULL,y = NULL)   + scale_fill_gradient(low = filllow, high = fillhigh) + theme_bw()
             p1 <- p + opts(panel.margin = unit(panel.margin, "lines"), strip.background = theme_rect(fill = strip.background))
             print(p1)
             }
             } else {
            if (chr.arrange == "LR") {
            p <- ggplot(dataframe,aes(y=namevar,x=position)) + facet_wrap(~group,scales = "free_x",  nrow = 1,  ncol = length (unique(dataframe$group))) +
            geom_blank() +  geom_tile(data = dataframe,aes(fill = yvar))  +
            labs(x = NULL,y = NULL)   + scale_fill_gradient(low = filllow, high = fillhigh) + theme_bw()
             p1 <- p + opts(panel.margin = unit(panel.margin, "lines"), strip.background = theme_rect(fill = strip.background))
             print(p1)
             }
            if (chr.arrange == "TB") {
             p <- ggplot(dataframe,aes(y=namevar,x=position)) + facet_wrap(~group, scales = "free_x",  ncol = 1, nrow = length (unique(dataframe$group))) +
            geom_blank() +  geom_tile(data = dataframe,aes(fill = yvar))  +
            labs(x = NULL,y = NULL)   + scale_fill_gradient(low = filllow, high = fillhigh) + theme_bw()
             p1 <- p + opts(panel.margin = unit(panel.margin, "lines"), strip.background = theme_rect(fill = strip.background))
             print(p1)
             }
             if (chr.arrange == "DF") {
             p <- ggplot(dataframe,aes(y=namevar,x=position)) + facet_wrap(~group, scales = "free_x") 
            geom_blank() +  geom_tile(data = dataframe,aes(fill = yvar)) +
            labs(x = NULL,y = NULL)   + scale_fill_gradient(low = filllow, high = fillhigh) + theme_bw()
             p1 <- p + opts(panel.margin = unit(panel.margin, "lines"), strip.background = theme_rect(fill = strip.background))
             print(p1)
             }
             }
             } else {
             if(subset == TRUE) {
           subsetdata <- data.frame (subsetdata[,namevar], subsetdata[,position], subsetdata[,yvar], subsetdata[,ycat], subsetdata[,group])
           names(subsetdata) <- c("namevar", "position", "yvar", "ycat", "group")
           if (chr.arrange == "LR") {
            p <- ggplot(dataframe,aes(y=namevar,x=position)) + facet_wrap(~group,scales = "free_x",  nrow = 1, ncol = length (unique(dataframe$group))) +
            geom_blank() +  geom_tile(data = datas,aes(fill = yvar)) +
            geom_text(data = datas,aes(label = ycat),size = 3, col = textcolor) +
            labs(x = NULL,y = NULL)   + scale_fill_gradient(low = filllow, high = fillhigh) + theme_bw()
             p1 <- p + opts(panel.margin = unit(panel.margin, "lines"), strip.background = theme_rect(fill = strip.background))
             print(p1)
             }
            if (chr.arrange == "TB") {
             p <- ggplot(dataframe,aes(y=namevar,x=position)) + facet_wrap(~group,scales = "free_x",  ncol = 1, nrow = length (unique(dataframe$group))) +
            geom_blank() +  geom_tile(data = datas,aes(fill = yvar)) +
            geom_text(data = datas,aes(label = ycat),size = 3, col = textcolor) +
            labs(x = NULL,y = NULL)   + scale_fill_gradient(low = filllow, high = fillhigh) + theme_bw()
             p1 <- p + opts(panel.margin = unit(panel.margin, "lines"), strip.background = theme_rect(fill = strip.background))
             print(p1)
             }
             if (chr.arrange == "DF"){
             p <- ggplot(dataframe,aes(y=namevar,x=position)) + facet_wrap(~group, scales = "free_x") +
            geom_blank() +  geom_tile(data = datas,aes(fill = yvar)) +
            geom_text(data = datas,aes(label = ycat),size = 3, col = textcolor) +
            labs(x = NULL,y = NULL)   + scale_fill_gradient(low = filllow, high = fillhigh) + theme_bw()
             p1 <- p + opts(panel.margin = unit(panel.margin, "lines"), strip.background = theme_rect(fill = strip.background))
             print(p1)
             }
             } else {
            if (chr.arrange == "LR") {
            p <- ggplot(dataframe,aes(y=namevar,x=position)) + facet_wrap(~group,scales = "free_x",  nrow = 1, ncol = length (unique(dataframe$group))) +
            geom_blank() +  geom_tile(data = dataframe,aes(fill = yvar)) +
            geom_text(data = dataframe,aes(label = ycat),size = 3, col = textcolor) +
            labs(x = NULL,y = NULL)   + scale_fill_gradient(low = filllow, high = fillhigh) + theme_bw()
             p1 <- p + opts(panel.margin = unit(panel.margin, "lines"), strip.background = theme_rect(fill = strip.background))
             print(p1)
             }
            if (chr.arrange == "TB") {
             p <- ggplot(dataframe,aes(y=namevar,x=position)) + facet_wrap(~group,scales = "free_x",ncol = 1, nrow = length (unique(dataframe$group))) +
            geom_blank() +  geom_tile(data = dataframe,aes(fill = yvar)) +
            geom_text(data = dataframe,aes(label = ycat),size = 3, col = textcolor) +
            labs(x = NULL,y = NULL)   + scale_fill_gradient(low = filllow, high = fillhigh) + theme_bw()
             p1 <- p + opts(panel.margin = unit(panel.margin, "lines"), strip.background = theme_rect(fill = strip.background))
             print(p1)
             }
             if (chr.arrange == "DF") {
             p <- ggplot(dataframe,aes(y=namevar,x=position)) + facet_wrap(~group, scales = "free_x") +
            geom_blank() +  geom_tile(data = dataframe,aes(fill = yvar)) +
            geom_text(data = dataframe,aes(label = ycat),size = 3, col = textcolor) +
            labs(x = NULL,y = NULL)   + scale_fill_gradient(low = filllow, high = fillhigh) + theme_bw()
             p1 <- p + opts(panel.margin = unit(panel.margin, "lines"), strip.background = theme_rect(fill = strip.background))
             print(p1)
             }
             }
             }
             }
