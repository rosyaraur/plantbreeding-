#' Design Inventory-Driven Multi-Environment Trials with Spatial Blocking
#'
#' @param locations_file A CSV file path or data frame containing 6 columns: Environment, Reps, Row, Range, Block_Dir, Block_Dim.
#' @param genotypes_file A CSV file path or data frame containing 4 columns: Name, Type (Check/Line), MaxRepsPerBlock, SeedAvail.
#' @param seed Numeric random seed for reproducibility. Default is 999.
#' @param max_reps_per_loc_lines Integer. The maximum number of plots an experimental line can be assigned within a single environment. Default is 1.
#'
#' @return A list containing three data frames: TrialPlan, RemainingInventory, and Summary.
#' @author Umesh R. Rosyara
#' @export
adesign_inventory <- function(locations_file, genotypes_file, seed = 999, max_reps_per_loc_lines = 1) {
  
  # 1. Flexible Input Handling (Accepts file paths OR data frames)
  if (is.character(locations_file)) {
    locs_raw <- read.csv(locations_file, header = TRUE, stringsAsFactors = FALSE)
  } else {
    locs_raw <- as.data.frame(locations_file)
  }
  
  if (is.character(genotypes_file)) {
    genos_raw <- read.csv(genotypes_file, header = TRUE, stringsAsFactors = FALSE)
  } else {
    genos_raw <- as.data.frame(genotypes_file)
  }
  
  # Validate Location Input
  if (ncol(locs_raw) < 6) {
    stop("Error: Locations data must contain at least 6 columns: Environment, Reps, Row, Range, Block_Dir, Block_Dim.")
  }
  
  # Extract strictly by position
  locs <- locs_raw[, 1:6]
  genos <- genos_raw[, 1:4] 
  
  # Standardize internal column names
  colnames(locs) <- c("Environment", "Reps", "Row", "Range", "Block_Dir", "Block_Dim")
  colnames(genos) <- c("Name", "Type", "MaxRepsPerBlock", "SeedAvail")
  
  # Format data types and inventory
  genos$SeedAvail <- as.numeric(genos$SeedAvail)
  genos$MaxRepsPerBlock <- as.numeric(genos$MaxRepsPerBlock)
  genos$SeedAvail[tolower(genos$Type) == "check" | is.na(genos$SeedAvail)] <- Inf
  
  if (!is.null(seed) && !is.na(seed) && seed != 999) set.seed(seed)
  
  all_env_plans <- list()
  
  # 2. Loop through Environments
  for (i in 1:nrow(locs)) {
    env_name <- locs$Environment[i]
    r <- as.numeric(locs$Reps[i])
    n_rows <- as.numeric(locs$Row[i])
    n_ranges <- as.numeric(locs$Range[i])
    b_dir <- trimws(as.character(locs$Block_Dir[i]))
    b_dim <- as.numeric(locs$Block_Dim[i])
    
    # Reset the tracking counter for lines planted in THIS specific location
    genos$CurrentLocReps <- 0
    
    # Generate the physical spatial grid
    grid <- data.frame(
      Environment = env_name, 
      Row = rep(1:n_rows, each = n_ranges), 
      Range = rep(1:n_ranges, times = n_rows), 
      stringsAsFactors = FALSE
    )
    
    # Cut the grid into spatial Blocks
    if (tolower(b_dir) %in% c("row", "rows")) {
      grid$Block <- ceiling(grid$Row / b_dim)
    } else if (tolower(b_dir) %in% c("range", "ranges", "col", "cols")) {
      grid$Block <- ceiling(grid$Range / b_dim)
    } else {
      stop(sprintf("Environment '%s': Block_Dir must be 'Row' or 'Range'. Found: '%s'", env_name, b_dir))
    }
    
    actual_reps <- max(grid$Block)
    env_data <- data.frame()
    
    # 3. Fill and randomize each spatial block based on inventory
    for (b in 1:actual_reps) {
      block_grid <- grid[grid$Block == b, ]
      block_size <- nrow(block_grid)
      block_trts <- c()
      
      # Assign Checks
      for (j in 1:nrow(genos)) {
        if (tolower(genos$Type[j]) == "check") {
          qty <- min(genos$MaxRepsPerBlock[j], genos$SeedAvail[j])
          if (qty > 0) block_trts <- c(block_trts, rep(genos$Name[j], qty))
        }
      }
      
      if (length(block_trts) > block_size) {
        stop(sprintf("Environment '%s' Block %d: Check plots (%d) exceed physical block size (%d).", env_name, b, length(block_trts), block_size))
      }
      
      # Assign Lines based on inventory availability AND Location Limits
      needed <- block_size - length(block_trts)
      for (j in 1:nrow(genos)) {
        if (needed == 0) break
        if (tolower(genos$Type[j]) != "check" && genos$SeedAvail[j] > 0) {
          
          # Calculate how many MORE times we are allowed to plant this line in THIS location
          allowed_in_loc <- max_reps_per_loc_lines - genos$CurrentLocReps[j]
          
          if (allowed_in_loc > 0) {
            qty <- min(needed, genos$MaxRepsPerBlock[j], genos$SeedAvail[j], allowed_in_loc)
            if (qty > 0) {
              block_trts <- c(block_trts, rep(genos$Name[j], qty))
              
              # Deduct from global seed inventory
              genos$SeedAvail[j] <- genos$SeedAvail[j] - qty
              # Add to current location tracking
              genos$CurrentLocReps[j] <- genos$CurrentLocReps[j] + qty
              
              needed <- needed - qty
            }
          }
        }
      }
      
      if (needed > 0) block_trts <- c(block_trts, rep("FILLER", needed))
      
      block_trts <- sample(block_trts) 
      block_grid$Treatment <- block_trts
      env_data <- rbind(env_data, block_grid)
    }
    
    # Format and Order Final Output
    env_data <- env_data[order(env_data$Row, env_data$Range), ] 
    env_data$PlotNumber <- 1:nrow(env_data)
    env_data <- env_data[, c("Environment", "PlotNumber", "Row", "Range", "Block", "Treatment")]
    
    all_env_plans[[i]] <- env_data
  }
  
  final_plan <- do.call(rbind, all_env_plans)
  
  # --- 4. Generate Output Summaries ---
  
  # Remaining Inventory
  remaining_lines <- genos[tolower(genos$Type) != "check", c("Name", "SeedAvail")]
  colnames(remaining_lines) <- c("Line", "Remaining_Seed_Quantity")
  
  # Cross-tabulation Replication Summary (Lines x Environments)
  trt_env_counts <- as.data.frame.matrix(table(final_plan$Treatment, final_plan$Environment))
  trt_env_counts$Total_Plots <- rowSums(trt_env_counts)
  trt_env_counts$Treatment <- rownames(trt_env_counts)
  
  # Join with original Genotype Types
  summary_df <- merge(genos_raw[, 1:2], trt_env_counts, by.x = 1, by.y = "Treatment", all.y = TRUE)
  colnames(summary_df)[1:2] <- c("Treatment", "Type")
  summary_df$Type[is.na(summary_df$Type)] <- "Filler"
  
  # Reorder columns: Treatment, Type, Total Plots, [Environments...]
  env_cols <- setdiff(names(summary_df), c("Treatment", "Type", "Total_Plots"))
  summary_df <- summary_df[, c("Treatment", "Type", "Total_Plots", env_cols)]
  
  # Sort table: Checks first, then Lines, then Fillers. Sorted descending by Total Plots.
  type_order <- ifelse(tolower(summary_df$Type) == "check", 1, ifelse(tolower(summary_df$Type) == "filler", 3, 2))
  summary_df <- summary_df[order(type_order, -summary_df$Total_Plots), ]
  rownames(summary_df) <- NULL
  
  return(list(
    TrialPlan = final_plan, 
    RemainingInventory = remaining_lines,
    Summary = summary_df
  ))
}

# Run the function
results <- adesign_inventory(
  locations_file = "~/Downloads/locations_parameters.csv", 
  genotypes_file = "~/Downloads/genotypes_parameters.csv",
  seed = 42,
  max_reps_per_loc_lines = 1
)

# 1. Access the main field plan (for export to Prism or SAS)
head(results$TrialPlan)

# 2. Check which lines have seed leftover for future nurseries
print(results$RemainingInventory)

# 3. Review the environment-by-environment allocation matrix
print(results$Summary)



