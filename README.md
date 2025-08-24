# 🌍 Kinshasa Earth Observation Project

This repository contains scripts, data summaries, and workflows for processing and analyzing environmental data from Kinshasa, DRC.

We integrate:

- 🌡️ Ground-based **weather station data** (NOAA ISD)  
- 🛰️ **Satellite remote sensing** from MODIS, Landsat, and ERA5  
- 📍 Zonal summaries using **QGIS** and Python  
- 📊 Visualization and wrangling in **R**  

---

🔗 **Full documentation and figures:**  
👉 [Overview of Earth Observation data processing](https://github.com/parker-group/Kinshasa_EO/blob/main/docs/OVERVIEW_KinshasaEO.md)

---

📁 Key files (examples):
- [`scripts/r/KinshasaWeatherStationData.R`](https://github.com/parker-group/Kinshasa_EO/blob/main/scripts/r/KinshasaWeatherStationData.R) – processes ISD weather data  
- [`scripts/gee/GEE_MODIS_Kinshasa.js`](https://github.com/parker-group/Kinshasa_EO/blob/main/scripts/gee/GEE_MODIS_Kinshasa.js) – extracts MODIS vegetation and LST  
- [`scripts/python/RemoteSensZonalStats.py`](https://github.com/parker-group/Kinshasa_EO/blob/main/scripts/python/RemoteSensZonalStats.py) – calculates zonal stats in QGIS  
- [`data/processed/zonal/KinshasaZonalStats_All.csv`](https://github.com/parker-group/Kinshasa_EO/blob/main/data/processed/zonal/KinshasaZonalStats_All.csv) – master remote sensing summary  

---

👤 Maintainer: [ORCID: 0000-0002-5352-7338](https://orcid.org/0000-0002-5352-7338)

🧪 *Work in progress — expect changes as workflows evolve*
