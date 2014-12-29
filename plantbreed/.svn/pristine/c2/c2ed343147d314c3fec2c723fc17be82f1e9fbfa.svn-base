line.tester <-
function (dataframe, yvar,  genotypes = genotypes, replication,  Lines = Lines, Testers = Tester, gclass = gclass )
{      dataframe <- data.frame (dataframe[,yvar], dataframe[,genotypes], dataframe [, replication], dataframe [,Lines], dataframe[,Testers], dataframe [,gclass])
       names(dataframe) <- c("yvar", "genotypes", "replication", "Lines", "Tester", "gclass")
       dataframe$genotypes <- as.factor(dataframe$genotypes)
       dataframe$gclass <- as.factor(dataframe$gclass)
       dataframe$Lines <- as.factor(dataframe$Lines)
        dataframe$Tester <- as.factor(dataframe$Tester)
       dataframe$replication <- as.factor(dataframe$replication)
        #data$Yld <- data$Yld
        #print(summary(dataframe))
        countN <- function ( v ) { # function to count number of values 
                                    sum ( !is.na ( v ) ) - sum ( is.na ( v ) )
                                        }
         #nas <- countN(y)
         #if (nas > = 1){
         #cat(" Aborted, missing value detected ")
         #cat("Missing values :", nas, "\n\n")
         #}
         
         ### if (nas == 0){ ????????????????????????????????????????????????????????????????????????????//
         md1 <- lm(yvar ~ genotypes + replication, data = dataframe) # anova treatment
         anvout <- anova(md1)
        
         # Treatment sumsusquare partioning in parent and crosses
          data1 <- data.frame(aggregate(yvar ~ Lines:Tester, data = dataframe, sum)) # new data frame with line x tester sum
          CF1 = sum(data1$yvar)^2 / (countN(data1$yvar)* nlevels(dataframe$replication))
          sscross <- (sum((data1$yvar)^2)/nlevels(dataframe$replication)) - CF1
          
          data2 <- subset(dataframe,gclass == "P")
          data3 <- data.frame(aggregate(yvar ~ genotypes, data = data2, sum))
          CF2 = sum(data3$yvar)^2 / (countN(data3$yvar)* nlevels(dataframe$replication))
          ssparent = (sum((data3$yvar)^2)/nlevels(dataframe$replication)) - CF2
          SSTr =   anvout["Sum Sq"]
          sspr.css = SSTr[1,] - ssparent - sscross
          
          # line x tester analysis
         data4 <- data.frame(aggregate(yvar ~ Lines, data = data1, sum))
          # SS due to lines
          ssline =  (sum((data4$yvar)^2)/(nlevels(dataframe$replication)*nlevels(dataframe$Tester))) - CF1
          # SS due to tester
          data5 <- data.frame(aggregate(yvar ~ Tester, data = data1, sum))
          sstester =  (sum((data5$yvar)^2)/(nlevels(dataframe$replication)*nlevels(dataframe$Lines))) - CF1
          sslinXtest = sscross -  ssline -  sstester

          # table ANOVA for line x tester analysis
           # degrees of freedom
           repdf =   nlevels(dataframe$replication)-1
           trtdf = nlevels(dataframe$genotype)-1
           parentdf = (nrow(data2))/(nlevels(dataframe$replication))-1
           prvscrdf = 1
           crossdf =   trtdf - parentdf - prvscrdf
           Linedf =  nlevels(dataframe$Lines)-1
           Testerdf = nlevels(dataframe$Tester)-1
           lintestdf = Linedf * Testerdf
           errordf = anvout$Df[3]
           totaldf = sum(anvout$Df)
           Df <- c(repdf,trtdf, parentdf, prvscrdf, crossdf,Linedf,Testerdf,lintestdf,errordf, totaldf)
            repssq = anvout$`Sum Sq`[2]
           trtssq = anvout$`Sum Sq`[1]
           errorsq = anvout$`Sum Sq`[3]
           ssq <- c(repssq, trtssq, ssparent,  sspr.css, sscross, ssline, sstester, sslinXtest, errorsq)
           ssq <- c(ssq, sum(ssq))
           msq = c(ssq[1:9]/Df[1:9],  NA) 
           Fval <- c(msq[1:5]/msq[9],msq[6:7]/msq[8],msq[8]/msq[9],NA, NA)   
           pval = c(1- pf(Fval[1:5],Df[1:5],errordf),1- pf(Fval[6:7],Df[6:7],lintestdf),1- pf(Fval[8],Df[8],errordf), NA, NA )
              
           anovadf <- data.frame(Df, `Sum Sq`=ssq, `Mean Sq`=msq, `F value`= Fval, `Pr(>F)`= pval, check.names=FALSE)
           rownames(anovadf) <- c("replication","treatments","parents", "parents vs cross", "cross", "Lines", "tester", "line x tester", "error", "total") 
           class(anovadf) <- c("anova","data.frame") 
            name.y <- yvar 
           cat("Analysis of variance:", name.y, "\n\n")
           print(anovadf)
           
           # Estimation of GCA effects 
           # Estimation of GCA effects
            # lines
          cat("General combining ability test:", name.y, "\n\n")
          cat("Lines", "\n\n")  
          cfac = sum(data4$yvar)/(nlevels(dataframe$replication)* nlevels(dataframe$Tester) * nlevels(dataframe$Lines))
          gcavec <- (data4$yvar /(nlevels(dataframe$Tester) * nlevels(dataframe$replication)))  - cfac
           data7 <- data.frame(aggregate(yvar ~ Lines, data = dataframe, mean))
           errgl      =   ((msq[9]) / ((nlevels(dataframe$Tester) * nlevels(dataframe$replication))))^0.5 # lines 
           errgldf      =   ((2*msq[9]) / ((nlevels(dataframe$Tester) * nlevels(dataframe$replication))))^0.5 
          gcline <- data.frame (Lines = data4$Lines,mean = data7$yvar, gca= gcavec,`Standard error`= errgl, `SE difference`= errgldf )
          print(gcline) 
          cat("Testers", "\n\n")   
          # sum(gcavec) ahould be zero
          # testers
          gcavect <- (data5$y /(nlevels(dataframe$Lines) * nlevels(dataframe$replication)))  - cfac
          data8 <- data.frame(aggregate(yvar ~ Tester, data = dataframe, mean))
           errglt      =   ((msq[9]) / ((nlevels(dataframe$Lines) * nlevels(dataframe$replication))))^0.5 # lines
           errgltdf      =   ((2*msq[9]) / ((nlevels(dataframe$Lines) * nlevels(dataframe$replication))))^0.5 # lines  
           gclinet <- data.frame (Testers = data5$Tester,mean = data8$yvar, gca= gcavect,`Standard error`= errglt, `SE difference`= errgltdf )
            print(gclinet)
        
# Estimation of sca effects
z1 <- data.frame(aggregate(yvar ~ Lines, data1, 'c')[,-1])
scamat <- (z1 /nlevels(dataframe$replication))  - (rowSums(z1)/(nlevels(dataframe$Tester)*nlevels(dataframe$replication))) - (colSums(z1)/(nlevels(dataframe$Lines)*nlevels(dataframe$replication)))+ (sum(z1)/ (nlevels(dataframe$Tester)*nlevels(dataframe$Lines)* nlevels(dataframe$replication)))
#names(scamat) <-?????????????????????????? 
#check the scamat  
 cat("SCA matrix", "\n\n")  
print(scamat) 
 
# Genetic components 
CovHSline = (msq[6] - msq[8])/(nlevels(dataframe$Tester)*nlevels(dataframe$replication))   
CovHStester = (msq[7] - msq[8])/(nlevels(dataframe$Lines)*nlevels(dataframe$replication))
r = nlevels(dataframe$replication)
t = nlevels(dataframe$Tester)
l = nlevels(dataframe$Lines)
frac = (1 / (r *((2 * l * t) - l - t)))
fr2 = ((l-1)* msq[6]) + ((t-1)* msq[7])
CovHSavg = frac * ((fr2 / (l + t -2)) - msq[8]) 

fr1 = ((msq[6] - msq[9]) + (msq[7] - msq[9]) + (msq[8] - msq[9]))/ (3 * r) 
fr2 = ((6 * r * CovHSavg) - (r *(l + t) * CovHSavg))/ (3*r)  
CovFS =  fr1 + fr2

# variance gca; cov HS; check the formula 
  VarAF0 = CovHSavg / (1/4)
  VarAF1 = CovHSavg / (1/2)
 
 # variance SCA ; check the formula  
 VarSCA = (msq[8] - msq[9])/ r
 varDF0 = 4 *  VarSCA
 varDF1 =  VarSCA   
 
cat("Genetic components:",  "\n\n")
cat("Covariance (Line):", CovHSline, "\n\n")
cat("Covariance (Tester):", CovHStester, "\n\n")
cat("Covariance (Average):", CovHSavg, "\n\n")
cat("Covariance (FS)/ variance GCA:", CovFS, "\n\n")
cat("Additive variance with F = 0:", VarAF0, "\n\n")
cat("Additive variance with F = 1:", VarAF1, "\n\n")  
cat("Dominance variance with F = 0:", varDF0, "\n\n")
cat("Dominance variance with F = 1:", varDF1, "\n\n") 
 cat("Variance (SCA):", VarSCA, "\n\n")
 covlist <- list (CovHSline = CovHSline,CovHStester = CovHStester,CovHSavg = CovHSavg,CovFS = CovFS,VarAF0 = VarAF0, varDF1 = varDF1)     
 
 # proportion of contribution from lines 
 contline = (ssq[6] * 100)/ssq[5]
  conttester = (ssq[7] * 100)/ssq[5]
  contlinextester = (ssq[8] * 100)/ssq[5]
 cat("Proportion of contributiin from lines, tester and lines x tester :",  "\n\n")
 cat("Contribution from lines:", contline, "\n\n") 
 cat("Contribution from tester:", conttester, "\n\n") 
  cat("Contribution from line x tester:", contlinextester, "\n\n")
  contib <- list (lines = contline, testers = conttester, linextester = contlinextester) 
 results = list(ANOVA = anovadf,GC.Lines = gcline,GC.tester = gclinet,SCA.mat = scamat, Covariance = covlist, contribution = contib)    
 return (results)    
 }
