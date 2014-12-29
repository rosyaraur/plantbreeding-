carolina1 <-
function (dataframe, set, male, female, progeny, replication, yvar )
{        
        dataframe <- data.frame (dataframe[,set],dataframe[,male], dataframe[,female],dataframe[,progeny], dataframe[,replication],dataframe[,yvar])
         names (dataframe) <- c("set", "male", "female", "replication","progeny", yvar)   
        dataframe$set <- as.factor(dataframe$set)
        dataframe$male <- as.factor(dataframe$male)
        dataframe$female <- as.factor(dataframe$female)
       dataframe$progeny <- as.factor(dataframe$progeny)
       dataframe$replication <- as.factor(dataframe$replication)
       mean.y <- mean(as.numeric(dataframe$yvar))
       name.y <- yvar 
       formula <- paste(yvar, "~ set + replication : set + male : set + female : male : set + replication : female : male : set")
       model <- lm(formula, data = dataframe)
       cat("North carolina 1 design output: ", name.y, "\n\n")
        print(anova(model))
        cv.model <- function (x){
                        sumsqr <- sum(x$residual^2)
                        gl <- x$df.residual
                        prom <- mean(x$fitted.values)
                        return(sqrt(sumsqr/gl) * 100/prom)
                        }
        cat("\nCV:", cv.model(model), "\tMean:", mean.y, "\n")
        m <- length(levels(model$model$male))
        f <- length(levels(model$model$female))
        s <- length(levels(model$model$set))
        r <- length(levels(model$model$replication))
        n <- length(levels(dataframe$progeny))
        anva <- as.matrix(anova(model))
        anva <- anva[, 1:3]
        var.m <- (anva["set:male", "Mean Sq"] - anva["set:male:female",
            "Mean Sq"])/(f * r * n)
        var.f <- (anva["set:male:female", "Mean Sq"] - anva["set:replication:male:female",
            "Mean Sq"])/(n * r)
        var.A <- 4 * var.m
        var.D <- 4 * var.f - 4 * var.m
        output <- list(model, var.m = var.m, var.f = var.f, var.A = var.A,
            var.D = var.D)
        return(output)
    }
