#' Classify Germplasm using Genomic Marker Data
#'
#' This function performs germplasm classification using unsupervised (PCA, K-means, Hierarchical)
#' or supervised (Random Forest) methods. It automatically handles the transposition of genomic 
#' data where markers are rows and accessions are columns.
#'
#' @param geno_data A data frame containing marker data. Expected format: first 3 columns 
#'   are metadata (ID, Chr, Pos), followed by accession columns with numeric genotypes.
#' @param method Character. Choice of "pca", "kmeans", "hclust", or "randomforest".
#' @param k Integer. The number of clusters to find (used for kmeans and hclust).
#' @param labels Factor/Vector. Known classification labels (required only for "randomforest").
#' @param plot Logical. If TRUE, generates a visualization appropriate for the method.
#'
#' @return Depending on the method: a PCA object, a kmeans object, an hclust object, 
#'   or a randomForest object.
#' 
#' @examples
#' # pca_res <- classify_germplasm(rice_data, method = "pca")
#' # km_res  <- classify_germplasm(rice_data, method = "kmeans", k = 3)
#'
library(ggplot2)
library(factoextra)

classify_germplasm <- function(geno_data, method = "pca", k = 3, labels = NULL, plot = TRUE) {
  
  # --- 1. Preprocessing ---
  # Remove metadata columns (id, chr, position)
  marker_data <- geno_data[, -c(1:3)]
  
  # Transpose: Algorithms require Accessions as rows and Markers as columns
  t_data <- t(marker_data)
  t_data <- apply(t_data, 2, as.numeric)
  rownames(t_data) <- colnames(marker_data)
  
  # --- 2. Method Logic & Visualization ---
  
  if (method == "pca") {
    pca_res <- prcomp(t_data, center = TRUE, scale. = FALSE)
    if (plot) {
      p <- fviz_pca_ind(pca_res, col.ind = "cos2", 
                        gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                        repel = TRUE, title = "PCA - Genetic Structure")
      print(p)
    }
    return(pca_res)
    
  } else if (method == "kmeans") {
    set.seed(42)
    km_res <- kmeans(t_data, centers = k, nstart = 25)
    if (plot) {
      p <- fviz_cluster(km_res, data = t_data, palette = "jco",
                        ellipse.type = "convex", star.plot = TRUE, 
                        repel = TRUE, main = paste("K-means (k =", k, ")"))
      print(p)
    }
    return(km_res)
    
  } else if (method == "hclust") {
    dist_matrix <- dist(t_data, method = "euclidean")
    hc_res <- hclust(dist_matrix, method = "ward.D2")
    if (plot) {
      p <- fviz_dend(hc_res, k = k, cex = 0.5, k_colors = "jco",
                     type = "phylogenic", repel = TRUE,
                     main = "Hierarchical Clustering (Phylogenic)")
      print(p)
    }
    return(hc_res)
    
  } else if (method == "randomforest") {
    if (is.null(labels)) stop("Labels are required for supervised Random Forest.")
    if (!requireNamespace("randomForest", quietly = TRUE)) install.packages("randomForest")
    library(randomForest)
    
    # Ensure labels are a factor and have more than 1 level
    labels_factor <- as.factor(labels)
    if (length(levels(labels_factor)) < 2) {
      stop("Random Forest requires at least 2 distinct classes in 'labels'.")
    }
    
    message("Training Random Forest... this may take a moment.")
    rf_res <- randomForest(x = t_data, y = labels_factor, ntree = 500, importance = TRUE)
    
    if (plot) {
      # Safely determine how many variables to plot (max 20, or the number of markers available)
      num_markers <- ncol(t_data)
      n_plot_vars <- min(20, num_markers)
      
      par(mfrow = c(1, 2)) # Put plots side-by-side
      
      # Plot 1: Standard plot for error convergence
      plot(rf_res, main = "RF Error Rate")
      
      # Plot 2: Variable importance plot (with safety check)
      if (n_plot_vars > 0) {
        varImpPlot(rf_res, n.var = n_plot_vars, main = paste("Top", n_plot_vars, "Diagnostic Markers"))
      }
      
      par(mfrow = c(1, 1)) # Reset plot layout
    }
    return(rf_res)
    
  } else {
    stop("Method not recognized. Choose 'pca', 'kmeans', 'hclust', or 'randomforest'.")
  }
}

# load("/Users/umeshrosyara/Documents/githubdir/plantbreeding-/package1.0/plantbreeding/data/rice44K.rda")
# riceLines = rice44K$geno[1:10,1:40]
# subpop = rice44K$disp$`Sub-population`[1:37]
# # 1. Principal Component Analysis (PCA)
# pca_results <- classify_germplasm(riceLines, method = "pca")
# 
# # 2. Hierarchical Clustering
# # Let's say you want to split them into 4 distinct subpopulations
# hc_results <- classify_germplasm(riceLines, method = "hclust", k = 4)
# 
# 
# #3. K-Means Clustering
# # A fast algorithm that partitions your accessions into k groups based on their marker profiles.
# km_results <- classify_germplasm(riceLines, method = "kmeans", k = 3)
# 
# 
# # 4. Random Forest (Supervised)
# # Example mock labels (you would replace this with your actual trait/subpop data)
# # Needs to be the same length as the number of accessions (columns - 3)
# my_labels <- subpop
# rf_model <- classify_germplasm(riceLines, method = "randomforest", labels = my_labels)
# 
# # View the model's accuracy
# print(rf_model)