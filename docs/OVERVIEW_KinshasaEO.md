# 🌍 Overview of Earth Observation data processing for Kinshasa, DRC

This project uses remote sensing (satellite) and weather station data for Kinshasa, Democratic Republic of Congo (DRC), to support spatiotemporal analyses of environmental conditions relevant to health. 
For a brief description of the remote sensing data sources and the science behind them, see this document: [`Remote Sensing Data Descriptions`](https://github.com/parker-group/Kinshasa_EO/blob/main/docs/EO_Products.md)

---

## 1. Weather Station Data: Download and Processing

We extract daily and monthly weather summaries from **NOAA ISD** for multiple stations in and around Kinshasa. This is handled using the [`rnoaa`](https://docs.ropensci.org/rnoaa/) package and organized into clean datasets with standardized naming and formatting. All output is saved as `.csv` files and visualized using maps, time series plots, etc.

**Script**: [`KinshasaWeatherStationData.R`](https://github.com/parker-group/Kinshasa_EO/blob/main/scripts/r/KinshasaWeatherStationData.R)

### Stations Included:

| Station Name             | USAF   | WBAN  |
|--------------------------|--------|-------|
| N’djili Intl             | 642100 | 99999 |
| Binza                    | 642200 | 99999 |
| Maya Maya (Brazzaville)  | 644500 | 99999 |
| N’dolo                   | 642110 | 99999 |

**Data files:**
- [`monthly_weather_Ndjili.csv`](https://github.com/parker-group/Kinshasa_EO/blob/main/data/processed/weather/monthly_weather_Ndjili.csv)
- [`monthly_weather_binza.csv`](https://github.com/parker-group/Kinshasa_EO/blob/main/data/processed/weather/monthly_weather_binza.csv)
- [`monthly_weather_maya.csv`](https://github.com/parker-group/Kinshasa_EO/blob/main/data/processed/weather/monthly_weather_maya.csv)
- [`monthly_weather_ndolo.csv`](https://github.com/parker-group/Kinshasa_EO/blob/main/data/processed/weather/monthly_weather_ndolo.csv)

**Map of approximate station locations:**
![Weather Station Locations](https://github.com/parker-group/Kinshasa_EO/blob/main/figures/WeatherStationLocations.png)

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

![Temperature Comparison](https://github.com/parker-group/Kinshasa_EO/blob/main/figures/temperature_comparison.png)

![Precipitation Comparison](https://github.com/parker-group/Kinshasa_EO/blob/main/figures/precipitation_comparison.png)


*Actual weather station data can be nice because they're 'real' data collected on the ground. However, weather station data often come with lots of messiness too. They must be maintained to remain accurate. Birds can lay nests on rain gauges, etc.* 

---

## 2. Remote Sensing Data via Google Earth Engine

We use Google Earth Engine (GEE) to extract and export monthly raster data for MODIS vegetation and surface water/moisture indices, MODIS and Landsat-derived land surface temperature (LST), and ERA5-modeled temperature and precipitation. All rasters are clipped to a Kinshasa area polygon shapefile (health area shapefile - plotted below) and exported to Google Drive.

### Scripts:
- **MODIS Vegetation & LST**: [`GEE_MODIS_Kinshasa.js`](https://github.com/parker-group/Kinshasa_EO/blob/main/scripts/gee/GEE_MODIS_Kinshasa.js)
- **Landsat LST**: [`GEE_Lndst_Kinshasa.js`](https://github.com/parker-group/Kinshasa_EO/blob/main/scripts/gee/GEE_Lndst_Kinshasa.js)
- **ERA5 Climate Data**: [`GEE_ERA5_Kinshasa.js`](https://github.com/parker-group/Kinshasa_EO/blob/main/scripts/gee/GEE_ERA5_Kinshasa.js)

### Variables Extracted:

| Data Source | Variable     | Output Prefix   |
|-------------|--------------|-----------------|
| MODIS       | NDVI         | MODIS_NDVI      |
| MODIS       | EVI          | MODIS_EVI       |
| MODIS       | NDWI         | MODIS_NDWI      |
| MODIS       | LST          | MODIS_LST       |
| Landsat 8   | LST          | Landsat_LST     |
| ERA5-Land   | Temp (2m)    | ERA5_Temp       |
| ERA5-Land   | Precip (mm)  | ERA5_Precip     |

### Key Features:
- Monthly rasters for Jan 2022 – Dec 2023
- Files exported with prefix + `YYYY_MM` naming convention
- Scripts apply cloud masking (Landsat), band scaling (MODIS, ERA5), and unit conversions (e.g., Kelvin to Celsius)
- `.tif` files organized into subfolders by data source for downstream processing
- **After testing scripts in the GEE Code Editor, batch exports were automated using Google Colab notebooks**, allowing scalable monthly exports without manually clicking "Run" for each task.

> ⚠️ Note: Opening notebooks via “Open in Colab” runs them in your own Google account and does not access the original author's Google Drive or data.

### Google Colab Notebooks Used:
- [`GEE_ERA5_Export_Kinshasa.ipynb`](https://github.com/parker-group/Kinshasa_EO/blob/main/notebooks/GEE_ERA5_Export_Kinshasa.ipynb)
- [`GEE_MODIS_Vege_Export_Kinshasa.ipynb`](https://github.com/parker-group/Kinshasa_EO/blob/main/notebooks/GEE_MODIS_Vege_Export_Kinshasa.ipynb)
- [`GEE_MODIS_LST_Export_Kinshasa.ipynb`](https://github.com/parker-group/Kinshasa_EO/blob/main/notebooks/GEE_MODIS_LST_Export_Kinshasa.ipynb)
- [`GEE_Landsat_LST_Export_Kinshasa.ipynb`](https://github.com/parker-group/Kinshasa_EO/blob/main/notebooks/GEE_Landsat_LST_Export_Kinshasa.ipynb)

Each notebook includes a complete Earth Engine export pipeline and is fully linked to the user's Google Drive for storage.

---

## 3. Zonal Statistics Calculation (QGIS + Python)

The remote sensing workflows above produce a time series of raster datasets. Each raster consists of a grid of pixels where every pixel contains an environmental measurement such as vegetation greenness, surface moisture, temperature, or precipitation. These rasters preserve the full spatial variation present in the original satellite or climate product.

### Step 1: Start with the Raster Data

The example below shows a MODIS-derived Land Surface Temperature (LST) raster for a portion of Kinshasa. Each pixel contains an estimated temperature value (°C), while the pixel size determines the spatial resolution of the dataset. Smaller pixels generally provide finer spatial detail, whereas larger pixels summarize conditions over larger areas. For MODIS LST products, each pixel represents an area on the ground rather than a single point measurement.

![BinzaMalukoMODISLSTExample1](https://github.com/parker-group/Kinshasa_EO/blob/main/figures/BinzaMalukoMODISLSTExample1.png)

While raster data contain rich spatial information, many analyses require environmental values summarized for administrative units, health areas, villages, survey clusters, or buffers around point locations.

### Step 2: Define the unit of analysis

Many analyses require environmental conditions to be summarized for a specific geographic unit. The choice of this unit is an important analytical decision and should be driven by the research question (though sometimes we are limited by data availability).

Common units of analysis include:

- Administrative areas (health areas, wards, districts, counties)
- Villages or settlements
- Survey clusters
- Buffers around households, clinics, schools, or GPS locations
- Ecological or watershed boundaries

In this example, we use health areas in Kinshasa as the unit of analysis.

**Example health area polygons:**

![Shapefile Example](https://github.com/parker-group/Kinshasa_EO/blob/main/figures/ShapesExample.png)

Each polygon serves as a geographic unit for extracting summary values from the underlying raster data.

### Step 3: Calculate zonal statistics

A QGIS Python script is used to loop through raster files, calculate zonal statistics for each raster, and attach the resulting values as new columns in the shapefile attribute table.

The script can be executed from the QGIS Python Console after adjusting folder paths to match your local machine.

**Script**: [`RemoteSensZonalStats.py`](https://github.com/parker-group/Kinshasa_EO/blob/main/scripts/python/RemoteSensZonalStats.py)

#### Key Features

- Automatically loops through each raster subfolder (e.g., `MODIS_EVI`, `MODIS_LST`, `ERA5_Precip`)
- Extracts the date (`YYYYMM`) from raster file names
- Calculates zonal statistics for every polygon
- Adds new columns with names such as:
  - `EVI_202201`
  - `LLST202307`
  - `Prcp202212`
- Exports both an updated shapefile and a `.csv` file for downstream analysis in R

#### Output Files

- `KinshasaZonalStats_All.shp`
- [`KinshasaZonalStats_All.csv`](https://github.com/parker-group/Kinshasa_EO/blob/main/data/processed/zonal/KinshasaZonalStats_All.csv)

This processing step creates the master remote sensing summary dataset, containing environmental measurements for every health area and month.

### Step 4: Visualize polygon-level summaries

After zonal statistics have been calculated, the summarized values can be visualized as a choropleth map. The example below shows mean MODIS-derived Land Surface Temperature (LST) values for each health area during a single month.

![LST Visualization Example](https://github.com/parker-group/Kinshasa_EO/blob/main/figures/ShapesExampleLST.png)

> **Key Concept**
>
> Zonal statistics convert spatially continuous raster data into summary values for discrete geographic units. This simplifies downstream analysis but inevitably reduces spatial detail.

Notice that the choropleth map is derived from the underlying raster shown earlier. Spatial variation within each polygon has been averaged into a single value. This effect becomes more pronounced when polygons are large or environmentally heterogeneous.

For many studies, it may be preferable to construct buffers around specific geographic coordinates and extract zonal statistics to those buffers rather than relying on administrative boundaries. However, when administrative units are the unit of analysis or decision-making, zonal statistics provide a convenient and interpretable summary of environmental conditions.

### Step 5: Repeat the Process Through Time

In practice, remote sensing analyses rarely involve a single raster. Instead, we often work with a time series of raster datasets, with a new raster generated for each month or date.

The figure below shows MODIS-derived Land Surface Temperature (LST) rasters from four different months. Notice that environmental conditions change over time and that some months contain missing pixels because of cloud cover, atmospheric conditions, sensor limitations, or quality-control filtering.

![MODIS LST Time Series](https://github.com/parker-group/Kinshasa_EO/blob/main/figures/MODISLSTexample1.png)

The zonal statistics workflow described above is repeated for every raster in the time series. For example, if there are 24 monthly rasters spanning two years, zonal statistics are calculated 24 times for every polygon in the study area.

The result is a table where each row represents a geographic unit and each column represents an environmental measurement from a specific point in time.

**Example output dataset:**

![Example Zonal Statistics Dataset](https://github.com/parker-group/Kinshasa_EO/blob/main/figures/KinshasaExampleZonaTimes.png)

In this example, each row represents a health area in Kinshasa and each column contains an environmental measurement extracted from a monthly raster. The column names indicate both the environmental variable and the time period (e.g., `EVI_202201` corresponds to the Enhanced Vegetation Index for January 2022).

> **Key Concept**
>
> A time series of raster datasets is transformed into a tabular dataset through repeated zonal extraction. This conversion allows environmental information from satellite imagery and climate products to be integrated with more traditional epidemiologic and demographic datasets and analyzed using standard statistical methods. 

The dataset shown above is currently in a **wide format**, where each environmental variable and time point occupies a separate column.

This structure is useful for storage and export, but many analyses and visualizations are easier using a **long format**, where each row corresponds to a single location and time point.

The next section demonstrates how the data can be reshaped in R for plotting and statistical analysis.

---

## 4. Wrangling and Visualization in R

The processed remote sensing data (`KinshasaZonalStats_All.csv`) is next cleaned and visualized in R to explore temporal trends and summary patterns. Currently the data are 'wide' (a row per location - and there is a colummn per unit of time, per environmental measure type) but we will probably want a 'long' dataset for plotting time-series and doing analyses (this will likely mean that location is repeated across several rows and that each row is a different time point). 

**Script**: [`KinshasaWeatherStationData.R`](https://github.com/parker-group/Kinshasa_EO/blob/main/scripts/r/KinshasaWeatherStationData.R)

### Tasks Performed:
- Load the `.csv` file containing zonal summaries per health area
- Parse and reshape monthly columns (e.g., `EVI_202201`) into long format
- Plot time series of environmental indicators across time

### Example Output:
A sample time series plot of ERA5 temperature and precipitation values across multiple months:

![ERA5 Weather Plot](https://github.com/parker-group/Kinshasa_EO/blob/main/figures/ERA5_BinzaMalukoWeather.png)

A sample time series plot of MODIS-derived LST (land surface temperature) values over time:

![MODIS LST Plot](https://github.com/parker-group/Kinshasa_EO/blob/main/figures/MODIS_LST_BinzaMaluko.png)

A sample time series plot of MODIS-derived NDVI, EVI, and NDWI values over time:

![MODIS Vege Plot](https://github.com/parker-group/Kinshasa_EO/blob/main/figures/MODIS_Vege_BinzaMaluko.png)


Looking at your data can help with assessing data completeness, detect anomalies, and understand broad environmental patterns.

---

_(More sections coming soon for integration with health data and downstream modeling.)_
