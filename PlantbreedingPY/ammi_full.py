import pandas as pd
import numpy as np
import statsmodels.api as sm
from statsmodels.formula.api import ols
from scipy.stats import f

def ammi_full(dataframe, environment, genotype, replication, yvar):
    """
    Implements Additive Main Effects and Multiplicative Interaction (AMMI) 
    analysis for multiple environment replicated data.
    
    Parameters:
    -----------
    dataframe : pandas.DataFrame
        The dataset containing the trial data.
    environment : str
        Name of environment (location or year) variable.
    genotype : str
        Name of genotype variable.
    replication : str
        Name of replication variable.
    yvar : str
        Name of the Y (response) variable to be used in the analysis.
        
    Returns:
    --------
    dict
        A dictionary containing the means matrix, ANOVA table, error statistics,
        GEI matrix, AMMI analysis table, PC scores, and SVD components.
    """
    # 1. Standardize and clean input dataframe
    df = pd.DataFrame({
        'environment': dataframe[environment].astype(str),
        'genotype': dataframe[genotype].astype(str),
        'replication': dataframe[replication].astype(str),
        'Y': dataframe[yvar]
    })
    
    print(f"\nAMMI Analysis for variable: {yvar}")
    print("........................................")
    
    nenv = df['environment'].nunique()
    ngen = df['genotype'].nunique()
    nrep = df['replication'].nunique()
    minM = min(ngen, nenv)
    
    # 2. Ordinary ANOVA Model
    # Using Type 1 ANOVA sequentially: environment -> env:rep -> genotype -> env:gen
    formula = 'Y ~ C(environment) + C(environment):C(replication) + C(genotype) + C(environment):C(genotype)'
    model = ols(formula, data=df).fit()
    anmm = sm.stats.anova_lm(model, typ=1)
    
    # Rename terms to match R output clarity
    rep_env_name = 'C(environment):C(replication)'
    env_name = 'C(environment)'
    
    if rep_env_name in anmm.index and env_name in anmm.index:
        anmm.rename(index={rep_env_name: 'replication(environment)'}, inplace=True)
        
        # Custom F-test for Environment using replication(environment) as the error term
        anmm.loc[env_name, 'F'] = anmm.loc[env_name, 'mean_sq'] / anmm.loc['replication(environment)', 'mean_sq']
        anmm.loc[env_name, 'PR(>F)'] = f.sf(
            anmm.loc[env_name, 'F'], 
            anmm.loc[env_name, 'df'], 
            anmm.loc['replication(environment)', 'df']
        )
        
    print(anmm)
    
    DFE = model.df_resid
    MSE = model.ssr / DFE
    medy = df['Y'].mean()
    CV = np.sqrt(MSE) * 100 / medy
    errorlist = {'DFE': DFE, 'MSE': MSE, 'mean_Y': medy, 'CV': CV}
    
    # 3. Calculate Means & Impute Missing Data
    # Unstacked matrix (Genotypes as rows, Environments as columns)
    avdm0 = df.groupby(['genotype', 'environment'])['Y'].mean().unstack()
    print(f"\nMeans for: {yvar}")
    print(avdm0.round(2))
    
    # Flat representation of means
    avdm = df.groupby(['genotype', 'environment'])['Y'].mean().reset_index()
    
    # Missing value imputation using a simple main effects model
    if avdm['Y'].isna().any():
        model2 = ols('Y ~ C(genotype) + C(environment)', data=avdm.dropna()).fit()
        na_idx = avdm['Y'].isna()
        avdm.loc[na_idx, 'Y'] = model2.predict(avdm.loc[na_idx])
        
    # 4. Main effects model to extract GEI Residuals
    model1 = ols('Y ~ C(environment) + C(genotype)', data=avdm).fit()
    avdm['RESIDUAL'] = model1.resid
    
    # Reshape residuals directly into a matrix for SVD
    res_mat = avdm.pivot(index='genotype', columns='environment', values='RESIDUAL')
    
    # 5. Singular Value Decomposition (SVD)
    # Note: numpy's svd returns U, S, and V^T (transposed V compared to R)
    U, S, Vh = np.linalg.svd(res_mat, full_matrices=False)
    L = S[:minM]
    V = Vh.T # Transpose back to match R's 'v'
    
    SS = (L**2) * nrep
    a_sumsq = np.sum(SS)
    percent = np.round((SS / a_sumsq) * 100, 1)
    
    # 6. Build the AMMI PCA Table
    pca_data = []
    acum = 0
    
    for i in range(minM):
        DF = (ngen - 1) + (nenv - 1) - (2 * (i + 1) - 1)
        if DF <= 0: break
        
        acum += percent[i]
        MSami = SS[i] / DF
        F_ami = np.round(MSami / MSE, 2)
        f_prob = np.round(f.sf(F_ami, DF, DFE), 4)
        
        pca_data.append({
            'PCA': f'PCA{i+1}',
            'percent': percent[i],
            'cumulative': acum,
            'Df': DF,
            'Sum Sq': np.round(SS[i], 1),
            'Mean Sq': np.round(MSami, 1),
            'F value': F_ami,
            'prob': f_prob
        })
        
    ammi_ss = pd.DataFrame(pca_data).set_index('PCA')
    nssammi = len(ammi_ss)
    
    print("\nAMMI Analysis Results per PCA axis")
    print(ammi_ss)
    
    # 7. Calculate AMMI Scores for Biplots
    sql = np.diag(np.sqrt(L[:nssammi]))
    
    regscr = U[:, :nssammi] @ sql
    scoree1 = V[:, :nssammi] @ sql
    
    gen_means = avdm.groupby('genotype')['Y'].mean()
    env_means = avdm.groupby('environment')['Y'].mean()
    
    # Create genotype scores DataFrame
    gen_m = pd.DataFrame(regscr, index=res_mat.index, columns=[f'PC{i+1}' for i in range(nssammi)])
    gen_m.insert(0, 'category', 'genotype')
    gen_m.insert(1, 'Y', gen_means)
    
    # Create environment scores DataFrame
    m_env = pd.DataFrame(scoree1, index=res_mat.columns, columns=[f'PC{i+1}' for i in range(nssammi)])
    m_env.insert(0, 'category', 'environment')
    m_env.insert(1, 'Y', env_means)
    
    # Bind them together
    scrs_plot = pd.concat([gen_m, m_env])
    
    # 8. Return Compiled Output
    return {
        'means_matrix': avdm0,
        'anova': anmm,
        'errorlist': errorlist,
        'gei_matrix': res_mat,
        'analysis': ammi_ss,
        'means_df': avdm,
        'pc_scrs': scrs_plot,
        'percentAxis': percent[:nssammi],
        'sdc': {'u': U, 'd': S, 'v': V}
    }
