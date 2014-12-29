aug.rcb <- function (dataframe, genotypes, block, yvar ) {
dataframe[,block] = factor(dataframe[,block])
dataframe[,genotypes] = factor(dataframe[,genotypes])
geno <- data.frame(table(dataframe[,genotypes]))
gr = as.vector (geno$Var1[geno$Freq == length (levels(dataframe[,block]))])
mydf1 = dataframe[dataframe[,genotypes]%in% gr,] 
model1 = lm(mydf1[,yvar] ~ mydf1[,genotypes] + mydf1[,block])
amodel1 <- anova(model1)
# anova renaming
Df <- amodel1$Df
"Sum Sq" <- amodel1$"Sum Sq"
"Mean Sq" <- amodel1$"Mean Sq"
"F value" <- amodel1$"F value"                
"Pr(>F)" <- amodel1$"Pr(>F)"
amod2 <- data.frame (Df = amodel1$Df, "Sum Sq" = amodel1$"Sum Sq","Mean Sq" = amodel1$"Mean Sq", "F value" = amodel1$"F value", "Pr(>F)" = amodel1$"Pr(>F)", check.names=FALSE)
rownames(amod2) <- c("Genotypes","Block", "Residual")
class(amod2) <- c("anova","data.frame")                                  


#block adjustment
blockdf = data.frame(aggregate (mydf1 [, yvar] ~  mydf1 [, block], data = mydf1, mean ))
names(blockdf) <- c("block","yvar") 
blockdf$yvar <- blockdf$yvar - mean(blockdf$yvar)

#mdd <- rep(mydf$yield, each = 21) ### 
pr = as.vector (geno$Var1[geno$Freq < length (levels(dataframe[,block]))])
newaugdata1 <- data.frame (dataframe[dataframe[,genotypes]%in% 
        pr,]) 
block_match <- match(newaugdata1[,block], blockdf$block)
mydf1.adj = transform(newaugdata1, yvar.adj = newaugdata1 [,yvar] - blockdf[block_match, 'yvar'])

 cat("Phenotypes and adjusted values : ", "\n\n")
print(mydf1.adj)
#plot unadjusted and adjusted values
plot(mydf1.adj$yvar,mydf1.adj$yvar.adj, xlab = "yvar", ylab = " yvar adjusted")
abline (a= 0, b = 1, col = "red", lty = 2)

# plot observed vs adjusted 
dev.new(width=8, height=8) 
plot(mydf1.adj$yvar,mydf1.adj$yvar.adj, xlab = "yvar", ylab = " yvar adjusted", asp=1, pch = 16, col = "lightseagreen") 
a = 0 
b = 1 
abline (a, b, col = "red", lty = 1) 
segments(mydf1.adj$yvar,mydf1.adj$yvar.adj, mydf1.adj$yvar,mydf1.adj$yvar, col = "blue1", lty = 2) 
text(mydf1.adj$yvar,mydf1.adj$yvar.adj,pos=3, cex = 0.5)
grid (NULL,NULL, lty = 6, col = "cornsilk2") 

 # standard errors for the different comparisions
 cat("Standard error of  different comparisions", "\n\n")
 MSE = amodel1$"Mean Sq"[3]
 SEcheck = (2 * MSE / (amodel1$Df[2] + 1)) ^ 0.5
cat("Difference between check means: ", SEcheck, "\n\n")
 SEwithin = (2 * MSE) ^ 0.5
 cat("Difference adjusted yield of two varities in same block : ", SEwithin, "\n\n")
  SEdiff = (2 * MSE * ( 1 + 1 / (amodel1$Df[1] +1))) ^ 0.5
cat("Difference between two varieties in different blocks: ", SEdiff, "\n\n")
  SEgcheck = ((MSE * (amodel1$Df[2] + 1 + 1) * (amodel1$Df[1]+1 + 1))/ ((amodel1$Df[1] +1) * (amodel1$Df[2] +1))) ^ 0.5
cat("Difference between two varieties and a check mean: ", SEgcheck, "\n\n")
results <- list (anova =amod2, adjusted_values = mydf1.adj, se_check = SEcheck,se_within = SEwithin, se_diff = SEdiff, se_geno = SEgcheck)  
return(results)
}