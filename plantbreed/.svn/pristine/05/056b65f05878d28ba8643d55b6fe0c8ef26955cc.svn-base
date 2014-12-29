
table.creator <- function (mydata, yvar = FALSE, classvars, classy = FALSE, ycut = NULL ) {
if(classy == FALSE) {
                  classd <- mydata[,classvars]
                  resulttab = as.data.frame (table(classd))
                  return(resulttab)
                 } else {
                         require(plyr)
                         mydata <- data.frame (mydata [,yvar],mydata [,classvars])
                         names(mydata) <-   c(yvar, classvars)
                         yvar2 <- cut(mydata[,yvar],breaks = ycut)
                         resulttab <- dlply(mydata,.(yvar2),function(x) addmargins(table(x[,classvars])))
                         return(resulttab)
                         }
}




