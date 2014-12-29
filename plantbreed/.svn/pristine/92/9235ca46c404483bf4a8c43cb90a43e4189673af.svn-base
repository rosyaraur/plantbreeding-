ammi.full <- function (dataframe, environment, genotype, replication, yvar){

dataframe <- data.frame (environment  = dataframe[, environment], genotype = dataframe[ , genotype], replication =  dataframe[, replication], Y = dataframe[,yvar])

     yvar <- yvar
    cat("\nAMMI Analysis for variable: ", yvar, "\n")
    cat("\n............................\n")
    dataframe$environment  <- as.factor(dataframe$environment )
    dataframe$genotype <- as.factor(dataframe$genotype)
    dataframe$replication <- as.factor(dataframe$replication)
    dataframe$Y <- dataframe $ Y
    nenv <- length(unique(dataframe$environment ))
    ngen <- length(unique(dataframe$genotype))
    nrep <- length(unique(replication))
    minM<- min(ngen, nenv)
    #ordinary anova
    model <- aov(Y ~ environment  + replication %in% environment  + genotype + environment :genotype, dataframe)
    anmm <- anova(model) # anova table for the model
        newm <- anmm[2, ]  # genotype component only from the model
        anmm[2, ] <- anmm[3, ]  # genotype is replaced by environment :replication
        anmm[3, ] <- newm     #environment :replication is repaced by genotype
        row.names(anmm)[2] <- "replication(environment )"  # renaming for the switch
        row.names(anmm)[3] <- "genotype"   # renaming for the switch
        anmm[1, 4] <- anmm[1, 3]/anmm[2, 3]
        anmm[1, 5] <- 1 - pf(anmm[1, 4], anmm[1, 1], anmm[2, 1])
        print(anmm)
        DFE <- df.residual(model)
        MSE <- deviance(model)/DFE
        medy <- mean(dataframe$Y, na.rm = TRUE)
        CV = sqrt(MSE) * 100 / medy
        errorlist <- list(DFE, MSE, medy,CV)

   # step 2
    df1 <- data.frame(environment =  dataframe$environment , genotype =  dataframe$genotype,  dataframe$Y)
    names(df1) <- c("environment" , "genotype", "Y")
  # calculating means
    avdm0 <- tapply(df1$Y, df1[, c("genotype", "environment")], mean)
    cat("\nMeans: ", yvar, "\n")
    print(round(avdm0, 2))
    require(reshape)
    avdm <- melt (avdm0, id = c( "environment ", "genotype"))
    V1 <- avdm[, 2]
    v2 <- avdm[, 1]
    v3 <- avdm[, 3]
    model2 <- lm(v3 ~ V1 + v2, avdm)
    # predicting values
   for (i in 1:length(v3)) {
        if (is.na(v3[i]))
            v3[i] <- predict(model2, data.frame(V1 = avdm[i,
                1], v2 = avdm[i, 2]))
    }

    avdm <- data.frame(environment  = V1, genotype = v2, Y = v3)

    # new model
   model1 <- lm(Y ~ environment  + genotype, data = avdm)
   residual <- model1$residuals

   # new cataframe with residuals
    avdm <- data.frame(avdm, RESIDUAL = residual)
    mlabel <- names(avdm)
    names(avdm) <- c(mlabel[1:2], yvar, mlabel[4])
    # ordering
    resouts <- avdm[order(avdm[, 1], avdm[, 2]), ]

    res22 <- aggregate ( resouts[, 4], by = list (resouts[, 2], resouts[,1]), FUN = sum)
    names(res22) <- c("genotype", "environment", "gei")
   res3 <- aggregate(gei~genotype, res22, 'c')
    res23 <- as.matrix(res3[,-1])
    mdout <- by(resouts [, 3], resouts[, c(2, 1)], function(x) sum(x,
        na.rm = TRUE))

   # Singular Value Decomposition of a Matrix
    sdc <- svd(res23)
    U <- sdc$u
    L <- sdc$d
    V <- sdc$v
    L <- L[1:minM]
    SS <- (L^2) * nrep

    a.sumsq <- sum(SS)
    percent <- round(((1/a.sumsq) * SS) * 100, 1)

    MINM<- min(ngen, nenv)


    acum <-MSami <- F.ami <- f.prob <-  DFami <- rep(0, minM)

    Acol1 <- 0

    for (i in 1:minM) {
        DF <- (ngen - 1) + (nenv - 1) - (2 * i - 1)
        if (DF <= 0)
            break
        DFami[i] <- DF
        Acol1 <- Acol1 + percent[i]
        acum[i] <- acum[i] + Acol1
        MSami[i] <- SS[i]/DFami[i]
        F.ami[i] <- round(MSami[i]/MSE, 2)
        f.prob[i] <- round(1 - pf(F.ami[i], DFami[i], DFE),
            4)
    }

    ammi.ss <- data.frame(percent, cumulative = acum, Df = DFami, `Sum Sq` = round (SS,1),
        `Mean Sq` = round (MSami, 1), `F value` = F.ami, prob = round (f.prob, 4))
    nssammi <- nrow(ammi.ss)
    ammi.ss <- ammi.ss[ammi.ss$Df > 0, ]
   row.names(ammi.ss) <- paste("PCA", 1:nrow(ammi.ss), sep = "")
    cat("\nAMMI Analysis Results per PCA axis \n")
    print(ammi.ss) # ammi results

    # ammi scrs
    sql <- sqrt(diag(L))
    regscr <- U %*% sql
    scoree1 <- V %*% sql
    SCORES <- rbind(regscr, scoree1)
    colnames(SCORES) <- paste("PC", 1:nssammi, sep = "")
    MSscoree1 <- SCORES[1:ngen, ]
    NSCORES <- SCORES[(ngen + 1):(ngen + nenv), ]
    gen.m <- data.frame(category = "genotype", Y = apply(mdout, 1, mean),
        MSscoree1)
    m.env <- data.frame(category = "environment", Y = apply(mdout, 2, mean),
        NSCORES)
    scrs.plot <- rbind(gen.m, m.env)
    scrs.plot <- scrs.plot[, 1:(nrow(ammi.ss)+ 2)]
    mlabel <- names(scrs.plot)
    names(scrs.plot) <- c(mlabel[1], yvar, mlabel[c(-1, -2)])
    row.names(scrs.plot) <- c(row.names(gen.m), row.names(m.env))
    perC <- ammi.ss[, 1]
    return(list(means = avdm0, anova = anmm,errorlist = errorlist, genotype.by.env = res22, resouts = resouts, analysis = ammi.ss, means = avdm,
        pc.scrs = scrs.plot, percentAxis = perC, sdc = sdc))
}