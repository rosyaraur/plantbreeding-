\name{graphicalgeno}
\alias{graphicalgeno}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Graphical genotype plot with shaded regions 
}
\description{
The function produce graphical genotype plot with multiple chromosomes - with whole chromosomes or certain regions shaded for whole or subset genomic regions. 
The function can plot multiple faceted plots per chromosome, where X axis consists of the position in chromosome and Y axis consists of Individual ID. 
Heatmap plot is prepared with additional variable and text labeling can be done with genotype codes. 
Color can be the genotype itself if is numerically inputted such as A =1, C =2, G =3, or T =4. 
}
\usage{
graphicalgeno(dataframe = dataframe, group = "group", position = "position",
 yvar = "yvar", ycat = "ycat", namevar = "namevar", subset = TRUE, 
 subsetdata = datas,  panel.margin = 0.1, strip.background = "lightpink", 
 filllow = "white", fillhigh = "darkgreen", textlab = TRUE, 
 textcolor = "blue", chr.arrange = "LR")
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{dataframe}{
The dataframe with group (= chromosome), position (map position), yvar (color coding variable, numeric), ycat (text variable for example genotype), and namevar (individual identification variable).
}
  \item{group}{
groups (= chromosomes) or segment names 
}
  \item{position}{
Position on X axis 
}
  \item{yvar}{
Name of numeric variable to be color coded.  
}
  \item{ycat}{
Name of variable to used as text
}
  \item{namevar}{
Name of variable for indivudalindividual id  
}
  \item{subset}{
Logical variable whether to subset data or not 
}
  \item{subsetdata}{
Name of subset dataframe. WheverWhenever subsettted data need only be plotted, there should be two datasets - full dataset specified in dataframe and subsetdata specified here. 
}
  \item{panel.margin}{
Width of panel margin, if you do not want to have panel margin use 0, otherwise use a numerical value, is interepretedinterpreted as number of lines 
}
  \item{strip.background}{
Color of strip background 
}
  \item{filllow}{
Lower color for the heatmap 
}
  \item{fillhigh}{
Higher color for the heatmap 
}
  \item{textlab}{
Logical, whether to label text or not 
}
  \item{textcolor}{
Color of the text 
}
  \item{chr.arrange}{
How to arrange chromosomes, "LR" is single row with left to right, "TR" a single column from top to bottom, "DF" is ggplot is allowed to decide number of rows or columns depending upon the open plot area. 
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
 Id = paste ("ID-", 1:5, sep = "")
position <- rep(seq (1, 100,10), each = 5)
group = rep (rep(rep (1:5, each = length (Id)), each = length(position)))
set.seed(1234)
yvar <- rnorm (length(position), 0.5, 0.1)
ycat <- c(sample (c("A", "B", "H"), length(yvar), replace = TRUE))
namevar <- rep(Id, length(group)/length(Id))
dataframe <- data.frame (namevar, group, position, yvar, ycat)

# subset the data
datas = subset(dataframe,(group == 1 & position >= 30 & position <= 50) |
 (group == 3 & position >= 20 & position <= 60))
datas1 = subset(dataframe,(group == 1 & position >= 30 & position <= 50) | 
(group == 3 & position >= 20 & position <= 60) |
(group == 3 & position >= 80 & position <= 85) )
             
 # Implementation
graphicalgeno (dataframe = dataframe, group = "group",position = "position", yvar = "yvar",
  ycat = "ycat",namevar = "namevar",subset = TRUE, subsetdata = datas, panel.margin = 0.1 , 
  strip.background = "lightpink", filllow = "white", fillhigh = "darkgreen",
  textlab = TRUE, textcolor = "blue", chr.arrange = "LR")
 
graphicalgeno (dataframe = dataframe, group = "group",position = "position", yvar = "yvar",
  ycat = "ycat",namevar = "namevar",subset = FALSE, subsetdata = datas, panel.margin = 0.2 ,
   strip.background = "lightpink", filllow = "white", fillhigh = "darkgreen", textcolor = "blue",
    chr.arrange = "LR")

datas1 = subset(dataframe,(group == 1 & position >= 30 & position <= 50) | 
  (group == 3 & position >= 20 & position <= 60)
   |(group == 5 & position >= 80 & position <= 85) )

graphicalgeno (dataframe = dataframe, group = "group",position = "position", yvar = "yvar", 
  ycat = "ycat",namevar = "namevar",subset = TRUE, subsetdata = datas1, panel.margin = 1 ,
   strip.background = "lightpink", filllow = "white", fillhigh = "darkgreen",
 textcolor = "blue", chr.arrange = "LR")

  # full data
graphicalgeno (dataframe = dataframe, group = "group",position = "position", yvar = "yvar",
  ycat = "ycat",namevar = "namevar",subset = FALSE, subsetdata = datas, panel.margin = 0.2 , 
  strip.background = "lightpink", filllow = "yellow", fillhigh = "blue", textcolor = "blue",
   chr.arrange = "DF")

graphicalgeno (dataframe = dataframe, group = "group",position = "position", yvar = "yvar",
   ycat = "ycat",namevar = "namevar",subset = FALSE, subsetdata = datas, panel.margin = 0 ,
    strip.background = "gray80", filllow = "yellow", fillhigh = "pink4", textcolor = "darkgreen",
     chr.arrange = "TB")
           
graphicalgeno (dataframe = dataframe, group = "group",position = "position", yvar = "yvar",
    ycat = "ycat",namevar = "namevar",subset = FALSE, subsetdata = datas, panel.margin = 0 ,
     strip.background = "gray80", filllow = "yellow", fillhigh = "midnightblue",
      textcolor = "red", chr.arrange = "LR")

graphicalgeno (dataframe = dataframe, group = "group",position = "position", yvar = "yvar",
    ycat = "ycat",namevar = "namevar",subset = TRUE, subsetdata = datas, panel.margin = 0.1 ,
     strip.background = "lightpink", filllow = "white", fillhigh = "darkgreen",textlab = FALSE,
      textcolor = NA, chr.arrange = "LR")

# Example 2
# data 
ID <- c("A", "B", "C", "D")
chromosomes <- rep (c(1,   1, 1,   1,   1,  1,    2,  2,    2,   2,  2,   2,    
3,  3,   3,  3, 3), each = length(ID))
markposition <- rep(c(1,  5, 10,   20, 35,  40,   1,  15,  18,  20, 30,  60, 
   1, 15,  20,  25, 26), each = length(ID))  
genotypes <- c(sample (c("AC", "CC", "AA"), length(markposition), replace = TRUE))

genotypicprob <- rnorm (length(markposition), 0.5, 0.1)
idvar <- rep(ID, length(markposition)/4) 
genoprob.data <- data.frame (chromosomes, markposition, genotypes, genotypicprob, idvar)

# plotting 
graphicalgeno (dataframe = genoprob.data, group = "chromosomes",
position = "markposition",   yvar = "genotypicprob", ycat = "genotypes",
namevar = "idvar",subset = FALSE,subsetdata = datas, panel.margin = 0.1 , 
strip.background = "lightpink", filllow = "yellow",
 fillhigh = "blue", textcolor = "blue", chr.arrange = "DF")
           
         
 }

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
