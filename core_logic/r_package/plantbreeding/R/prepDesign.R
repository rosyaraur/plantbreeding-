#' Design Proportional P-Rep Multi-Environment Trials with Spatial Blocking
#'
#' @param locations_file A CSV file path or data frame containing 6 columns: Environment, Reps (Ignored), Row, Range, Block_Dir, Block_Dim.
#' @param genotypes_file A CSV file path or data frame containing 4 columns: Name, Type (Check/Line), MaxRepsPerBlock, SeedAvail.
#' @param check_proportion Numeric. The target proportion of the field to be allocated to checks (e.g., 0.20 for 20%). Default is 0.20.
#' @param seed Numeric random seed for reproducibility. Default is 999.
#'
#' @return A list containing three data frames: TrialPlan, RemainingInventory, and Summary.
#' @author Umesh R. Rosyara
#' @export
prep_design_inventory <- function(locations_file, genotypes_file, check_proportion = 0.20, seed = 999) {
  
  if (check_proportion <= 0 || check_proportion >= 1) {
    stop("Error: check_proportion must be strictly between 0 and 1 (e.g., 0.15 for 15%).")
  }
  
  # 1. Flexible Input Handling
  locs_raw <- if (is.character(locations_file)) read.csv(locations_file, header = TRUE, stringsAsFactors = FALSE) else as.data.frame(locations_file)
  genos_raw <- if (is.character(genotypes_file)) read.csv(genotypes_file, header = TRUE, stringsAsFactors = FALSE) else as.data.frame(genotypes_file)
  
  if (ncol(locs_raw) < 6) stop("Error: Locations data must contain at least 6 columns.")
  
  locs <- locs_raw[, 1:6]
  genos <- genos_raw[, 1:4] 
  
  colnames(locs) <- c("Environment", "Reps", "Row", "Range", "Block_Dir", "Block_Dim")
  colnames(genos) <- c("Name", "Type", "MaxRepsPerBlock", "SeedAvail")
  
  genos$SeedAvail <- as.numeric(genos$SeedAvail)
  genos$SeedAvail[tolower(genos$Type) == "check" | is.na(genos$SeedAvail)] <- Inf
  
  if (!is.null(seed) && !is.na(seed) && seed != 999) set.seed(seed)
  
  all_env_plans <- list()
  
  # 2. Loop through Environments
  for (i in 1:nrow(locs)) {
    env_name <- locs$Environment[i]
    n_rows <- as.numeric(locs$Row[i])
    n_ranges <- as.numeric(locs$Range[i])
    b_dir <- trimws(as.character(locs$Block_Dir[i]))
    b_dim <- as.numeric(locs$Block_Dim[i])
    
    total_plots <- n_rows * n_ranges
    target_check_plots <- round(total_plots * check_proportion)
    
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
      stop(sprintf("Environment '%s': Block_Dir must be 'Row' or 'Range'.", env_name))
    }
    
    num_blocks <- max(grid$Block)
    
    # Calculate uniform check distribution across blocks
    base_checks_per_block <- floor(target_check_plots / num_blocks)
    remainder_checks <- target_check_plots %% num_blocks
    
    env_data <- data.frame()
    
    # 3. Fill and randomize each spatial block
    for (b in 1:num_blocks) {
      block_grid <- grid[grid$Block == b, ]
      block_size <- nrow(block_grid)
      
      # Distribute remainder checks to the first few blocks
      needed_checks <- base_checks_per_block + ifelse(b <= remainder_checks, 1, 0)
      needed_lines <- block_size - needed_checks
      
      block_trts <- c()
      
      # Assign Checks (Randomly sample from available check inventory)
      for (k in seq_len(needed_checks)) {
        avail_checks <- genos[tolower(genos$Type) == "check" & genos$SeedAvail > 0, ]
        if (nrow(avail_checks) == 0) {
          block_trts <- c(block_trts, "FILLER")
        } else {
          chosen_idx <- sample(1:nrow(avail_checks), 1)
          chosen_name <- avail_checks$Name[chosen_idx]
          block_trts <- c(block_trts, chosen_name)
          
          # Deduct global inventory
          g_idx <- which(genos$Name == chosen_name)
          genos$SeedAvail[g_idx] <- genos$SeedAvail[g_idx] - 1
        }
      }
      
      # Assign Experimental Lines (Sample without replacement within the block)
      avail_lines <- genos[tolower(genos$Type) != "check" & genos$SeedAvail > 0, ]
      
      num_to_pick <- min(needed_lines, nrow(avail_lines))
      if (num_to_pick > 0) {
        # Without replacement prevents duplicate lines in the same micro-environment
        chosen_indices <- sample(1:nrow(avail_lines), num_to_pick, replace = FALSE)
        chosen_names <- avail_lines$Name[chosen_indices]
        block_trts <- c(block_trts, chosen_names)
        
        # Deduct global inventory
        for(cn in chosen_names) {
          g_idx <- which(genos$Name == cn)
          genos$SeedAvail[g_idx] <- genos$SeedAvail[g_idx] - 1
        }
      }
      
      # Fill any remaining voids
      needed_lines <- needed_lines - num_to_pick
      if (needed_lines > 0) {
        block_trts <- c(block_trts, rep("FILLER", needed_lines))
      }
      
      # Randomize treatments and attach to spatial block coordinates
      block_grid$Treatment <- sample(block_trts) 
      env_data <- rbind(env_data, block_grid)
    }
    
    # Format Output
    env_data <- env_data[order(env_data$Row, env_data$Range), ] 
    env_data$PlotNumber <- 1:nrow(env_data)
    env_data <- env_data[, c("Environment", "PlotNumber", "Row", "Range", "Block", "Treatment")]
    
    all_env_plans[[i]] <- env_data
  }
  
  final_plan <- do.call(rbind, all_env_plans)
  
  # --- 4. Generate Output Summaries ---
  remaining_lines <- genos[tolower(genos$Type) != "check", c("Name", "SeedAvail")]
  colnames(remaining_lines) <- c("Line", "Remaining_Seed_Quantity")
  
  trt_env_counts <- as.data.frame.matrix(table(final_plan$Treatment, final_plan$Environment))
  trt_env_counts$Total_Plots <- rowSums(trt_env_counts)
  trt_env_counts$Treatment <- rownames(trt_env_counts)
  
  summary_df <- merge(genos_raw[, 1:2], trt_env_counts, by.x = 1, by.y = "Treatment", all.y = TRUE)
  colnames(summary_df)[1:2] <- c("Treatment", "Type")
  summary_df$Type[is.na(summary_df$Type)] <- "Filler"
  
  env_cols <- setdiff(names(summary_df), c("Treatment", "Type", "Total_Plots"))
  summary_df <- summary_df[, c("Treatment", "Type", "Total_Plots", env_cols)]
  
  type_order <- ifelse(tolower(summary_df$Type) == "check", 1, ifelse(tolower(summary_df$Type) == "filler", 3, 2))
  summary_df <- summary_df[order(type_order, -summary_df$Total_Plots), ]
  rownames(summary_df) <- NULL
  
  return(list(
    TrialPlan = final_plan, 
    RemainingInventory = remaining_lines,
    Summary = summary_df
  ))
}

# Run the p-rep engine
prep_results <- prep_design_inventory(
  locations_file = "~/Downloads/locations_parameters.csv", 
  genotypes_file = "~/Downloads/genotypes_parameters.csv",
  check_proportion = 0.20, # Generates a true 20/80 p-rep split
  seed = 42
)

# Export the final Prism-ready matrix
write.csv(prep_results$TrialPlan, "P_Rep_Trial_Plan.csv", row.names = FALSE)

# Review your spatial allocations
print(prep_results$Summary)

# Partially replicated (p-rep) designs are increasingly the standard for early-stage METs (Multi-Environment Trials) because
# they maximize the number of unique experimental lines you can evaluate while utilizing a dynamic proportion of checks to 
# capture spatial field variation.

# Unlike an Augmented or Alpha design where block dimensions and replications rigidly dictate the math, a p-rep design operates 
# on a grid-first, proportional basis.

# Key Differences in P-Rep Logic
# The Grid is the Truth: It calculates the total plots based strictly on your Row and Range inputs. The Reps column in your
# Locations file is intentionally ignored, as p-rep does not rely on rigid, whole-trial replications.

# Proportional Check Allocation: It calculates the required number of checks based on the check_proportion argument
# (e.g., 0.20 for 20%) and distributes them evenly across your spatial blocks to ensure uniform spatial
# adjustment capability.

#Line Maximization: It fills the remaining plots by sampling your experimental lines without replacement within a block. 
# This guarantees that you never accidentally plant the same experimental line twice within the same micro-environmental block, 
# adhering to true p-rep principles.

