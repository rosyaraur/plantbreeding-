import pandas as pd
import numpy as np
import statsmodels.api as sm
import statsmodels.formula.api as smf

def carolina1(dataframe, set_col, male_col, female_col, progeny_col, replication_col, yvar):
    """
    Analysis of North Carolina Design I
    
    Performs analysis of variance and estimates variance components for the 
    North Carolina I mating design (Comstock and Robinson, 1952) using 
    Expected Mean Squares (EMS).

    Parameters
    ----------
    dataframe : pandas.DataFrame
        A dataframe consisting of the variables for set, male, female, 
        progeny, and replication, along with at least one numeric response variable.
    set_col : str
        Name of the column containing the set variable.
    male_col : str
        Name of the column containing the male variable.
    female_col : str
        Name of the column containing the female variable.
    progeny_col : str
        Name of the column containing the progeny/plant variable.
    replication_col : str
        Name of the column containing the replication variable.
    yvar : str
        Name of the response variable to be analyzed.

    Returns
    -------
    dict
        A dictionary containing the following components:
        - 'model': The fitted statsmodels OLS object.
        - 'var_m': Estimated male variance component.
        - 'var_f': Estimated female variance component.
        - 'var_A': Estimated additive genetic variance.
        - 'var_D': Estimated dominance genetic variance.

    References
    ----------
    Comstock R.E., Robinson H.F. (1952). Estimation of average dominance of genes. 
    In Heterosis, Iowa State College Press, Ames, Iowa, Chapter 30.
    
    Singh R.K., Chaudhary B.D. (1985) Biometrical Methods in Quantitative Genetic Analysis.
    
    Mather K., Jinks J.L. (1971). Biometrical Genetics. Chapman & Hall, London.
    
    Saxton A. (2004) Genetic Analysis of Complex Traits Using SAS. SAS Institute, Inc.
    """
    
    # Safely subset and rename columns
    df = dataframe[[set_col, male_col, female_col, replication_col, progeny_col, yvar]].copy()
    df.columns = ["set", "male", "female", "replication", "progeny", yvar]
    
    # Drop NAs to mimic R's lm() default behavior of complete cases
    df = df.dropna().copy()
    
    # Vectorized factor (categorical) conversion
    factor_cols = ["set", "male", "female", "replication", "progeny"]
    for col in factor_cols:
        df[col] = df[col].astype('category')
        
    # Ensure the response variable is numeric
    df[yvar] = pd.to_numeric(df[yvar])
    
    # Calculate mean
    mean_y = df[yvar].mean()
    
    # Construct formula robustly and run the linear model
    form_str = f"{yvar} ~ set + set:replication + set:male + set:male:female + set:male:female:replication"
    model = smf.ols(form_str, data=df).fit()
    
    # Generate Type I (sequential) ANOVA table to match R's default anova()
    anva = sm.stats.anova_lm(model, typ=1)
    
    print(f"North Carolina 1 Design Output for: {yvar}\n")
    print(anva)
    
    # Cleaned up Coefficient of Variation (CV) calculation
    cv = np.sqrt(model.ssr / model.df_resid) * 100 / model.fittedvalues.mean()
    print(f"\nCV: {cv:.3f}%\tMean: {mean_y:.4f}\n")
    
    # Extract level counts directly from the cleaned dataframe
    f = df['female'].nunique()
    r = df['replication'].nunique()
    n = df['progeny'].nunique()
    
    # Helper function to reliably fetch mean squares regardless of Patsy interaction ordering
    def get_ms(anova_df, factor_list):
        target_set = set(factor_list)
        for idx in anova_df.index:
            if set(idx.split(':')) == target_set:
                return anova_df.loc[idx, 'mean_sq']
        raise KeyError(f"Could not find ANOVA term for factors: {factor_list}")

    # Extract Mean Squares and calculate variance components (EMS method)
    ms_male = get_ms(anva, ['set', 'male'])
    ms_fem  = get_ms(anva, ['set', 'male', 'female'])
    ms_err  = get_ms(anva, ['set', 'replication', 'male', 'female'])
    
    var_m = (ms_male - ms_fem) / (f * r * n)
    var_f = (ms_fem - ms_err) / (n * r)
    
    var_A = 4 * var_m
    var_D = 4 * var_f - 4 * var_m
    
    # Return a properly named dictionary
    output = {
        'model': model,
        'var_m': var_m,
        'var_f': var_f,
        'var_A': var_A,
        'var_D': var_D
    }
    
    return output
