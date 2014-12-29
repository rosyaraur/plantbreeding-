\name{geno.convert}
\alias{geno.convert}
 
\title{
Recoding genotypes 
}
\description{
The function converts recoding from DNA base pair (A/C/G/T) to number or other preferred forms.   
}
\usage{
geno.convert(dataframe, tranvec, ownvec = "ACGT", output.file, outsep = ",", 
na.strings = "NA")
}
\arguments{
  \item{dataframe}{
Input dataframe, the text or other documents can read to create dataframe using read.table function  
}
  \item{tranvec}{
What type of recoding needed: 
"ACGT" to recode basepair to number, A = 1, C = 2, G = 3, T = 4, D = 5, I = 6, else missing string defined in na.string or default = "NA"  
"AB" to recode basepair to number, A = 1, B = 2, else missing string defined in na.string or default = "NA" 
"num2base" to recode number of basepair, 1 = A, 2 = C, 3 = G, 4 = T, 5 = D, 6=I, else missing string defined in na.string or default = "NA"                                                                                                        
If "OWN", we need to define the ownvec with recoding information 
}                                               
  \item{ownvec}{
If defined as "OWN" in tranvec, ownvec must be defined as list with list (in data = recoded to), example, 
ove <- c( "AA" = "A", "AB" = "H", "BB" = "B" ), here AA will be recoded to A, AB recoded to H and BB recoded to B.   
}
  \item{output.file}{
The output fileoutput files to be produced. 
}
  \item{outsep}{
The output file seperator. Use "," for comma delinimated file, " " space deliminated and other delimiter is also supported 
}
  \item{na.strings}{
what spring should be used for missing data. 
}
}
\author{
Umesh Rosyara
}
\examples{
# Example 1, convert number base (A, C, G, T, D, I) to number (1, 2, 3, 4, 5, 6) 
X1 <- c(sample (c("AA", "AC", "CA", "CC", "--"), 200, replace = "TRUE"))
X2 <- c(sample (c("II", "ID", "DI", "DD", "--"), 200, replace = "TRUE"))
X3 <- c(sample (c("TT", "GG", "TG", "GT", "--"), 200, replace = "TRUE"))
mydf1 <- data.frame(X1, X2, X3)

p1 <- geno.convert(dataframe = mydf1, tranvec="ACGT", output.file = "p2.csv",
 outsep = ",", na.strings = "-")
p1 <- geno.convert(dataframe = mydf1, tranvec="ACGT", output.file = "p2.txt", 
outsep = "  ", na.strings = "NA")
print(p1)

# Example 2, convert number (1, 2, 3, 4, 5, 6) to base (A, C, G, T, D, I) 

var1 <- c(sample (c(11, 13, 31, 33, "--"), 100, replace = "TRUE"))
var2 <- c(sample (c(11, 12, 21, 22, "--"), 100, replace = "TRUE"))
var3 <- c(sample (c(55, 56, 65, 66, "--"), 100, replace = "TRUE"))
ex2 <- data.frame(var1, var2, var3)
p2 <- geno.convert(dataframe = ex2, tranvec="num2base", output.file = "p.csv",
 outsep = ",", na.strings = "-")
print(p2)

# Example 3, convert A, B to number 1, 2 
V1 <- c(sample (c("AA", "AB", "BA", "BB", "--"), 100, replace = "TRUE"))
V2 <- c(sample (c("AA", "AB", "BA", "BB", "--"), 100, replace = "TRUE"))
V3 <- c(sample (c("AA", "AB", "BA", "BB", "--"), 100, replace = "TRUE"))
ex3 <- data.frame(V1, V2, V3)

p3 <- geno.convert(dataframe = ex3, tranvec="AB", output.file = "p3.csv", 
outsep = ",", na.strings = "-")
print(p3)

# Example 4: recoding the data with own vector
# ove <- c( "AA" = "A", "AB" = "H", "BA" = "H", "BB" = "B" )

# p4 <- geno.convert(dataframe = ex3,tranvec= "OWN", ownvec = ove, output.file = "p4.csv",
 # outsep = ",",na.strings = "-")
# print(p4)
}

