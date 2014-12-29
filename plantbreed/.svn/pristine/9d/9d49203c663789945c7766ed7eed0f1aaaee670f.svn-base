\name{assoc.unr}
\alias{assoc.unr}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Association mapping in unrelated or unstructured mapping population using linear model 
}
\description{
The function pefroms mapping in unrelated or without clear population structure population using linear model. 
Both binomial (eg. susceptible or resistance, diseased or disease free, present or abscent) variable are also possible using glm chi-square test. 
Also covariate can be fitted to model. The different genetic model (Additive or dominance) can be fitted. 
}
\usage{
assoc.unr(dataframe, yvar, xvars, covariate = FALSE, cvar, binomial = FALSE, model = "ADD")
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{dataframe}{
dataframe with at least one y variable (yvar), x variable(s) (SNP markers) while covariate (cvar)  
}
  \item{yvar}{
Name of Y variable to be used in association mapping, when binomial = TRUE the value must be 0 to 1.  
}
  \item{xvars}{
Name of X variable (SNPs). vector of names of x variables (SNPs) (eg. c("SNP1", "xLoci12", "SNP1-3-4")) 
or column number (for example - c(6, 8, 10) or 6:100, or 6:length(dataframe)) 
}
  \item{covariate}{
Logical (TRUE or FALSE) whether we need to fit covariate in the model  
}
  \item{cvar}{
While covariate = TRUE, we need name of covariate variable 
}
  \item{binomial}{
Logical whether the y variable is used is binomial 
}
  \item{model}{
  
Whether to fit additive model - "ADD", or dominance - "DOM" or regular anova - "NONE". 
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
The function output  a dataframe with markers, pvalue (for SNPs) and cprob (for covariate), if covariate is fitted in the model.
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
# simulated example
set.seed(3456)
id <- c(1:115)
snpmat<- data.frame(matrix(sample(c("AA","AB","BB"), 115000, replace = TRUE), ncol = 1000))
names(snpmat) <- c(paste ("SNP",1:1000, sep='' ))
trait1 <- rnorm(115, 30, 5)
covtrait <- rnorm(115, 25, 3)
status <- sample (c(1,0), 115, replace = TRUE)
snpdata <- data.frame(id, trait1, covtrait, status, snpmat)

# x variable in range
out1.add <- assoc.unr(dataframe = snpdata,  yvar = "trait1", xvars = 6:10,
 covariate = FALSE, cvar = NA, binomial = FALSE, model = "ADD")
out1.add

out1.dom <- assoc.unr(dataframe = snpdata,  yvar = "trait1", xvars = 6:10, 
covariate = FALSE, cvar = NA, binomial = FALSE, model = "DOM")
out1.dom

out1.dom <- assoc.unr(dataframe = snpdata,  yvar = "trait1", xvars = 6:10, 
covariate = FALSE, cvar = NA, binomial = FALSE, model = "NONE")
out1.dom

# X variables
xout <- assoc.unr(dataframe = snpdata,  yvar = "trait1", xvars = 5:length (snpdata),
 covariate = FALSE, cvar = NA, binomial = FALSE)

plot(xout[,1], xout[,2], pch = 19, xaxt="n")
labdf <- xout[seq(1, nrow(xout), 100),]
axis(1, at=labdf[,1], label= labdf[,1])


# selected x vars
 vars <- c("SNP3", "SNP4", "SNP10")
out4 <- assoc.unr(dataframe = snpdata,  yvar = "trait1", xvars = vars, 
covariate = FALSE, cvar = NA, binomial = FALSE)
out4
# with covariates
out5 <- assoc.unr(dataframe = snpdata,  yvar = "trait1", xvars = vars, covariate = TRUE,
 cvar = "covtrait", binomial = FALSE)
out5 
# binomial is true, uses Chi-square test probablities
out6 <- assoc.unr (dataframe = snpdata,  yvar = "status", xvars = vars, covariate = FALSE,
 cvar = NA, binomial = TRUE)
out6
# binomial with covariates
out7 <- assoc.unr(dataframe = snpdata,  yvar = "status", xvars = 5:length (snpdata),
 covariate = TRUE, cvar = "covtrait", binomial = TRUE)
out7 
}
\keyword{}
\keyword{}% __ONLY ONE__ keyword per line
