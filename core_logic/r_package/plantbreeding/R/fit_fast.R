
library(lme4)
library(Matrix)


#' Fit Factor Analytic Selection Tools (FAST) using EBLUPs
#'
#' @description Fits a mixed model to calculate Empirical Best Linear Unbiased Predictors 
#' (EBLUPs) for Genotype and Genotype-by-Environment (GxE) effects. It then uses Singular 
#' Value Decomposition (SVD) on the centered EBLUP matrix to approximate a Factor Analytic 
#' (FA) model of order \code{k}. 
#' 
#' The function automatically detects whether the dataset is replicated or unreplicated 
#' and adjusts the \code{lme4} mixed model formula accordingly to extract the correct 
#' random effects.
#'
#' @param data A data frame containing the multi-environment trial data.
#' @param genotype_col Character. The name of the column containing genotype identifiers.
#' @param env_col Character. The name of the column containing environment identifiers.
#' @param yield_col Character. The name of the column containing the response variable (e.g., Yield).
#' @param k Integer. The number of latent factors to extract. Default is 1.
#'
#' @return A list containing:
#' \itemize{
#'   \item \code{FAST}: A data frame ranking genotypes by Overall Performance (OP) and Stability.
#'   \item \code{Genotype_Scores}: A matrix of genotype scores across the \code{k} factors.
#'   \item \code{Env_Loadings}: A matrix of environment loadings across the \code{k} factors.
#'   \item \code{Variance_Explained}: A data frame detailing individual and cumulative variance explained per factor.
#'   \item \code{GxE_Centered}: The centered matrix of EBLUPs used for the SVD.
#' }
#' 
#' @import lme4
#' @importFrom stats as.formula predict residuals
#' 
#' @export
#'
#' @examples
#' \dontrun{
#' # Assuming 'df' is your replicated breeding data
#' results <- fit_fast(
#'   data = df, 
#'   genotype_col = "Genotype", 
#'   env_col = "Env", 
#'   yield_col = "Yield", 
#'   k = 2
#' )
#' 
#' head(results$FAST)
#' }
fit_fast <- function(data, genotype_col, env_col, yield_col, k = 1) {
  
  # Ensure factors for mixed modeling
  data[[genotype_col]] <- as.factor(data[[genotype_col]])
  data[[env_col]] <- as.factor(data[[env_col]])
  
  # 1. Fit Mixed Model for EBLUPs
  # Check if data is replicated to determine the correct mixed model structure
  counts <- table(data[[genotype_col]], data[[env_col]])
  is_replicated <- max(counts) > 1
  
  if (is_replicated) {
    message("Replicated data detected. Fitting (1|Genotype) + (1|Genotype:Env)...")
    form <- as.formula(paste(yield_col, "~", env_col, "+ (1|", genotype_col, ") + (1|", genotype_col, ":", env_col, ")"))
  } else {
    message("Unreplicated data detected. Fitting (1|Genotype) and using residuals for GxE...")
    form <- as.formula(paste(yield_col, "~", env_col, "+ (1|", genotype_col, ")"))
  }
  
  model <- lmer(form, data = data)
  
  # 2. Construct Centered GxE Matrix from Random Effects
  # predict() gives Fixed + Random. predict(re.form=NA) gives Fixed only.
  # The difference isolates the EBLUPs (Genotype + GxE contribution).
  random_effs <- predict(model) - predict(model, re.form = NA)
  
  if (!is_replicated) {
    # If unreplicated, the GxE interaction is contained entirely within the residual
    random_effs <- random_effs + residuals(model)
  }
  
  data$Centered_EBLUP <- random_effs
  
  # Pivot into a GxE Matrix
  gxe_centered <- tapply(data$Centered_EBLUP, list(data[[genotype_col]], data[[env_col]]), mean)
  
  # Shrinkage naturally handles missing cells by pushing them to the expected mean (0)
  gxe_centered[is.na(gxe_centered)] <- 0
  
  message("Step 2: Singular Value Decomposition...")
  # 3. Singular Value Decomposition
  svd_decomp <- svd(gxe_centered)
  
  # Calculate Variance Explained
  var_raw <- svd_decomp$d^2
  var_percent <- (var_raw / sum(var_raw)) * 100
  var_table <- data.frame(
    Factor = paste0("Factor_", 1:length(var_raw)),
    Variance_Percent = round(var_percent, 2),
    Cumulative_Percent = round(cumsum(var_percent), 2)
  )
  
  # Limit k to the maximum available dimensions
  max_k <- min(nrow(gxe_centered), ncol(gxe_centered), k)
  if(k > max_k) {
    warning(paste("Requested k =", k, "exceeds dimensions. Setting k to", max_k))
    k <- max_k
  }
  
  # 4. Extract Genotype Scores and Environment Loadings for k factors
  D_sqrt <- diag(sqrt(svd_decomp$d[1:k]), nrow = k)
  
  geno_scores <- svd_decomp$u[, 1:k, drop = FALSE] %*% D_sqrt
  rownames(geno_scores) <- rownames(gxe_centered)
  colnames(geno_scores) <- paste0("Factor_", 1:k)
  
  env_loadings <- svd_decomp$v[, 1:k, drop = FALSE] %*% D_sqrt
  rownames(env_loadings) <- colnames(gxe_centered)
  colnames(env_loadings) <- paste0("Factor_", 1:k)
  
  # 5. Calculate FAST Metrics
  op_scores <- geno_scores[, 1]
  
  reconstructed_gk <- geno_scores %*% t(env_loadings)
  residuals_k <- gxe_centered - reconstructed_gk
  specific_var_k <- rowSums(residuals_k^2)
  stability_k <- 1 / (specific_var_k + 0.01)
  
  fast_df <- data.frame(
    Genotype = rownames(geno_scores),
    OP = as.numeric(op_scores),
    Stability = as.numeric(stability_k)
  )
  
  return(list(
    FAST = fast_df[order(-fast_df$OP), ],
    Genotype_Scores = geno_scores,
    Env_Loadings = env_loadings,
    Variance_Explained = var_table[1:max_k, ],
    GxE_Centered = gxe_centered
  ))
}

#' Simulate Multi-Environment Trial (MET) Data
#'
#' @description Generates a synthetic dataset for plant breeding trials with a 
#' latent Genotype x Environment (GxE) structure. The model assumes that yield 
#' is a function of environment means, a latent genotype performance factor 
#' scaled by environment sensitivity, and random noise.
#'
#' @param n_env Integer. The number of environments to simulate. Default is 10.
#' @param n_geno Integer. The number of genotypes to simulate. Default is 50.
#' @param seed Integer. Seed for reproducibility. Default is 123.
#'
#' @return A data frame in long format with columns: Genotype, Env, and Yield.
#' @export
#'
#' @examples
#' raw_data <- simulate_breeding_data(n_env = 5, n_geno = 20)
simulate_breeding_data <- function(n_env = 10, n_geno = 50, seed = 123) {
  set.seed(seed)
  envs <- paste0("E", 1:n_env)
  genos <- paste0("G", 1:n_geno)
  
  # Latent "true" performance and environment sensitivities
  true_op <- rnorm(n_geno, 0, 2)
  env_sensitivity <- runif(n_env, 0.5, 1.5)
  
  df <- expand.grid(Genotype = genos, Env = envs)
  
  # Model: Yield = Intercept + Env_Effect + (Sensitivity * Performance) + Noise
  df$Yield <- 50 + 
    rep(rnorm(n_env, 0, 5), each = n_geno) + 
    (rep(env_sensitivity, each = n_geno) * rep(true_op, n_env)) + 
    rnorm(nrow(df), 0, 1)
  
  return(df)
}

library(plotly)
library(magrittr)

#' Create Interactive FAST Visualizations (Includes EBLUPs)
#'
#' @param results List. Output from `fit_fast` containing SVD and EBLUP matrices.
#' @param type Character. "selection", "biplot", "scree", "loadings", "correlation", or "eblup".
#' @param top_n Integer. Number of top genotypes to label in the selection plot.
#' @param highlight Character vector. Genotypes to highlight.
#' @param digits Integer. Precision of numbers for hover and text labels.
#'
#' @return A plotly object.
#' @export
plot_fast_interactive <- function(results, type = "selection", top_n = 10, highlight = NULL, digits = 2) {
  library(plotly)
  
  # --- 1. Selection Plot ---
  if (type == "selection") {
    df <- results$FAST
    df$Rank <- rank(-df$OP)
    df$Status <- "Standard"
    if (!is.null(highlight)) {
      df$Status[df$Genotype %in% highlight] <- "Highlighted"
    }
    
    df$Display_Label <- ifelse(df$Rank <= top_n | df$Status == "Highlighted", 
                               as.character(df$Genotype), "")
    
    p_out <- plot_ly(df, x = ~OP, y = ~Stability, type = 'scatter', mode = 'markers+text',
                     text = ~Display_Label, textposition = "top right",
                     hoverinfo = 'text',
                     hovertext = ~paste("<b>Genotype:</b>", Genotype,
                                        "<br><b>OP:</b>", round(OP, digits),
                                        "<br><b>Stability:</b>", round(Stability, digits)),
                     color = ~Status, 
                     colors = c("Standard" = "#A9A9A980", "Highlighted" = "#FF8C00"),
                     marker = list(size = ~ifelse(Status == "Highlighted", 14, 10),
                                   line = list(color = "white", width = 1))) %>%
      layout(title = "Interactive FAST Selection Plot",
             xaxis = list(title = "Overall Performance (Factor 1)"),
             yaxis = list(title = "Stability Index (1 / Specific Variance)"),
             showlegend = TRUE)
  }
  
  # --- 2. Biplot ---
  else if (type == "biplot") {
    if (ncol(results$Genotype_Scores) < 2) stop("Biplot requires k >= 2 factors.")
    
    g_df <- as.data.frame(results$Genotype_Scores)
    g_df$Genotype <- rownames(g_df)
    g_df$Status <- "Standard"
    if (!is.null(highlight)) {
      g_df$Status[g_df$Genotype %in% highlight] <- "Highlighted"
    }
    
    e_df <- as.data.frame(results$Env_Loadings)
    e_df$Env <- rownames(e_df)
    
    p_out <- plot_ly() %>%
      add_trace(data = g_df, x = ~Factor_1, y = ~Factor_2, type = 'scatter', mode = 'markers+text',
                text = ~ifelse(Status == "Highlighted", Genotype, ""), textposition = "top right",
                hoverinfo = 'text',
                hovertext = ~paste("<b>Genotype:</b>", Genotype),
                color = ~Status, 
                colors = c("Standard" = "#A9A9A966", "Highlighted" = "#FF8C00"),
                marker = list(size = ~ifelse(Status == "Highlighted", 12, 8)),
                name = "Genotypes")
    
    for(i in 1:nrow(e_df)) {
      p_out <- p_out %>%
        add_segments(x = 0, xend = e_df$Factor_1[i], y = 0, yend = e_df$Factor_2[i],
                     line = list(color = 'steelblue', width = 2),
                     hoverinfo = 'text', text = paste("<b>Env:</b>", e_df$Env[i]),
                     showlegend = FALSE) %>%
        add_annotations(x = e_df$Factor_1[i], y = e_df$Factor_2[i], text = e_df$Env[i],
                        showarrow = FALSE, xanchor = 'left', yanchor = 'bottom',
                        font = list(color = 'steelblue', size = 12))
    }
    
    p_out <- p_out %>%
      layout(title = "Interactive GxE Biplot",
             xaxis = list(title = "Factor 1 (General Adaptation)", zeroline = TRUE, zerolinecolor = "gray"),
             yaxis = list(title = "Factor 2 (Specific Adaptation)", zeroline = TRUE, zerolinecolor = "gray"))
  }
  
  # --- 3. Scree Plot ---
  else if (type == "scree") {
    df <- results$Variance_Explained
    df$Factor <- factor(df$Factor, levels = df$Factor)
    
    p_out <- plot_ly(df, x = ~Factor) %>%
      add_bars(y = ~Variance_Percent, name = "Individual Variance",
               marker = list(color = "steelblue"),
               hoverinfo = "text",
               hovertext = ~paste("<b>", Factor, "</b><br>Variance:", Variance_Percent, "%")) %>%
      add_lines(y = ~Cumulative_Percent, name = "Cumulative Variance",
                line = list(color = "red", width = 2),
                hoverinfo = "text",
                hovertext = ~paste("Cumulative:", Cumulative_Percent, "%")) %>%
      add_markers(y = ~Cumulative_Percent, name = "Cumulative Markers",
                  marker = list(color = "red", size = 8), showlegend = FALSE, hoverinfo = "none") %>%
      layout(title = "Interactive Scree Plot: Variance Explained",
             xaxis = list(title = "Latent Factor"),
             yaxis = list(title = "Variance Percentage (%)", range = c(0, 105)),
             hovermode = "x unified")
  }
  
  # --- 4. Loadings Heatmap ---
  else if (type == "loadings") {
    mat <- as.matrix(results$Env_Loadings)
    mat_r <- round(mat, digits)
    p_out <- plot_ly(x = colnames(mat), y = rownames(mat), z = mat, type = "heatmap",
                     colorscale = "RdBu", reversescale = TRUE, zmin = -1, zmax = 1) %>%
      layout(title = "Interactive Environment Loadings")
    
    text_labels <- list()
    for (i in 1:nrow(mat)) {
      for (j in 1:ncol(mat)) {
        text_labels[[length(text_labels) + 1]] <- list(
          x = colnames(mat)[j], y = rownames(mat)[i], text = mat_r[i, j],
          showarrow = FALSE, font = list(color = ifelse(abs(mat[i, j]) > 0.5, "white", "black"))
        )
      }
    }
    p_out <- p_out %>% layout(annotations = text_labels)
  }
  
  # --- 5. Correlation Heatmap ---
  else if (type == "correlation") {
    Ge <- results$Env_Loadings %*% t(results$Env_Loadings)
    mat <- cov2cor(Ge)
    mat_r <- round(mat, digits)
    
    p_out <- plot_ly(x = colnames(mat), y = rownames(mat), z = mat, type = "heatmap",
                     colorscale = "RdBu", reversescale = TRUE, zmin = -1, zmax = 1) %>%
      layout(title = "Interactive Genetic Correlation Matrix")
    
    text_labels <- list()
    for (i in 1:nrow(mat)) {
      for (j in 1:ncol(mat)) {
        text_labels[[length(text_labels) + 1]] <- list(
          x = colnames(mat)[j], y = rownames(mat)[i], text = mat_r[i, j],
          showarrow = FALSE, font = list(color = ifelse(abs(mat[i, j]) > 0.5, "white", "black"))
        )
      }
    }
    p_out <- p_out %>% layout(annotations = text_labels)
  }
  
  # --- 6. EBLUPs Heatmap (NEW) ---
  else if (type == "eblup") {
    # Extract the centered EBLUP matrix (G + GxE effects)
    mat <- as.matrix(results$GxE_Centered)
    
    # We do not use zmin/zmax bounds of -1 to 1 here, as EBLUPs are in native trait units
    # Instead, we center the color scale at 0
    max_val <- max(abs(mat), na.rm = TRUE)
    
    p_out <- plot_ly(x = colnames(mat), y = rownames(mat), z = mat, type = "heatmap",
                     colorscale = "RdBu", reversescale = TRUE, 
                     zmin = -max_val, zmax = max_val,
                     hovertemplate = paste("<b>Environment:</b> %{x}<br>",
                                           "<b>Genotype:</b> %{y}<br>",
                                           "<b>EBLUP:</b> %{z:.3f}<extra></extra>")) %>%
      layout(title = "Centered Genotype & GxE EBLUPs",
             xaxis = list(title = "Environment"),
             yaxis = list(title = "Genotype", showticklabels = FALSE)) # Hide y-axis text to prevent clutter
  }
  
  else {
    stop("Invalid type. Choose 'selection', 'biplot', 'scree', 'loadings', 'correlation', or 'eblup'.")
  }
  
  return(p_out)
}
raw_data <- simulate_breeding_data(n_env = 12, n_geno = 60)

results <- fit_fast(
  data = raw_data, 
  genotype_col = "Genotype", 
  env_col = "Env", 
  yield_col = "Yield", k=4
)

# Preview Selections
print("Top Genotypes by Elemental OP:")
head(results$FAST)

# Define your checks or specific lines of interest
my_checks <- c("G1", "G15", "G42")

# 1. Selection Plot: View checks relative to the rest of the population
plot_fast_interactive (results, type = "selection", highlight = my_checks, top_n = 5)


# 2. Biplot: See if your checks are adapted to specific environments
plot_fast_interactive(results, type = "biplot", highlight = my_checks)

# 3. Selection View: Identify high-performing stable genotypes
plot_fast_interactive(results, type = "selection")

# 4. Pattern View: See which environments cluster together
plot_fast_interactive(results, type = "biplot")

# 5. Diagnostic View: How many factors do we really need?
plot_fast_interactive(results, type = "scree")

# 6. Visualize how each environment 'weights' against the factors
plot_fast_interactive(results, type = "loadings")

# 7. Visualize the network of environments to see which locations are redundant
plot_fast_interactive(results, type = "correlation")

# ############ Notes ########################################
# #The fit_fast function represents a highly robust, two-stage approach to analyzing Multi-Environment Trials (MET). By bridging mixed-model theory (EBLUPs) with multivariate dimension reduction (SVD),
#it provides a stable approximation of the Factor Analytic (FA) framework.
# Here is a practical breakdown of the methodology, why it works, and the critical
#"watch-outs" to keep in mind when deploying it in a live breeding program.
# 
# 1. Stage 1: The Mixed-Model Engine (Shrinkage & Imputation)
# Methodology: The function first analyzes the raw data using lme4 to fit a linear 
#mixed model. It dynamically checks if your trial has replications. If yes, it models (1|Genotype) + (1|Genotype:Env). If no, it relies on the residual variance for the interaction. It then extracts the Empirical Best Linear Unbiased Predictors (EBLUPs) specifically for the $G + G \times E$ components, effectively stripping away the environmental main effects (the fact that Location A just yields higher than Location B).
# Practical Value: * Shrinkage: Unlike simple arithmetic means, EBLUPs apply 
# "shrinkage." If a genotype performs exceptionally well in one location but is highly variable or poorly replicated, the model conservatively pulls its estimate closer to the population mean.
# Native Missing Data Handling: In plant breeding, missing data is a guarantee. In a centered EBLUP matrix, the expected value of an unobserved random effect is exactly $0$. The function safely assigns $0$ to missing $G \times E$ cells, allowing the downstream matrix math to run without failing.
# Watch-Outs:
#   Computational Bottleneck: While lme4 is fast for hundreds of lines, if you scale this to tens of thousands of lines across dozens of environments (e.g., early-stage yield trials), the mixed-model step can become a computational bottleneck.
# Extreme Unbalance: If a trial is so unbalanced that some genotypes only appear in one environment with no replication, the shrinkage might be so aggressive that the EBLUP approaches zero, masking a potentially true biological signal.

# 2. Stage 2: Singular Value Decomposition (Dimensionality Reduction)
# Methodology: The function takes the "clean," centered EBLUP matrix and decomposes it using Singular Value Decomposition (SVD). SVD mathematically rotates the data to find orthogonal (independent) axes—or "latent factors"—that explain the maximum amount of genetic variance.
# Practical Value:
#   Simplifying GxE: Instead of looking at a chaotic 150 $\times$ 20 interaction matrix, SVD condenses the noise. Factor 1 usually represents the dominant biological response of the entire trial network (e.g., general adaptation), while Factor 2 might represent a major geographical or stress split (e.g., drought vs. irrigated).
# Watch-Outs:
#   Non-Linear Responses: SVD assumes linear relationships. If your $G \times E$ is driven by a stark, non-linear threshold—like a sudden killing frost that wipes out exactly half the trial—SVD might struggle to isolate this into a single clean factor, instead smearing the variance across multiple dimensions.
# The "k" Limit: You cannot extract more factors ($k$) than the minimum of your genotypes or environments. If you only test in 3 environments, you can only ever have a maximum of $k=3$.

# 3. Stage 3: FAST Metrics (Selection Criteria)
# Methodology: The function translates the SVD outputs into actionable breeding metrics. 
# Overall Performance (OP) is extracted directly from the Genotype Scores on Factor 1. Stability is calculated by reconstructing the matrix using only your chosen $k$ factors, finding the residuals (the variance not explained by the factors), and taking the inverse.
# Practical Value:
#   Decoupled Metrics: It gives breeders two distinct numbers. You can filter for a baseline Stability (ensuring predictability) and then strictly rank by OP to make your final selections.
# Watch-Outs:
#   Redefining "Stability": In the FAST framework, a highly "stable" genotype is not one that yields the exact same amount everywhere. A stable genotype is one whose performance perfectly tracks the dominant latent factors of your network, meaning its behavior is highly predictable.
# The Danger of Factor 1 Over-Reliance: If you look at the Scree Plot and Factor 1 only explains 35% of the variance, do not select strictly on OP. Low variance on Factor 1 indicates massive crossover $G \times E$ (distinct mega-environments). Selecting solely on OP in this scenario means 
# you are selecting for a "jack-of-all-trades" that will likely be outcompeted by specifically adapted lines in every individual sub-region.
