import pandas as pd
import numpy as np
import statsmodels.api as sm
import statsmodels.formula.api as smf
from scipy.stats import f

def diallele1(dataframe, yvar="yvar", progeny="progeny", 
              male="male", female="female", 
              replication="replication", verbose=True):
    """
    Analysis of Diallel data

    Calculates general and specific combining ability and other estimates for 
    Diallel mating design using Griffing's Method I (parents, F1s, and reciprocals) 
    (Griffing, 1956). 
    """
    
    # 1. Input Validation and Data Preparation
    req_cols = [yvar, progeny, male, female, replication]
    if not all(col in dataframe.columns for col in req_cols):
        raise ValueError("One or more specified columns are not found in the dataframe.")
    
    # Work on a clean subset
    df = dataframe[req_cols].copy()
    
    # Ensure categorical variables are treated as factors (strings/objects)
    for col in [progeny, male, female, replication]:
        df[col] = df[col].astype(str)
        
    df[yvar] = pd.to_numeric(df[yvar])
    
    mean_y = df[yvar].mean()
    
    # 2. Initial Analysis of Variance (Treatments)
    # Using statsmodels to fit the linear model
    formula_str = f"{yvar} ~ C({progeny}) + C({replication})"
    md1 = smf.ols(formula_str, data=df).fit()
    anvout = sm.stats.anova_lm(md1, typ=1)
    
    # Identify the residual index (statsmodels usually calls it 'Residual')
    resid_idx = "Residual" if "Residual" in anvout.index else anvout.index[-1]
    
    if verbose:
        print(f"Diallel analysis for trait: {yvar}")
        print("...........................\n")
        print(anvout)
        
        progeny_p = anvout.loc[f"C({progeny})", "PR(>F)"]
        if progeny_p > 0.05:
            print("\nNote: Progeny effect is not significant at 0.05 p-threshold\n")
        elif progeny_p > 0.01:
            print("\nNote: Progeny effect is not significant at 0.01 p-threshold\n")
            
    # 3. Create the Male x Female Matrix using a pivot table
    pivot_df = df.pivot_table(values=yvar, index=male, columns=female, aggfunc='mean')
    myMatrix = pivot_df.values
    parents = pivot_df.index.tolist()
    
    if myMatrix.shape[0] != myMatrix.shape[1]:
        raise ValueError("The number of male and female parents do not match. Matrix is not square.")
        
    n = myMatrix.shape[0]
    
    # 4. Sums of Squares Calculations
    row_sums = myMatrix.sum(axis=1)
    col_sums = myMatrix.sum(axis=0)
    matrix_sum = myMatrix.sum()
    
    acon = np.sum((1 / (2 * n)) * ((row_sums + col_sums)**2))
    ssgca = acon - (2 / (n**2)) * (matrix_sum**2)
    sssca = np.sum((1 / 2) * (myMatrix * (myMatrix + myMatrix.T))) - acon + (1 / (n**2)) * (matrix_sum**2)
    ssrecp = (1 / 4) * np.sum((myMatrix - myMatrix.T)**2)
    
    r = df[replication].nunique()
    MSEAD = anvout.loc[resid_idx, "mean_sq"] / r
    
    # 5. Combining Ability ANOVA - Model I (Fixed)
    Df = [n - 1, n * (n - 1) / 2, n * (n - 1) / 2, anvout.loc[resid_idx, "df"]]
    SSS = [ssgca, sssca, ssrecp]
    ssq = SSS + [anvout.loc[resid_idx, "sum_sq"] / r]
    
    MSSS = [SSS[i] / Df[i] for i in range(3)]
    MSSS1 = MSSS + [MSEAD]
    
    FVAL = [MSSS1[0] / MSEAD, MSSS1[1] / MSEAD, MSSS1[2] / MSEAD, np.nan]
    pval = [f.sf(FVAL[i], Df[i], Df[3]) if not np.isnan(FVAL[i]) else np.nan for i in range(4)]
    
    anovadf_mod1 = pd.DataFrame({
        "Df": Df,
        "Sum Sq": ssq,
        "Mean Sq": MSSS1,
        "F value": FVAL,
        "Pr(>F)": pval
    }, index=["GCA", "SCA", "Reciprocal", "Error"])
    
    if verbose:
        print("\nAnova for combining ability - Model I (Fixed)")
        print(anovadf_mod1)
        
    # Genetic Components - Model I
    GCAcomp = (MSSS[0] - MSEAD) / (2 * n)
    SCAcomp = (MSSS[1] - MSEAD)
    RCAcomp = (MSSS[2] - MSEAD) / 2
    GCARCAratio = GCAcomp / SCAcomp if SCAcomp != 0 else np.nan
    
    components_model1 = {
        "GCAcomp": GCAcomp, 
        "SCAcomp": SCAcomp, 
        "RCAcomp": RCAcomp, 
        "GCRCAratio": GCARCAratio
    }
    
    if verbose:
        print("\nComponents: Model 1")
        print(f"GCA : {GCAcomp}")
        print(f"SCA : {SCAcomp}")
        print(f"Reciprocal: {RCAcomp}")
        print(f"GCA to SCA ratio: {GCARCAratio}")
        
    # 6. GCA, SCA, and Reciprocal Effects Matrices
    P = row_sums + col_sums
    
    gcaeff = ((1 / (2 * n)) * P) - ((1 / (n**2)) * matrix_sum)
    gcaeff_series = pd.Series(gcaeff, index=parents)
    
    # Utilizing np.newaxis to correctly broadcast the parent additions (Xi. + X.i + Xj. + X.j)
    scaeff = (0.5 * (myMatrix + myMatrix.T)) - \
             ((1 / (2 * n)) * (P[:, np.newaxis] + P[np.newaxis, :])) + \
             ((1 / (n**2)) * matrix_sum)
    scaeff_df = pd.DataFrame(scaeff, index=parents, columns=parents)
             
    recieff = 0.5 * (myMatrix - myMatrix.T)
    recieff_df = pd.DataFrame(recieff, index=parents, columns=parents)
    
    # Variances: standard error and critical differences
    varcompare = {
        "var_gi": ((n - 1) / (2 * n**2)) * MSEAD,
        "var_sii": (((n - 1)**2) / n**2) * MSEAD,
        "var_sij": (1 / (2 * n**2)) * ((n**2) - 2 * n + 2) * MSEAD,
        "var_rij": 0.5 * MSEAD,
        "var_gi_gj": (1 / n) * MSEAD,
        "var_sij_sji": ((2 * (n - 2)) / n) * MSEAD,
        "var_sii_sij": ((3 * n - 2) / (2 * n)) * MSEAD,
        "var_sii_sjk": ((3 * (n - 2)) / (2 * n)) * MSEAD,
        "var_sij_sik": ((n - 1) / n) * MSEAD,
        "var_sij_skl": ((n - 2) / n) * MSEAD,
        "var_rij_rkl": MSEAD
    }
    
    # 7. Combining Ability ANOVA - Model II (Random)
    FVAL1 = [MSSS1[0] / MSSS1[1], MSSS1[1] / MSEAD, MSSS1[2] / MSEAD, np.nan]
    pval1 = [
        f.sf(FVAL1[0], Df[0], Df[1]),
        f.sf(FVAL1[1], Df[1], Df[3]),
        f.sf(FVAL1[2], Df[2], Df[3]),
        np.nan
    ]
    
    anovadf_mod2 = pd.DataFrame({
        "Df": Df,
        "Sum Sq": ssq,
        "Mean Sq": MSSS1,
        "F value": FVAL1,
        "Pr(>F)": pval1
    }, index=["GCA", "SCA", "Reciprocal", "Error"])
    
    if verbose:
        print("\nAnova for combining ability - Model II (Random)")
        print(anovadf_mod2)
        
    # Genetic components estimates - Model II
    sigmasq_g = (1 / (2 * n)) * (MSSS1[0] - (((MSEAD + n * (n - 1) * MSSS1[1])) / (n**2 - n + 1)))
    sigmasq_s = ((n**2) / (2 * (n**2 - n + 1))) * (MSSS1[1] - MSEAD)
    sigmasq_r = 0.5 * (MSSS1[2] - MSEAD)
    sigmasq_error = MSEAD
    sigmasq_A = 2 * sigmasq_g
    sigmasq_D = sigmasq_s
    gca_scaratio = sigmasq_g / sigmasq_s if sigmasq_s != 0 else np.nan
    
    if verbose:
        print("\nComponents: Model 2")
        print(f"GCA (sigma^2 g) : {sigmasq_g}")
        print(f"SCA (sigma^2 s) : {sigmasq_s}")
        print(f"Reciprocal (sigma^2 r): {sigmasq_r}")
        print(f"GCA to SCA ratio: {gca_scaratio}\n")
        
    varcomp_model2 = {
        "sigmasq_g": sigmasq_g, 
        "sigmasq_s": sigmasq_s, 
        "sigmasq_r": sigmasq_r, 
        "sigmasq_error": sigmasq_error,
        "sigmasq_A": sigmasq_A, 
        "sigmasq_D": sigmasq_D, 
        "gca_scaratio": gca_scaratio
    }
    
    # 8. Return comprehensive dictionary
    results = {
        "anvout": anvout, 
        "anova_mod1": anovadf_mod1,
        "components_model1": components_model1, 
        "gca_effmat": gcaeff_series, 
        "sca_effmat": scaeff_df,
        "reciprocal_effmat": recieff_df, 
        "varcompare": varcompare,
        "anova_mod2": anovadf_mod2,
        "varcomp_model2": varcomp_model2
    }
    
    return results
