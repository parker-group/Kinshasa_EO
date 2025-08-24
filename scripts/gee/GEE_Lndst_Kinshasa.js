///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Google Earth Engine Script to Export Monthly Landsat LST Rasters (Standalone)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////



var roi = table;
var startDate = ee.Date('2022-01-01');
var endDate = ee.Date('2023-12-31');

// Function to export individual rasters per month
function exportRasters(collection, bandName, labelPrefix, scale, folder, reducer) {
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
      image = ee.Image(image);
      var bandNames = image.bandNames();

      bandNames.evaluate(function(bands) {
        if (bands.length > 0) {
          print('✅ Exporting:', labelPrefix + '_' + label);

          // Add image layer to map for preview
          Map.addLayer(image.clip(roi), {min: 20, max: 45, palette: ['blue', 'green', 'yellow', 'red']}, labelPrefix + '_' + label);

          Export.image.toDrive({
            image: image.clip(roi),
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

// Landsat 8 Surface Temperature (LST)
var landsat = ee.ImageCollection('LANDSAT/LC08/C02/T1_L2')
  .filterBounds(roi)
  .filterDate(startDate, endDate)
  .filter(ee.Filter.eq('PROCESSING_LEVEL', 'L2SP'));

function maskClouds(image) {
  var qa = image.select('QA_PIXEL');
  var mask = qa.bitwiseAnd(1 << 3).eq(0)
    .and(qa.bitwiseAnd(1 << 4).eq(0))
    .and(qa.bitwiseAnd(1 << 5).eq(0));
  return image.updateMask(mask);
}

function convertToCelsius(image) {
  var lst = image.select('ST_B10')
    .multiply(0.00341802)
    .add(149.0)
    .subtract(273.15)
    .rename('LST_C');
  return lst.copyProperties(image, ['system:time_start']);
}

var lstC = landsat
  .map(maskClouds)
  .map(convertToCelsius);

exportRasters(lstC, 'LST_C', 'Landsat_LST', 30, 'GEE_Kinshasa', function(c) { return c.mean(); });