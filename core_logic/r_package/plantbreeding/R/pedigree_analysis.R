# Ensure required packages are loaded
# install.packages(c("AGHmatrix", "visNetwork", "dplyr"))
library(AGHmatrix)
library(visNetwork)
library(dplyr)

#' @title Process, Calculate, and Visualize Pedigree Data
#'
#' @description This function takes raw pedigree data (3 columns: Individual, Parent1, Parent2),
#' standardizes missing values to "0" (as required by the AGHmatrix package), 
#' calculates the Numerator Relationship Matrix (A-matrix) to estimate additive genetic 
#' covariances, and generates an interactive, zoomable network visualization.
#'
#' @param ped_data A dataframe with exactly 3 columns representing Individual, Parent 1, 
#' and Parent 2, in that exact order.
#' @param missing_flags A character vector specifying which strings should be treated 
#' as missing or unknown parents. Defaults to c(".", "NA", "unknown", "Unknown", "", " ").
#'
#' @return A list containing three elements:
#' \itemize{
#'   \item \code{cleaned_data}: The formatted dataframe with standardized missing values ("0").
#'   \item \code{matrix}: The calculated A-matrix (Numerator Relationship Matrix) from AGHmatrix.
#'   \item \code{plot}: The interactive visNetwork htmlwidget object.
#' }
#'
#' @examples
#' \dontrun{
#' # Read in your raw data
#' my_pedigree <- read.csv("cherry_pedigree.csv")
#' 
#' # Process the data
#' results <- process_pedigree(my_pedigree)
#' 
#' # Access the outputs
#' clean_df <- results$cleaned_data
#' A_mat <- results$matrix
#' interactive_plot <- results$plot
#' 
#' # View the plot in RStudio Viewer
#' interactive_plot
#' }
#' 
#' @export
pedigree_analysis <- function(ped_data, missing_flags = c(".", "NA", "unknown", "Unknown", "", " ")) {
  
  # 1. DATA CLEANING & FORMATTING
  # Ensure we have exactly 3 columns and convert to plain characters
  if(ncol(ped_data) != 3) {
    stop("Input data must have exactly 3 columns: Individual, Parent1, Parent2")
  }
  
  colnames(ped_data) <- c("Name", "Parent1", "Parent2")
  ped_data$Name <- as.character(ped_data$Name)
  ped_data$Parent1 <- as.character(ped_data$Parent1)
  ped_data$Parent2 <- as.character(ped_data$Parent2)
  
  # Standardize all missing values to "0" for AGHmatrix compatibility
  ped_data$Parent1[is.na(ped_data$Parent1) | ped_data$Parent1 %in% missing_flags] <- "0"
  ped_data$Parent2[is.na(ped_data$Parent2) | ped_data$Parent2 %in% missing_flags] <- "0"
  
  # 2. CALCULATE A-MATRIX
  message("Calculating Numerator Relationship Matrix (A-matrix)...")
  a_matrix <- Amatrix(ped_data)
  
  # 3. GENERATE INTERACTIVE PLOT
  message("Generating interactive visNetwork plot...")
  
  # Create Edge List (excluding "0" parents)
  edges <- rbind(
    data.frame(from = ped_data$Parent1, to = ped_data$Name),
    data.frame(from = ped_data$Parent2, to = ped_data$Name)
  )
  edges <- edges[edges$from != "0", ]
  edges <- na.omit(edges)
  
  # Create Node List
  unique_nodes <- unique(c(edges$from, edges$to))
  nodes <- data.frame(
    id = unique_nodes,
    label = unique_nodes,
    shape = "box",
    color = list(
      background = "#D2E5FF",
      border = "#2B7CE9",
      highlight = "#FFC0CB"
    ),
    font = list(size = 16)
  )
  
  # Build Plot
  ped_plot <- visNetwork(nodes, edges, width = "100%", height = "800px") %>%
    visEdges(arrows = "to", color = list(color = "#848484", highlight = "#FF0000")) %>%
    visHierarchicalLayout(direction = "UD", sortMethod = "directed", levelSeparation = 100) %>%
    visInteraction(dragNodes = TRUE, dragView = TRUE, zoomView = TRUE, navigationButtons = TRUE) %>%
    visOptions(highlightNearest = list(enabled = TRUE, degree = 1, hover = TRUE), nodesIdSelection = TRUE)
  
  # 4. RETURN OUTPUT AS A LIST
  return(list(
    cleaned_data = ped_data,
    matrix = a_matrix,
    plot = ped_plot
  ))
}

# cherry_pedigree <- read.table(text = "
# 8011-3	.	.
# Ambrunes	.	.
# Beaulieu	.	.
# Bertiolle	.	.
# BlackHeart	.	.
# BlackRepublican	.	.
# Cristobalina	.	.
# Dzherlo	.	.
# EarlyBurlat	.	.
# EmperorFrancis	.	.
# EmpressEugenie	.	.
# F_Bing	.	.
# F_PC7147-009	.	.
# F_PC7147-4	.	.
# F_Van	.	.
# Gil-Peck	.	.
# Hedelfingen	.	.
# Krupnoplodnaya	.	.
# MIM17	.	.
# MIM23	.	.
# Moreau	.	.
# Napoleon	.	.
# P8-79	.	.
# PMR-1	.	.
# Rube	.	.
# Schmidt	.	.
# Schneiders	.	.
# Vittoria	.	.
# Windsor	.	.
# Cowiche	47-4	46-11
# Pop_6.29.49	BB	MIM17
# Pop_6.29.50	BB	MIM23
# Pop_5.23.15	Benton	Regina
# Pop_5.23.2	Benton	Ambrunes
# Pop_5.23.6	Benton	Dzherlo
# Pop_6.23.44	Benton	Bertiolle
# Pop_6.23.55	Benton	Vittoria
# Chinook	Bing	Gil-Peck
# Pop_5.4.15	Bing	Regina
# Pop_5.4.6	Bing	Dzherlo
# Pop_6.4.44	Bing	Bertiolle
# Pop_6.4.45	Bing	Cristobalina
# Pop_6.4.55	Bing	Vittoria
# Pop_9814-010	Bing	PMR-1
# Rainier	Bing	Van
# Vic	Bing	Schmidt
# Bing	BlackRepublican	.
# Pop_6.30.49	CC	MIM17
# Pop_6.30.50	CC	MIM23
# Pop_5.28.15	Cowiche	Regina
# Pop_5.28.37	Cowiche	Summit
# Pop_6.28.44	Cowiche	Bertiolle
# Pop_6.28.45	Cowiche	Cristobalina
# Pop_6.28.55	Cowiche	Vittoria
# Pop_6.31.49	DD	MIM17
# Pop_6.31.50	DD	MIM23
# Pop_6.32.49	EE	MIM17
# Pop_6.32.50	EE	MIM23
# JI2420	EmperorFrancis	Napoleon
# Van	EmpressEugenie	.
# Pop_6.33.49	GG	MIM17
# Pop_6.33.50	GG	MIM23
# Kiona	Glacier	Cashmere
# Venus	Hedelfingen	Windsor
# Pop_5.12.5	Kiona	Chelan
# Pop_6.12.45	Kiona	Cristobalina
# Stella	Lambert	JI2420
# Pop_4.10.19	Lapins	Tieton
# Pop_4.10.2	Lapins	Ambrunes
# Pop_4.10.5	Lapins	Chelan
# Pop_4.18.2	Lapins	Ambrunes
# Pop_5.10.25	Lapins	Krupnoplodnaya
# Pop_5.10.26	Lapins	Moreau
# Pop_5.10.40	Lapins	Venus
# Pop_6.10.55	Lapins	Vittoria
# Sel_4.10.15-001	Lapins	Regina
# Sel_4.10.5-002	Lapins	Chelan
# Sel_4.10.5-034	Lapins	Chelan
# Lambert	Napoleon	BlackHeart
# Selah	P8-79	Stella
# AA	PMR-1	Rainier
# BB	PMR-1	Rainier
# CC	PMR-1	Rainier
# DD	PMR-1	Rainier
# EE	PMR-1	Rainier
# Pop_5.13.26	PMR-1	Moreau
# Pop_5.13.40	PMR-1	Venus
# Pop_9819-027	PMR-1	Van
# Sel_9819-031	PMR-1	Van
# Brooks	Rainier	EarlyBurlat
# GG	Rainier	PMR-1
# JJ	Rainier	PMR-1
# Pop_5.14.23	Rainier	Benton
# Pop_5.14.26	Rainier	Moreau
# Pop_5.14.6	Rainier	Dzherlo
# Pop_6.14.2	Rainier	Ambrunes
# Pop_6.14.45	Rainier	Cristobalina
# Pop_9816-112	Rainier	PMR-1
# Sel_4.14.17-001	Rainier	Sunburst
# Ulster	Schmidt	Lambert
# Regina	Schneiders	Rube
# Pop_4.16.2	Selah	Ambrunes
# Pop_5.16.25	Selah	Krupnoplodnaya
# Pop_5.16.26	Selah	Moreau
# Pop_5.16.40	Selah	Venus
# Pop_6.16.44	Selah	Bertiolle
# Pop_6.16.55	Selah	Vittoria
# 46-11	Stella	Beaulieu
# 47-4	Stella	F_PC7147-4
# Benton	Stella	Beaulieu
# Cashmere	Stella	EarlyBurlat
# Chelan	Stella	Beaulieu
# Glacier	Stella	EarlyBurlat
# Index	Stella	.
# Lapins	Stella	Van
# Tieton	Stella	EarlyBurlat
# Pop_4.18.12	Sweetheart	Regina
# Pop_5.18.25	Sweetheart	Krupnoplodnaya
# Pop_5.18.26	Sweetheart	Moreau
# Sel_4.18.12-005	Sweetheart	Kiona
# Newstar	Van	Stella
# Pop_5.20.6	Van	Dzherlo
# Pop_6.20.45	Van	Cristobalina
# Summit	Van	Sam
# Sunburst	Van	Stella
# Sweetheart	Van	Newstar
# Sam	Windsor	.
# ", header = FALSE, col.names = c("Name", "Parent1", "Parent2"), na.strings = ".")
# 
# # Assuming 'cherry_raw_data' is your uncleaned dataframe read from CSV/txt
# results <- pedigree_analysis(cherry_pedigree)
# 
# # Access 1: The Cleaned Data
# clean_df <- results$cleaned_data
# head(clean_df)
# 
# # Access 2: The A-Matrix
# cherry_A <- results$matrix
# print(cherry_A[1:5, 1:5])
# 
# # Access 3: The Interactive Plot (Running this line will render it in the Viewer)
# results$plot