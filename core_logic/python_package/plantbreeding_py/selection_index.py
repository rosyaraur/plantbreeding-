import numpy as np
import pandas as pd
from scipy.stats import norm

def selection_index(phenodf, pcovmat, gcovmat, ecovmat, exout=True, selectint=0.01, verbose=True):
    """
    Calculate Selection Index
    
    This function illustrates the development of the selection index outlined by Smith (1936) 
    and further described in Singh and Chaudhary (1985).
    
    Parameters:
    -----------
    phenodf : pandas.DataFrame
        A phenotypic data frame. The first column is assumed to be identifiers (e.g., parents) 
        and is excluded from calculations.
    pcovmat : numpy.ndarray or list
        Phenotypic covariance matrix (X).
    gcovmat : numpy.ndarray or list
        Genotypic covariance matrix (G).
    ecovmat : numpy.ndarray or list
        Economic weight matrix or vector (A).
    exout : bool
        Included for backward compatibility; determines if outliers are excluded (currently inactive). 
        Default is True.
    selectint : float
        The proportion of the population to be selected. Default is 0.01 (1% selection intensity).
    verbose : bool
        If True, prints intermediate equations and matrices to the console. Default is True.
        
    Returns:
    --------
    dict
        A dictionary containing:
        - 'bis': A pandas DataFrame of the calculated selection index coefficients.
        - 'pmat': The phenotypic matrix used in calculations (excluding the ID column).
        - 'selectdf': The original phenotypic data frame appended with the calculated selection criterion.
        - 'exp_ggain': The expected genetic gain as a float.
    """
    
    # Ensure inputs are numpy arrays for matrix multiplication
    pcovmat = np.asarray(pcovmat)
    gcovmat = np.asarray(gcovmat)
    ecovmat = np.asarray(ecovmat).reshape(-1, 1) # Ensure ecovmat is a column vector
    
    # Calculate selection intensity (zv) dynamically based on the normal distribution
    zv = norm.pdf(norm.ppf(1 - selectint)) / selectint
    
    # Calculate index coefficients (b = P^-1 * G * A)
    # Using numpy.linalg.inv to solve the phenotypic covariance matrix
    pcov_inv = np.linalg.inv(pcovmat)
    bmat = pcov_inv @ gcovmat @ ecovmat
    
    # Format b values into a DataFrame
    traits = phenodf.columns[1:].tolist()
    bdatf = pd.DataFrame({'traits': traits, 'bi': bmat.flatten()})
    
    if verbose:
        print("b values for selection index equations\n")
        print(bdatf.to_string(index=False))
        print("\n")
        
    # Extract phenotypic matrix (ignoring the first ID column)
    pmat = phenodf.iloc[:, 1:].values
    
    if verbose:
        print("Phenotypic matrix\n")
        print(pmat)
        print("\n")
        
    # Calculate selection criteria
    selcriterion = pmat @ bmat
    
    # Append to original dataframe
    selectdf = phenodf.copy()
    selectdf['selcriterion'] = selcriterion.flatten()
    
    if verbose:
        print("Phenotypic values and selection criterion\n")
        print(selectdf.to_string(index=False))
        print("\n")
        
    # Expected genetic gain
    # R's W1 <- matrix(gcovmat %*% bmat, nrow=1) is a transposition
    W1 = (gcovmat @ bmat).T 
    W = np.sum(W1 @ ecovmat)
    
    # R's bmatj <- matrix(bmat, nrow = 1) is a transposition
    bmatj = bmat.T
    VP1 = bmatj @ pcovmat
    VP = VP1 @ bmat
    
    # Calculate final expected gain
    dgain = float((zv * W) / np.sqrt(VP.item()))
    
    if verbose:
        print(f"Expected genetic gain : {dgain}\n")
        
    return {
        'bis': bdatf,
        'pmat': pmat,
        'selectdf': selectdf,
        'exp_ggain': dgain
    }
