diallele1 <- function (dataframe,yvar = "yvar", progeny = "progeny",  male = "male", female = "female",  replication = "replication")
{
dataframe <- data.frame (yvar = dataframe[,yvar],progeny = dataframe[,progeny],male = dataframe[, male], female = dataframe[,female], replication = dataframe[, replication])
 dataframe$male = as.factor(dataframe$male)
dataframe$female = as.factor(dataframe$female)
dataframe$progeny = as.factor(dataframe$progeny)
dataframe$replication =  as.factor(dataframe$replication)
mean.y =  mean(as.numeric(dataframe$yvar))

#Analysis of variance
formula = paste ("yvar"," ~ ", "progeny", " + ", "replication")
md1 <- lm(formula, data= dataframe) # anova treatment
yvar = yvar
 cat("Diallel analysis for trait: ", yvar, "\n\n")
 cat("...........................\n\n")
anvout <- anova(md1)
print(anvout)
if ( anvout[1,5] > 0.05){
           cat ("Note: Progeny effect is not significant at 0.05 p threshold")
           }
if ( anvout[1,5] > 0.01){
           cat ("Note: Progeny effect is not significant at 0.01 p threshold")
           }

data1 <- data.frame(aggregate(yvar ~ male: female, data = dataframe, mean))

mydf <- aggregate(yvar ~ female, data1, 'c')

myMatrix <- as.matrix (mydf[,-1])

n = (length(myMatrix))^0.5

acon <- sum((1/(2 * n))*((rowSums(myMatrix) + colSums(myMatrix))^2))
ssgca = acon - (2/ (n ^2))* (sum(myMatrix)^2)

sssca  = sum((1/ 2)*(myMatrix * (myMatrix + t(myMatrix)))) - acon + (1/ (n ^2))* (sum(myMatrix)^2)

ssrecp =   ((1/ 4)* sum((myMatrix - t(myMatrix))^2))
 r = nlevels(as.factor(dataframe$replication))
MSEAD = anvout$`Mean Sq`[3] / r

p = n # number of parents
Df <- c((p-1), (p *(p-1)/2), (p*(p-1)/2), anvout$Df[3])
SSS <- c(ssgca, sssca,ssrecp)
ssq <- c( SSS, anvout$`Sum Sq`[3]/r)
MSSS = SSS/Df[1:3]
MSSS1 = c(MSSS,MSEAD)
FVAL = c(MSSS1[1:3]/MSEAD, NA)
pval = c(1- pf(FVAL[1:3], Df[1:3], Df[3]), NA)
anovadf.mod1 <- data.frame(Df, `Sum Sq`=ssq, `Mean Sq`=MSSS1, `F value`= FVAL, `Pr(>F)`= pval, check.names=FALSE)
rownames(anovadf.mod1) <- c("GCA","SCA","Reciprocal", "error")
class(anovadf.mod1) <- c("anova","data.frame")
yvar <- names(dataframe$yvar)
yvar <- yvar
cat("Anova for combining ability - ModelI", yvar, "\n\n")
print(anovadf.mod1)

# genetic components
#GCA component
 GCAcomp = (MSSS[1] - MSEAD) / (2 * n)
 # SCA component

  SCAcomp = (MSSS[2] - MSEAD)
  RCAcomp  = (MSSS[3] - MSEAD) / 2
  GCARCAratio = GCAcomp /  SCAcomp
 components.model1 <- list (GCAcomp = GCAcomp, SCAcomp = SCAcomp, RCAcomp = RCAcomp, GCRCAratio = GCARCAratio)

  cat("Componets: Model 1",  "\n\n")
  cat("GCA :", GCAcomp, "\n\n")
  cat("SCA :", SCAcomp, "\n\n")
  cat("Reciprocal:", RCAcomp, "\n\n")
  cat("GCA to RCA ratio: ", GCARCAratio, "\n\n")

# GCA effects
gcaeff <- ((1/(2 * n))*(rowSums(myMatrix) + colSums(myMatrix))) - ((1/ (n ^2))* (sum(myMatrix)))
scaeff <- ((1/ 2) * (myMatrix + t(myMatrix))) -  ((1/(2 *n ))* (rowSums(myMatrix) + colSums(myMatrix) + colSums(t(myMatrix)) + rowSums(t(myMatrix)))) + ((1/ (n ^2))* (sum(myMatrix)))
recieff <-  0.5 * (myMatrix - t(myMatrix))
effmat <- gcaeff
#effmat <- diag(gcaeff)
#effmat <- lower.tri(recieff, diag = FALSE)

# Variances: standard error and critical differences
var.gi = ((n-1) / (2 * n ^2)) * MSEAD
var.sii = (((n-1)^2) / n ^2 ) *  MSEAD
var.sij = (1/(2*n^2))*((n^2)-2*n + 2) * MSEAD
var.rij =  0.5 * MSEAD
var.gi_gj = (1/n)*MSEAD
var.sij_sji = ((2*(n-2)) / n)* MSEAD
var.sii_sij = ((3*n -2)/ (2*n)) * MSEAD
var.sii_sjk =  ((3*(n-2)) / (2*n))* MSEAD
var.sij_sik = ((n-1)/n )* MSEAD
var.sij_skl = ((n-2)/n) * MSEAD
var.rij_rkl = MSEAD

varcompare <- list ( var.gi = var.gi,var.sii = var.sii, var.sij = var.sij, var.rij = var.rij, var.gi_gj = var.gi_gj, var.sij_sji = var.sij_sji,
var.sii_sij = var.sii_sij, var.sii_sjk = var.sii_sjk, var.sij_sik = var.sij_sik, var.sij_skl = var.sij_skl, var.rij_rkl = var.rij_rkl)

# model II
# Test of significance
cat("Anova for combining ability, model II", yvar, "\n\n")
FVAL1 = c(MSSS1[1]/MSSS1[2],MSSS1[2:3]/MSEAD, NA)
pval1 = c(1- pf(FVAL1[1], Df[1], Df[2]),1- pf(FVAL1[2:3], Df[2:3], Df[4]), NA)
anovadf.mod2 <- data.frame(Df, `Sum Sq`=ssq, `Mean Sq`=MSSS1, `F value`= FVAL1, `Pr(>F)`= pval1, check.names=FALSE)
rownames(anovadf.mod2) <- c("GCA","SCA","Reciprocal", "error")
class(anovadf.mod2) <- c("anova","data.frame")
print(anovadf.mod2)
# genetic components estimates
sigmasq.g = (1/(2* n))*(MSSS1[1] - (((MSEAD + n * (n-1) * MSSS1[2])) / (n^2 - n + 1)))
sigmasq.s = ((n ^ 2) / (2*(n^2 - n + 1))) * (MSSS1[2] - MSEAD )
sigmasq.r = 0.5 * (MSSS1[3] - MSEAD )
sigmasq.error = MSEAD
sgimasq.A = 2 * sigmasq.g
sigmasq.D = sigmasq.s
gca.scaratio = sigmasq.g /sigmasq.s

  cat("Componets: Model 2",  "\n\n")
  cat("GCA :", sigmasq.g , "\n\n")
  cat("SCA :", sigmasq.s, "\n\n")
  cat("Reciprocal:", sigmasq.r, "\n\n")
  cat("GCA to RCA ratio: ", gca.scaratio, "\n\n")

varcomp.model2 = list (sigmasq.g = sigmasq.g, sigmasq.s = sigmasq.s, sigmasq.r = sigmasq.r ,
sigmasq.error = sigmasq.error,sgimasq.A = sgimasq.A, sigmasq.D = sigmasq.D, gca.scaratio = gca.scaratio)

 # need to be expanded
return (list (anvout = anvout, anova.mod1 = anovadf.mod1,components.model1 = components.model1, gca.effmat = gcaeff, sca.effmat = scaeff,
reciprocal.effmat = recieff, varcompare = varcompare,anovadf.mod2 = anovadf.mod2,
varcomp.model2 = varcomp.model2))
}
