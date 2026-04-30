import pandas as pd
import numpy as np
import statsmodels.api as sm
from statsmodels.formula.api import ols

def gencor_lm(dataframe, yvar1, yvar2, genovar, replication, exout=False):
    """
    Calculates genetic correlation using Mean Squares extracted from ANOVA tables.
    """
    # 1. Safely extract data into a clean, internal dataframe
    # Converting genovar and replication to 'category' ensures statsmodels treats them as factors
    df = pd.DataFrame({
        'y1': dataframe[yvar1],
        'y2': dataframe[yvar2],
        'geno': dataframe[genovar].astype('category'),
        'rep': dataframe[replication].astype('category')
    })
    
    # We pre-calculate the sum here to avoid formula parsing ambiguity in Python
    df['y_sum'] = df['y1'] + df['y2']
    
    # 2. Fit models
    # ols() fits the model, typ=1 in anova_lm perfectly mimics R's default sequential anova()
    mod1 = ols('y1 ~ geno + rep', data=df).fit()
    mod2 = ols('y2 ~ geno + rep', data=df).fit()
    mod3 = ols('y_sum ~ geno + rep', data=df).fit()
    
    # 3. Cache ANOVA tables
    aov1 = sm.stats.anova_lm(mod1, typ=1)
    aov2 = sm.stats.anova_lm(mod2, typ=1)
    aov3 = sm.stats.anova_lm(mod3, typ=1)
    
    # Divisor is the number of replications (Replication df + 1)
    r_divisor = aov1.loc['rep', 'df'] + 1
    
    # 4. Variance components (Extracting Mean_Sq by index name instead of integer positions)
    g2gw = (aov1.loc['geno', 'mean_sq'] - aov1.loc['Residual', 'mean_sq']) / r_divisor
    g2tg = (aov2.loc['geno', 'mean_sq'] - aov2.loc['Residual', 'mean_sq']) / r_divisor
    
    # 5. Covariance components [ Cov(X,Y) = (Var(X+Y) - Var(X) - Var(Y)) / 2 ]
    cvtg_gy  = (aov3.loc['geno', 'mean_sq'] - aov2.loc['geno', 'mean_sq'] - aov1.loc['geno', 'mean_sq']) / 2
    ecvtg_gy = (aov3.loc['Residual', 'mean_sq'] - aov2.loc['Residual', 'mean_sq'] - aov1.loc['Residual', 'mean_sq']) / 2
    
    g2ecvtg_gy = (cvtg_gy - ecvtg_gy) / r_divisor
    
    # 6. Final calculations
    cohert = g2ecvtg_gy / (g2ecvtg_gy + ecvtg_gy) 
    genetic_corr = g2ecvtg_gy / np.sqrt(g2gw * g2tg)
    
    # 7. Output handling
    if not exout:
        return genetic_corr
    else:
        name_y1 = str(yvar1)
        name_y2 = str(yvar2)
        
        print(f"Analysis of variance: {name_y1}\n")
        print(aov1, "\n")
        
        print(f"Analysis of variance: {name_y2}\n")
        print(aov2, "\n")
        
        print(f"Analysis of co-variance: ({name_y1} + {name_y2})\n")
        print(aov3, "\n")
        
        print(f"Genetic correlation between {name_y1} and {name_y2}:\n")
        print(genetic_corr, "\n")
        
        results = {
            'genetic_corr': genetic_corr, 
            'coherence': cohert,
            'modelV1': mod1, 
            'modelV2': mod2, 
            'modelV1V2': mod3
        }
        return results

### ==========================================
### 2. SIMULATE THE DATA
### ==========================================
##np.random.seed(123) # Set seed for reproducibility
##
### Simulation Parameters
##n_geno = 60  # Number of genotypes/lines
##n_rep  = 4   # Number of replications/blocks
##
### Define the TRUE variances and the TRUE genetic correlation we want to test
##var_g1 = 10.0    # True genetic variance for Trait 1
##var_g2 = 15.0    # True genetic variance for Trait 2
##true_rg = 0.70   # The TRUE genetic correlation (Our Target)
##
### Calculate covariance based on the formula: Cov = r * sqrt(Var1 * Var2)
##cov_g = true_rg * np.sqrt(var_g1 * var_g2)
##
### Create the variance-covariance matrix for genotypes
##Sigma_G = np.array([[var_g1, cov_g], 
##                    [cov_g, var_g2]])
##
### Simulate true genetic values for the 60 genotypes based on the matrix
##geno_effects = np.random.multivariate_normal([0, 0], Sigma_G, n_geno)
##
### Build the base experimental design (Grid of genotypes x replications)
### This is the pandas equivalent of expand.grid()
##index = pd.MultiIndex.from_product([range(1, n_geno + 1), range(1, n_rep + 1)], names=['genovar', 'replication'])
##sim_data = pd.DataFrame(index=index).reset_index()
##
### Map the simulated true genetic effects to the specific rows
### Subtracting 1 from genovar because Python uses 0-based indexing
##sim_data['G1'] = sim_data['genovar'].apply(lambda x: geno_effects[x-1, 0])
##sim_data['G2'] = sim_data['genovar'].apply(lambda x: geno_effects[x-1, 1])
##
### Add random replication/block effects
##rep_eff_1 = np.random.normal(0, 2, n_rep)
##rep_eff_2 = np.random.normal(0, 3, n_rep)
##sim_data['R1'] = sim_data['replication'].apply(lambda x: rep_eff_1[x-1])
##sim_data['R2'] = sim_data['replication'].apply(lambda x: rep_eff_2[x-1])
##
### Add random residual/environmental noise
##sim_data['E1'] = np.random.normal(0, np.sqrt(5), len(sim_data))
##sim_data['E2'] = np.random.normal(0, np.sqrt(6), len(sim_data))
##
### Calculate final phenotypic traits (Y = Intercept + Genotype + Replication + Error)
##sim_data['Trait_A'] = 50  + sim_data['G1'] + sim_data['R1'] + sim_data['E1']
##sim_data['Trait_B'] = 100 + sim_data['G2'] + sim_data['R2'] + sim_data['E2']
##
### ==========================================
### 3. TEST THE FUNCTION
### ==========================================
##print("Running Test...\n")
##results = gencor_lm(dataframe = sim_data, 
##                    yvar1 = "Trait_A", 
##                    yvar2 = "Trait_B", 
##                    genovar = "genovar", 
##                    replication = "replication", 
##                    exout = True)
##
##print("=== SIMULATION RESULTS ===")
##print(f"Target (True) Genetic Correlation:  {true_rg}")
##print(f"Estimated Genetic Correlation:      {results['genetic_corr']:.4f}")
