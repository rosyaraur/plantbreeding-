AUDPC.cal <- function(reading.dates, severity.data)
{
    if (length(reading.dates) != (ncol(severity.data)-1))
        stop("The Reading dates and severity data columns and dates doesn't match")

    out <- as.data.frame(NULL)
    for (i in 1:nrow(severity.data))
    {
        x <- NULL
        for (j in 2:length(severity.data))
            x <- c(x, (severity.data[i,j]+severity.data[i,j+1])/2 * difftime(reading.dates[j], reading.dates[j-1], "days"))
        out <- rbind(out, c(severity.data[i,1], sum(x)))
    }

    colnames(out) <- c("ID", "AUDPC")
    return(out);
}
