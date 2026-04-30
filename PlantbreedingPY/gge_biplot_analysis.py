import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

def gge_biplot_analysis(indata, gen_col, draw_circles=True):
    """
    GGE Biplot Analysis with Concentric Circles
    
    Replicates a standard SAS macro/R script for GGE Biplot Analysis.
    It performs Singular Value Decomposition (SVD) on environment-centered data
    and generates three scatter plots based on different scaling methods.
    Features publication-style concentric circles for vector magnitude assessment.
    
    Parameters:
    -----------
    indata : pandas.DataFrame
        A dataframe containing the mean yields. It must contain a column 
        for Genotype labels and numeric columns representing Environments.
    gen_col : str
        A string specifying the name of the column in `indata` that contains 
        the Genotype labels.
    draw_circles : bool, default=True
        If TRUE, draws concentric circles centered at the origin to aid in 
        assessing distances and vector lengths.
        
    Returns:
    --------
    dict
        A dictionary containing the matplotlib figures ('plots') and the 
        calculated PCA coordinates ('coords').
    """
    
    # --------------------------------------------------------- 
    # 1. SVD and Partitioning
    # --------------------------------------------------------- 
    genotypes = indata[gen_col].values
    
    # Select only numeric columns for environments
    numeric_cols = indata.select_dtypes(include=[np.number]).columns
    environments = numeric_cols.tolist()
    
    y_raw_matrix = indata[numeric_cols].values
    
    # Environment-centering (column means)
    col_means = y_raw_matrix.mean(axis=0)
    y_centered = y_raw_matrix - col_means
    
    # SVD
    # Note: numpy returns U, S, V^T. R returns U, d, V. 
    # Therefore, we transpose Vt to get V.
    U, s, Vt = np.linalg.svd(y_centered, full_matrices=False)
    V = Vt.T
    
    U2 = U[:, :2]
    V2 = V[:, :2]
    d2 = s[:2]
    
    Lambda = np.diag(d2)
    Lambda_half = np.diag(np.sqrt(d2))
    
    # Scores
    G_scores_f1 = U2 @ Lambda
    E_scores_f1 = V2
    
    G_scores_f0 = U2
    E_scores_f0 = V2 @ Lambda
    
    G_scores_f05 = U2 @ Lambda_half
    E_scores_f05 = V2 @ Lambda_half
    
    # --------------------------------------------------------- 
    # 2. Helper Function for Plotting
    # --------------------------------------------------------- 
    def generate_biplot(g_scores, e_scores, title_text):
        fig, ax = plt.subplots(figsize=(8, 8))
        
        # Calculate max distance for scaling limits and circles
        g_dist = np.linalg.norm(g_scores, axis=1)
        e_dist = np.linalg.norm(e_scores, axis=1)
        max_dist = max(np.max(g_dist), np.max(e_dist))
        
        # Optional: Generate Concentric Circles
        if draw_circles:
            radii = np.linspace(max_dist * 0.25, max_dist, 4)
            for r in radii:
                circle = plt.Circle((0, 0), r, color="gray", fill=False, 
                                    linestyle="dotted", linewidth=1.2, alpha=0.7)
                ax.add_patch(circle)
                
        # Draw Origin Axes
        ax.axhline(0, color="gray", linestyle="--", alpha=0.7)
        ax.axvline(0, color="gray", linestyle="--", alpha=0.7)
        
        # Plot Environment Vectors and Labels
        for i, env in enumerate(environments):
            x, y = e_scores[i, 0], e_scores[i, 1]
            # Arrow
            ax.annotate("", xy=(x, y), xytext=(0, 0),
                        arrowprops=dict(arrowstyle="-|>", color="blue", lw=1.5, alpha=0.7))
            
            # Label (dynamic outward adjustment based on quadrant)
            ha_val = "left" if x > 0 else "right"
            va_val = "bottom" if y > 0 else "top"
            offset_x = np.sign(x) * (max_dist * 0.02)
            offset_y = np.sign(y) * (max_dist * 0.02)
            
            ax.text(x + offset_x, y + offset_y, env, color="blue", 
                    fontweight="bold", ha=ha_val, va=va_val)
            
        # Plot Genotype Points and Labels
        for i, gen in enumerate(genotypes):
            x, y = g_scores[i, 0], g_scores[i, 1]
            ax.scatter(x, y, color="red", s=50, zorder=3)
            # Position label slightly below the point
            ax.text(x, y - (max_dist * 0.025), gen, color="red", 
                    ha="center", va="top", zorder=4)
            
        # Formatting
        ax.set_aspect('equal', adjustable='datalim') # Force 1:1 aspect ratio
        ax.set_title(title_text, fontweight="bold", pad=15)
        ax.set_xlabel("PC1")
        ax.set_ylabel("PC2")
        
        # Minimal theme grid
        ax.grid(True, which='major', color='whitesmoke', linestyle='-')
        ax.set_axisbelow(True) # Put grid behind data
        
        # Add some padding to limits so labels don't get cut off
        padding = max_dist * 0.1
        ax.set_xlim(-max_dist - padding, max_dist + padding)
        ax.set_ylim(-max_dist - padding, max_dist + padding)
        
        return fig

    # --------------------------------------------------------- 
    # 3. Generate and Print Plots
    # --------------------------------------------------------- 
    plot_f1 = generate_biplot(G_scores_f1, E_scores_f1, "Genotype-Focused GGE Biplot (f = 1)")
    plot_f0 = generate_biplot(G_scores_f0, E_scores_f0, "Environment-Focused GGE Biplot (f = 0)")
    plot_f05 = generate_biplot(G_scores_f05, E_scores_f05, "Symmetrical GGE Biplot (f = 0.5)")
    
    plt.show()
    
    return {
        "plots": {"f1": plot_f1, "f0": plot_f0, "f05": plot_f05},
        "coords": {
            "f1": {"Genotypes": G_scores_f1, "Environments": E_scores_f1},
            "f0": {"Genotypes": G_scores_f0, "Environments": E_scores_f0},
            "f05": {"Genotypes": G_scores_f05, "Environments": E_scores_f05}
        }
    }

## =====================================================================
## Execution / Example Usage
## =====================================================================
##if __name__ == "__main__":
##    # 1. Create the test dataset matching Table 4.4 format
##    wheat_trials = pd.DataFrame({
##        "Names": ["Ann", "Ari", "Aug", "Cas", "Del"],
##        "BH93": [4.460, 4.417, 4.669, 4.732, 4.390],
##        "EA93": [4.150, 4.771, 4.578, 4.745, 4.603],
##        "HW93": [2.849, 2.912, 3.098, 3.375, 3.511],
##        "ID93": [3.084, 3.506, 3.460, 3.904, 3.848],
##        "KE93": [5.940, 5.699, 6.070, 6.224, 5.773],
##        "NN93": [4.450, 5.152, 5.025, 5.340, 5.421],
##        "OA93": [4.351, 4.956, 4.730, 4.226, 5.147],
##        "RN93": [4.039, 4.386, 3.900, 4.893, 4.098],
##        "WP93": [2.672, 2.938, 2.621, 3.451, 2.832]
##    })
##
##    # 2. Call the function
##    results = gge_biplot_analysis(indata=wheat_trials, gen_col="Names")
