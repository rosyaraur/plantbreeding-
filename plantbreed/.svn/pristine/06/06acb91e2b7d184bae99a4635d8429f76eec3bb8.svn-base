stability <-
function (dataframe, yvar, genotypes, environments, replication){
dataframe <- data.frame (yvar = dataframe[,yvar], genotypes = dataframe[,genotypes], environments = dataframe[,environments], replication = dataframe [, replication])  
# 3D display of raw data
dev.new(width=8, height=6) 
require(lattice)
wfd <- wireframe(yvar ~ genotypes + environments, data = dataframe, scales=list(arrows=FALSE), col = "green4", drape=TRUE)  
print(wfd)

dataframe$replication <- as.factor(dataframe$replication)
dataframe$genotypes <- as.factor(dataframe$genotypes)
model1 <- lm(yvar ~ genotypes + environments + environments / replication + environments* genotypes, data = dataframe)
modav <- anova(model1)
mydf = data.frame(aggregate (yvar ~ genotypes + environments, data = dataframe, mean))
#names(mydf) <- unique(environments) # check how this performs, alphabet ordering  
myAgg = aggregate(yvar ~ genotypes, mydf, 'c')
matx <- myAgg$yvar
myAgg$genotypes
meandf = data.frame( genotypes = myAgg$genotypes, myAgg$yvar)
names (meandf) = c("genotypes", levels(mydf$environments))  
#meandf                                                         

gradyt = mean(matx)
# iij = as.matrix((apply (matx, 2, mean) - gradyt), 1)
iij = apply (matx, 2, mean) - gradyt # environmental index for environment
sqiij = sum ((iij)^2)
YiIj =  matx %*% iij
bij = YiIj / sqiij # regression coefficient for genotype i
svar = (apply(matx ^2, 1, sum)) - (((apply(matx, 1, sum))^2) /ncol(matx))
bYijIj = bij * YiIj
deltaij = svar -  bYijIj

# deviations and their regression table
devtab <- data.frame(genotypes = meandf$genotypes, svar, bij,YiIj,  bYijIj, deltaij)

S2e = modav$'Mean Sq'[5] 
rps = length(levels(dataframe$replication))  # number of reps
en = length(levels(dataframe$environments))   # number of locations / environments
S2di = ( deltaij / (en -2)) - ( S2e / rps) # environmental index 

# Anova for mean data 
require(reshape)
meandf1 = data.frame(melt(meandf, id.var = "genotypes"))
model2 <- lm(value ~ genotypes + variable , data = meandf1)
amod2 <- anova(model2)

# sum of squares
SSL = amod2$'Sum Sq'[2]
SSGxL = amod2$'Sum Sq'[3] 
SS.L.GxL = SSL + SSGxL
SSL.Linear = ( 1/ length(levels(dataframe$genotypes))) * (colSums(matx) %*% iij)^2/ sum(iij^2) 
SS.L.GxL.linear = sum(bYijIj) - SSL.Linear 

 
 #  Anova 
rps = rps # number of reps 
en = en # number of environments 
ge =  length(levels(mydf$genotypes)) # number of genotypes 
Df <- c(en*ge -1, ge -1, ge*(en-1), 1, ge -1, ge *(en-2), rep(en-2, length(deltaij)), en*ge*(rps-1)) 
poolerr = modav $"Sum Sq"[5] / rps 
SSS <- c(sum(amod2$'Sum Sq'), amod2$'Sum Sq'[1], SSL + SSGxL,  SSL.Linear, SS.L.GxL.linear, sum(deltaij),deltaij, poolerr)
MSSS = (SSS/Df)
FVAL = c(NA, MSSS[2]/MSSS[6],NA, NA,MSSS[5]/MSSS[6], NA, MSSS[7:(length(MSSS)- 1)]/MSSS[length(MSSS)], NA)

PLINES = 1- pf(FVAL[7:(length(MSSS)- 1)],Df[7], Df[length(Df)])

pval = c(NA, 1- pf(FVAL[2], Df[2], Df[6]), NA, NA,1- pf(FVAL[5], Df[5], Df[6]),NA,PLINES, NA)

anovadf <- data.frame(Df, `Sum Sq`=SSS, `Mean Sq`=MSSS, `F value`= FVAL, `Pr(>F)`= pval, check.names=FALSE)
rownames(anovadf) <- c("Total","Genotypes","Env + (Gen x Env)", "Env (linear)", " Gen x Env(linear)", "Pooled deviation",levels(dataframe$genotypes), "Pooled error" ) 
class(anovadf) <- c("anova","data.frame")

name.y <- yvar
cat("Anova for stability analysis", name.y, "\n\n")
print(anovadf)

cat(" Eberhart and Russell Model of stability, Crop Science 1966, 6:37-40", "\n\n" )

outdat = data.frame(genotypes= devtab$genotypes, bij = devtab$bij, sdij = S2di)
print(outdat)
cat(" Stable genotype have bij = 1 and sdij = 0", "\n\n"  )
windows()
dev.new(width=8, height=8)
plotst = data.frame (mydf, envindex = rep (iij, each = length(levels(dataframe$genotypes))))   
plot(plotst$yvar, plotst$envindex, xlab = "trait", ylab = "stability index", pch= 16, col = "blue")
with(plotst, text(plotst$yvar, plotst$envindex, labels= plotst$genotypes, pos=3, cex=0.75))
#abline (a= 0, b = 1, col = "red", lty = 2)
#segments(plotst$yvar, plotst$envindex, plotst$yvar, plotst$yvar, lty = 3, col = "green4")
 results = list(ANOVA = anovadf, Means = meandf,scores = outdat, devtab = devtab)    
 return (results) 
}
