import pandas as pd
import numpy as np
import random
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import math

def generate_rcbd_plan(lines, checks, n_locs=2, n_blocks=3, rows_per_block=None, cols_per_block=None):
    """
    Generate Variable-Dimension RCBD Randomization Plan with Bold Block Borders.
    
    Parameters:
    -----------
    lines : list of str
        Treatment/line names.
    checks : list of str
        Check names.
    n_locs : int
        Number of locations.
    n_blocks : int
        Number of blocks (replicates) per location.
    rows_per_block : int or list of int
        A single integer (applied to all) OR a list of integers per location.
    cols_per_block : int or list of int
        A single integer (applied to all) OR a list of integers per location.
        
    Returns:
    --------
    dict
        A dictionary containing the randomization dataframe ('Data') and the matplotlib figure ('Plot').
    """
    
    treatments = lines + checks
    n_trt = len(treatments)
    
    # ---------------------------------------------------------
    # 1. Handle Variable Dimensions Across Locations
    # ---------------------------------------------------------
    
    if isinstance(rows_per_block, int):
        rows_per_block = [rows_per_block] * n_locs
    elif len(rows_per_block) != n_locs:
        raise ValueError(f"Error: 'rows_per_block' must be an integer or match n_locs ({n_locs}).")
        
    if isinstance(cols_per_block, int):
        cols_per_block = [cols_per_block] * n_locs
    elif len(cols_per_block) != n_locs:
        raise ValueError(f"Error: 'cols_per_block' must be an integer or match n_locs ({n_locs}).")
        
    for i in range(n_locs):
        if rows_per_block[i] * cols_per_block[i] != n_trt:
            raise ValueError(
                f"Error at Location {i+1}: Grid ({rows_per_block[i]}x{cols_per_block[i]} = "
                f"{rows_per_block[i] * cols_per_block[i]}) does not equal total treatments ({n_trt})."
            )
            
    # ---------------------------------------------------------
    # 2. Randomization Engine
    # ---------------------------------------------------------
    
    plan_list = []
    
    for loc in range(n_locs):
        for blk in range(n_blocks):
            
            # Shuffle treatments
            shuffled_trt = random.sample(treatments, n_trt)
            r_loc = rows_per_block[loc]
            c_loc = cols_per_block[loc]
            
            # Rep equivalents in numpy
            local_row = np.repeat(np.arange(1, r_loc + 1), c_loc)
            local_col = np.tile(np.arange(1, c_loc + 1), r_loc)
            
            temp_df = pd.DataFrame({
                "Location": f"Location {loc + 1}",
                "Block": f"Block {blk + 1}",
                "Block_Num": blk + 1,
                "Local_Row": local_row,
                "Local_Col": local_col,
                "Treatment": shuffled_trt,
                "Type": ["Check" if t in checks else "Line" for t in shuffled_trt]
            })
            
            plan_list.append(temp_df)
            
    final_plan = pd.concat(plan_list, ignore_index=True)
    
    # ---------------------------------------------------------
    # 3. Spatial Calculations
    # ---------------------------------------------------------
    
    # Calculate global coordinates
    max_rows_per_loc = final_plan.groupby('Location')['Local_Row'].transform('max')
    final_plan['Global_Row'] = final_plan['Local_Row'] + (final_plan['Block_Num'] - 1) * max_rows_per_loc
    final_plan['Global_Col'] = final_plan['Local_Col']
    
    # Calculate bounding boxes for the bold block borders
    block_boundaries = final_plan.groupby(['Location', 'Block']).agg(
        xmin=('Global_Col', lambda x: x.min() - 0.5),
        xmax=('Global_Col', lambda x: x.max() + 0.5),
        ymin=('Global_Row', lambda x: x.min() - 0.5),
        ymax=('Global_Row', lambda x: x.max() + 0.5)
    ).reset_index()
    
    # ---------------------------------------------------------
    # 4. Plotting
    # ---------------------------------------------------------
    
    locations = final_plan['Location'].unique()
    n_cols = 2
    n_rows = math.ceil(len(locations) / n_cols)
    
    fig, axes = plt.subplots(n_rows, n_cols, figsize=(n_cols * 5, n_rows * 5), squeeze=False)
    axes = axes.flatten()
    
    color_map = {"Check": "#FFD700", "Line": "#ADD8E6"}
    
    for idx, loc in enumerate(locations):
        ax = axes[idx]
        df_loc = final_plan[final_plan['Location'] == loc]
        bounds_loc = block_boundaries[block_boundaries['Location'] == loc]
        
        # Draw individual plots (thin lines)
        for _, row in df_loc.iterrows():
            facecolor = color_map[row['Type']]
            rect = patches.Rectangle(
                (row['Global_Col'] - 0.5, row['Global_Row'] - 0.5), 
                1, 1, facecolor=facecolor, edgecolor="gray", linewidth=0.3
            )
            ax.add_patch(rect)
            
            # Add treatment labels
            ax.text(
                row['Global_Col'], row['Global_Row'], row['Treatment'],
                ha='center', va='center', weight='bold', fontsize=8, color='black'
            )
            
        # Draw block boundaries (bold lines)
        for _, row in bounds_loc.iterrows():
            rect = patches.Rectangle(
                (row['xmin'], row['ymin']),
                row['xmax'] - row['xmin'],
                row['ymax'] - row['ymin'],
                facecolor='none', edgecolor='black', linewidth=2
            )
            ax.add_patch(rect)
            
        # Formatting the subplot
        ax.set_title(loc, fontweight='bold')
        
        # Reverse Y-axis (equivalent to scale_y_reverse)
        max_y = df_loc['Global_Row'].max() + 1
        min_y = df_loc['Global_Row'].min() - 1
        ax.set_ylim(max_y, min_y) 
        
        ax.set_xlim(df_loc['Global_Col'].min() - 1, df_loc['Global_Col'].max() + 1)
        ax.set_aspect('equal')
        ax.axis('off')

    # Remove any empty subplots
    for i in range(len(locations), len(axes)):
        fig.delaxes(axes[i])
        
    fig.suptitle("Multi-Location RCBD Field Layout\n", fontweight='bold', fontsize=14)
    plt.tight_layout()
    
    return {"Data": final_plan, "Plot": fig}

### ==========================================
### EXAMPLE USAGE
### ==========================================
##
##if __name__ == "__main__":
##    my_lines = [f"L-{i}" for i in range(1, 11)]
##    my_checks = ["CHK-A", "CHK-B"]
##
##    variable_trial = generate_rcbd_plan(
##        lines=my_lines,
##        checks=my_checks,
##        n_locs=3,
##        n_blocks=2,
##        rows_per_block=[3, 2, 4],
##        cols_per_block=[4, 6, 3]
##    )
##
##    # Display the plot
##    plt.show()
##    
##    # View the top of the generated DataFrame
##    print(variable_trial["Data"].head(15))
