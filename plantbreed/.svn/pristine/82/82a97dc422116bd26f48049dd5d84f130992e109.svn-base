 shaded.normal <- function (type = "TH", trait = NULL, avg = 0, sdev= 1, shade = "percent",  lowrp, uprp = 0, Lcolfill = "lightgreen",Fcolfill = "pink", lincolor = "blue", lat = NULL) {
 if (type == "TH") {
                mu = avg
               sigma = sdev
                x <- rnorm(10000000, mu, sigma)
               if (shade == "percent"){
                                  upperp <- round(qnorm(p=1-uprp, mean=mu, sd=sigma), 2)
                                  lowerp <- round (qnorm(p=lowrp, mean=mu, sd=sigma), 2)
                                   plot(density(x), col = lincolor, xlab = "phenotype", main=paste("Theortical Distribution", ": mean = ", mu, ", sd= ", sigma),
                                           sub = paste("shaded area  <", lowerp, " -", upperp, "<:", sep = ""))
                                  dens <- density(x)
                                  x11 <- min(which(dens$x <= lowerp))
                                  x12 <- max(which(dens$x <= lowerp))
                                  x21 <- min(which(dens$x > upperp))
                                   x22 <- max(which(dens$x > upperp))
                                   with(dens, polygon(x=c(x[c(x11,x11:x12,x12)]), y= c(0, y[x11:x12], 0), col=Lcolfill))
                                  with(dens, polygon(x=c(x[c(x21,x21:x22,x22)]), y= c(0, y[x21:x22], 0), col=Fcolfill))
                                  abline(v=c(mu), lwd=2, lty=2, col = "red")
                                   abline(v=c(lat), lwd=1, lty=c(1:length(lat)), col = c(1:length(lat)))
                                  }
               if (shade == "trunp" ){
                                  upperp = uprp
                                  lowerp = lowrp
                                   plot(density(x), col = lincolor, xlab = "phenotype", main=paste("Theortical Distribution", ": mean = ", mu, ", sd= ", sigma),
                                           sub = paste("shaded area  <", lowerp, " -", upperp, "<:", sep = ""))
                                   dens <- density(x)

                                  x11 <- min(which(dens$x <= lowerp))
                                  x12 <- max(which(dens$x <= lowerp))

                                  x21 <- min(which(dens$x > upperp))

                                  x22 <- max(which(dens$x > upperp))

                                  with(dens, polygon(x=c(x[c(x11,x11:x12,x12)]), y= c(0, y[x11:x12], 0), col=Lcolfill))
                                  with(dens, polygon(x=c(x[c(x21,x21:x22,x22)]), y= c(0, y[x21:x22], 0), col=Fcolfill))

                                   abline(v=c(mu), lwd=2, lty=2, col = "red")
                                    abline(v=c(lat), lwd=1, lty=c(1:length(lat)), col = c(1:length(lat)))
                }
                }else {

                      x <- trait
                       mu = round (mean(trait), 1)
                      sigma = round (sd(trait), 1)
                      if (shade == "percent"){

                                  upperp <- round (qnorm(p=1-uprp, mean=mu, sd=sigma), 2)
                                  lowerp <- round (qnorm(p=lowrp, mean=mu, sd=sigma), 2)
                                  plot(density(x), col = lincolor, xlab = "phenotype", main=paste("trait", ": mean = ", mu, ", sd= ", sigma),
                                           sub = paste("shaded area  <", lowerp, " -", upperp, "<:", sep = ""))
                                  dens <- density(x)
                                  x11 <- min(which(dens$x <= lowerp))

                                  x12 <- max(which(dens$x <= lowerp))

                                  x21 <- min(which(dens$x > upperp))

                                  x22 <- max(which(dens$x > upperp))

                                 with(dens, polygon(x=c(x[c(x11,x11:x12,x12)]), y= c(0, y[x11:x12], 0), col=Lcolfill))
                                  with(dens, polygon(x=c(x[c(x21,x21:x22,x22)]), y= c(0, y[x21:x22], 0), col=Fcolfill))
                                  abline(v=c(mu), lwd=2, lty=2, col = "red")
                                   abline(v=c(lat), lwd=1, lty=c(1:length(lat)), col = c(1:length(lat)))
                                  }
               if (shade == "trunp" ){
                                  upperp = uprp
                                  lowerp = lowrp
                                  plot(density(x), col = lincolor, xlab = "phenotype", main=paste("trait", ": mean = ", mu, ", sd= ", sigma),
                                          sub = paste("shaded area  <", lowerp, " -", upperp, "<:", sep = ""))
                                   dens <- density(x)
                                   x11 <- min(which(dens$x <= lowerp))

                                  x12 <- max(which(dens$x <= lowerp))

                                  x21 <- min(which(dens$x > upperp))

                                  x22 <- max(which(dens$x > upperp))

                                 with(dens, polygon(x=c(x[c(x11,x11:x12,x12)]), y= c(0, y[x11:x12], 0), col=Lcolfill))
                                  with(dens, polygon(x=c(x[c(x21,x21:x22,x22)]), y= c(0, y[x21:x22], 0), col=Fcolfill))
                                  abline(v=c(mu), lwd=2, lty=2, col = "red")
                           abline(v=c(mu), lwd=2, lty=2, col = "red")
                            abline(v=c(lat), lwd=1, lty=c(1:length(lat)), col = c(1:length(lat)))
                                  }
                              }
                              }