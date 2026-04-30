import numpy as np
import pandas as pd
import math

def simulate_field_trial(
    n_locs: int = 3,
    n_traits: int = 2,
    n_entries: int = 50,
    n_reps: int = 2,
    missing_prop: float = 0.05,
    G_cov: np.ndarray = None,
    E_corr: np.ndarray = None,
    loc_res_vars: list = None,
    rho_row: float = 0.7,
    rho_range: float = 0.7,
    rows: int = 10,
    ranges: int = 10
) -> pd.DataFrame:
    """
    Simulates multi-environment trial (MET) data for multiple correlated traits.
    It accounts for genetic correlations between traits, environmental correlations, 
    heterogeneous residual variances, and spatial autocorrelation (AR1 x AR1).

    Args:
        n_locs: Number of locations (environments).
        n_traits: Number of traits to simulate.
        n_entries: Number of genotypes/treatments.
        n_reps: Number of replications per location.
        missing_prop: Proportion of missing data points (0-1).
        G_cov: Genetic covariance between traits (n_traits x n_traits).
        E_corr: Correlation matrix between environments (n_locs x n_locs).
        loc_res_vars: Residual variance for each location (length = n_locs).
        rho_row: Autocorrelation coefficient for rows (0-1).
        rho_range: Autocorrelation coefficient for ranges (0-1).
        rows: Number of rows in the field grid at each location.
        ranges: Number of ranges in the field grid at each location.

    Returns:
        pd.DataFrame: A data frame in long format containing spatial coordinates, 
                      Entry IDs, and simulated trait values.
    """
    
    # Handle mutable default arguments
    if G_cov is None:
        G_cov = np.array([[1.0, 0.6], 
                          [0.6, 1.2]])
    if E_corr is None:
        E_corr = np.eye(n_locs)
    if loc_res_vars is None:
        loc_res_vars = [0.2, 0.5, 0.8]
        
    # --- 1. Structural Setup ---
    df_list = []
    
    # Helper: Generate AR1 correlation matrix (R_h = rho^|i-j|)
    def ar1_mat(n, rho):
        times = np.arange(n)
        # Create an absolute distance matrix
        H = np.abs(times[:, None] - times[None, :])
        return rho ** H

    # --- 2. Genetic Effects (G x E) ---
    # Simulate genotype effects correlated across traits and environments
    # Sigma_G = E_corr %x% G_cov (Kronecker Product)
    Sigma_G = np.kron(E_corr, G_cov)
    mu_G = np.zeros(n_traits * n_locs)
    
    # Generate multivariate normal distribution for genetic effects
    g_effects_raw = np.random.multivariate_normal(mean=mu_G, cov=Sigma_G, size=n_entries)
    
    # Create Genotype labels and map to their generated values
    genotypes = [f"G{i+1}" for i in range(n_entries)]
    g_effect_dict = {genotypes[i]: g_effects_raw[i, :] for i in range(n_entries)}

    # --- 3. Location-Specific Simulation ---
    for l in range(n_locs):
        
        # Generate spatial grid (Match R's expand.grid where Row varies fastest)
        row_arr = np.arange(1, rows + 1)
        range_arr = np.arange(1, ranges + 1)
        grid = [(r, rg) for rg in range_arr for r in row_arr]
        
        loc_df = pd.DataFrame(grid, columns=['Row', 'Range'])
        loc_df['Loc'] = l + 1
        loc_df['Plot'] = np.arange(1, len(loc_df) + 1)
        
        # Assign Genotypes (Randomized)
        reps_needed = math.ceil(len(loc_df) / n_entries)
        repeated_entries = (genotypes * reps_needed)[:len(loc_df)]
        loc_df['Entry'] = np.random.choice(repeated_entries, size=len(loc_df), replace=False)
        
        # Assign Replication/Block (Simple blocking based on layout)
        loc_df['Rep'] = (loc_df['Plot'] % n_reps) + 1
        
        # Generate Spatial Residuals (AR1 x AR1)
        # The spatial surface is specific to the location's variance
        R_spatial = loc_res_vars[l] * np.kron(ar1_mat(ranges, rho_range), 
                                              ar1_mat(rows, rho_row))
        
        for t in range(n_traits):
            trait_name = f"Trait_{t+1}"
            
            # Map genetic effects
            loc_idx = (l * n_traits) + t
            g_vals = np.array([g_effect_dict[entry][loc_idx] for entry in loc_df['Entry']])
            
            # Combine components: Y = G + Error_spatial
            spatial_noise = np.random.multivariate_normal(mean=np.zeros(len(loc_df)), cov=R_spatial)
            loc_df[trait_name] = g_vals + spatial_noise
            
            # Apply Missingness
            if missing_prop > 0:
                num_missing = int(np.floor(missing_prop * len(loc_df)))
                mask = np.random.choice(loc_df.index, size=num_missing, replace=False)
                loc_df.loc[mask, trait_name] = np.nan
                
        df_list.append(loc_df)

    # Combine all locations into a single DataFrame
    return pd.concat(df_list, ignore_index=True)

##import seaborn as sns
##import matplotlib.pyplot as plt
##
### Run the simulation
##trial_results = simulate_field_trial(n_locs=3)
##
### Filter for Location 1
##loc1_data = trial_results[trial_results['Loc'] == 1]
##
### Pivot the data so Rows and Ranges become a 2D matrix for the heatmap
##heatmap_data = loc1_data.pivot(index='Range', columns='Row', values='Trait_1')
##
### Create the spatial gradient plot
##plt.figure(figsize=(8, 6))
##sns.heatmap(heatmap_data, cmap="coolwarm", center=0, cbar_kws={'label': 'Trait_1'})
##
##plt.title("Spatial Gradient Simulation (Location 1)")
##plt.gca().invert_yaxis() # Invert Y axis to mimic standard field row/range layouts visually
##plt.tight_layout()
##plt.show()
