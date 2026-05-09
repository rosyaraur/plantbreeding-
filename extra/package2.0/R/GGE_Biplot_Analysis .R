library(ggplot2)

#' GGE Biplot Analysis
#'
#' @description 
#'  It performs Singular Value 
#' Decomposition (SVD) on environment-centered data and generates three 
#' scatter plots based on different scaling methods (Genotype-focused, 
#' Environment-focused, and Symmetrical).
#'
#' @param indata A data frame containing the mean yields. It must contain 
#'   a column for Genotype labels and numeric columns representing Environments.
#' @param gen_col A string specifying the name of the column in `indata` 
#'   that contains the Genotype labels. NOTE: All other numeric columns 
#'   in the dataset will automatically be treated as Environments.
#'
#' @return Invisibly returns a list containing two main elements:
#'   \itemize{
#'     \item \code{plots}: A list of the three generated ggplot2 objects 
#'     (\code{f1}, \code{f0}, \code{f05}).
#'     \item \code{coords}: A list containing the calculated PC1 and PC2 
#'     coordinates for Genotypes and Environments under each scaling method.
#'   }
#'   The function also prints the three plots to the active graphics device.
#'
#' @examples
#' \dontrun{
#' wheat_trials <- data.frame(
#'   Names = c("Ann", "Ari", "Aug", "Cas", "Del"),
#'   BH93 = c(4.460, 4.417, 4.669, 4.732, 4.390),
#'   EA93 = c(4.150, 4.771, 4.578, 4.745, 4.603)
#' )
#' results <- GGE_Biplot_Analysis(indata = wheat_trials, gen_col = "Names")
#' }
#' 
#' @export
library(ggplot2)

#' GGE Biplot Analysis with Concentric Circles
#'
#' @description 
#' Replicates a standard SAS macro for GGE Biplot Analysis using R. 
#' It performs Singular Value Decomposition (SVD) on environment-centered data 
#' and generates three scatter plots based on different scaling methods.
#' Features publication-style concentric circles for vector magnitude assessment.
#'
#' @param indata A data frame containing the mean yields. It must contain 
#'   a column for Genotype labels and numeric columns representing Environments.
#' @param gen_col A string specifying the name of the column in `indata` 
#'   that contains the Genotype labels.
#' @param draw_circles Logical. If TRUE, draws concentric circles centered 
#'   at the origin to aid in assessing distances and vector lengths. Default is TRUE.
#'
#' @return Invisibly returns a list containing the plots and calculated coordinates.
#' @export
GGE_Biplot_Analysis <- function(indata, gen_col, draw_circles = TRUE) {
  
  # --------------------------------------------------------- 
  # 1. SVD and Partitioning
  # --------------------------------------------------------- 
  Genotypes <- indata[[gen_col]]
  Y_raw <- indata[, sapply(indata, is.numeric)]
  Environments <- colnames(Y_raw)
  Y_raw_matrix <- as.matrix(Y_raw)
  
  n_geno <- nrow(Y_raw_matrix)
  col_means <- colMeans(Y_raw_matrix)
  Y_centered <- sweep(Y_raw_matrix, 2, col_means, "-")
  
  svd_res <- svd(Y_centered)
  U2 <- svd_res$u[, 1:2]
  V2 <- svd_res$v[, 1:2]
  
  Lambda <- diag(svd_res$d[1:2])
  Lambda_half <- diag(sqrt(svd_res$d[1:2]))
  
  G_scores_f1 <- U2 %*% Lambda
  E_scores_f1 <- V2
  
  G_scores_f0 <- U2
  E_scores_f0 <- V2 %*% Lambda
  
  G_scores_f05 <- U2 %*% Lambda_half
  E_scores_f05 <- V2 %*% Lambda_half
  
  # --------------------------------------------------------- 
  # 2. Helper Function for Plotting
  # --------------------------------------------------------- 
  generate_biplot <- function(G_scores, E_scores, title_text) {
    
    G_df <- data.frame(ID = Genotypes, PC1 = G_scores[, 1], PC2 = G_scores[, 2])
    E_df <- data.frame(ID = Environments, PC1 = E_scores[, 1], PC2 = E_scores[, 2])
    
    # Initialize the ggplot object
    p <- ggplot()
    
    # Optional: Generate Concentric Circles
    if (draw_circles) {
      # Find the maximum extent of the data to scale the circles properly
      max_dist <- max(sqrt(c(G_df$PC1^2 + G_df$PC2^2, E_df$PC1^2 + E_df$PC2^2)))
      radii <- seq(max_dist * 0.25, max_dist, length.out = 4)
      
      circle_data <- data.frame()
      angles <- seq(0, 2 * pi, length.out = 100)
      
      for (r in radii) {
        circle_data <- rbind(circle_data, data.frame(
          r_group = as.factor(r),
          x = r * cos(angles),
          y = r * sin(angles)
        ))
      }
      
      # Add circles to the plot (placed first so they are behind the data)
      p <- p + geom_path(data = circle_data, aes(x = x, y = y, group = r_group), 
                         color = "gray70", linetype = "dotted", linewidth = 0.5)
    }
    
    # Add remaining plot elements
    p <- p +
      geom_hline(yintercept = 0, linetype = "dashed", color = "gray40") +
      geom_vline(xintercept = 0, linetype = "dashed", color = "gray40") +
      
      geom_segment(data = E_df, aes(x = 0, y = 0, xend = PC1, yend = PC2),
                   color = "blue", linewidth = 0.8, alpha = 0.7,
                   arrow = arrow(length = unit(0.2, "cm"), type = "closed")) +
      
      geom_text(data = E_df, aes(x = PC1, y = PC2, label = ID),
                color = "blue", fontface = "bold", vjust = "outward", hjust = "outward") +
      
      geom_point(data = G_df, aes(x = PC1, y = PC2),
                 color = "red", size = 3) +
      
      geom_text(data = G_df, aes(x = PC1, y = PC2, label = ID),
                color = "red", vjust = 1.5) +
      
      # Force aspect ratio to be 1:1 so circles don't warp into ovals
      coord_fixed(ratio = 1) + 
      
      labs(title = title_text, x = "PC1", y = "PC2") +
      theme_minimal() +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold"),
        panel.grid.major = element_line(color = "grey90"),
        panel.grid.minor = element_blank() # Hide minor grid lines to make circles pop
      )
    
    return(p)
  }
  
  # --------------------------------------------------------- 
  # 3. Generate and Print Plots
  # --------------------------------------------------------- 
  plot_f1  <- generate_biplot(G_scores_f1, E_scores_f1, "Genotype-Focused GGE Biplot (f = 1)")
  plot_f0  <- generate_biplot(G_scores_f0, E_scores_f0, "Environment-Focused GGE Biplot (f = 0)")
  plot_f05 <- generate_biplot(G_scores_f05, E_scores_f05, "Symmetrical GGE Biplot (f = 0.5)")
  
  print(plot_f1)
  print(plot_f0)
  print(plot_f05)
  
  invisible(list(
    plots = list(f1 = plot_f1, f0 = plot_f0, f05 = plot_f05),
    coords = list(
      f1 = list(Genotypes = G_scores_f1, Environments = E_scores_f1),
      f0 = list(Genotypes = G_scores_f0, Environments = E_scores_f0),
      f05 = list(Genotypes = G_scores_f05, Environments = E_scores_f05)
    )
  ))
}

# # 1. Create the test dataset matching Table 4.4 format
# wheat_trials <- data.frame(
#   Names = c("Ann", "Ari", "Aug", "Cas", "Del"),
#   BH93 = c(4.460, 4.417, 4.669, 4.732, 4.390),
#   EA93 = c(4.150, 4.771, 4.578, 4.745, 4.603),
#   HW93 = c(2.849, 2.912, 3.098, 3.375, 3.511),
#   ID93 = c(3.084, 3.506, 3.460, 3.904, 3.848),
#   KE93 = c(5.940, 5.699, 6.070, 6.224, 5.773),
#   NN93 = c(4.450, 5.152, 5.025, 5.340, 5.421),
#   OA93 = c(4.351, 4.956, 4.730, 4.226, 5.147),
#   RN93 = c(4.039, 4.386, 3.900, 4.893, 4.098),
#   WP93 = c(2.672, 2.938, 2.621, 3.451, 2.832)
# )
# 
# # 2. Call the function!
# GGE_Biplot_Analysis(indata = wheat_trials, gen_col = "Names")