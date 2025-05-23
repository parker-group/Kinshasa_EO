# 🌍 Overview of Earth Observation data processing for Kinshasa, DRC

This project uses remote sensing (satellite) and weather station data for Kinshasa, Democratic Republic of Congo (DRC), to support spatiotemporal analyses of environmental conditions relevant to health. 
For a brief description of the remote sensing data sources and the science behind them, see this document: [`Remote Sensing Data Descriptions`](https://github.com/parker-group/Kinshasa_EO/blob/main/EO_Products.odt)

---

## 1. Weather Station Data: Download and Processing

We extract daily and monthly weather summaries from **NOAA ISD** for multiple stations in and around Kinshasa. This is handled using the [`rnoaa`](https://docs.ropensci.org/rnoaa/) package and organized into clean datasets with standardized naming and formatting. All output is saved as `.csv` files and visualized using maps, time series plots, etc.

**Script**: [`KinshasaWeatherStationData.r`](https://github.com/parker-group/Kinshasa_EO/blob/main/KinshasaWeatherStationData.r)

### Stations Included:

| Station Name       | USAF    | WBAN   |
|--------------------|---------|--------|
| N’djili Intl       | 642100  | 99999  |
| Binza              | 642200  | 99999  |
| Maya Maya (Brazzaville) | 644500 | 99999 |
| N’dolo             | 642110  | 99999  |

**Data files:**
- [`monthly_weather_Ndjili.csv`](https://github.com/parker-group/Kinshasa_EO/blob/main/monthly_weather_Ndjili.csv)
- [`monthly_weather_binza.csv`](https://github.com/parker-group/Kinshasa_EO/blob/main/monthly_weather_binza.csv)
- [`monthly_weather_maya.csv`](https://github.com/parker-group/Kinshasa_EO/blob/main/monthly_weather_maya.csv)
- [`monthly_weather_ndolo.csv`](https://github.com/parker-group/Kinshasa_EO/blob/main/monthly_weather_ndolo.csv)

**Map of approximate station locations:**
![Weather Station Locations](https://github.com/parker-group/Kinshasa_EO/blob/main/WeatherStationLocations.png)

### Processing Steps:

- Download ISD records for 2022–2023 for each station (data are hourly)
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

![Temperature Comparison](https://github.com/parker-group/Kinshasa_EO/blob/main/temperature_comparison.png)

![Precipitation Comparison](https://github.com/parker-group/Kinshasa_EO/blob/main/precipitation_comparison.png)


*Actual weather station data can be nice because they're 'real' data collected on the ground. However, weather station data often come with lots of messiness too. They must be maintained to remain accurate. Birds can lay nests on rain gauges, etc. 

---

## 2. Remote Sensing Data via Google Earth Engine

We use Google Earth Engine (GEE) to extract and export monthly raster data for MODIS vegetation and surface water/moisture indices, MODIS and Landsat-derived land surface temperature (LST), and ERA5-modeled temperature and precipitation. All rasters are clipped to a Kinshasa area polygon shapefile (health area shapefile - plotted below) and exported to Google Drive.

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
| MODIS       | LST          | MODIS_LST      |
| Landsat 8   | LST          | Landsat_LST    |
| ERA5-Land   | Temp (2m)    | ERA5_Temp      |
| ERA5-Land   | Precip (mm)  | ERA5_Precip    |

### Key Features:
- Monthly rasters for Jan 2022 – Dec 2023
- Files exported with prefix + `YYYY_MM` naming convention
- Scripts apply cloud masking (Landsat), band scaling (MODIS, ERA5), and unit conversions (e.g., Kelvin to Celsius)
- `.tif` files organized into subfolders by data source for downstream processing
- **After testing scripts in the GEE Code Editor, batch exports were automated using Google Colab notebooks**, allowing scalable monthly exports without manually clicking "Run" for each task.

> ⚠️ Note: Opening notebooks via “Open in Colab” runs them in your own Google account and does not access the original author's Google Drive or data.

### Google Colab Notebooks Used:
- [`GEE_ERA5_Export_Kinshasa.ipynb`](https://github.com/parker-group/Kinshasa_EO/blob/main/GEE_ERA5_Export_Kinshasa.ipynb)
- [`GEE_MODIS_Vege_Export_Kinshasa.ipynb`](https://github.com/parker-group/Kinshasa_EO/blob/main/GEE_MODIS_Vege_Export_Kinshasa.ipynb)
- [`GEE_MODIS_LST_Export_Kinshasa.ipynb`](https://github.com/parker-group/Kinshasa_EO/blob/main/GEE_MODIS_LST_Export_Kinshasa.ipynb)
- [`GEE_Landsat_LST_Export_Kinshasa.ipynb`](https://github.com/parker-group/Kinshasa_EO/blob/main/GEE_Landsat_LST_Export_Kinshasa.ipynb)

Each notebook includes a complete Earth Engine export pipeline and is fully linked to the user's Google Drive for storage.

---

## 3. Zonal Statistics Calculation (QGIS + Python)

We use a shapefile for **health areas in Kinshasa** as the basis for zonal extraction. This is the same polygon layer used in GEE to clip exported rasters. Presumably we could do the zonal calculations in GEE as well, but for now it seems more efficient to have the time series of rasters in a local hard drive and running the zonal stats in QGIS is quite fast. If we need to recalculate zonal statistics at other aggregations it is also easy since everything is local now. 

**Example preview**:
![Shapefile Example](https://github.com/parker-group/Kinshasa_EO/blob/main/ShapesExample.png)

This layer is loaded into QGIS and must be the active vector layer during zonal stats processing.

A QGIS Python script is used to loop over raster files, calculate zonal statistics for each raster, and attach the resulting values as new columns in the shapefile attribute table. I save the script in a folder on my PC and then direct the Python console in QGIS to its location. It is also possible to run Python script directly through the console. 

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
You can also **visualize spatial variation in the remote sensing data by health area** for any given month. For example, below is a choropleth map of MODIS-derived Land Surface Temperature (LST) for a single month, created in QGIS (underlying raster is peaking out the edges):

![LST Visualization Example](https://github.com/parker-group/Kinshasa_EO/blob/main/ShapesExampleLST.png)


These data are generated from the original raster data below. Note that spatial variation is lost, especially in large polygons in the choropleth above. Often we will instead draw a buffer around a specific location (e.g. geographic coordinates) and then extract summary values (i.e. zonal statistics) to that buffer rather than based on administrative unit polygons - unless polygons are the unit of interest, or if they're essentially of similar shape/size. 

![BinzaMalukoMODISLSTExample1](https://github.com/parker-group/Kinshasa_EO/blob/main/BinzaMalukoMODISLSTExample1.png)

---

## 4. Wrangling and Visualization in R

The processed remote sensing data (`KinshasaZonalStats_All.csv`) is next cleaned and visualized in R to explore temporal trends and summary patterns. Currently the data are 'wide' (a row per location - and there is a colummn per unit of time, per environmental measure type) but we will probably want a 'long' dataset for plotting time-series and doing analyses (this will likely mean that location is repeated across several rows and that each row is a different time point). 

**Script**: [`KinshasaWeatherStationData.r`](https://github.com/parker-group/Kinshasa_EO/blob/main/KinshasaWeatherStationData.r)

### Tasks Performed:
- Load the `.csv` file containing zonal summaries per health area
- Parse and reshape monthly columns (e.g., `EVI_202201`) into long format
- Plot time series of environmental indicators across time

### Example Output:
A sample time series plot of ERA5 temperature and precipitation values across multiple months:

![ERA5 Weather Plot](https://github.com/parker-group/Kinshasa_EO/blob/main/ERA5_BinzaMalukoWeather.png)

A sample time series plot of MODIS-derived LST (land surface temperature) values over time:

![MODIS LST Plot](https://github.com/parker-group/Kinshasa_EO/blob/main/MODIS_LST_BinzaMaluko.png)

A sample time series plot of MODIS-derived NDVI, EVI, and NDWI values over time:

![MODIS Vege Plot](https://github.com/parker-group/Kinshasa_EO/blob/main/MODIS_Vege_BinzaMaluko.png)


Looking at your data can help with assessing data completeness, detect anomalies, and understand broad environmental patterns.

---

_(More sections coming soon for integration with health data and downstream modeling.)_

