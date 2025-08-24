///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Google Earth Engine Script to Export Monthly MODIS NDVI, EVI, NDWI, and Land Surface Temperature (LST)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

var roi = table;

var startDate = ee.Date('2022-01-01');
var endDate = ee.Date('2023-12-31'); // Full year range

// Function to export individual rasters per month
function exportRasters(collection, bandName, labelPrefix, scale, folder, reducer, visParams) {
  var months = ee.List.sequence(0, endDate.difference(startDate, 'month')).map(function(m) {
    var start = startDate.advance(m, 'month');
    var end = start.advance(1, 'month');
    var label = start.format('YYYY_MM');
    return ee.Dictionary({start: start.millis(), end: end.millis(), label: label});
  });

  months.evaluate(function(monthList) {
    monthList.forEach(function(m) {
      var start = ee.Date(m.start);
      var end = ee.Date(m.end);
      var label = m.label;

      var image = reducer(collection.filterDate(start, end)).select(bandName);

      image = ee.Image(image).clip(roi);
      var bandNames = image.bandNames();

      bandNames.evaluate(function(bands) {
        if (bands.length > 0) {
          print('✅ Exporting:', labelPrefix + '_' + label);
          Map.addLayer(image, visParams, labelPrefix + '_' + label);

          Export.image.toDrive({
            image: image,
            description: labelPrefix + '_' + label,
            folder: folder,
            fileNamePrefix: labelPrefix + '_' + label,
            scale: scale,
            region: roi.geometry(),
            crs: 'EPSG:4326',
            maxPixels: 1e13
          });
        } else {
          print('⚠️ Skipping export for ' + labelPrefix + '_' + label + ': no bands available.');
        }
      });
    });
  });
}

// MODIS (NDVI, EVI, NDWI) from Collection 6.1
var modis = ee.ImageCollection('MODIS/061/MOD13Q1')
  .filterDate(startDate, endDate)
  .select(['NDVI', 'EVI', 'sur_refl_b02', 'sur_refl_b07'])
  .map(function(img) {
    var ndvi = img.select('NDVI').multiply(0.0001).rename('NDVI');
    var evi = img.select('EVI').multiply(0.0001).rename('EVI');
    var nir = img.select('sur_refl_b02').multiply(0.0001);
    var swir = img.select('sur_refl_b07').multiply(0.0001);
    var ndwi = nir.subtract(swir).divide(nir.add(swir)).rename('NDWI');
    return ndvi.addBands(evi).addBands(ndwi).copyProperties(img, ['system:time_start']);
  });

exportRasters(modis, 'NDVI', 'MODIS_NDVI', 250, 'GEE_Kinshasa', function(c) { return c.mean(); }, {
  min: 0,
  max: 1,
  palette: ['white', 'green']
});

exportRasters(modis, 'EVI', 'MODIS_EVI', 250, 'GEE_Kinshasa', function(c) { return c.mean(); }, {
  min: 0,
  max: 1,
  palette: ['white', 'blue']
});

exportRasters(modis, 'NDWI', 'MODIS_NDWI', 250, 'GEE_Kinshasa', function(c) { return c.mean(); }, {
  min: -1,
  max: 1,
  palette: ['brown', 'white', 'blue']
});

// MODIS LST from MOD11A2 (8-day composites) Collection 6.1
var modis_lst = ee.ImageCollection('MODIS/061/MOD11A2')
  .filterDate(startDate, endDate)
  .select('LST_Day_1km')
  .map(function(img) {
    return img.select('LST_Day_1km').multiply(0.02).subtract(273.15).rename('LST_C')
              .copyProperties(img, ['system:time_start']);
  });

exportRasters(modis_lst, 'LST_C', 'MODIS_LST', 1000, 'GEE_Kinshasa', function(c) { return c.mean(); }, {
  min: 0,
  max: 50,
  palette: ['blue', 'cyan', 'green', 'yellow', 'red']
});

