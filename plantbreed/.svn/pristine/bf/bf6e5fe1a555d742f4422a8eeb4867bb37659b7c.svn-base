rqtl2mapchart <- function (crossobj, trait = "1", chr = c(1, 2, 3)) {

write.cross(crossobj, format = "gary", filestem="data", chr = chr, digits=5)

chid <- read.table("chrid.dat",header=F)
markpos <- read.table("markerpos.txt",header=F)
mymap <- data.frame(chid, markpos)
names(mymap) <- c("group", "marker", "markpos")

lodout.t <- data.frame(Map = out.em$pos, Group = out.em$chr, LOD = out.em$lod)

spt1 <- split(lodout.t, lodout.t$ Group)


lapply(names(spt1), function(x){write.table(spt1[[x]], file = paste("lodout", x, ".txt", sep = ""), row.names=FALSE, col.names=T, quote=FALSE) })

spt <- split(mymap, mymap$group)
syt <- format(Sys.time(), "%d%b%Y")
filename <- paste("rc",trait, syt, ".mct", sep="")
sink(filename)
invisible(lapply(spt, function(DF) {
             cat (paste (";created from R/qtl output on  ", Sys.time(), sep = ""))
             cat("\n")
             cat("group ")
             cat(DF$group[1])
             cat("\n")
             write.table(DF[,-1], row.names=FALSE, col.names=FALSE, quote=FALSE)
             cat("\n")
cat("qtls")
cat("\n")
cat (paste (paste("qtl-", DF$group[1], sep = "" ), "auto",  "1", "2", "C4" ))
cat("\n")
cat (paste ("graphs", "S=3" , "H=", max(out.em$lod)+0.5))
cat("\n")
cat ("const 2.85 L2 ")
cat("\n")
cat (paste (paste("qtl-", DF$group[1], sep = "" ), paste ("lodout", DF$group[1], ".txt", sep = ""),  "I",  "C3", "S2", "L1" ))
cat("\n")
cat("\n")
}))
sink()
file.remove("chrid.dat", "markerpos.txt", "geno.dat", "pheno.dat", "pnames.txt")
cat (paste("The mapchart file: ", filename, sep= ""))
cat("\n")
}
