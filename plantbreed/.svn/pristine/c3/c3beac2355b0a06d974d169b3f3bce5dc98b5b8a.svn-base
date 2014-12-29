\name{datapbib}
\alias{datapbib}
\docType{data}
\title{
A partially balanced incomplete block experiment
}
\description{
A partially balanced incomplete block experiment
}
\usage{data(datapbib)}
\format{
  A data frame with 60 observations on the following 3 variables.
  \describe{
    \item{\code{response}}{a numeric vector}
    \item{\code{Treatment}}{a factor with levels \code{1} \code{10} \code{11} \code{12} \code{13} \code{14} \code{15} \code{2} \code{3} \code{4} \code{5} \code{6} \code{7} \code{8} \code{9}}
    \item{\code{Block}}{a factor with levels \code{1} \code{10} \code{11} \code{12} \code{13} \code{14} \code{15} \code{2} \code{3} \code{4} \code{5} \code{6} \code{7} \code{8} \code{9}}
  }
}
\details{
%%  ~~ If necessary, more details than the __description__ above ~~
}
\source{
%%  ~~ reference to a publication or URL from which the data were obtained ~~
}
\references{
Littel, R. C., Milliken, G. A., Stroup, W. W., and Wolfinger, R. D. (1996),
 SAS System for Mixed Models, SAS Institute (Data Set 1.5.1).
}
\examples{
data(datapbib)
help(datapbib)

require("lme4")
print(mod1 <- lmer(response ~ Treatment + (1|Block), data = datapbib,
contrasts = c(unordered = "contr.SAS", ordered = "contr.poly")))
print(anova(mod1))

}

\keyword{datasets}
