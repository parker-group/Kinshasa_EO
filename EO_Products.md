
# 🛰️ Remote Sensing Data Descriptions

This document provides a brief description of the remote sensing data sources used in the **Kinshasa Earth Observation project** and the scientific rationale behind each dataset. All data are processed via Google Earth Engine (GEE) and organized into standardized monthly raster outputs for downstream analysis.

---

## 1. MODIS (Moderate Resolution Imaging Spectroradiometer)

- **Spatial Resolution**: 250m (NDVI, EVI, NDWI), 1km (LST)  
- **Temporal Resolution**: Daily → aggregated to monthly composites  
- **Variables Used**:
  - **NDVI** (Normalized Difference Vegetation Index): Proxy for vegetation greenness, photosynthetic activity.
  - **EVI** (Enhanced Vegetation Index): Adjusts for canopy background and atmospheric influences.
  - **NDWI** (Normalized Difference Water Index): Indicates vegetation water content and surface water presence.
  - **LST** (Land Surface Temperature): Thermal infrared estimate of land surface skin temperature.
- **Scientific Rationale**:  
  Vegetation and water indices are relevant to mosquito habitat, crop cycles, and land cover change. LST is a key driver of mosquito development and viral replication rates.

---

## 2. Landsat 8 Thermal Data

- **Spatial Resolution**: 30m (resampled thermal band ~100m)  
- **Temporal Resolution**: 16-day revisit → aggregated to monthly composites  
- **Variable Used**:  
  - **LST** (Land Surface Temperature): Derived from thermal infrared bands (TIRS).  
- **Scientific Rationale**:  
  Provides higher spatial detail than MODIS, useful for within-city heterogeneity in urban heat, land cover, and microclimate variation.

---

## 3. ERA5-Land (ECMWF Climate Reanalysis)

- **Spatial Resolution**: ~9km (native grid)  
- **Temporal Resolution**: Hourly → aggregated to monthly summaries  
- **Variables Used**:
  - **2m Temperature** (°C)
  - **Total Precipitation** (mm/month)  
- **Scientific Rationale**:  
  Global reanalysis product with complete coverage, filling gaps where ground station data are missing. Provides long-term climatology and consistency checks with station observations.

---

## 4. Why Combine These Datasets?

- **Cross-validation**: Ground station observations anchor and validate satellite/reanalysis data.  
- **Spatial detail**: MODIS and Landsat provide fine-scale variation, ERA5 provides broad-scale continuity.  
- **Health relevance**: Environmental drivers of disease (temperature, rainfall, vegetation/water availability) are captured across multiple sensors and scales.  

---

## 5. Processing Overview (Quick Reference)

- All rasters clipped to **Kinshasa health area polygons**  
- Naming convention: `<Dataset>_<Variable>_<YYYY_MM>.tif`  
- Cloud masking and scaling applied where relevant (e.g. Landsat, MODIS)  
- Exported from GEE to Google Drive → downloaded to local for zonal statistics  

---

## 6. References

- Huete, A. et al. (2002). Overview of the radiometric and biophysical performance of the MODIS vegetation indices. *Remote Sensing of Environment*.  
- Wan, Z. (2008). New refinements and validation of the MODIS Land-Surface Temperature/Emissivity products. *Remote Sensing of Environment*.  
- Muñoz-Sabater, J. et al. (2021). ERA5-Land: a state-of-the-art global reanalysis dataset for land applications. *Earth System Science Data*.  

---

👉 Return to the main overview: [Overview of Earth Observation data processing for Kinshasa](https://github.com/parker-group/Kinshasa_EO/blob/main/README.md)
