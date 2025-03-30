# 🌍 Overview of Earth Observation data processing for Kinshasa, DRC

This project integrates satellite remote sensing and weather station data for Kinshasa, Democratic Republic of Congo, to support spatiotemporal analyses of environmental conditions relevant to health.

---

## 1. Weather Station Data: Download and Processing

We extract daily and monthly weather summaries from **NOAA ISD** for multiple stations in and around Kinshasa. This is handled using the [`rnoaa`](https://docs.ropensci.org/rnoaa/) package and organized into clean datasets with standardized naming and formatting. All output is saved as `.csv` files and visualized as time series plots.

**Script**: [`KinshasaWeatherStationData.r`](https://github.com/parker-group/Kinshasa_EO/blob/main/KinshasaWeatherStationData.r)

### Stations Included:

| Station Name       | USAF    | WBAN   |
|--------------------|---------|--------|
| N’djili Intl       | 642100  | 99999  |
| Binza              | 642200  | 99999  |
| Maya Maya (Brazzaville) | 644500 | 99999 |
| N’dolo             | 642110  | 99999  |

### Processing Steps:

- Download ISD records for 2022–2023 for each station
- Clean and quality-control temperature and precipitation values
- Generate:
  - **Daily summaries**: mean temperature and total precipitation
  - **Monthly summaries**: average temperature and cumulative precipitation

### Outputs:

- `daily_weather_[station].csv`  
- `monthly_weather_[station].csv`
- `.png` plots for each station and comparisons across all stations

### Plots:

- Time series of **monthly average temperature**
- Time series of **monthly total precipitation**
- **Comparison plots** of all stations:

![Temperature Comparison](https://github.com/parker-group/Kinshasa_EO/blob/main/docs/temperature_comparison.png)

![Precipitation Comparison](https://github.com/parker-group/Kinshasa_EO/blob/main/docs/precipitation_comparison.png)

---

## 2. Remote Sensing Data via Google Earth Engine

We use Google Earth Engine (GEE) to extract and export monthly raster data for MODIS vegetation and surface water/moisture indices, MODIS and Landsat-derived land surface temperature (LST), and ERA5-modeled temperature and precipitation. All rasters are clipped to the Kinshasa buffer polygon and exported to Google Drive.

### Scripts:
- **MODIS Vegetation & LST**: [`GEE_MODIS_Kinshasa.js`](https://github.com/parker-group/Kinshasa_EO/blob/main/GEE_MODIS_Kinshasa.js)
- **Landsat LST**: [`GEE_Lndst_Kinshasa.js`](https://github.com/parker-group/Kinshasa_EO/blob/main/GEE_Lndst_Kinshasa.js)
- **ERA5 Climate Data**: [`GEE_ERA5_Kinshasa.js`](https://github.com/parker-group/Kinshasa_EO/blob/main/GEE_ERA5_Kinshasa.js)

### Variables Extracted:

| Data Source | Variable     | Output Prefix |
|-------------|--------------|----------------|
| MODIS       | NDVI         | MODIS_NDVI     |
| MODIS       | EVI          | MODIS_EVI      |
| MODIS       | NDWI         | MODIS_NDWI     |
| MODIS       | LST (Day)    | MODIS_LST      |
| Landsat 8   | LST (Surface)| Landsat_LST    |
| ERA5-Land   | Temp (2m)    | ERA5_Temp      |
| ERA5-Land   | Precip (mm)  | ERA5_Precip    |

### Key Features:
- Monthly rasters for Jan 2022 – Dec 2023
- Files exported with prefix + `YYYY_MM` naming convention
- Scripts apply cloud masking (Landsat), band scaling (MODIS, ERA5), and unit conversions (e.g., Kelvin to Celsius)
- `.tif` files organized into subfolders by data source for downstream processing

---

## 3. Load Polygon Shapefile (Health Areas)

We use a shapefile of **health areas in Kinshasa** as the basis for zonal extraction. This is the same polygon layer used in GEE to clip exported rasters.

**Example preview**:
![Shapefile Example](https://github.com/parker-group/Kinshasa_EO/blob/main/ShapesExample.png)

This layer is loaded into QGIS and must be the active vector layer during zonal stats processing.

---

## 4. Zonal Statistics Calculation (QGIS + Python)

A QGIS Python script is used to loop over raster files, calculate zonal statistics for each raster, and attach the resulting values as new columns in the shapefile attribute table.

**Script**: [`RemoteSensZonalStats.py`](https://github.com/parker-group/Kinshasa_EO/blob/main/RemoteSensZonalStats.py)

### Key Features:
- Automatically loops through each subfolder (e.g., `MODIS_EVI`, `ERA5_Precip`, etc.)
- Extracts the date (`YYYYMM`) from each `.tif` file name
- Adds columns to the shapefile with names like: `EVI_202201`, `LLST202307`, `Prcp202212`
- Exports both the updated shapefile and a `.csv` version for use in R

### Output Files:
- [`KinshasaZonalStats_All.shp`](https://github.com/parker-group/Kinshasa_EO)  
- [`KinshasaZonalStats_All.csv`](https://github.com/parker-group/Kinshasa_EO/blob/main/KinshasaZonalStats_All.csv)

This processing step creates the **master remote sensing summary file**, with all variables and months per health area.

### Optional Visualization:
You can also **visualize spatial variation in the remote sensing data by health area** for any given month. For example, below is a choropleth map of MODIS-derived Land Surface Temperature (LST) for a single month, created in QGIS:

![LST Visualization Example](https://github.com/parker-group/Kinshasa_EO/blob/main/ShapesExampleLST.png)

---

## 5. Wrangling and Visualization in R

The processed remote sensing data (`KinshasaZonalStats_All.csv`) is next cleaned and visualized in R to explore temporal trends and summary patterns.

**Script**: [`KinshasaWeatherStationData.r`](https://github.com/parker-group/Kinshasa_EO/blob/main/KinshasaWeatherStationData.r)

### Tasks Performed:
- Load the `.csv` file containing zonal summaries per health area
- Parse and reshape monthly columns (e.g., `EVI_202201`) into long format
- Plot time series of environmental indicators across time

### Example Output:
A sample time series plot of MODIS-derived LST values across multiple months:

![MODIS LST Plot](https://github.com/parker-group/Kinshasa_EO/blob/main/MODIS_LST_TemporalPlot.png)

This step helps assess data completeness, detect anomalies, and understand broad environmental patterns in Kinshasa. [For LST, you can see that some data are missing during some months - often because of cloud cover]

---

_(More sections coming soon for integration with health data and downstream modeling.)_

