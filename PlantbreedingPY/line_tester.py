import pandas as pd
import numpy as np
import statsmodels.api as sm
from statsmodels.formula.api import ols
from scipy.stats import f

def line_tester(dataframe: pd.DataFrame, yvar: str, genotypes: str, 
                replication: str, lines: str, testers: str, gclass: str) -> dict:
    """
    The function performs line x tester analysis as outlined by Singh and Chaudhary (1985). 
    It partitions the treatment sum of squares into parents, crosses, and parent vs. crosses, 
    and further calculates General Combining Ability (GCA), Specific Combining Ability (SCA), 
    and various genetic variance components.

    Parameters
    ----------
    dataframe : pd.DataFrame
        A data frame object containing the dataset.
    yvar : str
        Name of the dependent/response variable (trait).
    genotypes : str
        Name of the genotype variable.
    replication : str
        Name of the replication variable.
    lines : str
        Name of the lines variable.
    testers : str
        Name of the testers variable.
    gclass : str
        Name of the generation class variable (used to subset Parents, e.g., "P").

    Returns
    -------
    dict
        A dictionary containing the ANOVA table, GCA for lines and testers, SCA matrix, 
        covariance genetic components, and percentage contributions.
    """
    
    # 1. Safely extract and rename required columns
    df = dataframe[[yvar, genotypes, replication, lines, testers, gclass]].copy()
    df.columns = ["yvar", "genotypes", "replication", "Lines", "Tester", "gclass"]
    
    # 2. Convert grouping variables to categorical/factors
    for col in ["genotypes", "gclass", "Lines", "Tester", "replication"]:
        df[col] = df[col].astype('category')
        
    # Helper function to count non-NA values
    def countN(v):
        return v.notna().sum()
    
    # Store core counts to keep formulas clean
    r = df['replication'].nunique()
    l = df['Lines'].nunique()
    t = df['Tester'].nunique()
    
    # 3. Base ANOVA for treatments
    # Using Type 1 ANOVA to match R's default anova() behavior
    md1 = ols('yvar ~ genotypes + replication', data=df).fit()
    anvout = sm.stats.anova_lm(md1, typ=1)
    
    # 4. Treatment sums of square partitioning
    # Crosses
    data1 = df.groupby(['Lines', 'Tester'], observed=True)['yvar'].sum().reset_index()
    CF1 = (data1['yvar'].sum() ** 2) / (countN(data1['yvar']) * r)
    sscross = (np.sum(data1['yvar'] ** 2) / r) - CF1
    
    # Parents
    data2 = df[df['gclass'] == "P"]
    data3 = data2.groupby('genotypes', observed=True)['yvar'].sum().reset_index()
    CF2 = (data3['yvar'].sum() ** 2) / (countN(data3['yvar']) * r)
    ssparent = (np.sum(data3['yvar'] ** 2) / r) - CF2
    
    # Extract safely using row names
    SSTr = anvout.loc['genotypes', 'sum_sq']
    sspr_css = SSTr - ssparent - sscross
    
    # 5. Line x Tester analysis
    data4 = data1.groupby('Lines', observed=True)['yvar'].sum().reset_index()
    ssline = (np.sum(data4['yvar'] ** 2) / (r * t)) - CF1
    
    data5 = data1.groupby('Tester', observed=True)['yvar'].sum().reset_index()
    sstester = (np.sum(data5['yvar'] ** 2) / (r * l)) - CF1
    
    sslinXtest = sscross - ssline - sstester
    
    # Degrees of freedom and Sum of Squares extraction
    repdf = r - 1
    trtdf = df['genotypes'].nunique() - 1
    parentdf = (len(data2) / r) - 1
    prvscrdf = 1
    crossdf = trtdf - parentdf - prvscrdf
    Linedf = l - 1
    Testerdf = t - 1
    lintestdf = Linedf * Testerdf
    
    errordf = anvout.loc['Residual', 'df']
    totaldf = anvout['df'].sum()
    
    Df = np.array([repdf, trtdf, parentdf, prvscrdf, crossdf, Linedf, Testerdf, lintestdf, errordf, totaldf])
    
    repssq = anvout.loc['replication', 'sum_sq']
    trtssq = anvout.loc['genotypes', 'sum_sq']
    errorsq = anvout.loc['Residual', 'sum_sq']
    
    ssq = np.array([repssq, trtssq, ssparent, sspr_css, sscross, ssline, sstester, sslinXtest, errorsq])
    ssq = np.append(ssq, np.sum(ssq))
    
    # Mean Squares, F-values, and P-values
    msq = np.append(ssq[:9] / Df[:9], np.nan)
    
    Fval = np.array([
        msq[0]/msq[8], msq[1]/msq[8], msq[2]/msq[8], msq[3]/msq[8], msq[4]/msq[8], # 1-5 vs error
        msq[5]/msq[7], msq[6]/msq[7],                                              # lines/testers vs lineXtester
        msq[7]/msq[8],                                                             # lineXtester vs error
        np.nan, np.nan
    ])
    
    pval = np.full(10, np.nan)
    pval[0:5] = 1 - f.cdf(Fval[0:5], Df[0:5], errordf)
    pval[5:7] = 1 - f.cdf(Fval[5:7], Df[5:7], lintestdf)
    pval[7]   = 1 - f.cdf(Fval[7], Df[7], errordf)
    
    anovadf = pd.DataFrame({
        'Df': Df,
        'Sum Sq': ssq,
        'Mean Sq': msq,
        'F value': Fval,
        'Pr(>F)': pval
    }, index=["replication", "treatments", "parents", "parents vs cross", "cross", 
              "Lines", "tester", "line x tester", "error", "total"])
    
    print(f"Analysis of variance: {yvar}\n")
    print(anovadf.to_string(na_rep=""))
    
    # 6. Estimation of GCA effects
    print(f"\nGeneral combining ability test: {yvar}\n\nLines\n")
    
    cfac = data4['yvar'].sum() / (r * t * l)
    gcavec = (data4['yvar'] / (t * r)) - cfac
    data7 = df.groupby('Lines', observed=True)['yvar'].mean().reset_index()
    
    errgl = np.sqrt(msq[8] / (t * r))
    errgldf = np.sqrt(2 * msq[8] / (t * r))
    
    gcline = pd.DataFrame({
        'Lines': data4['Lines'],
        'mean': data7['yvar'],
        'gca': gcavec,
        'Standard error': errgl,
        'SE difference': errgldf
    })
    print(gcline.to_string(index=False))
    
    print("\nTesters\n")
    
    gcavect = (data5['yvar'] / (l * r)) - cfac
    data8 = df.groupby('Tester', observed=True)['yvar'].mean().reset_index()
    
    errglt = np.sqrt(msq[8] / (l * r))
    errgltdf = np.sqrt(2 * msq[8] / (l * r))
    
    gclinet = pd.DataFrame({
        'Testers': data5['Tester'],
        'mean': data8['yvar'],
        'gca': gcavect,
        'Standard error': errglt,
        'SE difference': errgltdf
    })
    print(gclinet.to_string(index=False))
    
    # 7. Estimation of SCA effects
    print("\nSCA matrix\n")
    
    z1 = data1.pivot(index='Lines', columns='Tester', values='yvar').fillna(0)
    
    mat_r = z1 / r
    row_sub = z1.sum(axis=1) / (t * r)
    col_sub = z1.sum(axis=0) / (l * r)
    grand_add = z1.to_numpy().sum() / (l * t * r)
    
    # Matrix sweeping (broadcasting)
    scamat = mat_r.sub(row_sub, axis=0)
    scamat = scamat.sub(col_sub, axis=1)
    scamat = scamat + grand_add
    
    print(scamat)
    
    # 8. Genetic components
    CovHSline = (msq[5] - msq[7]) / (t * r)
    CovHStester = (msq[6] - msq[7]) / (l * r)
    
    frac = 1 / (r * ((2 * l * t) - l - t))
    fr2_avg = ((l - 1) * msq[5]) + ((t - 1) * msq[6])
    CovHSavg = frac * ((fr2_avg / (l + t - 2)) - msq[7])
    
    fr1_fs = ((msq[5] - msq[8]) + (msq[6] - msq[8]) + (msq[7] - msq[8])) / (3 * r)
    fr2_fs = ((6 * r * CovHSavg) - (r * (l + t) * CovHSavg)) / (3 * r)
    CovFS = fr1_fs + fr2_fs
    
    VarAF0 = CovHSavg / 0.25
    VarAF1 = CovHSavg / 0.50
    
    VarSCA = (msq[7] - msq[8]) / r
    varDF0 = 4 * VarSCA
    varDF1 = VarSCA
    
    print("\nGenetic components:\n")
    print(f"Covariance (Line): {CovHSline}")
    print(f"Covariance (Tester): {CovHStester}")
    print(f"Covariance (Average): {CovHSavg}")
    print(f"Covariance (FS)/ variance GCA: {CovFS}")
    print(f"Additive variance with F = 0: {VarAF0}")
    print(f"Additive variance with F = 1: {VarAF1}")
    print(f"Dominance variance with F = 0: {varDF0}")
    print(f"Dominance variance with F = 1: {varDF1}")
    print(f"Variance (SCA): {VarSCA}\n")
    
    covlist = {
        'CovHSline': CovHSline, 'CovHStester': CovHStester, 'CovHSavg': CovHSavg, 
        'CovFS': CovFS, 'VarAF0': VarAF0, 'varDF1': varDF1
    }
    
    # 9. Proportion of contribution
    contline = (ssq[5] * 100) / ssq[4]
    conttester = (ssq[6] * 100) / ssq[4]
    contlinextester = (ssq[7] * 100) / ssq[4]
    
    print("Proportion of contribution from lines, tester and lines x tester:\n")
    print(f"Contribution from lines: {contline}")
    print(f"Contribution from tester: {conttester}")
    print(f"Contribution from line x tester: {contlinextester}")
    
    contib = {'lines': contline, 'testers': conttester, 'linextester': contlinextester}
    
    results = {
        'ANOVA': anovadf,
        'GC_Lines': gcline,
        'GC_tester': gclinet,
        'SCA_mat': scamat,
        'Covariance': covlist,
        'contribution': contib
    }
    
    return results
