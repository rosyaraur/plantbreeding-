hsq.single <-
function (dataframe, yvars, genovar, replication, exout = F, 
    REML = F) 
{
    dataframe[, genovar] = as.factor(dataframe[, genovar])
    dataframe[, replication] = as.factor(dataframe[, replication])
    if (REML == F) {
        formula = paste(yvars, " ~ ", genovar, " + ", replication)
        mod1 <- lm(formula, data = dataframe)
        g2gw <- c((anova(mod1)$"Mean Sq"[1] - anova(mod1)$"Mean Sq"[3])/(anova(mod1)$Df[2] + 
            1))
        h2bsgw <- g2gw/(g2gw + anova(mod1)$"Mean Sq"[3])
        if (exout == FALSE) {
         return(h2bsgw)
        }
        else if (exout == TRUE) {
            name.y <- names(dataframe$yvars)
            cat("Anova for :", name.y, "\n\n")
            print(anova(mod1))
            cat("Broad sense heritability :", h2bsgw, "\n\n")
            results = list (model = mod1, hertiability = h2bsgw)
            return (results)  
        }
    }
    else if (REML == TRUE) {
        dataframe <- dataframe
        require("lme4")
        formula <- paste(yvars, "~ (1|", genovar, ") + (1|", 
            replication, ")")
        model2 <- lmer(formula, data = dataframe, REML = TRUE)
        ranef(model2)
        fm1.ran <- VarCorr(model2)
        gvar <- c(as.numeric(diag(fm1.ran$genovar)))
        rvar <- c(as.numeric(diag(fm1.ran$replication)))
        resvar <- c(attr(VarCorr(model2), "sc")^2)
        totalv = gvar + rvar + resvar
        heritability = gvar/totalv
        if (exout == FALSE) {
            return(heritability)
        }
        else if (exout == TRUE) {
            cat("Broad sense heritability :", heritability, "\n\n")
            cat("var(genotype):", gvar, "\n\n")
            cat("var (total):", totalv, "\n\n")
            cat("Random effects for genotype :", "\n\n")
            randomeffects = data.frame(genotypes = levels(dataframe$genovar), 
                randomeffects = ranef(model2)$genovar)
            names(randomeffects) <- c("genotypes", "randomeffects")
            print(randomeffects)
            results = list(heritability = heritability,genovar = gvar,  totalvar = totalv, randomeffects = randomeffects )
            return (results)   
        }
    }
  }
