#' Trim Pedigree to Specific Individuals
#'
#' @param ped_data A dataframe representing the full pedigree. 
#'                 It expects the first three columns to be: Name, Parent1, Parent2.
#' @param targets A character vector of one or more individual names to track.
#' @param founder_marks A character vector of values that represent unknown parents/founders.
#' @return A dataframe containing the trimmed pedigree.
trim_pedigree <- function(ped_data, targets, founder_marks = c("*", "NA", "nan", "", "0", NA)) {
  
  # Ensure the first three columns are treated as character strings, not factors
  ped_data[, 1:3] <- lapply(ped_data[, 1:3], as.character)
  
  # Standardize the column names for internal use
  colnames(ped_data)[1:3] <- c("Name", "Parent1", "Parent2")
  
  # Initialize variables for the Breadth-First Search
  queue <- as.character(targets)
  processed <- character()
  result_list <- list()
  
  while (length(queue) > 0) {
    # Pop the first individual from the queue
    current <- queue[1]
    queue <- queue[-1]
    
    # Skip if we've already processed them, or if they are a founder/missing
    if (is.na(current) || current %in% processed || current %in% founder_marks) {
      next
    }
    
    # Mark as processed to prevent infinite loops (in case of pedigree errors)
    processed <- c(processed, current)
    
    # Find the individual in the full dataset
    row_idx <- which(ped_data$Name == current)
    
    if (length(row_idx) > 0) {
      # Extract parents (using the first match if there are duplicates)
      p1 <- ped_data$Parent1[row_idx[1]]
      p2 <- ped_data$Parent2[row_idx[1]]
      
      # Handle NAs just in case
      if (is.na(p1)) p1 <- "*"
      if (is.na(p2)) p2 <- "*"
      
      # Store the record
      result_list[[length(result_list) + 1]] <- data.frame(
        Name = current,
        Parent1 = p1,
        Parent2 = p2,
        stringsAsFactors = FALSE
      )
      
      # Add the parents to the queue to be processed next
      if (!(p1 %in% founder_marks)) queue <- c(queue, p1)
      if (!(p2 %in% founder_marks)) queue <- c(queue, p2)
    }
  }
  
  # Combine all the collected records into a single dataframe
  if (length(result_list) > 0) {
    final_ped <- do.call(rbind, result_list)
    # Remove any potential duplicate rows
    final_ped <- unique(final_ped)
    return(final_ped)
  } else {
    message("No valid pedigree data found for the specified targets.")
    return(data.frame(Name=character(), Parent1=character(), Parent2=character()))
  }
}

# # 1. Load your data
# full_pedigree_df <- read.csv("~/Documents/githubdir/DataIntellEngine/apps/shiny/pedigreeExplorer/apple_ped_complete.csv")
# 
# # 2. Define the individuals you want to track
# my_targets <- c("AE0234", "Pop_HCxAr", "CornellPop13")
# 
# # 3. Run the function
# trimmed_pedigree_df <- trim_pedigree(full_pedigree_df, my_targets)
# 
# # 4. View and export the result
# print(trimmed_pedigree_df)
# write.csv(trimmed_pedigree_df, "trimmed_pedigree_output.csv", row.names = FALSE)