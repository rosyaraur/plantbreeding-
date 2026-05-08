import pandas as pd
import numpy as np

def adesign_inventory(locations_file, genotypes_file, seed=999, max_reps_per_loc_lines=1):
    """
    Design Inventory-Driven Multi-Environment Trials with Spatial Blocking.
    """
    
    # 1. Flexible Input Handling
    if isinstance(locations_file, str):
        locs_raw = pd.read_csv(locations_file)
    else:
        locs_raw = locations_file.copy()
        
    if isinstance(genotypes_file, str):
        genos_raw = pd.read_csv(genotypes_file)
    else:
        genos_raw = genotypes_file.copy()
        
    # Validate Location Input
    if locs_raw.shape[1] < 6:
        raise ValueError("Error: Locations data must contain at least 6 columns: Environment, Reps, Row, Range, Block_Dir, Block_Dim.")
        
    # Extract strictly by position
    locs = locs_raw.iloc[:, 0:6].copy()
    genos = genos_raw.iloc[:, 0:4].copy()
    
    # Standardize internal column names
    locs.columns = ["Environment", "Reps", "Row", "Range", "Block_Dir", "Block_Dim"]
    genos.columns = ["Name", "Type", "MaxRepsPerBlock", "SeedAvail"]
    
    # --- THE FIX IS HERE ---
    # Format data types and inventory. Explicitly cast to float64 to allow 'inf'
    genos['SeedAvail'] = pd.to_numeric(genos['SeedAvail'], errors='coerce').astype('float64')
    genos['MaxRepsPerBlock'] = pd.to_numeric(genos['MaxRepsPerBlock'], errors='coerce')
    
    # Set SeedAvail to infinity for Checks or where NA
    is_check = genos['Type'].astype(str).str.lower() == "check"
    genos.loc[is_check | genos['SeedAvail'].isna(), 'SeedAvail'] = float('inf')
    
    if seed is not None and not np.isnan(seed) and seed != 999:
        np.random.seed(int(seed))
        
    all_env_plans = []
    
    # 2. Loop through Environments
    for i, loc_row in locs.iterrows():
        env_name = loc_row['Environment']
        n_rows = int(loc_row['Row'])
        n_ranges = int(loc_row['Range'])
        b_dir = str(loc_row['Block_Dir']).strip().lower()
        b_dim = float(loc_row['Block_Dim'])
        
        # Reset the tracking counter for lines planted in THIS specific location
        genos['CurrentLocReps'] = 0
        
        # Generate the physical spatial grid
        rows_arr = np.repeat(np.arange(1, n_rows + 1), n_ranges)
        ranges_arr = np.tile(np.arange(1, n_ranges + 1), n_rows)
        
        grid = pd.DataFrame({
            'Environment': env_name,
            'Row': rows_arr,
            'Range': ranges_arr
        })
        
        # Cut the grid into spatial Blocks
        if b_dir in ["row", "rows"]:
            grid['Block'] = np.ceil(grid['Row'] / b_dim).astype(int)
        elif b_dir in ["range", "ranges", "col", "cols"]:
            grid['Block'] = np.ceil(grid['Range'] / b_dim).astype(int)
        else:
            raise ValueError(f"Environment '{env_name}': Block_Dir must be 'Row' or 'Range'. Found: '{b_dir}'")
            
        actual_reps = grid['Block'].max()
        env_data_list = []
        
        # 3. Fill and randomize each spatial block based on inventory
        for b in range(1, actual_reps + 1):
            block_grid = grid[grid['Block'] == b].copy()
            block_size = len(block_grid)
            block_trts = []
            
            # Assign Checks
            for j, g_row in genos.iterrows():
                if str(g_row['Type']).lower() == "check":
                    qty = min(g_row['MaxRepsPerBlock'], g_row['SeedAvail'])
                    if qty > 0:
                        block_trts.extend([g_row['Name']] * int(qty))
                        
            if len(block_trts) > block_size:
                raise ValueError(f"Environment '{env_name}' Block {b}: Check plots ({len(block_trts)}) exceed physical block size ({block_size}).")
                
            # Assign Lines based on inventory availability AND Location Limits
            needed = block_size - len(block_trts)
            for j, g_row in genos.iterrows():
                if needed == 0:
                    break
                if str(g_row['Type']).lower() != "check" and genos.at[j, 'SeedAvail'] > 0:
                    
                    # Calculate how many MORE times we are allowed to plant this line in THIS location
                    allowed_in_loc = max_reps_per_loc_lines - genos.at[j, 'CurrentLocReps']
                    
                    if allowed_in_loc > 0:
                        qty = min(needed, genos.at[j, 'MaxRepsPerBlock'], genos.at[j, 'SeedAvail'], allowed_in_loc)
                        if qty > 0:
                            qty = int(qty)
                            block_trts.extend([g_row['Name']] * qty)
                            
                            # Deduct from global seed inventory and update location tracking
                            genos.at[j, 'SeedAvail'] -= qty
                            genos.at[j, 'CurrentLocReps'] += qty
                            needed -= qty
                            
            if needed > 0:
                block_trts.extend(["FILLER"] * needed)
                
            # Randomize block treatments
            np.random.shuffle(block_trts)
            block_grid['Treatment'] = block_trts
            env_data_list.append(block_grid)
            
        # Format and Order Final Output for this environment
        env_data = pd.concat(env_data_list, ignore_index=True)
        env_data = env_data.sort_values(by=['Row', 'Range']).reset_index(drop=True)
        env_data['PlotNumber'] = np.arange(1, len(env_data) + 1)
        env_data = env_data[['Environment', 'PlotNumber', 'Row', 'Range', 'Block', 'Treatment']]
        
        all_env_plans.append(env_data)
        
    final_plan = pd.concat(all_env_plans, ignore_index=True)
    
    # --- 4. Generate Output Summaries ---
    
    # Remaining Inventory
    is_not_check = genos['Type'].astype(str).str.lower() != "check"
    remaining_lines = genos.loc[is_not_check, ["Name", "SeedAvail"]].copy()
    remaining_lines.columns = ["Line", "Remaining_Seed_Quantity"]
    
    # Cross-tabulation Replication Summary (Lines x Environments)
    trt_env_counts = pd.crosstab(final_plan['Treatment'], final_plan['Environment'])
    trt_env_counts['Total_Plots'] = trt_env_counts.sum(axis=1)
    trt_env_counts = trt_env_counts.reset_index()
    
    # Join with original Genotype Types
    genos_sub = genos_raw.iloc[:, 0:2].copy()
    genos_sub.columns = ["Treatment", "Type"]
    
    summary_df = pd.merge(genos_sub, trt_env_counts, on="Treatment", how="right")
    summary_df['Type'] = summary_df['Type'].fillna("Filler")
    
    # Reorder columns: Treatment, Type, Total Plots, [Environments...]
    env_cols = [col for col in summary_df.columns if col not in ["Treatment", "Type", "Total_Plots"]]
    summary_df = summary_df[["Treatment", "Type", "Total_Plots"] + env_cols]
    
    # Sort table: Checks first, then Lines, then Fillers. Sorted descending by Total Plots.
    def get_sort_order(t):
        t_lower = str(t).lower()
        if t_lower == "check": return 1
        elif t_lower == "filler": return 3
        else: return 2
        
    summary_df['_sort_key'] = summary_df['Type'].apply(get_sort_order)
    summary_df = summary_df.sort_values(by=['_sort_key', 'Total_Plots'], ascending=[True, False])
    summary_df = summary_df.drop(columns=['_sort_key']).reset_index(drop=True)
    
    return {
        'TrialPlan': final_plan,
        'RemainingInventory': remaining_lines,
        'Summary': summary_df
    }
