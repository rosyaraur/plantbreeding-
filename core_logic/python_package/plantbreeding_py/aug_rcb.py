import pandas as pd
import numpy as np
import statsmodels.api as sm
from statsmodels.formula.api import ols
import matplotlib.pyplot as plt

def aug_rcb(dataframe: pd.DataFrame, genotypes: str, block: str, yvar: str, plot: bool = True, verbose: bool = True) -> dict:
    """
    Implements an analysis of an augmented randomized complete block design (ARCBD).
    
    The function assumes that checks (controls) are replicated *r* times, making complete 
    blocks, while other treatments (new entries) are unreplicated. The checks are completely 
    randomized making complete blocks, and the remaining experimental units are completely 
    randomized with the unreplicated new treatments.
    
    Parameters:
    -----------
    dataframe : pd.DataFrame
        A dataframe object containing at least the variables for genotypes, blocks, and the response variable.
    genotypes : str
        The name of the column consisting of genotypes or treatments.
    block : str
        The name of the column consisting of blocks.
    yvar : str
        The name of the response variable column.
    plot : bool, default True
        If True, generates matplotlib plots comparing the observed and adjusted values.
    verbose : bool, default True
        If True, prints standard errors and a preview of the adjusted dataset to the console.
        
    Returns:
    --------
    dict
        A dictionary consisting of the following items:
        - 'anova': Analysis of variance dataframe (ANOVA table) based on the checks.
        - 'adjusted_values': A dataframe containing the raw observed and block-adjusted values.
        - 'se_check': Standard error of the difference between two check means.
        - 'se_within': Standard error of the difference between adjusted yields of two entries in the same block.
        - 'se_diff': Standard error of the difference between adjusted yields of two entries in different blocks.
        - 'se_geno': Standard error of the difference between an adjusted entry and a check mean.
    """
    
    # 1. Format inputs and prep data (Ensure categorical behavior)
    df = dataframe.copy()
    df[block] = df[block].astype(str)
    df[genotypes] = df[genotypes].astype(str)
    
    # 2. Identify Checks (replicated in all blocks) vs New Genotypes (unreplicated)
    n_blocks = df[block].nunique()
    geno_freq = df[genotypes].value_counts()
    
    checks = geno_freq[geno_freq == n_blocks].index.tolist()
    tests = geno_freq[geno_freq < n_blocks].index.tolist()
    
    if not checks:
        raise ValueError("No checks found. Checks must be present in all blocks.")
        
    check_data = df[df[genotypes].isin(checks)].copy()
    test_data = df[df[genotypes].isin(tests)].copy()
    
    # 3. Fit Linear Model and ANOVA
    # C() forces statsmodels to treat the variables as categorical (factors)
    formula_str = f"{yvar} ~ C({genotypes}) + C({block})"
    model1 = ols(formula_str, data=check_data).fit()
    
    # Type I ANOVA to match R's default anova() function
    amodel = sm.stats.anova_lm(model1, typ=1) 
    
    # Clean up the ANOVA table indexing to mimic R
    idx_map = {
        f'C({genotypes})': 'Genotypes (Checks)',
        f'C({block})': 'Block'
    }
    amodel.rename(index=idx_map, inplace=True)
    
    # 4. Calculate Block Adjustments
    # Block effect = Block Mean - Grand Mean of Checks
    block_means = check_data.groupby(block)[yvar].mean().reset_index()
    grand_mean = block_means[yvar].mean()
    block_means['block_effect'] = block_means[yvar] - grand_mean
    
    # Adjust the unreplicated test genotypes
    test_data = test_data.merge(block_means[[block, 'block_effect']], on=block, how='left')
    test_data['yvar_adj'] = test_data[yvar] - test_data['block_effect']
    
    # 5. Standard Error Calculations
    c = len(checks)
    b = n_blocks
    MSE = amodel.loc['Residual', 'mean_sq']
    
    se_check  = np.sqrt(2 * MSE / b)
    se_within = np.sqrt(2 * MSE)
    se_diff   = np.sqrt(2 * MSE * (1 + 1 / c))
    se_geno   = np.sqrt(MSE * (b + 1) * (c + 1) / (b * c))
    
    # 6. Console Output (Controlled by 'verbose')
    if verbose:
        print("\n--- Augmented RCB Analysis ---\n")
        print("Phenotypes and adjusted values:")
        print(test_data.head()) 
        print("\nStandard Errors for Comparisons:")
        print(f"  Difference between check means:                           {se_check:.4f}")
        print(f"  Difference between two test varieties in same block:      {se_within:.4f}")
        print(f"  Difference between two test varieties in diff blocks:     {se_diff:.4f}")
        print(f"  Difference between a test variety and a check mean:       {se_geno:.4f}\n")
        
    # 7. Visualization (Controlled by 'plot')
    if plot:
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 6))
        
        # Helper function to plot y=x identity lines safely spanning the data points
        def add_identity_line(ax, color="red", linestyle="--"):
            lims = [
                np.min([ax.get_xlim(), ax.get_ylim()]),
                np.max([ax.get_xlim(), ax.get_ylim()]),
            ]
            ax.plot(lims, lims, color=color, linestyle=linestyle, zorder=0)
            ax.set_xlim
