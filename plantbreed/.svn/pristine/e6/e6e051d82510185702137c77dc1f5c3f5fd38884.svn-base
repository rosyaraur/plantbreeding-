geno.convert <- function (dataframe, tranvec,ownvec = "ACGT", output.file, outsep = ",", na.strings = "NA")  {

 atgc <- function(x) {
          xlate <- c( "AA" = 11, "AC" = 12, "AG" = 13, "AT" = 14,
                       "CA"= 12, "CC" = 22, "CG"= 23,"CT"= 24,
                       "GA" = 13, "GC" = 23, "GG"= 33,"GT"= 34,
                        "TA"= 14,  "TC" = 24, "TG"= 34,"TT"=44,
                         "ID"= 56, "DI"= 56, "DD"= 55, "II"= 66
                         )
          x =   xlate[as.character(x)]
          }
numbase <-  function(x) {
          xlate <- c( '11'='AA', '12'='AC', '13'='AG','14'='AT',
                       '21'='AC', '22'='CC', '23'='CG','24'='CT',
                       '31'='AG', '32'='CG', '33'='GG','34'='GT',
                        '41'='AT', '42'='CT', '43'='GT','44'='TT'
                      )
          x =   xlate[as.character(x)]
          }
ownvec <- function(x) {
          xlate <- ove
          x =   xlate[as.character (x)]
          }

 abfun <- function(x) {
          xlate <- c( 'AA'= 11, 'AB'= 12, 'BA'= 12,'BB'= 22
          )
          x =   xlate[as.character (x)]
          }
if (tranvec == "ACGT"){
            outdataframe <- sapply (dataframe, atgc)
            outdataframe <- data.frame (outdataframe, row.names = NULL)
            write.table(outdataframe, file = output.file, sep = outsep, na = na.strings)
            cat("A output file has been created in the working directory: ",output.file, "\n\n")
            return(outdataframe)
                      }
if (tranvec == "AB") {
           outdataframe <- sapply (dataframe, abfun)
           outdataframe <- data.frame (outdataframe, row.names = NULL)
           write.table(outdataframe, file = output.file, sep = outsep, na = na.strings)
           cat("A output file has been created in the working directory: ",output.file, "\n\n")
           return(outdataframe)
                      }
if (tranvec == "num2base") {
           outdataframe <- sapply (dataframe, numbase)
           outdataframe <- data.frame (outdataframe, row.names = NULL)
           write.table(outdataframe, file = output.file, sep = outsep, na = na.strings)
           cat("A output file has been created in the working directory: ",output.file, "\n\n")
           return(outdataframe)
           } else {
           outdataframe <- sapply (dataframe, ownvec)
             outdataframe <- data.frame (outdataframe, row.names = NULL)
           write.table(outdataframe, file = output.file, sep = outsep, na = na.strings)
           cat("A output file has been created in the working directory: ",output.file, "\n\n")
           return (outdataframe)

                     }
    }