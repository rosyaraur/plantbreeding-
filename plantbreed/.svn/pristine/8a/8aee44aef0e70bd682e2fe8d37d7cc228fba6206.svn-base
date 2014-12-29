aug.rowcol <- function (dataframe, rows, columns, genotypes, yield) { 
 dataframe <- data.frame (rows = dataframe[, "rows"], columns = dataframe [, "columns"], genotypes = dataframe [, "genotypes"], 
               yield = dataframe [, "yield"]) 
 # analysis 
dataframe$rows = factor(dataframe$rows)
dataframe$columns = factor(dataframe$columns)
dataframe$genotypes = factor(dataframe$genotypes)

geno <- data.frame(table(dataframe$genotypes))
gr = as.vector (geno$Var1[geno$Freq == length (levels(dataframe$rows))])
mydf1 = dataframe[dataframe$genotypes %in% gr, ] 
model1 = lm(yield ~ genotypes + rows + columns, data = mydf1)
amodel1 <- anova(model1)
model1.res = resid(model1)

dev.new(width=8, height=8) 
plot(mydf1$yield, model1.res, ylab="Residuals", xlab="Trait", main = "residual plot of checks") 
text(mydf1$yield, model1.res, labels=mydf1$genotypes, pos=3, cex=0.75, col = "red")
abline(0, 0, col = "blue4")

# anova renaming
Df <- amodel1$Df
"Sum Sq" <- amodel1$"Sum Sq"
"Mean Sq" <- amodel1$"Mean Sq"
"F value" <- amodel1$"F value"
"Pr(>F)" <- amodel1$"Pr(>F)"
amod2 <- data.frame (Df = amodel1$Df, "Sum Sq" = amodel1$"Sum Sq","Mean Sq" = amodel1$"Mean Sq", "F value" = amodel1$"F value", "Pr(>F)" = amodel1$"Pr(>F)", check.names=FALSE)
rownames(amod2) <- c("Genotypes","rows", "columns", "Residual")
class(amod2) <- c("anova","data.frame")
print(amod2)


#row adjustment factors 
rowdf = data.frame(aggregate (yield ~  rows, data = mydf1, mean ))
rowdf$yield <- rowdf$yield - mean(rowdf$yield)

#column adjustment factor 
columndf = data.frame(aggregate (yield ~  columns, data = mydf1, mean ))
columndf$yield <- columndf$yield - mean(columndf$yield)

#row adjument 
pr = as.vector (geno$Var1[geno$Freq < length (levels(dataframe$rows))])
newaugdata1 <- data.frame (dataframe[dataframe$genotypes %in% gr, ]) 

row_match <- match(newaugdata1$rows, rowdf$rows)  
col_match <- match(newaugdata1$columns, columndf$columns)
mydf1.adj = transform(newaugdata1, yield.adj = yield - rowdf[row_match, 'yield'] - columndf[col_match, 'yield'])

cat("Phenotypes and adjusted values : ", "\n\n")
print(mydf1.adj)

 windows()
#plot unadjusted and adjusted values
plot(mydf1.adj$yield,mydf1.adj$yield.adj, xlab = "yield", ylab = " yield adjusted")
abline (a= 0, b = 1, col = "red", lty = 2)

 windows()
# plot observed vs adjusted 
dev.new(width=8, height=8) 
plot(mydf1.adj$yield,mydf1.adj$yield.adj, xlab = "yield", ylab = " yield adjusted", asp=1, pch = 16, col = "lightseagreen") 
a = 0 
b = 1 
abline (a, b, col = "red", lty = 1) 
segments(mydf1.adj$yield,mydf1.adj$yield.adj, mydf1.adj$yield,mydf1.adj$yield, col = "blue1", lty = 2) 
text(mydf1.adj$yield,mydf1.adj$yield.adj,pos=3, cex = 0.5)
grid (NULL,NULL, lty = 6, col = "cornsilk2")

 # standard errors for the different comparisions
 cat("Standard error of  different comparisions", "\n\n")
 MSE = amodel1$"Mean Sq"[4]
 SEcheck = (2 * MSE / (amodel1$Df[2] + 1)) ^ 0.5
cat("Difference between check means: ", SEcheck, "\n\n")
 SEwithin = (2 * MSE + (2 * MSE)/(amodel1$Df[2] + 1) ) ^ 0.5
 cat("Difference adjusted yield of two varities in same row or column : ", SEwithin, "\n\n")
  SEdiff = (2 * MSE  + (4 * MSE)/(amodel1$Df[2] + 1)) ^ 0.5
cat("Difference between two varieties in different rows or blocks: ", SEdiff, "\n\n")
  SEgcheck = (MSE + ((3 * MSE)/(amodel1$Df[2] + 1)) - ((2 * MSE)/((amodel1$Df[2] + 1)^2)))^0.5 
 cat("Difference between two varieties and a check mean: ", SEgcheck, "\n\n")
 results = list(ANOVA = amod2, Adjustment = mydf1.adj, se_check = SEcheck, se_within = SEwithin, se_diff = SEdiff, se_geno_check = SEgcheck)
 return (results)   
}