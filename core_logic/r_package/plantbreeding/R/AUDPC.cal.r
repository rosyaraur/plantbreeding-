#' Calculation of Area Under Disease / Pest Progress Curve
#'
#' @description
#' The function calculates the area under the disease or pest progress curve 
#' (Jeger and Viljanen-Rollinson 2001; Madden et al. 2007). The AUDPC is a 
#' useful quantitative summary of disease or pest intensity over time. 
#' This function uses the frequently used trapezoidal method to estimate the AUDPC. 
#' It discretizes time into specific units (based on the provided dates) and 
#' calculates the average disease intensity between each pair of adjacent time 
#' points, which are then summed over all time intervals.
#'
#' @param reading.dates A vector of dates corresponding to the disease readings 
#'   (should ideally be of class `Date`).
#' @param severity.data A data frame or matrix of severity data. The first 
#'   column must be the ID of the individuals, and subsequent columns must 
#'   contain the numeric severity readings corresponding to `reading.dates`.
#' @param plot Logical; if `TRUE` (default), generates a base R plot for each 
#'   individual showing the disease progress curve and shades the area under 
#'   the curve. Prompts the user to press 'Enter' between plots if multiple 
#'   individuals exist.
#'
#' @return A data frame containing two columns: `ID` (the identifier of the 
#'   individual) and `AUDPC` (the calculated area under the progress curve).
#'
#' @references 
#' Jeger M.J., Viljanen-Rollinson S.L.H. (2001) The use of the area under the 
#' disease-progress curve (AUDPC) to assess quantitative disease resistance 
#' in crop cultivars, Theor Appl Genet 102:32-40.
#' 
#' Madden L.V., Hughes, G., van den Bosch, F. (2007) The study of plant disease 
#' epidemics. The American Phytopathological Society, APS Press St. Paul, Minnesota.
#'
#' @author Umesh Rosyara
#'
#' @examples
#' # Define reading dates
#' reading.dates <- as.Date(c("2012-02-13", "2012-02-20", "2012-02-28"))
#'
#' # Create example dataset
#' mydat <- data.frame(ID = c("A", "B", "C", "D"), 
#'                     Date1 = c(1, 2, 3, 4), 
#'                     Date2 = c(5, 6, 7, 8),
#'                     Date3 = c(11, 12, 13, 14))
#'
#' # Calculate AUDPC and generate plots
#' cd <- AUDPC.cal(reading.dates, mydat, plot = TRUE)
#' print(cd)
#' 
#' @export
AUDPC.cal <- function(reading.dates, severity.data, plot = TRUE) {
  # 1. Check if dates and data columns match
  if (length(reading.dates) != (ncol(severity.data) - 1)) {
    stop("The reading dates and severity data columns do not match.")
  }
  
  # Initialize the output data frame
  out <- data.frame(ID = character(), AUDPC = numeric(), stringsAsFactors = FALSE)
  
  # 2. Set up plotting parameters if visualization is requested
  if (plot) {
    oldpar <- par(no.readonly = TRUE)
    on.exit(par(oldpar)) # Restore original par settings when function exits
    
    # If multiple IDs exist, prompt user to press 'Enter' between plots
    if (nrow(severity.data) > 1) {
      par(ask = TRUE)
    }
  }
  
  # 3. Loop through each individual
  for (i in 1:nrow(severity.data)) {
    x_area <- numeric(length(reading.dates) - 1)
    
    # Extract the severity values for this individual as a numeric vector
    y_vals <- as.numeric(severity.data[i, -1]) 
    
    # Calculate trapezoidal area for each interval
    for (j in 1:(length(reading.dates) - 1)) {
      time_diff <- as.numeric(difftime(reading.dates[j+1], reading.dates[j], units = "days"))
      x_area[j] <- ((y_vals[j] + y_vals[j+1]) / 2) * time_diff
    }
    
    # Sum the areas and store
    audpc_val <- sum(x_area)
    out <- rbind(out, data.frame(ID = severity.data[i, 1], AUDPC = audpc_val))
    
    # 4. Generate the Visualization
    if (plot) {
      # Draw the main line graph
      plot(reading.dates, y_vals, type = "b", pch = 19, col = "blue", lwd = 2, 
           ylim = c(0, max(y_vals, na.rm = TRUE) * 1.2),
           xlab = "Date", ylab = "Disease Severity",
           main = paste("Disease Progress Curve - ID:", severity.data[i, 1], 
                        "\nAUDPC =", round(audpc_val, 2)))
      
      # Shade the Area Under the Curve using a polygon
      polygon(x = c(reading.dates[1], reading.dates, reading.dates[length(reading.dates)]),
              y = c(0, y_vals, 0), 
              col = rgb(0.2, 0.5, 0.8, alpha = 0.3), border = NA)
      
      # Add vertical dashed lines at each reading date for clarity
      abline(v = reading.dates, lty = 2, col = "gray")
    }
  }
  
  return(out)
}

# # Example Data
# reading.dates <- as.Date(c("2012-02-13","2012-02-20","2012-02-28"))
# mydat <- data.frame(ID = c("A", "B", "C", "D"), 
#                     Date1 = c(1, 2, 3, 4), 
#                     Date2 = c(5, 6, 7, 8),
#                     Date3 = c(11, 12, 13, 14))
# 
# # Run the calculation with plotting enabled
# # Note: Look at your plot viewer. You will need to press "Enter" in the console to cycle through individuals A, B, C, and D.
# cd <- AUDPC.cal(reading.dates, mydat, plot = TRUE)
# 
# # View the final output table
# print(cd)
