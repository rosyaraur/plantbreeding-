import numpy as np
import pandas as pd
import statsmodels.api as sm
from statsmodels.formula.api import ols
import scipy.stats as stats
import matplotlib.pyplot as plt

def stability(dataframe, yvar, genotypes, environments, replication, verbose=True):
    """
    Stability analysis based on Eberhart and Russell (1966) model.
    """
    # 1. Safely extract and format data
    df = pd.DataFrame({
        'yvar': dataframe[yvar],
        'genotypes': dataframe[genotypes].astype(str),
        'environments': dataframe[environments].astype(str),
        'replication': dataframe[replication].astype(str)
    })
    
    # 2. Base Models
    # R uses Type I (sequential) SS. statsmodels anova_lm(typ=1) matches this.
    formula1 = "yvar ~ C(genotypes) + C(environments) + C(environments):C(replication) + C(environments):C(genotypes)"
    model1 = ols(formula1, data=df).fit()
    anova1 = sm.stats.anova_lm(model1, typ=1)
    
    # 3. Aggregations and Matrix Setup
    mydf = df.groupby(['genotypes', 'environments'])['yvar'].mean().reset_index()
    matx_wide_df = mydf.pivot(index='genotypes', columns='environments', values='yvar')
    matx = matx_wide_df.values
    gen_names = matx_wide_df.index.values
    env_names = matx_wide_df.columns.values
    
    # 4. Eberhart & Russell Parameters
    gradyt = np.mean(matx)
    iij = np.mean(matx, axis=0) - gradyt  # Environmental index
    sqiij = np.sum(iij**2)
    
    YiIj = np.dot(matx, iij)
    bij = YiIj / sqiij  # Regression coefficient (stability parameter)
    
    svar = np.sum(matx**2, axis=1) - (np.sum(matx, axis=1)**2) / matx.shape[1]
    bYijIj = bij * YiIj
    deltaij = svar - bYijIj
    
    devtab = pd.DataFrame({
        'genotypes': gen_names,
        'svar': svar,
        'bij': bij,
        'YiIj': YiIj,
        'bYijIj': bYijIj,
        'deltaij': deltaij
    })
    
    # 5. Variances
    S2e = anova1.loc['Residual', 'mean_sq']  # Mean Sq of error
    rps = df['replication'].nunique()
    en = df['environments'].nunique()
    ge = df['genotypes'].nunique()
    
    S2di = (deltaij / (en - 2)) - (S2e / rps)  # Deviation from regression
    
    # 6. ANOVA for Mean Data
    formula2 = "yvar ~ C(genotypes) + C(environments)"
    model2 = ols(formula2, data=mydf).fit()
    anova2 = sm.stats.anova_lm(model2, typ=1)
    
    SSL = anova2.loc['C(environments)', 'sum_sq']
    SSGxL = anova2.loc['Residual', 'sum_sq'] 
    SSL_Linear = (1 / ge) * (np.dot(np.sum(matx, axis=0), iij))**2 / np.sum(iij**2)
    SS_L_GxL_linear = np.sum(bYijIj) - SSL_Linear
    
    # 7. Consolidate Final ANOVA Table
    Df = [en*ge - 1, ge - 1, ge*(en - 1), 1, ge - 1, ge*(en - 2)] + [en - 2] * len(deltaij) + [en*ge*(rps - 1)]
    poolerr = anova1.loc['Residual', 'sum_sq'] / rps
    
    SSS_list = [
        np.sum(anova2['sum_sq']),
        anova2.loc['C(genotypes)', 'sum_sq'],
        SSL + SSGxL,
        SSL_Linear,
        SS_L_GxL_linear,
        np.sum(deltaij)
    ] + deltaij.tolist() + [poolerr]
    
    SSS = np.array(SSS_list)
    MSSS = SSS / Df
    
    # Calculate F-Values
    FVAL = np.full(len(SSS), np.nan)
    FVAL[1] = MSSS[1] / MSSS[5]
    FVAL[4] = MSSS[4] / MSSS[5]
    FVAL[6:-1] = MSSS[6:-1] / MSSS[-1]
    
    # Calculate P-Values using survival function (1 - CDF)
    pval = np.full(len(SSS), np.nan)
    pval[1] = stats.f.sf(FVAL[1], Df[1], Df[5])
    pval[4] = stats.f.sf(FVAL[4], Df[4], Df[5])
    pval[6:-1] = stats.f.sf(FVAL[6:-1], Df[6], Df[-1])
    
    rownames = ["Total", "Genotypes", "Env + (Gen x Env)", "Env (linear)", "Gen x Env(linear)", 
                "Pooled deviation"] + list(gen_names) + ["Pooled error"]
    
    anovadf = pd.DataFrame({
        'Df': Df,
        'Sum Sq': SSS,
        'Mean Sq': MSSS,
        'F value': FVAL,
        'Pr(>F)': pval
    }, index=rownames)
    
    # 8. Output Formatting & Plotting
    outdat = pd.DataFrame({
        'genotypes': gen_names,
        'bij': bij,
        'sdij': S2di
    })
    
    env_index_df = pd.DataFrame({'environments': env_names, 'envindex': iij})
    plotst = pd.merge(mydf, env_index_df, on='environments')
    
    if verbose:
        print("========================================================")
        print(f"Anova for stability analysis: {yvar}")
        print("========================================================")
        print(anovadf.fillna('').to_string())
        
        print("\nEberhart and Russell Model of stability (Crop Science 1966, 6:37-40)\n")
        print(outdat.to_string(index=False))
        print("\n* Note: A perfectly stable genotype has bij = 1 and sdij = 0\n")
        
        # Plot 1: 3D Wireframe (equivalent to lattice::wireframe)
        fig1 = plt.figure(figsize=(10, 7))
        ax1 = fig1.add_subplot(111, projection='3d')
        x_idx = np.arange(len(gen_names))
        y_idx = np.arange(len(env_names))
        X, Y = np.meshgrid(x_idx, y_idx)
        Z = matx_wide_df.values.T
        ax1.plot_wireframe(X, Y, Z, color='green')
        ax1.set_xticks(x_idx)
        ax1.set_xticklabels(gen_names)
        ax1.set_yticks(y_idx)
        ax1.set_yticklabels(env_names)
        ax1.set_zlabel('Trait Mean')
        ax1.set_title(f"Wireframe Plot: {yvar}")
        plt.show()

        # Plot 2: Scatter plot mapping trait mean vs stability index
        plt.figure(figsize=(8, 6))
        plt.scatter(plotst['yvar'], plotst['envindex'], color='blue', zorder=2)
        for i, row in plotst.iterrows():
            plt.text(row['yvar'], row['envindex'] + 0.5, row['genotypes'], 
                     fontsize=9, ha='center', va='bottom', zorder=3)
        plt.title(f"Stability Plot: {yvar}")
        plt.xlabel("Trait Mean")
        plt.ylabel("Stability Index")
        plt.grid(True, linestyle='--', alpha=0.6, zorder=1)
        plt.show()

    # 9. Return structured results silently
    return {
        'ANOVA': anovadf,
        'Means': matx_wide_df,
        'scores': outdat,
        'devtab': devtab,
        'plot_data': plotst
    }
