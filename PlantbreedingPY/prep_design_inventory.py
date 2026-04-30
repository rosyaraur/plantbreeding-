import pandas as pd
import numpy as np
import random
import math

def prep_design_inventory(locations_file, genotypes_file, check_proportion=0.20, seed=999):
    """
    Design Proportional P-Rep Multi-Environment Trials with Spatial Blocking
    
    :param locations_file: Path to CSV or pandas DataFrame containing 6 columns: 
                           Environment, Reps (Ignored), Row, Range, Block_Dir, Block_Dim.
    :param genotypes_file: Path to CSV or pandas DataFrame containing 4 columns: 
                           Name, Type (Check/Line), MaxRepsPerBlock, SeedAvail.
    :param check_proportion: Float. The target proportion of the field to be allocated to checks (e.g., 0.20).
    :param seed: Integer random seed for reproducibility. Default is 999.
    :return: A dictionary containing three pandas DataFrames: 'TrialPlan', 'RemainingInventory', and 'Summary'.
    """
    
    if not (0 < check_proportion < 1):
        raise ValueError("Error: check_proportion must be strictly between 0 and 1 (e.g., 0.15 for 15%).")
        
    # 1. Flexible Input Handling
    if isinstance(locations_file, str):
        locs_raw = pd.read_csv(locations_file)
    else:
        locs_raw = pd.DataFrame(locations_file)
        
    if isinstance(genotypes_file, str):
        genos_raw = pd.read_csv(genotypes_file)
    else:
        genos_raw = pd.DataFrame(genotypes_file)
        
    if locs_raw.shape[1] < 6:
        raise ValueError("Error: Locations data must contain at least 6 columns.")
        
    locs = locs_raw.iloc[:, :6].copy()
    genos = genos_raw.iloc[:, :4].copy()
    
    locs.columns = ["Environment", "Reps", "Row", "Range", "Block_Dir", "Block_Dim"]
    genos.columns = ["Name", "Type", "MaxRepsPerBlock", "SeedAvail"]
    
    # Handle Seed Availability (Infinity for Checks or missing)
    # The .astype(float) prevents integer mismatch errors when assigning np.inf
    genos['SeedAvail'] = pd.to_numeric(genos['SeedAvail'], errors='coerce').astype(float)
    is_check = genos['Type'].astype(str).str.lower() == 'check'
    genos.loc[is_check | genos['SeedAvail'].isna(), 'SeedAvail'] = np.inf
    
    # Set Seeds
    if seed is not None and seed != 999:
        random.seed(seed)
        np.random.seed(seed)
        
    all_env_plans = []
    
    # 2. Loop through Environments
    for i in range(len(locs)):
        env_name = locs['Environment'].iloc[i]
        n_rows = int(locs['Row'].iloc[i])
        n_ranges = int(locs['Range'].iloc[i])
        b_dir = str(locs['Block_Dir'].iloc[i]).strip().lower()
        b_dim = float(locs['Block_Dim'].iloc[i])
        
        total_plots = n_rows * n_ranges
        target_check_plots = round(total_plots * check_proportion)
        
        # Generate the physical spatial grid
        grid = pd.DataFrame({
            'Environment': env_name,
            'Row': np.repeat(np.arange(1, n_rows + 1), n_ranges),
            'Range': np.tile(np.arange(1, n_ranges + 1), n_rows)
        })
        
        # Cut the grid into spatial Blocks
        if b_dir in ['row', 'rows']:
            grid['Block'] = np.ceil(grid['Row'] / b_dim).astype(int)
        elif b_dir in ['range', 'ranges', 'col', 'cols']:
            grid['Block'] = np.ceil(grid['Range'] / b_dim).astype(int)
        else:
            raise ValueError(f"Environment '{env_name}': Block_Dir must be 'Row' or 'Range'.")
            
        num_blocks = grid['Block'].max()
        
        # Calculate uniform check distribution across blocks
        base_checks_per_block = math.floor(target_check_plots / num_blocks)
        remainder_checks = target_check_plots % num_blocks
        
        env_data_list = []
        
        # 3. Fill and randomize each spatial block
        for b in range(1, num_blocks + 1):
            block_grid = grid[grid['Block'] == b].copy()
            block_size = len(block_grid)
            
            # Distribute remainder checks to the first few blocks
            needed_checks = base_checks_per_block + (1 if b <= remainder_checks else 0)
            needed_lines = block_size - needed_checks
            
            block_trts = []
            
            # Assign Checks (Randomly sample from available check inventory)
            for k in range(needed_checks):
                avail_checks = genos[(genos['Type'].astype(str).str.lower() == 'check') & (genos['SeedAvail'] > 0)]
                if avail_checks.empty:
                    block_trts.append("FILLER")
                else:
                    chosen_idx = random.choice(avail_checks.index.tolist())
                    chosen_name = genos.at[chosen_idx, 'Name']
                    block_trts.append(chosen_name)
                    
                    # Deduct global inventory
                    genos.at[chosen_idx, 'SeedAvail'] -= 1
                    
            # Assign Experimental Lines (Sample without replacement within the block)
            avail_lines = genos[(genos['Type'].astype(str).str.lower() != 'check') & (genos['SeedAvail'] > 0)]
            
            num_to_pick = min(needed_lines, len(avail_lines))
            if num_to_pick > 0:
                chosen_indices = random.sample(avail_lines.index.tolist(), num_to_pick)
                for idx in chosen_indices:
                    chosen_name = genos.at[idx, 'Name']
                    block_trts.append(chosen_name)
                    
                    # Deduct global inventory
                    genos.at[idx, 'SeedAvail'] -= 1
                    
            # Fill any remaining voids
            needed_lines -= num_to_pick
            if needed_lines > 0:
                block_trts.extend(["FILLER"] * needed_lines)
                
            # Randomize treatments and attach to spatial block coordinates
            random.shuffle(block_trts)
            block_grid['Treatment'] = block_trts
            env_data_list.append(block_grid)
            
        # Format Output
        env_data = pd.concat(env_data_list, ignore_index=True)
        env_data = env_data.sort_values(by=['Row', 'Range']).reset_index(drop=True)
        env_data['PlotNumber'] = range(1, len(env_data) + 1)
        env_data = env_data[['Environment', 'PlotNumber', 'Row', 'Range', 'Block', 'Treatment']]
        
        all_env_plans.append(env_data)
        
    final_plan = pd.concat(all_env_plans, ignore_index=True)
    
    # --- 4. Generate Output Summaries ---
    remaining_lines = genos[genos['Type'].astype(str).str.lower() != 'check'][['Name', 'SeedAvail']].copy()
    remaining_lines.columns = ['Line', 'Remaining_Seed_Quantity']
    
    # Treatment by Environment Crosstab
    trt_env_counts = pd.crosstab(final_plan['Treatment'], final_plan['Environment'])
    trt_env_counts['Total_Plots'] = trt_env_counts.sum(axis=1)
    trt_env_counts = trt_env_counts.reset_index()
    
    # Merge to get Types back for the summary
    summary_df = pd.merge(genos_raw.iloc[:, :2], trt_env_counts, left_on=genos_raw.columns[0], right_on='Treatment', how='right')
    summary_df = summary_df.drop(columns=[genos_raw.columns[0]]) # Drop duplicate name column
    summary_df = summary_df.rename(columns={genos_raw.columns[1]: 'Type'})
    summary_df['Type'] = summary_df['Type'].fillna("Filler")
    
    # Reorder columns
    env_cols = [c for c in summary_df.columns if c not in ['Treatment', 'Type', 'Total_Plots']]
    summary_df = summary_df[['Treatment', 'Type', 'Total_Plots'] + env_cols]
    
    # Sorting: Checks first (1), Lines second (2), Fillers last (3), then by Total_Plots descending
    def get_type_order(t):
        t_low = str(t).lower()
        if t_low == 'check': return 1
        if t_low == 'filler': return 3
        return 2
        
    summary_df['Sort_Order'] = summary_df['Type'].apply(get_type_order)
    summary_df = summary_df.sort_values(by=['Sort_Order', 'Total_Plots'], ascending=[True, False])
    summary_df = summary_df.drop(columns=['Sort_Order']).reset_index(drop=True)
    
    return {
        'TrialPlan': final_plan,
        'RemainingInventory': remaining_lines,
        'Summary': summary_df
    }

### ==========================================
### Run the p-rep engine
### ==========================================
##if __name__ == "__main__":
##    try:
##        prep_results = prep_design_inventory(
##            locations_file="~/Downloads/locations_parameters.csv", 
##            genotypes_file="~/Downloads/genotypes_parameters.csv",
##            check_proportion=0.20, # Generates a true 20/80 p-rep split
##            seed=42
##        )
##        
##        # Export the final Prism-ready matrix
##        prep_results['TrialPlan'].to_csv("P_Rep_Trial_Plan.csv", index=False)
##        
##        # Review your spatial allocations
##        print(prep_results['Summary'])
##        
##    except Exception as e:
##        print(f"Failed to generate trial plan: {e}")
