genotype2alleles <- function (input.file, input.sep = ",", column.num = "all",  allele.sep = "/",comment.char = "#",na.strings = "NA",
                             output.file, output.spe = ",") {
ndf <- input.file

ndf <- read.table(file= input.file, header = TRUE, sep = input.sep,na.strings = na.strings,check.names = TRUE, comment.char = comment.char)

if (column.num == "all") {

splitdf <- read.table(text=capture.output(write.table(ndf, quote=FALSE, sep= allele.sep,col.names=FALSE,row.names=FALSE)), sep= allele.sep)
names(splitdf) <- paste( rep(names(ndf), each=2), c("a","b"), sep="")
write.table(splitdf, file = output.file, sep = output.spe, na = na.strings)
 cat("A output file has been created in the working directory: ", output.file, "\n\n")
 return (splitdf)
} else {
  ndf1 <- ndf[,c(column.num)]
  ndf2 <-  ndf[, ! names(ndf) %in% names(ndf1)]
  splitdf1 <- read.table(text=capture.output(write.table(ndf1, quote=FALSE, sep= allele.sep,col.names=FALSE,row.names=FALSE)), sep= allele.sep)
  names(splitdf1) <- paste( rep(names(ndf1), each=2), c("a","b"), sep="")
   splitdf <- data.frame(ndf2, splitdf1)
   write.table(splitdf, file = output.file, sep = output.spe, na = na.strings)
   cat("A output file has been created in the working directory: ", output.file, "\n\n")
 return (splitdf)
 }
 }