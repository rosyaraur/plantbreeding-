assoc.unr <- function (dataframe,  yvar, xvars, covariate = FALSE, cvar, binomial = FALSE, model = "ADD") {
  xdf <- data.frame (dataframe[,xvars])
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
# linear model based, assumption of no population structure, unrelated individuals
 if (binomial == TRUE) {
          if (covariate == FALSE) {
                     mydata <- data.frame (yvar = dataframe[,yvar], xdf)
                     for (i in seq(nvars)) {
                       prob[i] <- anova(glm(yvar ~ mydata[, i + 1], family = "binomial", data = mydata), test = "Chisq")$`Pr(>Chi)`[2]
                       }
                     out <- data.frame (marker = names (mydata[,2:length (mydata)]), pvalue = prob)
                     return(out)
                       }  else {
                     mydata <- data.frame (yvar = dataframe[,yvar], covariate = dataframe[,cvar], dataframe[,xvars])
                      for (i in seq(nvars)) {
                     prob[i] <- anova(glm(status ~ mydata[,i+1] + covariate, family = "binomial", data = mydata), test = "Chisq")$`Pr(>Chi)`[2]
                     cprob[i] <- anova(glm(status ~ mydata[,i+1] + covariate, family = "binomial", data = mydata), test = "Chisq")$`Pr(>Chi)`[3]
                     }
                     out <- data.frame (marker = names (mydata[,3:length (mydata)]), pvalue = prob, cpvalue = cprob)
                     return(out)
                     }

} else {
           if (covariate == FALSE) {
                     mydata <- data.frame (yvar = dataframe[,yvar], xdf)

                     for (i in seq(nvars)) {
                      prob[[i]] <- anova(lm(yvar  ~ mydata[,i+1] , data=  mydata))$`Pr(>F)`[1]
                              }
                      out <- data.frame (markers = names (mydata[,2:length (mydata)]), pvalue = prob)
                      return(out)
                     } else {
                    mydata <- data.frame (yvar = dataframe[,yvar],covariate = dataframe[,cvar], xdf)
                    for (i in seq(nvars)) {
                   prob[i] <- anova(lm(yvar  ~ mydata[,i + 2] + covariate, data=  mydata))$`Pr(>F)`[1]
                   cprob[i] <- anova(lm(yvar  ~ mydata[,i+2] + covariate, data=  mydata))$`Pr(>F)`[2]
                    }
                    out <- data.frame (marker = names (mydata[,3:length (mydata)]), pvalue = prob, cpvalue = cprob)
                    return(out)
                    }
         }
         }
