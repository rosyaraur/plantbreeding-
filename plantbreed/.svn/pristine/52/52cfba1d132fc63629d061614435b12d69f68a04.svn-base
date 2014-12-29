\name{gs2joinmap}
\alias{gs2joinmap}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Convert Conversion of Ggenostudio matrix output to cross pollinated or self-pollinated Joinmap codes. 
}
\description{
The function convert the Genostudio matrix output to cross pollinated or self-pollinated Joinmap code formats. 
Genomestudio software is Illumina proprietary software for visualization and scoring of single nucleotide polymorphism (SNP) run in golden gate and iscan platforms. 
Joinmap is proprietary software from Kyazma commonly used for creating linkage / genetic maps. 
Manual conversion of genome studio output matrix to Joinmap code can be crumble some if need to be done manually, thus this function automate the process.    
}
\usage{
gs2joinmap(dataframe, type = "CP")
}
\arguments{
  \item{dataframe}{
Dataframe should consist of first two rows for parent 1 and parent 2 followed by all columns with the genotype data (without any other columns) 
}
  \item{type}{
Type of population to be coded "CP" for cross pollinated fullsib family or "F2" for F2 or RIL of early or advanced generations 
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
http://www.kyazma.nl/index.php/mc.JoinMap/sc.Evaluate

http://www.illumina.com/support/array/array_software/genomestudio.ilmn

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
# Cross pollinated (CP) population example 
mark1 <- c("AB", "BB", "AB", "BB", "BB", "AB", "--", "BB")
mark2 <- c("AB", "AB", "AA", "BB", "BB", "AA", "--", "BB")
mark3 <- c("BB", "AB", "AA", "BB", "BB", "AA", "--", "BB")
mark4 <- c("AA", "AB", "AA", "BB", "BB", "AA", "--", "BB")
mark5 <- c("AB", "AB", "AA", "BB", "BB", "AA", "--", "BB")
mark6 <- c("--", "BB", "AA", "BB", "BB", "AA", "--", "BB")
mark7 <- c("AB", "--", "AA", "BB", "BB", "AA", "--", "BB")
mark8 <- c("BB", "AA", "AA", "BB", "BB", "AA", "--", "BB")
loctype <-c(4, 3, 5, 5, 3,6,6, 0)

cp.pop <- data.frame (mark1, mark2, mark3, mark4, mark5, mark6, mark7, mark8)
outjoinCP <- gs2joinmap(dataframe = cp.pop, type = "CP")
write.table(outjoinCP, file = "outjoinCP.csv", sep = ",", col.names = NA,  
qmethod = "double")

# F2 population 
mark1 <- c("AA", "BB", "AB", "BB", "BB", "AB", "--", "BB")
mark2 <- c("BB", "AA", "AA", "BB", "BB", "AA", "--", "BB")
mark3 <- c("BB", "AA", "AA", "BB", "BB", "AA", "--", "BB")
mark4 <- c("AA", "BB", "AA", "BB", "BB", "AA", "--", "BB")
mark5 <- c("AA", "BB", "AA", "BB", "BB", "AA", "--", "BB")
mark6 <- c("--", "BB", "AA", "BB", "BB", "AA", "--", "BB")
mark7 <- c("AA", "--", "AA", "BB", "BB", "AA", "--", "BB")
mark8 <- c("BB", "AA", "AA", "BB", "BB", "AA", "--", "BB")
f2.pop <- data.frame (mark1, mark2, mark3, mark4, mark5, mark6, 
mark7, mark8)
outjoinF2 <- gs2joinmap(dataframe = f2.pop, type = "F2")
write.table(outjoinF2, file = "outjoinF2.csv", sep = ",", col.names = NA,  
qmethod = "double")

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
