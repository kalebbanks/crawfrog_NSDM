import arcpy
from arcpy.sa import *
import os
import re

###To run code in arcgis pro, copy this line in the python window: 
# exec(open(r"C:\Users\Froglab\Desktop\r project folders\N_SDM\scripts\quant_future_scenario.py").read())

arcpy.CheckOutExtension("Spatial")

# CHANGE Paths
current_raster_path = r"C:\Users\Froglab\Desktop\r project folders\N_SDM\Results\Global\Projections\R.areolata.Current.tif"
future_folder = r"C:\Users\Froglab\Desktop\r project folders\N_SDM\Results\Global\Projections"
output_folder = r"C:\Users\Froglab\Desktop\r project folders\N_SDM\outputs\future_scenario"

#CHANGE depending on model specs
TSS_cutoff = 481

# Step 0: Binary current raster
current_binary = Con(Raster(current_raster_path) < TSS_cutoff, 0, 1)

# CHANGE OUTPUT PATH
current_binary_path = os.path.join(output_folder, "glob_cur_binary.tif")
current_binary.save(current_binary_path)
print(f"Saved current binary raster → {current_binary_path}")

# Step 1: Loop through all future scenario rasters that exactly match the pattern
pattern = re.compile(r'future_scenario_(\d+)\.tif$')

for fname in os.listdir(future_folder):
    match = pattern.search(fname)
    if match:
        scenario_num = match.group(1)
        future_raster_path = os.path.join(future_folder, fname)

        # Binary future raster
        future_binary = Con(Raster(future_raster_path) < TSS_cutoff, 0, 1)

        # Subtract
        binary_minus = future_binary - current_binary

        # Set zeros to NoData
        binary_minus_2 = SetNull(binary_minus == 0, binary_minus)

        # Set 1s to 2
        binary_minus_3 = Con(binary_minus_2 == 1, 2, binary_minus_2)

        # Combine with original binary
        final_raster = Con(IsNull(binary_minus_3), current_binary, binary_minus_3)

        # Save output raster with scenario number
        output_raster = os.path.join(output_folder, f"glob_fs{scenario_num}.tif")
        final_raster.save(output_raster)

        print(f"Processed {fname} → {output_raster}")

print("All matching future scenarios processed successfully!")