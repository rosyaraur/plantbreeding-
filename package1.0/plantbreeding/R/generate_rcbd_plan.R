library(dplyr)
library(ggplot2)

#' Generate Variable-Dimension RCBD Randomization Plan with Bold Block Borders
#'
#' @param lines Vector of treatment/line names.
#' @param checks Vector of check names.
#' @param n_locs Number of locations.
#' @param n_blocks Number of blocks (replicates) per location.
#' @param rows_per_block A single integer (applied to all) OR a vector of integers per location.
#' @param cols_per_block A single integer (applied to all) OR a vector of integers per location.
#'
#' @return A list containing the randomization data frame and the ggplot object.
generate_rcbd_plan <- function(lines, checks, n_locs = 2, n_blocks = 3, 
                               rows_per_block, cols_per_block) {
  
  treatments <- c(lines, checks)
  n_trt <- length(treatments)
  
  # ---------------------------------------------------------
  # 1. Handle Variable Dimensions Across Locations
  # ---------------------------------------------------------
  
  if (length(rows_per_block) == 1) {
    rows_per_block <- rep(rows_per_block, n_locs)
  } else if (length(rows_per_block) != n_locs) {
    stop(paste("Error: 'rows_per_block' must be length 1 or match n_locs (", n_locs, ")."))
  }
  
  if (length(cols_per_block) == 1) {
    cols_per_block <- rep(cols_per_block, n_locs)
  } else if (length(cols_per_block) != n_locs) {
    stop(paste("Error: 'cols_per_block' must be length 1 or match n_locs (", n_locs, ")."))
  }
  
  for (i in 1:n_locs) {
    if (rows_per_block[i] * cols_per_block[i] != n_trt) {
      stop(paste0("Error at Location ", i, ": Grid (", rows_per_block[i], "x", 
                  cols_per_block[i], " = ", rows_per_block[i] * cols_per_block[i], 
                  ") does not equal total treatments (", n_trt, ")."))
    }
  }
  
  # ---------------------------------------------------------
  # 2. Randomization Engine
  # ---------------------------------------------------------
  
  plan_list <- list()
  counter <- 1
  
  for (loc in 1:n_locs) {
    for (blk in 1:n_blocks) {
      
      shuffled_trt <- sample(treatments)
      r_loc <- rows_per_block[loc]
      c_loc <- cols_per_block[loc]
      
      temp_df <- data.frame(
        Location = paste("Location", loc),
        Block = paste("Block", blk),
        Block_Num = blk,
        Local_Row = rep(1:r_loc, each = c_loc),
        Local_Col = rep(1:c_loc, times = r_loc),
        Treatment = shuffled_trt,
        Type = ifelse(shuffled_trt %in% checks, "Check", "Line")
      )
      
      plan_list[[counter]] <- temp_df
      counter <- counter + 1
    }
  }
  
  final_plan <- bind_rows(plan_list)
  
  # ---------------------------------------------------------
  # 3. Spatial Calculations
  # ---------------------------------------------------------
  
  final_plan <- final_plan %>%
    group_by(Location) %>%
    mutate(Global_Row = Local_Row + (Block_Num - 1) * max(Local_Row),
           Global_Col = Local_Col) %>%
    ungroup()
  
  # Calculate bounding boxes for the bold block borders
  # geom_tile centers at integer coordinates, so edges are at +/- 0.5
  block_boundaries <- final_plan %>%
    group_by(Location, Block) %>%
    summarize(
      xmin = min(Global_Col) - 0.5,
      xmax = max(Global_Col) + 0.5,
      ymin = min(Global_Row) - 0.5,
      ymax = max(Global_Row) + 0.5,
      .groups = "drop"
    )
  
  # ---------------------------------------------------------
  # 4. Plotting
  # ---------------------------------------------------------
  
  field_plot <- ggplot() +
    # Draw individual plots (thin lines)
    geom_tile(data = final_plan, 
              aes(x = Global_Col, y = Global_Row, fill = Type), 
              color = "gray40", linewidth = 0.3) +
    
    # Draw block boundaries (bold lines)
    geom_rect(data = block_boundaries, 
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
    labs(title = "Multi-Location RCBD Field Layout",
         subtitle = "Blocks highlighted with bold borders.",
         x = "Field Column (Range)",
         y = "Field Row",
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

my_lines <- paste0("L-", 1:10)
my_checks <- c("CHK-A", "CHK-B")

variable_trial <- generate_rcbd_plan(
  lines = my_lines, 
  checks = my_checks, 
  n_locs = 3,             
  n_blocks = 2,           
  rows_per_block = c(3, 2, 4), 
  cols_per_block = c(4, 6, 3)  
)