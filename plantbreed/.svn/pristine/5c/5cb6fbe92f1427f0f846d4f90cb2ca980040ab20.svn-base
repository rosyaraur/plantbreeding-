
carolina2 <- function (dataframe, set, male, female,  replication, yvar )
{        
        dataframe <- data.frame (dataframe[,set],dataframe[,male], dataframe[,female], dataframe[,replication],dataframe[,yvar])
         names (dataframe) <- c("set", "male", "female", "replication", yvar)   
        dataframe$set <- as.factor(dataframe$set)
        dataframe$male <- as.factor(dataframe$male)
        dataframe$female <- as.factor(dataframe$female)
         dataframe$replication <- as.factor(dataframe$replication)
       mean.y <- mean(as.numeric(dataframe[,yvar]))
        name.y <- yvar 
       formula <- paste(yvar, "~ set +  replication %in% set + male %in% set + female %in% set + male : female %in% set")                           
       model <- lm(formula, data = dataframe)
       cat("North carolina 2 design output: ", name.y, "\n\n")
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
        anva <- as.matrix(anova(model))
        
        anva <- anva[, 1:3]
        var.m <- (anva["set:male", "Mean Sq"] - anva["set:male:female",
            "Mean Sq"])/(m * r)
        var.f <- (anva["set:female", "Mean Sq"] - anva["set:male:female",
            "Mean Sq"])/(f * r)   
        var.mf <- (anva["set:male:female", "Mean Sq"] - anva["Residuals",
            "Mean Sq"])/r    
        var.Am <- 4 * var.m
        var.Af <- 4 * var.f
        var.D <- 4 * var.mf
        output <- list(model = model, var.m = var.m, var.f = var.f,
            var.mf = var.mf, var.Am = var.Am, var.Af = var.Af,
            var.D = var.D)
           return(output)
    }  
   

 