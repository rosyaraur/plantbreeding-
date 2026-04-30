import pandas as pd
import numpy as np
import statsmodels.api as sm
from statsmodels.formula.api import ols
import matplotlib.pyplot as plt

def aug_rowcol(dataframe, rows, columns, genotypes, yield_col):
    """
    Analysis of an augmented random row and column design.
    Adjusts un-replicated test lines based on replicated check varieties 
    while safely handling missing (NaN) data.

    Args:
        dataframe (pd.DataFrame): Dataframe containing the data.
        rows (str): Column name for rows.
        columns (str): Column name for columns.
        genotypes (str): Column name for treatments/genotypes.
        yield_col (str): Column name for the numeric response variable (e.g., yield).

    Returns:
        dict: A dictionary containing:
            - 'ANOVA': Analysis of Variance Table for the checks.
            - 'Adjustment': Dataframe with original and adjusted phenotypic values.
            - 'se_check': Standard error of the difference between check means.
            - 'se_within': Standard error of difference in adjusted yield (same row/col).
            - 'se_diff': Standard error of difference between varieties (different rows/blocks).
            - 'se_geno_check': Standard error of difference between a variety and a check mean.
    """
    
    # 1. Safely extract columns and ensure correct data types
    # Rename internally to avoid statsmodels formula errors with spaces/special characters
    df = dataframe[[rows, columns, genotypes, yield_col]].copy()
    df.rename(columns={rows: 'rows', columns: 'columns', 
                       genotypes: 'genotypes', yield_col: 'yield_val'}, inplace=True)
    
    # Force categorical variables to string and response to numeric
    df['rows'] = df['rows'].astype(str)
    df['columns'] = df['columns'].astype(str)
    df['genotypes'] = df['genotypes'].astype(str)
    df['yield_val'] = pd.to_numeric(df['yield_val'], errors='coerce')
    
    # 2. Identify checks (must have VALID/NON-NA data spanning all rows)
    df_valid = df.dropna(subset=['yield_val'])
    num_rows = df['rows'].nunique()
    
    geno_counts = df_valid['genotypes'].value_counts()
    checks = geno_counts[geno_counts == num_rows].index.tolist()
    
    if not checks:
        raise ValueError("No check genotypes found with valid (non-NaN) data spanning all rows. Check your data structure.")
        
    # Subset checks for modeling
    checks_df = df[df['genotypes'].isin(checks)].copy()
    
    # 3. Model and ANOVA on checks
    # statsmodels automatically drops NaNs when fitting the model
    model = ols('yield_val ~ C(genotypes) + C(rows) + C(columns)', data=checks_df).fit()
    
    # Typ=1 matches standard R anova() sequential sums of squares
    anova_table = sm.stats.anova_lm(model, typ=1) 
    
    # 4. Calculate adjustment factors (ignoring NAs)
    # Row adjustments
    row_means = checks_df.dropna(subset=['yield_val']).groupby('rows')['yield_val'].mean().reset_index()
    row_means['row_adj'] = row_means['yield_val'] - row_means['yield_val'].mean()
    
    # Column adjustments
    col_means = checks_df.dropna(subset=['yield_val']).groupby('columns')['yield_val'].mean().reset_index()
    col_means['col_adj'] = col_means['yield_val'] - col_means['yield_val'].mean()
    
    # 5. Apply adjustments to the ENTIRE dataset
    df_adj = df.merge(row_means[['rows', 'row_adj']], on='rows', how='left')
    df_adj = df_adj.merge(col_means[['columns', 'col_adj']], on='columns', how='left')
    
    # Calculate adjusted yield
    df_adj['yield_adj'] = df_adj['yield_val'] - df_adj['row_adj'] - df_adj['col_adj']
    
    # Clean up dataframe for output, restoring the original response column name
    df_adj = df_adj[['genotypes', 'rows', 'columns', 'yield_val', 'yield_adj']]
    df_adj.rename(columns={'yield_val': yield_col}, inplace=True)
    
    # 6. Graphical Output (Handling NAs safely)
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # Plot 1: Residuals of checks
    checks_valid = checks_df.dropna(subset=['yield_val']).copy()
    checks_valid['residuals'] = model.resid
    
    axes[0].scatter(checks_valid['yield_val'], checks_valid['residuals'], color='darkgray', marker='o')
    for i, row_data in checks_valid.iterrows():
        axes[0].text(row_data['yield_val'], row_data['residuals'] + 0.02, 
                     row_data['genotypes'], color='red', fontsize=8, ha='center')
        
    axes[0].axhline(0, color='darkblue', linestyle='--')
    axes[0].set_xlabel('Trait Yield')
    axes[0].set_ylabel('Residuals')
    axes[0].set_title('Residual Plot of Checks')
    
    # Plot 2: Observed vs Adjusted
    adj_valid = df_adj.dropna(subset=[yield_col, 'yield_adj'])
    axes[1].scatter(adj_valid[yield_col], adj_valid['yield_adj'], color='lightseagreen', marker='o')
    
    # 1:1 Line
    min_val = min(adj_valid[yield_col].min(), adj_valid['yield_adj'].min())
    max_val = max(adj_valid[yield_col].max(), adj_valid['yield_adj'].max())
    axes[1].plot([min_val, max_val], [min_val, max_val], color='red', linestyle='-')
    
    # Segments dropping to the 1:1 line equivalent
    for i, row_data in adj_valid.iterrows():
        axes[1].plot([row_data[yield_col], row_data[yield_col]], 
                     [row_data['yield_adj'], row_data[yield_col]], 
                     color='blue', linestyle='--', alpha=0.5)
        
    axes[1].set_xlabel('Observed Yield')
    axes[1].set_ylabel('Adjusted Yield')
    axes[1].set_title('Observed vs Adjusted')
    axes[1].grid(color='cornsilk', linestyle=':', linewidth=1.5)
    axes[1].set_aspect('equal', adjustable='box')
    
    plt.tight_layout()
    plt.show()
    
    # 7. Standard Errors
    # Extract values safely based on statsmodels typical output names
    try:
        mse = anova_table.loc['Residual', 'mean_sq']
    except KeyError:
        # Fallback if the index name varies slightly by statsmodels version
        mse = model.mse_resid
        
    r = anova_table.loc['C(rows)', 'df'] + 1
    
    se_check = np.sqrt(2 * mse / r)
    se_within = np.sqrt(2 * mse + (2 * mse) / r)
    se_diff = np.sqrt(2 * mse + (4 * mse) / r)
    se_gcheck = np.sqrt(mse + (3 * mse) / r - (2 * mse) / (r**2))
    
    print("\n--- Standard Errors for Comparisons ---")
    print(f"Difference between check means: {se_check:.4f}")
    print(f"Difference (adj yield) of two varieties in same row/col: {se_within:.4f}")
    print(f"Difference between two varieties in different rows/blocks: {se_diff:.4f}")
    print(f"Difference between two varieties and a check mean: {se_gcheck:.4f}\n")
    
    # 8. Return Dictionary
    results = {
        'ANOVA': anova_table,
        'Adjustment': df_adj,
        'se_check': se_check,
        'se_within': se_within,
        'se_diff': se_diff,
        'se_geno_check': se_gcheck
    }
    
    return results
