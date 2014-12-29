\name{shaded.normal}
\alias{shaded.normal}
\title{
Shading regions in theoritical normal curves or sample density curves for quantative traits 
}
\description{
The function is useful for teaching and publication purpose. 
}
\usage{
shaded.normal(type = "TH", trait = NULL, avg = 0, sdev = 1, shade = "percent", lowrp,
 uprp = 0, Lcolfill = "lightgreen", Fcolfill = "pink", lincolor = "blue", lat = NULL)
}
\arguments{
  \item{type}{
"TH" if theoritical distribution with specified average (avg) and standard deviation (sdev). 
If type is "TR", distribution for trait datapoints provided in trait column 
}                           
  \item{trait}{
If type is "TR", trait is vector of trait values, otherwise NULL  
}
  \item{avg}{
mean of population if  type is "TH", else NULL 
}
  \item{sdev}{
standard deviation of population if  type is "TH", else NULL 
}
  \item{shade}{
"percent" - Whether to shade upper or lower percent,  "trunp" - when defined is upper or lower truncation point 
}
  \item{lowrp}{
Lower truncation point or percent in the distribution  
}
  \item{uprp}{
Upper truncation point or percent in the distribution 
}
  \item{Lcolfill}{
Color to fill lower area (polygon) 
}
  \item{Fcolfill}{
Color to fill upper area (polygon) 
}
  \item{lincolor}{
Color of additional veritical lines added to plot 
}
  \item{lat}{
Point of additional veritical lines added to plot 
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
The function will output shaded normal or density curves with user defined shaded regions on the trails of the density plot of 
observed or theoritical distribution  
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

    # plot with mean 0 and sd = 1 , percent in fraction highlighted 
 shaded.normal(lowrp = 0.1, uprp = 0.1, avg = 50, sdev= 40)
    
    #plotting density
shaded.normal (type = "TH", trait = NULL, avg = 20, sdev= 5, shade = "percent",
lowrp = 0.10, uprp = 0.2, Fcolfill = "lightgreen", Lcolfill = "aquamarine3", 
lincolor = "blue", lat = NULL)

shaded.normal (type = "TH", trait = NULL, avg = 20, sdev= 5, shade = "percent",  
lowrp = 0.3, uprp = 0.05,  Fcolfill = "#F5F5DC", Lcolfill = "#FF7F50", 
lincolor = "blue", lat = NULL)
 
shaded.normal (type = "TH", trait = NULL, avg = 20, sdev= 5, shade = "percent", 
 lowrp = 0.10, uprp = 0.2, Fcolfill = "lightgreen", Lcolfill = "aquamarine3", 
 lincolor = "blue", lat = NULL)
   
   # plot with mean 0 and sd = 1 , percent in fraction highlighted 
par(mfrow=c(3,1))
shaded.normal(shade = "percent", lowrp = 0.05, uprp = 0.05, avg = 50, sdev= 40)
shaded.normal(shade = "percent",lowrp = 0.2, uprp = 0.2, avg = 70, sdev= 20)
shaded.normal(shade = "percent",lowrp = 0.25, uprp = 0.25, avg = 80, sdev= 10)
     
     
   
   # tait
trait <- rnorm(800, 50, 10)
shaded.normal (type = "TR", trait = trait, shade = "percent",  lowrp = 0.010,
 uprp = 0.1, Fcolfill = 2, Lcolfill = 4, lincolor = c("blue","red"), lat = c(45, 80))
data(respdataf)
 shaded.normal (type = "TR", trait = respdataf$traitF2, shade = "trunp",  lowrp = 40,
  uprp = 60, Fcolfill = "#CAFF70", Lcolfill = "#FF7F50")
   
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{}
\keyword{}% __ONLY ONE__ keyword per line
