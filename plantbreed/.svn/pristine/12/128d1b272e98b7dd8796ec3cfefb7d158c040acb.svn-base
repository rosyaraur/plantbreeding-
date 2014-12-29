gs2joinmap <- function (dataframe, type = "CP") {

if(type == "CP") {
tmymark <- data.frame (t(dataframe))
names (tmymark) <- c("P1", "P2","I1", "I2", "I3", "I4", "KL", "MN")

key <- data.frame(
                 P1=c(  "AB",       "AB",   "AB",         "AA",     "BB",          "AA",   "BB",   "--", "--",   "AA", "BB", "AB", "--"),
                   P2=c("AB",       "BB",   "AA",         "AB",     "AB",          "BB",   "AA",   "AA", "BB",   "--", "--","--",   "AB" ),
            loctype=c(  "<hkxhk>", "<lmxll>","<lmxll>",  "<nnxnp>", "<nnxnp>",     "MN",   "MN",   "NR",   "NR", "NR",   "NR", "NR",   "NR"))

key2 <- cbind(
  `<hkxhk>` = c("hk","hk","hh","kk", "--"),
  `<lmxll>` = c("lm", "lm", "--", "ll", "--"),
  `<nnxnp>` = c("np", "np", "nn", "--", "--"),
    MN = rep("--", 5),
    NR = rep("NA", 5) )
rownames(key2) = c("AB","BA", "AA", "BB", "--")

loctype <- key$loctype[match(with(tmymark, paste(P1, P2, sep="\b")),
                             with(key, paste(P1, P2, sep="\b")))]
ii <- match(as.vector(as.matrix(tmymark)), rownames(key2))
jj <- rep(match(loctype, colnames(key2)), nrow(tmymark))
out <- as.data.frame(matrix(key2[cbind(ii,jj)], nrow=nrow(tmymark)))
colnames(out) <- colnames(tmymark)
rownames(out) <- rownames(tmymark)
out$loctype <- loctype
return (out)
}
if(type == "F2") {
tmymark <- data.frame (t(dataframe))
names (tmymark) <- c("P1", "P2","I1", "I2", "I3", "I4", "KL", "MN")

mymat <- as.matrix(tmymark)

 recodeRows <- function(x){
        if (any(x[1:2]=="--")){
             x[3: ncol(mymat)] <- NA
        } else {
             x[3: ncol(mymat)][x[3: ncol(mymat)]==x[1]] <- "A"
             x[3: ncol(mymat)][x[3: ncol(mymat)]==x[2]] <- "B"
             x[3: ncol(mymat)][x[3: ncol(mymat)]=="--"] <- NA
             x[3: ncol(mymat)][!x[3: ncol (mymat)] %in% c("A","B",NA)] <- "H"
        }
    x
    }

out <- t(apply(mymat,1,recodeRows))
return(out)
}else {
 stop("The method is available to recode cross pollinated (CP) or F2 populations")
}
}