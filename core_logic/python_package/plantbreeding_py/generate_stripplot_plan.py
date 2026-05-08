import pandas as pd
import random
import matplotlib.pyplot as plt
import matplotlib.patches as patches

def generate_stripplot_plan(wp_factor, sp_factor, n_locs=2, n_blocks=3):
    """
    Generate Strip-Plot Design Randomization Plan
    
    Parameters:
    wp_factor (list): Whole-plot treatment names (e.g., Irrigation levels).
    sp_factor (list): Sub-plot treatment names (e.g., Varieties).
    n_locs (int): Number of locations.
    n_blocks (int): Number of blocks (replicates) per location.
    
    Returns:
    dict: A dictionary containing the randomization DataFrame and the Matplotlib figure.
    """
    n_wp = len(wp_factor)
    n_sp = len(sp_factor)
    
    # ---------------------------------------------------------
    # 1. Randomization Engine
    # ---------------------------------------------------------
    plan_list = []
    
    for loc in range(1, n_locs + 1):
        for blk in range(1, n_blocks + 1):
            
            # Step 1: Randomize the Whole-plot factor within the block
            wp_rand = random.sample(list(wp_factor), n_wp)
            
            for w, current_wp in enumerate(wp_rand, start=1):
                
                # Step 2: Randomize the Sub-plot factor WITHIN the current Whole-plot
                sp_rand = random.sample(list(sp_factor), n_sp)
                
                # Assign spatial coordinates 
                temp_df = pd.DataFrame({
                    "Location": f"Location {loc}",
                    "Block": f"Block {blk}",
                    "Block_Num": blk,
                    "Whole_Plot_Unit": f"B{blk}-WP{w}",
                    "Whole_Plot_Trt": current_wp,
                    "Sub_Plot_Trt": sp_rand,
                    "Local_Row": w,                   # Row assignment based on WP index
                    "Local_Col": range(1, n_sp + 1)   # Column assignment based on SP index
                })
                
                plan_list.append(temp_df)
                
    final_plan = pd.concat(plan_list, ignore_index=True)
    
    # ---------------------------------------------------------
    # 2. Spatial Calculations
    # ---------------------------------------------------------
    
    # Stack blocks vertically
    final_plan['Global_Row'] = final_plan['Local_Row'] + (final_plan['Block_Num'] - 1) * n_wp
    final_plan['Global_Col'] = final_plan['Local_Col']
    
    # Bounding boxes for Whole-Plots (thicker gray lines)
    wp_boundaries = final_plan.groupby(['Location', 'Block', 'Whole_Plot_Unit']).agg(
        xmin=('Global_Col', lambda x: x.min() - 0.5),
        xmax=('Global_Col', lambda x: x.max() + 0.5),
        ymin=('Global_Row', lambda y: y.min() - 0.5),
        ymax=('Global_Row', lambda y: y.max() + 0.5)
    ).reset_index()
    
    # Bounding boxes for full Blocks (bold black lines)
    blk_boundaries = final_plan.groupby(['Location', 'Block']).agg(
        xmin=('Global_Col', lambda x: x.min() - 0.5),
        xmax=('Global_Col', lambda x: x.max() + 0.5),
        ymin=('Global_Row', lambda y: y.min() - 0.5),
        ymax=('Global_Row', lambda y: y.max() + 0.5)
    ).reset_index()
    
    # ---------------------------------------------------------
    # 3. Plotting
    # ---------------------------------------------------------
    
    fig, axes = plt.subplots(1, n_locs, figsize=(6 * n_locs, 8), squeeze=False)
    axes = axes.flatten()
    
    # Set up discrete color palette (matching Pastel1 from ggplot)
    unique_wp = final_plan['Whole_Plot_Trt'].unique()
    pastel_colors = plt.cm.Pastel1.colors
    color_map = {trt: pastel_colors[i % len(pastel_colors)] for i, trt in enumerate(unique_wp)}
    
    for i, loc in enumerate(final_plan['Location'].unique()):
        ax = axes[i]
        loc_data = final_plan[final_plan['Location'] == loc]
        
        # Draw individual Sub-plots
        for _, row in loc_data.iterrows():
            rect = patches.Rectangle(
                (row['Global_Col'] - 0.5, row['Global_Row'] - 0.5),
                1, 1, facecolor=color_map[row['Whole_Plot_Trt']],
                edgecolor='white', linewidth=0.5
            )
            ax.add_patch(rect)
            
            # Add Sub-plot treatment labels
            ax.text(row['Global_Col'], row['Global_Row'], row['Sub_Plot_Trt'],
                    ha='center', va='center', fontsize=9, fontweight='bold', color='black')
        
        # Draw Whole-plot boundaries
        loc_wp = wp_boundaries[wp_boundaries['Location'] == loc]
        for _, row in loc_wp.iterrows():
            rect = patches.Rectangle(
                (row['xmin'], row['ymin']), row['xmax'] - row['xmin'], row['ymax'] - row['ymin'],
                fill=False, edgecolor='dimgray', linewidth=1.5
            )
            ax.add_patch(rect)
            
        # Draw Block boundaries (Bold)
        loc_blk = blk_boundaries[blk_boundaries['Location'] == loc]
        for _, row in loc_blk.iterrows():
            rect = patches.Rectangle(
                (row['xmin'], row['ymin']), row['xmax'] - row['xmin'], row['ymax'] - row['ymin'],
                fill=False, edgecolor='black', linewidth=2.5
            )
            ax.add_patch(rect)
            
        # Facet Formatting
        ax.set_title(loc, fontweight='bold', fontsize=12)
        ax.set_xlim(0.5, n_sp + 0.5)
        ax.set_ylim(loc_data['Global_Row'].max() + 0.5, 0.5)  # Scale Y Reverse
        ax.set_xticks([])
        ax.set_yticks([])
        ax.set_xlabel("Sub-Plot (Column)")
        if i == 0:
            ax.set_ylabel("Whole-Plot (Row)")
        ax.set_aspect('equal')
        
    # Add Legend
    handles = [patches.Patch(color=color_map[trt], label=trt) for trt in unique_wp]
    fig.legend(handles=handles, title="Main Plot\nTreatment", loc='center right', bbox_to_anchor=(0.95, 0.5))
    
    # Titles and Subtitles
    plt.suptitle("Multi-Location Split-Plot Field Layout", fontsize=14, fontweight='bold')
    fig.text(0.5, 0.05, "Color = Whole-Plot Treatment. Text = Sub-Plot Treatment.\nBold Black = Block. Thin Gray = Whole-plot Strip.", 
             ha='center', fontsize=10, color='gray')
    
    plt.tight_layout(rect=[0, 0.08, 0.88, 0.95])
    plt.show()
    
    return {"Data": final_plan, "Plot": fig}

### ==========================================
### EXAMPLE USAGE
### ==========================================
##
##if __name__ == "__main__":
##    # Define 3 Main Plot treatments (e.g., Irrigation methods)
##    main_plots = ["Irrigated", "Dryland", "Deficit"]
##    
##    # Define 5 Sub-plot treatments (e.g., Varieties)
##    sub_plots = [f"Var-{i}" for i in range(1, 6)]
##    
##    # Generate the split-plot plan
##    split_trial = generate_stripplot_plan(
##        wp_factor=main_plots, 
##        sp_factor=sub_plots, 
##        n_locs=2, 
##        n_blocks=3
##    )
##    
##    # Check the generated dataset
##    print(split_trial["Data"].head(10))
