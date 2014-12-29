adesign <-
function (checks, newtrt, block.size = block.size, r,  seed = 999)
          { 
          checks <- as.vector(na.omit(checks))
          newtrt <- as.vector(na.omit(newtrt))
           block.size <- as.vector(na.omit (block.size))
        if (seed != 999)
         set.seed(seed)
       ttrtn = length(newtrt) + length(checks)*r 
       if (min(block.size) < length(checks)) {
                 warning (" Block size can not be zero, NA, or less than number of checks: ", length(checks),"\n\n")
                 } else if (sum (block.size) !=  ttrtn){
                 warning (" Sum of block.size =  ", sum(block.size), "  should be equal to number of required plots =  ",ttrtn, "\n")
                                  } else  {
     trts <- rep (checks, r)
      blocks <- rep(1:r, each = length(checks))
      checkdf <- data.frame(trts, blocks) 
      
       nbls <- c(block.size - length(checks))
       blocks <- rep(1:r, nbls) 
       nnewdf <- data.frame(trts = newtrt, blocks)
       dataf <- data.frame (rbind(checkdf,nnewdf))
      dataf$rnd <- ave(dataf$trts, dataf$blocks, FUN=sample) 
     dataf$rnd <- ave(dataf$trts, dataf$blocks, FUN=sample)
      dataf   <- dataf[with(dataf, order(blocks)),]
     randomplan <- data.frame(plotnumber = 1: nrow(dataf), dataf[,-1])
     names (randomplan) <- c("plot.number", "blocks", "treatment")
     return(randomplan)
                 }
         }
