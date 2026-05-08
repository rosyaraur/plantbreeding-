library(dplyr)
library(ggplot2)

#' Generate Resolvable Incomplete Block / Alpha Design Plan
#'
#' @param lines Vector of treatment/line names.
#' @param checks Vector of check names.
#' @param n_locs Number of locations.
#' @param n_reps Number of full replications per location.
#' @param k Block size (number of plots per incomplete block).
#'
#' @return A list containing the randomization data frame and the ggplot object.
generate_lattice_plan <- function(lines, checks, n_locs = 2, n_reps = 2, k) {
  
  treatments <- c(lines, checks)
  v <- length(treatments) # Total number of treatments
  
  # Validation step: For a resolvable incomplete block design, 
  # total treatments must be a multiple of the incomplete block size.
  if (v %% k != 0) {
    stop(paste("Error: Total treatments (", v, 
               ") must be perfectly divisible by incomplete block size k (", k, ")."))
  }
  
  s <- v / k # Number of incomplete blocks per replicate
  
  # ---------------------------------------------------------
  # 1. Randomization Engine
  # ---------------------------------------------------------
  
  plan_list <- list()
  counter <- 1
  
  for (loc in 1:n_locs) {
    for (rep in 1:n_reps) {
      
      # Randomize treatments for the full replication
      shuffled_trt <- sample(treatments)
      
      # Assign treatments to incomplete blocks
      temp_df <- data.frame(
        Location = paste("Location", loc),
        Replicate = paste("Rep", rep),
        Rep_Num = rep,
        Inc_Block_Num = rep(1:s, each = k),  # Assign 's' blocks
        Local_Col = rep(1:k, times = s),     # 'k' plots per block
        Treatment = shuffled_trt,
        Type = ifelse(shuffled_trt %in% checks, "Check", "Line")
      )
      
      # Create a unique identifier for each incomplete block for plotting
      temp_df$Inc_Block <- paste("Rep", rep, "- Blk", temp_df$Inc_Block_Num)
      
      plan_list[[counter]] <- temp_df
      counter <- counter + 1
    }
  }
  
  final_plan <- bind_rows(plan_list)
  
  # ---------------------------------------------------------
  # 2. Spatial Calculations
  # ---------------------------------------------------------
  
  # Stack Replications vertically. 
  # Each Incomplete Block becomes a row, and the plots within it are columns.
  final_plan <- final_plan %>%
    group_by(Location) %>%
    mutate(
      Global_Row = Inc_Block_Num + (Rep_Num - 1) * s,
      Global_Col = Local_Col
    ) %>%
    ungroup()
  
  # Bounding boxes for Full Replicates (Bold Black)
  rep_boundaries <- final_plan %>%
    group_by(Location, Replicate) %>%
    summarize(
      xmin = min(Global_Col) - 0.5,
      xmax = max(Global_Col) + 0.5,
      ymin = min(Global_Row) - 0.5,
      ymax = max(Global_Row) + 0.5,
      .groups = "drop"
    )
  
  # Bounding boxes for Incomplete Blocks (Dashed Blue)
  blk_boundaries <- final_plan %>%
    group_by(Location, Inc_Block) %>%
    summarize(
      xmin = min(Global_Col) - 0.5,
      xmax = max(Global_Col) + 0.5,
      ymin = min(Global_Row) - 0.5,
      ymax = max(Global_Row) + 0.5,
      .groups = "drop"
    )
  
  # ---------------------------------------------------------
  # 3. Plotting
  # ---------------------------------------------------------
  
  field_plot <- ggplot() +
    # Draw individual plots (thin gray lines)
    geom_tile(data = final_plan, 
              aes(x = Global_Col, y = Global_Row, fill = Type), 
              color = "gray80", linewidth = 0.3) +
    
    # Draw Incomplete Block boundaries (dashed blue)
    geom_rect(data = blk_boundaries, 
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), 
              fill = NA, color = "#005b96", linewidth = 0.8, linetype = "dashed") +
    
    # Draw Full Replicate boundaries (bold black)
    geom_rect(data = rep_boundaries, 
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), 
              fill = NA, color = "black", linewidth = 1.2) +
    
    # Add treatment labels
    geom_text(data = final_plan, 
              aes(x = Global_Col, y = Global_Row, label = Treatment), 
              size = 3.5, fontface = "bold") +
    
    scale_fill_manual(values = c("Check" = "#FFD700", "Line" = "#ADD8E6")) +
    scale_y_reverse() + 
    scale_x_continuous() +
    facet_wrap(~ Location, ncol = 2, scales = "free") + 
    labs(title = "Multi-Location Alpha / Incomplete Block Layout",
         subtitle = "Black borders = Full Replications. Dashed Blue borders = Incomplete Blocks.",
         x = "Field Column (Plot within Block)",
         y = "Field Row (Incomplete Block)",
         fill = "Entry Type") +
    theme_minimal() +
    theme(
      panel.grid = element_blank(),
      strip.text = element_text(size = 12, face = "bold"),
      axis.text = element_blank() 
    )
  
  print(field_plot)
  return(list(Data = final_plan, Plot = field_plot))
}

# ==========================================
# EXAMPLE USAGE
# ==========================================

# 24 Total Treatments
my_lines <- paste0("L-", 1:22)
my_checks <- c("CHK-1", "CHK-2")

# Run the lattice generator
# We have 24 treatments. We can use an incomplete block size (k) of 4.
# This results in s = 6 incomplete blocks per full replication.
lattice_trial <- generate_lattice_plan(
  lines = my_lines, 
  checks = my_checks, 
  n_locs = 2,             # 2 environments
  n_reps = 2,             # 2 full replications per environment
  k = 4                   # 4 plots per incomplete block
)