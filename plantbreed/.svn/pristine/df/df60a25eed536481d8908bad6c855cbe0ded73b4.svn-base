\name{genotype2alleles}
\alias{genotype2alleles}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Converting SNP or other two letter genotype format to alelele format
}
\description{
Converting SNP or other two letter genotype format to alelele format
}
\usage{
genotype2alleles(input.file, input.sep = ",", column.num = "all", allele.sep = "/",
 comment.char = "#", na.strings = "NA", output.file, output.spe = ",")
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{input.file}{
Name of input file - eg csv or txt tabdelimited files  
}
  \item{input.sep}{
Input seperator - eg "," for csv file input or "  " space deliminated (this is seperator used in file) 
}
  \item{column.num}{
Whether to use all column ("all") or range of column to be converted from genotype to allele format 
}
  \item{allele.sep}{
If thee is seperator between allele characters (eg. for A/B for the seperator is "/", A-B format the seperator is "-".  
}
  \item{comment.char}{
The comment character used in the file to be read. The default is "#", it can be any special characters such as ";" 
}
  \item{na.strings}{
What is missing value string used in the file to be read - default is NA 
}
  \item{output.file}{
Desired name of output file 
}
  \item{output.spe}{
Desired seperator for the output file (use "," for csv, "  " for space delimited files) 
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
Umesh Rosyara 
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
# Example 1
A1 <- c("A/B", "A/A", "B/B", "A/A")
B1 <- c("B/B", "C/C", "C/B", "D/A")
C1 <- c("B/B", "C/C", "-/-", "D/A")
mydf <- data.frame (A1, B1, C1)
write.table(mydf, file = "mycsv22.csv", sep = ",")

p <- genotype2alleles(input.file = "mycsv22.csv", input.sep = ",", column.num = "all", 
 allele.sep = "/",comment.char = "#",na.strings = "NA", output.file = "out_mycsv22.csv" ,
  output.spe = ",")
print(p)
                             
# Example 2
ID <- 1:4
pos <- c(0, 245, 567, 871)
A1 <- c("A/B", "A/A", "B/B", "A/A")
B1 <- c("B/B", "C/C", "C/B", "D/A")
C1 <- c("B/B", "C/C", "-/-", "D/A")
mydf2 <- data.frame (ID, A1, B1, C1, pos)
write.table(mydf2, file = "mycsv26.csv", sep = ",")

p <- genotype2alleles(input.file = "mycsv26.csv", input.sep = ",", column.num = 2:4,
  allele.sep = "/",comment.char = "#",na.strings = "NA", output.file = "out_mycsv26.csv" ,
   output.spe = ",")
print(p)


}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
