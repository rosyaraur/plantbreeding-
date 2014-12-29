assoc.kin <- function (dataframe,  yvar, xvars, id = "id", dadid = "dadid", momid = "momid", sex = "sex", kmats = "calculate", kmatrix = NA, covariate = FALSE, cvar, model = "ADD") {
 xdf <- data.frame (dataframe[,xvars])
 names(xdf)
 if (model == "ADD"){
 add.convertf <- function(x) {
        xlate <- c("AA" = 1,"AB"=0, "BB" = -1)
        x = xlate[as.character(x)]
    }
 xdf <- sapply(xdf,  add.convertf)
   xdf <- data.frame(xdf, row.names = NULL)
 }
 if (model == "DOM"){
 rec.convertf <- function(x) {
        xlate <- c("AA" = 1,"AB"=1, "BB" = -1)
        x = xlate[as.character(x)]
    }
  xdf <- sapply(xdf,  rec.convertf)
   xdf <- data.frame(xdf, row.names = NULL)
  }
 if (model == "NONE"){
   xdf <- xdf
   }
 nvars <- ncol(xdf)
  prob <- numeric(nvars)
 cprob <- numeric(nvars)
 # fitting mixed model with kinship matrix
       if (covariate == FALSE) {
                mydf <- data.frame (id = dataframe[,id], dadid = dataframe[,dadid], momid = dataframe[,momid], sex = dataframe[,sex],yvar = dataframe[,yvar], xdf)
                if(kmats == "calculate"){
                          fam1.ped<-pedigree(id=mydf$id,dadid=mydf$dadid, momid= mydf$momid, sex= mydf$sex)
                          cfam <- makefamid(mydf$id,mydf$momid, mydf$dadid)
                          kmat <- makekinship(cfam, mydf$id, mydf$momid, mydf$dadid)# kinship matrix
                              }
                if (kmats == "user") {
                               kmat <- kmatrix
                                        }
                for (i in seq(nvars)){
               mydf$SNP <- mydf[,i + 5]
             prob[i] <- lmekin(yvar ~ SNP, data= mydf, random = ~1|id, varlist=list(kmat))$ctable[2,4]
              }
             out <- data.frame (markers = names (xdf), pvalue = prob)
             return(out)
               } else {
              mydf <- data.frame (id = dataframe[,id], dadid = dataframe[,dadid], momid = dataframe[,momid], sex = dataframe[,sex],
              yvar = dataframe[,yvar], covariate = dataframe[,cvar], xdf)
               names (mydf)
              # creating pedigree object
            if(kmats == "calculate"){
                          fam1.ped<-pedigree(id=mydf$id,dadid=mydf$dadid, momid= mydf$momid, sex= mydf$sex)
                    cfam <- makefamid(mydf$id,mydf$momid, mydf$dadid)
                      kmat <- makekinship(cfam, mydf$id, mydf$momid, mydf$dadid)# kinship matrix
                        }
            dim(kmat)
            if (kmats =="user") {
                               kmat <- kmatrix
                                        }
                   xdf <- data.frame (dataframe[,xvars])
                   nvars <- ncol(xdf)
                  nvars <- ncol(xdf)
                    prob <- numeric(nvars)
                   cprob <- numeric(nvars)
             for (i in seq(nvars)) {
            mydf$SNP <- mydf[,i + 6]
            mydf$covr <- mydf$covariate
            prob[i] <- lmekin(yvar ~ SNP + covr, data=  mydf, random = ~1|id, varlist=list(kmat))$ctable[2,4]
            cprob[i] <- lmekin(yvar ~ SNP + covr, data=  mydf, random = ~1|id, varlist=list(kmat))$ctable[3,4]
            }
            out <- data.frame (markers = names (xdf), pvalue = prob, cpvalue = cprob)
              return(out)
             }
}