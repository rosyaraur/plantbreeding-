\name{table.creator}
\alias{table.creator}

\title{
Table creator 
}
\description{
Creates tables for categorical variable or categorizing quantitative variable.  
}
\usage{
table.creator(mydata, yvar = FALSE, classvars, classy = FALSE, ycut = NULL)
}

\arguments{
  \item{mydata}{
Name of dataframe 
}
  \item{yvar}{
Name of variable 
}
  \item{classvars}{
Name of class variable 
}
  \item{classy}{
Name of class variable 
}
  \item{ycut}{
cut vector with information how to categorize a quantitative variable 
}
}
\author{
Umesh Rosyara 
}
\examples{
# Example 1:
 mydata1 <- data.frame (yvar1 = rnorm(2000, 15, 5), xv1 = rep(1:5, each = 400),
   xv2 = rep(1:10, 200), xv3 = rep(1:2, 1000), xv4 = rep(1:2, 1000))

table.creator (mydata = mydata1, yvar = NA, classvars = c("xv1", "xv2", "xv3"),
 ycut = FALSE)
 
table.creator (mydata = mydata1, yvar = NA, classvars = c("xv2", "xv3"), ycut = FALSE)

table.creator (mydata = mydata1, yvar = "yvar1", classvars = c("xv2", "xv3"), 
classy = TRUE, ycut = c(-Inf,10,14,16,Inf))

table.creator (mydata = mydata1, yvar = "yvar1", classvars = c("xv2", "xv3", "xv1"),
 classy = TRUE, ycut = c(-Inf,10,14,16,Inf))
 
outv <- table.creator (mydata = mydata1, yvar = "yvar1", 
classvars = c("xv2", "xv3", "xv1", "xv4"), classy = TRUE, ycut = c(-Inf,10,14,16,Inf))


# Example 2
snpprop <- data.frame (SN = 1:4000, chromsome = as.factor (rep(1:10, each = 400)), 
genome = sample (c("A", "B", "C"), 4000, replace = "TRUE"),
snpsource = sample (c("Nap", "Kat"), 4000, replace = "TRUE"),
 minorAF = rnorm (4000, 0.5, 0.1), GenTrain = rnorm(4000, 0.8, 0.05)) 
 
 summary (snpprop)
 af1 <- table.creator (mydata = snpprop, yvar = FALSE, 
 classvars = c("chromsome","genome"), classy = FALSE, ycut = NULL)
 
 af1
 
 snpout <- table.creator (mydata = snpprop, yvar = "minorAF", classvars = c("chromsome","genome"),
  classy = TRUE, ycut = c(-Inf,0.15,0.35,0.75,Inf))
  
 snpout1 <- table.creator (mydata = snpprop, yvar = "minorAF", 
 classvars = c("snpsource", "chromsome","genome"), 
 classy = TRUE, ycut = c(-Inf,0.5,Inf))
snpout1[["(-Inf,0.5]"]]

# cateogrizing numerical variables and cross tabling it 
snpprop$GTcategory <- cut(snpprop$GenTrain,
breaks = c(-Inf,0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9,Inf))

snpout2 <- table.creator (mydata = snpprop, yvar = "minorAF", classvars = "GTcategory",
 classy = TRUE, ycut = c(-Inf,0.15,0.35,0.75,Inf))
 
snpout2

 snpout3 <- table.creator (mydata = snpprop, yvar = "minorAF", 
 classvars = c("chromsome","GTcategory"), 
 classy = TRUE, ycut = c(-Inf,0.15,0.35,0.75,Inf))  
 
snpout3[["(0.75, Inf]"]]


}

