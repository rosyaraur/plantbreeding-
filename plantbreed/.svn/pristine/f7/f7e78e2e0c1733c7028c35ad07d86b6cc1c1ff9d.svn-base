onemap2mapchart <- function (mapfile, outprefix = "."){
mymap <- read.table(mapfile,header=F)
spt <- split(mymap, mymap$V1)
syt <- format(Sys.time(), "%d%b%Y")
filename <- paste(mapfile,syt,".mct", sep="")
sink(filename)
invisible(lapply(spt, function(DF) {
             cat (paste (";created from onemap output on  ", Sys.time(), sep = ""))
             cat("\n")
             cat("group ")
             cat(DF$V1[1])
             cat("\n")
             write.table(DF[,-1], row.names=FALSE, col.names=FALSE, quote=FALSE)
             cat("\n")
}))
sink()
cat (paste("The mapchart file: ", filename, sep= ""))
cat("\n")
}