library(dplyr)
library(ggplot2)

#' Generate Strip-Plot Design Randomization Plan
#'
#' @param wp_factor Vector of Whole-plot treatment names (e.g., Irrigation levels).
#' @param sp_factor Vector of Sub-plot treatment names (e.g., Varieties).
#' @param n_locs Number of locations.
#' @param n_blocks Number of blocks (replicates) per location.
#'
#' @return A list containing the randomization data frame and the ggplot object.
generate_stripplot_plan <- function(wp_factor, sp_factor, n_locs = 2, n_blocks = 3) {
  
  n_wp <- length(wp_factor)
  n_sp <- length(sp_factor)
  
  # ---------------------------------------------------------
  # 1. Randomization Engine
  # ---------------------------------------------------------
  
  plan_list <- list()
  counter <- 1
  
  for (loc in 1:n_locs) {
    for (blk in 1:n_blocks) {
      
      # Step 1: Randomize the Whole-plot factor within the block
      wp_rand <- sample(wp_factor)
      
      for (w in 1:n_wp) {
        current_wp <- wp_rand[w]
        
        # Step 2: Randomize the Sub-plot factor WITHIN the current Whole-plot
        sp_rand <- sample(sp_factor)
        
        # Assign spatial coordinates 
        # (Whole-plots = Rows within block, Sub-plots = Columns within Whole-plot)
        temp_df <- data.frame(
          Location = paste("Location", loc),
          Block = paste("Block", blk),
          Block_Num = blk,
          Whole_Plot_Unit = paste0("B", blk, "-WP", w),
          Whole_Plot_Trt = current_wp,
          Sub_Plot_Trt = sp_rand,
          Local_Row = w,               # Row assignment based on WP index
          Local_Col = 1:n_sp           # Column assignment based on SP index
        )
        
        plan_list[[counter]] <- temp_df
        counter <- counter + 1
      }
    }
  }
  
  final_plan <- bind_rows(plan_list)
  
  # ---------------------------------------------------------
  # 2. Spatial Calculations
  # ---------------------------------------------------------
  
  # Stack blocks vertically
  final_plan <- final_plan %>%
    group_by(Location) %>%
    mutate(
      Global_Row = Local_Row + (Block_Num - 1) * n_wp,
      Global_Col = Local_Col
    ) %>%
    ungroup()
  
  # Bounding boxes for Whole-Plots (thicker gray lines)
  wp_boundaries <- final_plan %>%
    group_by(Location, Block, Whole_Plot_Unit) %>%
    summarize(
      xmin = min(Global_Col) - 0.5,
      xmax = max(Global_Col) + 0.5,
      ymin = min(Global_Row) - 0.5,
      ymax = max(Global_Row) + 0.5,
      .groups = "drop"
    )
  
  # Bounding boxes for full Blocks (bold black lines)
  blk_boundaries <- final_plan %>%
    group_by(Location, Block) %>%
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
    # Draw individual Sub-plots
    geom_tile(data = final_plan, 
              aes(x = Global_Col, y = Global_Row, fill = Whole_Plot_Trt), 
              color = "white", linewidth = 0.5) +
    
    # Draw Whole-plot boundaries
    geom_rect(data = wp_boundaries, 
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), 
              fill = NA, color = "gray20", linewidth = 0.8) +
    
    # Draw Block boundaries (Bold)
    geom_rect(data = blk_boundaries, 
              aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax), 
              fill = NA, color = "black", linewidth = 1.5) +
    
    # Add Sub-plot treatment labels
    geom_text(data = final_plan, 
              aes(x = Global_Col, y = Global_Row, label = Sub_Plot_Trt), 
              size = 3.5, fontface = "bold", color = "black") +
    
    scale_y_reverse() + 
    scale_x_continuous() +
    facet_wrap(~ Location, ncol = 2, scales = "free") + 
    
    # Using a discrete color palette for the Whole-plot treatments
    scale_fill_brewer(palette = "Pastel1") + 
    
    labs(title = "Multi-Location Split-Plot Field Layout",
         subtitle = "Color = Whole-Plot Treatment. Text = Sub-Plot Treatment.\nBold Black = Block. Thin Gray = Whole-plot Strip.",
         x = "Sub-Plot (Column)",
         y = "Whole-Plot (Row)",
         fill = "Main Plot\nTreatment") +
    theme_minimal() +
    theme(
      panel.grid = element_blank(),
      strip.text = element_text(size = 12, face = "bold"),
      axis.text = element_blank() 
    )
  
  print(field_plot)
  return(list(Data = final_plan, Plot = field_plot))
}

# # ==========================================
# # EXAMPLE USAGE
# # ==========================================
# 
# # Define 3 Main Plot treatments (e.g., Irrigation methods)
# main_plots <- c("Irrigated", "Dryland", "Deficit")
# 
# # Define 5 Sub-plot treatments (e.g., Varieties)
# sub_plots <- paste0("Var-", 1:5)
# 
# # Generate the split-plot plan
# # This will result in blocks of 3 rows (Main plots) and 5 columns (Sub-plots)
# split_trial <- generate_stripplot_plan(
#   wp_factor = main_plots, 
#   sp_factor = sub_plots, 
#   n_locs = 2,             # 2 environments
#   n_blocks = 3            # 3 replicates per environment
# )
# 
# # Check the generated dataset
# head(split_trial$Data, 10)