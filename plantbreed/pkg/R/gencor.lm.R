gencor.lm <-
function (dataframe, yvar1, yvar2, genovar, replication = replication, 
    exout = FALSE) 
{
    dataframe <- data.frame (yvar1 = dataframe[,yvar1], yvar2 = dataframe[,yvar2], genovar = dataframe[,genovar], replication = dataframe[,replication])
    dataframe$genovar = as.factor(dataframe$genovar)
    dataframe$replication = as.factor(dataframe$replication)
    mod1 <- lm(yvar1 ~ genovar + replication, data = dataframe)
    g2gw <- c((anova(mod1)$"Mean Sq"[1] - anova(mod1)$"Mean Sq"[3])/(anova(mod1)$Df[2] + 
        1))
    mod2 <- lm(yvar2 ~ genovar + replication, data = dataframe)
    g2tg <- c((anova(mod1)$"Mean Sq"[1] - anova(mod1)$"Mean Sq"[3])/(anova(mod1)$Df[2] + 
        1))
    mod3 <- lm(yvar1 + yvar2 ~ genovar + replication, data = dataframe)         
    cvtg.gy <- ((anova(mod3)$"Mean Sq"[1]) - (anova(mod2)$"Mean Sq"[1]) - 
        (anova(mod1)$"Mean Sq"[1]))/2
    ecvtg.gy <- ((anova(mod3)$"Mean Sq"[3]) - (anova(mod2)$"Mean Sq"[3]) - 
        (anova(mod1)$"Mean Sq"[3]))/2
    g2ecvtg.gy <- (cvtg.gy - ecvtg.gy)/(anova(mod3)$Df[3] + 1)
    cohert = g2ecvtg.gy/(g2ecvtg.gy + ecvtg.gy)
    genetic.corr = g2ecvtg.gy/((g2gw * g2tg)^0.5)
    if (exout == FALSE) {
        return(genetic.corr)
    }
    else if (exout == TRUE) {
        name.y1 <- names(dataframe$yvar1)
        name.y2 <- names(dataframe$yvar2)
        cat("Analysis of variance:", name.y1, "\n\n")
        print(anova(mod1))
        cat("Analysis of variance:", name.y2, "\n\n")
        print(anova(mod2))
        cat("Analysis of co-variance:", name.y2, "\n\n")
        print(anova(mod3))
        cat("genetic correlation:", name.y1 , "and", name.y2, 
            "\n\n") 
        print(genetic.corr)
        results <- list(genetic.corr = genetic.corr, modelV1 = mod1, modelV2 = mod2, modelV1V2 = mod3)
        return(results) 
    }
  }
