seletion.index <-
function (phenodf, pcovmat, gcovmat, ecovmat, exout = TRUE, selectint = 0.01) {
zv = 1.76 # calculated based on selectint
bmat = solve(pcovmat) %*% gcovmat %*% ecovmat
cat("b values for selection index equations", "\n\n" )
bdatf <- data.frame(traits= names(phenodf) [-1], bi= bmat)
print(bdatf)
cat("", "\n\n" )
pmat <- as.matrix(phenodf[,-1])
print(pmat)
selcriterion <- pmat %*% bmat
selectdf <- data.frame(phenodf,selcriterion)
cat(" phenotypic values and selection criterion", "\n\n" )
print(selectdf)
# heatmap plot
# expected genetic gain
 ecovmats <- matrix(ecovmat, nrow = 1)
 W1 = matrix(gcovmat %*% bmat, nrow= 1)
 W = sum(W1 %*% ecovmat)
  bmatj = matrix(bmat, nrow = 1)
 VP1 = bmatj %*% pcovmat
 VP = VP1 %*% bmat
 dgain = (zv * W) / (VP ^ 0.5)
 cat("Expected genetic gain :", dgain, "\n\n")
 return(list(bis = bdatf, pmat = pmat,selectdf = selectdf, exp.ggain = dgain))
}
