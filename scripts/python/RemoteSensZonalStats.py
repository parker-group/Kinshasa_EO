# Python script for calculating zonal statistics from raster data, assigning names by type YYYY and MM to the .shp file attribute table

import os
import glob
import qgis.analysis
from qgis.core import QgsVectorFileWriter
import processing

# Get the currently selected vector layer
vectorlayer = qgis.utils.iface.mapCanvas().currentLayer()

# Base folder with raster subdirectories
base_folder = 'G:/Research/Kinshasa_EarthObserve/RemoteSense'

# Raster subfolders, prefixes, and stat types
raster_types = {
    'MODIS_EVI': {'prefix': 'EVI_', 'stat': 2},      # mean, underscore avoids trailing "m"
    'MODIS_NDVI': {'prefix': 'NDVI', 'stat': 2},     # mean
    'MODIS_NDWI': {'prefix': 'NDWI', 'stat': 2},     # mean
    'MODIS_LST': {'prefix': 'MLST', 'stat': 2},      # mean for MODIS LST
    'ERA5_Precip': {'prefix': 'Prcp', 'stat': 2},    # mean
    'ERA5_Temp': {'prefix': 'Temp', 'stat': 2},      # mean
    'Landsat_LST': {'prefix': 'LLST', 'stat': 2}     # mean for Landsat LST
}

# Function to process all rasters in a subfolder
def process_all_rasters(raster_dir, prefix_type, stat_type):
    tif_files = sorted(glob.glob(os.path.join(raster_dir, '*.tif')))
    if not tif_files:
        print(f"No .tif files found in {raster_dir}")
        return
    for path in tif_files:
        filename = os.path.basename(path)
        try:
            # Extract clean YYYYMM from filename
            name_parts = filename.replace('.tif', '').split('_')
            if len(name_parts) >= 3:
                year = name_parts[-2]
                month = name_parts[-1].zfill(2)
                date_part = year + month  # e.g., 202201
            else:
                raise ValueError("Filename does not contain expected YYYY_MM format.")

            column_prefix = f"{prefix_type}{date_part}"
            print(f"Processing {filename} → {column_prefix} using stat {stat_type}")
            params = {
                'INPUT_RASTER': path,
                'RASTER_BAND': 1,
                'INPUT_VECTOR': vectorlayer,
                'COLUMN_PREFIX': column_prefix,
                'STATISTICS': [stat_type]
            }
            processing.run("qgis:zonalstatistics", params)
        except Exception as e:
            print(f"Error processing {filename}: {e}")

# Loop through each raster type
for subfolder, info in raster_types.items():
    raster_path = os.path.join(base_folder, subfolder)
    process_all_rasters(raster_path, info['prefix'], info['stat'])

# Save shapefile
output_path = os.path.join(base_folder, 'KinshasaZonalStats_All.shp')
QgsVectorFileWriter.writeAsVectorFormat(vectorlayer, output_path, "utf-8", vectorlayer.crs(), "ESRI Shapefile")

# Export CSV
csv_output_path = output_path.replace('.shp', '.csv')
with open(csv_output_path, 'w', encoding='utf-8') as f:
    fields = [field.name() for field in vectorlayer.fields()]
    f.write(','.join(fields) + '\n')
    for feat in vectorlayer.getFeatures():
        values = [str(feat[field]) for field in fields]
        f.write(','.join(values) + '\n')

print("🎉 All zonal statistics completed — full dataset processed and saved.")