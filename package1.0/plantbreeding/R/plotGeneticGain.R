# Base R function to plot genetic gain over cycles 
# Base R function to check distribution progress with light boundaries and grid
plotGeneticGain <- function(df, cycle_col = "cycle", value_col = "values") {
  
  # Ensure cycle column is a factor to maintain order (e.g., Cycle 1, Cycle 2...)
  df[[cycle_col]] <- as.factor(df[[cycle_col]])
  cycles <- levels(df[[cycle_col]])
  num_cycles <- length(cycles)
  
  # Set up the plotting area dynamically based on the number of cycles
  par(mfrow = c(1, num_cycles), mar = c(3, 0, 2, 0), oma = c(2, 4, 2, 1))
  
  # Find global min/max across all data to share the Y-axis properly
  min_y <- min(df[[value_col]], na.rm = TRUE)
  max_y <- max(df[[value_col]], na.rm = TRUE)
  
  # Add 5% padding to the top and bottom of the limits, and INVERT them
  y_padding <- (max_y - min_y) * 0.05
  y_limits <- c(max_y + y_padding, min_y - y_padding) 
  
  # Determine sensible tick marks for the Y-axis and the grid
  y_ticks <- pretty(c(min_y, max_y))
  
  # Generate a distinct color palette for the number of cycles
  bar_colors <- hcl.colors(num_cycles, palette = "Pastel 1")
  
  # Loop through and plot each cycle
  for (i in 1:num_cycles) {
    current_cycle <- cycles[i]
    
    # Filter data for the current cycle
    cycle_data <- df[df[[cycle_col]] == current_cycle, value_col]
    
    # Calculate histogram and density
    hist_data <- hist(cycle_data, breaks = 20, plot = FALSE)
    density_data <- density(cycle_data)
    
    # Scale density curve to match histogram frequency
    scale_factor <- max(hist_data$counts) / max(density_data$y)
    scaled_density_y <- density_data$y * scale_factor
    
    # Draw plot canvas 
    plot(hist_data$counts, hist_data$mids, type = "n", 
         xlab = "", ylab = "", main = current_cycle,
         xlim = c(0, max(hist_data$counts) * 1.2),
         ylim = y_limits, yaxt = "n", xaxt = "n")
    
    # --- NEW: Add light gray grid lines parallel to the x-axis (behind the data) ---
    abline(h = y_ticks, col = "gray90", lty = 3, lwd = 1.5)
    
    if (i == 1) {
      # Use the dynamically calculated pretty ticks for the leftmost axis
      axis(2, at = y_ticks, las = 1) 
    }
    
    # --- UPDATED: Add a dim, light gray bounding box ---
    box(col = "gray80", lwd = 1)
    
    # Draw horizontal histogram bars using the unique color assigned to this cycle
    for (j in 1:(length(hist_data$breaks) - 1)) {
      rect(0, hist_data$breaks[j], hist_data$counts[j], hist_data$breaks[j + 1], 
           col = bar_colors[i], border = "gray50")
    }
    
    # Draw smooth density line and mean line
    lines(scaled_density_y, density_data$x, col = "#1f3a5c", lwd = 2)
    cycle_mean <- mean(cycle_data)
    abline(h = cycle_mean, col = "coral", lty = 2, lwd = 2)
  }
  
  # Add global Y axis label
  mtext("Y values", side = 2, outer = TRUE, line = 2, font = 2)
}

# Generate LONG format sample data including a 5th cycle
set.seed(42)

df_long <- data.frame(
  cycle = rep(paste("Cycle", 1:6), each = 1000),
  values = c(
    rnorm(1000, mean = -1.0, sd = 0.6),
    rnorm(1000, mean = -1.8, sd = 0.5),
    rnorm(1000, mean = 0.6, sd = 0.55),
    rnorm(1000, mean = -3.2, sd = 0.45),
    rnorm(1000, mean = -4.0, sd = 0.5) ,
    rnorm(1000, mean = -6.0, sd = 0.2)
  )
)

# Run the function
# Note: Ensure your plotting window in R is wide enough to fit 5 columns comfortably!
plotGeneticGain(df_long, cycle_col = "cycle", value_col = "values")
