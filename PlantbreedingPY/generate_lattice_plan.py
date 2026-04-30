import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import random

def generate_lattice_plan(lines, checks, k, n_locs=2, n_reps=2):
    """
    Generate Resolvable Incomplete Block / Alpha Design Plan
    
    Parameters:
    lines (list): List of treatment/line names.
    checks (list): List of check names.
    k (int): Block size (number of plots per incomplete block).
    n_locs (int): Number of locations.
    n_reps (int): Number of full replications per location.
    
    Returns:
    dict: A dictionary containing the randomization DataFrame and the matplotlib Figure object.
    """
    
    treatments = list(lines) + list(checks)
    v = len(treatments) # Total number of treatments
    
    # Validation step: For a resolvable incomplete block design, 
    # total treatments must be a multiple of the incomplete block size.
    if v % k != 0:
        raise ValueError(f"Error: Total treatments ({v}) must be perfectly divisible by incomplete block size k ({k}).")
    
    s = v // k # Number of incomplete blocks per replicate
    
    # ---------------------------------------------------------
    # 1. Randomization Engine
    # ---------------------------------------------------------
    
    plan_list = []
    
    for loc in range(1, n_locs + 1):
        for rep in range(1, n_reps + 1):
            
            # Randomize treatments for the full replication
            shuffled_trt = treatments.copy()
            random.shuffle(shuffled_trt)
            
            # Assign treatments to incomplete blocks
            inc_block_num = np.repeat(np.arange(1, s + 1), k)  # Assign 's' blocks
            local_col = np.tile(np.arange(1, k + 1), s)        # 'k' plots per block
            
            types = ["Check" if t in checks else "Line" for t in shuffled_trt]
            
            temp_df = pd.DataFrame({
                "Location": f"Location {loc}",
                "Replicate": f"Rep {rep}",
                "Rep_Num": rep,
                "Inc_Block_Num": inc_block_num,
                "Local_Col": local_col,
                "Treatment": shuffled_trt,
                "Type": types
            })
            
            # Create a unique identifier for each incomplete block for plotting
            temp_df["Inc_Block"] = f"Rep {rep} - Blk " + temp_df["Inc_Block_Num"].astype(str)
            
            plan_list.append(temp_df)
            
    final_plan = pd.concat(plan_list, ignore_index=True)
    
    # ---------------------------------------------------------
    # 2. Spatial Calculations
    # ---------------------------------------------------------
    
    # Stack Replications vertically. 
    # Each Incomplete Block becomes a row, and the plots within it are columns.
    final_plan["Global_Row"] = final_plan["Inc_Block_Num"] + (final_plan["Rep_Num"] - 1) * s
    final_plan["Global_Col"] = final_plan["Local_Col"]
    
    # ---------------------------------------------------------
    # 3. Plotting
    # ---------------------------------------------------------
    
    locations = final_plan["Location"].unique()
    fig, axes = plt.subplots(1, len(locations), figsize=(6 * len(locations), 8), squeeze=False)
    axes = axes.flatten()
    
    for i, loc_name in enumerate(locations):
        ax = axes[i]
        loc_data = final_plan[final_plan["Location"] == loc_name]
        
        # Draw individual plots (tiles)
        for _, row in loc_data.iterrows():
            color = "#FFD700" if row["Type"] == "Check" else "#ADD8E6"
            rect = patches.Rectangle(
                (row["Global_Col"] - 0.5, row["Global_Row"] - 0.5), 1, 1,
                linewidth=0.5, edgecolor="gray", facecolor=color
            )
            ax.add_patch(rect)
            
            # Add treatment labels
            ax.text(row["Global_Col"], row["Global_Row"], row["Treatment"],
                    ha="center", va="center", fontsize=8, fontweight="bold")
            
        # Draw Incomplete Block boundaries (dashed blue)
        blocks = loc_data.groupby("Inc_Block")
        for _, blk in blocks:
            xmin = blk["Global_Col"].min() - 0.5
            xmax = blk["Global_Col"].max() + 0.5
            ymin = blk["Global_Row"].min() - 0.5
            ymax = blk["Global_Row"].max() + 0.5
            rect = patches.Rectangle(
                (xmin, ymin), xmax - xmin, ymax - ymin,
                linewidth=2, edgecolor="#005b96", facecolor="none", linestyle="dashed"
            )
            ax.add_patch(rect)
            
        # Draw Full Replicate boundaries (bold black)
        reps = loc_data.groupby("Replicate")
        for _, rep_data in reps:
            xmin = rep_data["Global_Col"].min() - 0.5
            xmax = rep_data["Global_Col"].max() + 0.5
            ymin = rep_data["Global_Row"].min() - 0.5
            ymax = rep_data["Global_Row"].max() + 0.5
            rect = patches.Rectangle(
                (xmin, ymin), xmax - xmin, ymax - ymin,
                linewidth=3, edgecolor="black", facecolor="none"
            )
            ax.add_patch(rect)
            
        # Formatting the axes
        ax.set_title(loc_name, fontweight="bold")
        ax.set_xlim(loc_data["Global_Col"].min() - 1, loc_data["Global_Col"].max() + 1)
        ax.set_ylim(loc_data["Global_Row"].min() - 1, loc_data["Global_Row"].max() + 1)
        ax.invert_yaxis() # Match scale_y_reverse()
        ax.axis('off')    # Match theme_minimal() + axis.text.blank()
        
    # Custom Legend
    check_patch = patches.Patch(color='#FFD700', label='Check')
    line_patch = patches.Patch(color='#ADD8E6', label='Line')
    fig.legend(handles=[check_patch, line_patch], loc='lower center', ncol=2, title="Entry Type")
    
    # Title and subtitles
    fig.suptitle("Multi-Location Alpha / Incomplete Block Layout\nBlack borders = Full Replications. Dashed Blue borders = Incomplete Blocks.", 
                 fontweight="bold", y=0.95)
    
    plt.tight_layout()
    fig.subplots_adjust(bottom=0.10, top=0.88) 
    
    plt.show()
    
    return {"Data": final_plan, "Plot": fig}


### ==========================================
### EXAMPLE USAGE
### ==========================================
##
### 24 Total Treatments
##my_lines = [f"L-{i}" for i in range(1, 23)]
##my_checks = ["CHK-1", "CHK-2"]
##
### Run the lattice generator
### We have 24 treatments. We can use an incomplete block size (k) of 4.
### This results in s = 6 incomplete blocks per full replication.
##lattice_trial = generate_lattice_plan(
##    lines = my_lines, 
##    checks = my_checks, 
##    n_locs = 2,              # 2 environments
##    n_reps = 2,              # 2 full replications per environment
##    k = 4                    # 4 plots per incomplete block
##)
##
### You can access the DataFrame using:
### print(lattice_trial["Data"].head())
