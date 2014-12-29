diversity <-
function (dataframe, varcol = 2:length(dataframe), xvar = "genotype",
    yvarlab = "marker", dendocol = "blue4", cor = TRUE, heatcol = cm.colors(256),
    rc = rainbow(nrow(tvar), start = 0, end = 0.3), cc = rainbow(ncol(tvar),
        start = 0, end = 0.3), method = "ward",
    scale = "column", ...)
{
    dataframe1 <- dataframe[, varcol]
    dataframe2 <- data.frame(t(dataframe[, varcol]))
    names(dataframe2) <- c(paste("ind.", dataframe[, xvar], sep = ""))
    lf2 <- paste(names(dataframe2), collapse = " + ")
    formula0 <- as.formula(paste(" ~", lf2, sep = ""))
    pc.cr <- prcomp(formula = formula0, data = dataframe2, na.action = na.exclude,
        cor = cor)
    plot(pc.cr)
    dev.new()
    biplot(pc.cr)
    tkw = c(dataframe[, xvar])
    lf <- paste(names(dataframe1), collapse = " + ")
    formula <- as.formula(paste(xvar, lf, sep = " ~"))
    HClust.2 <- hclust(dist(model.matrix(formula, dataframe)),
        method = method)
    dev.new()
    plot(HClust.2, main = "Cluster Dendrogram", xlab = "Observation Number",
        sub = paste("Method=", method, "; Distance=eucledian",
            sep = ""), col = dendocol)
    tvariability = data.frame(t(dataframe[,varcol]))
    names(tvariability) <- tkw
    tvar <- as.matrix(tvariability)
    dev.new()
    hv <- heatmap(tvar, scale = scale, col = heatcol, margins = c(5, 10), xlab = xvar,
        ylab = yvarlab, main = " Heat map plot", ...)
    return(list(pca.results = pc.cr, Hclust = HClust.2, hv = hv))
  }