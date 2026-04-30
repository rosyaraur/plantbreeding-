import pandas as pd
import matplotlib.pyplot as plt
from datetime import datetime

def calculate_audpc(reading_dates, severity_data, plot=True):
    """
    Calculation of Area Under Disease / Pest Progress Curve (AUDPC).

    The function calculates the area under the disease or pest progress curve
    (Jeger and Viljanen-Rollinson 2001; Madden et al. 2007). The AUDPC is a
    useful quantitative summary of disease or pest intensity over time.
    This function uses the frequently used trapezoidal method to estimate the AUDPC.
    It discretizes time into specific units (based on the provided dates) and
    calculates the average disease intensity between each pair of adjacent time
    points, which are then summed over all time intervals.

    Parameters:
    -----------
    reading_dates : list or pandas.DatetimeIndex
        A sequence of dates corresponding to the disease readings.
    severity_data : pandas.DataFrame
        A dataframe of severity data. The first column must be the ID of the
        individuals, and subsequent columns must contain the numeric severity
        readings corresponding to `reading_dates`.
    plot : bool, default True
        If True, generates a matplotlib plot for each individual showing the
        disease progress curve and shades the area under the curve. The plot 
        window must be closed to proceed to the next individual.

    Returns:
    --------
    pandas.DataFrame
        A dataframe containing two columns: 'ID' (the identifier of the
        individual) and 'AUDPC' (the calculated area under the progress curve).
    """
    
    # 1. Check if dates and data columns match
    if len(reading_dates) != (severity_data.shape[1] - 1):
        raise ValueError("The reading dates and severity data columns do not match.")

    # Initialize the output list
    out_records = []

    # 3. Loop through each individual
    for i in range(len(severity_data)):
        row = severity_data.iloc[i]
        ind_id = row.iloc[0]
        y_vals = row.iloc[1:].values.astype(float)
        
        x_area = 0.0
        
        # Calculate trapezoidal area for each interval
        for j in range(len(reading_dates) - 1):
            time_diff = (reading_dates[j+1] - reading_dates[j]).days
            area = ((y_vals[j] + y_vals[j+1]) / 2) * time_diff
            x_area += area
            
        audpc_val = x_area
        out_records.append({'ID': ind_id, 'AUDPC': audpc_val})
        
        # 4. Generate the Visualization
        if plot:
            plt.figure(figsize=(8, 5))
            
            # Draw the main line graph
            plt.plot(reading_dates, y_vals, marker='o', color='blue', 
                     linewidth=2, label='Disease Severity')
            
            # Shade the Area Under the Curve using fill_between
            plt.fill_between(reading_dates, y_vals, color='steelblue', alpha=0.3)
            
            # Add vertical dashed lines at each reading date for clarity
            for date in reading_dates:
                plt.axvline(x=date, color='gray', linestyle='--')
                
            plt.ylim(0, max(y_vals) * 1.2)
            plt.xlabel("Date")
            plt.ylabel("Disease Severity")
            plt.title(f"Disease Progress Curve - ID: {ind_id}\nAUDPC = {audpc_val:.2f}")
            plt.tight_layout()
            
            # Show the plot. Execution will pause until the user closes the plot window.
            print(f"Showing plot for ID {ind_id}. Close the plot window to continue.")
            plt.show()

    # Convert the records to a DataFrame and return
    return pd.DataFrame(out_records)

### ==========================================
### Example Usage
### ==========================================
##if __name__ == "__main__":
##    # Define reading dates (Convert to pandas datetime objects)
##    reading_dates = pd.to_datetime(["2012-02-13", "2012-02-20", "2012-02-28"])
##
##    # Create example dataset
##    mydat = pd.DataFrame({
##        'ID': ["A", "B", "C", "D"],
##        'Date1': [1, 2, 3, 4],
##        'Date2': [5, 6, 7, 8],
##        'Date3': [11, 12, 13, 14]
##    })
##
##    # Calculate AUDPC and generate plots
##    cd = calculate_audpc(reading_dates, mydat, plot=True)
##    
##    # View the final output table
##    print("\nFinal Output:")
##    print(cd)
