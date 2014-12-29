phenosim <-
function (n, p = 0.5, alpha = 10, delta = -10, sig = 4, mu = 50, plot = TRUE){
x <- rbinom(n,2,p)
simulatedY <- mu + alpha*x + delta*(x==1) + sig*rnorm(n)
h2 <- var(alpha*x + delta*(x==1))/var(simulatedY)
if (plot == FALSE){
                 return(simulatedY)
         } else {#

plot.new()
dev.new(width=10, height=10)
plot(density(simulatedY), col = "blue4", main =  paste("simulated phenotype:\n heritability = ",round(h2,3)),
xlab = paste ("mean: ", round(mean (simulatedY), 1), "   sd: ", round(sd(simulatedY), 1)))
return(simulatedY)
}
}
