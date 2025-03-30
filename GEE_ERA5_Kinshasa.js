///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Google Earth Engine Script to Export Monthly ERA5-Land Temperature and Precipitation (Standalone)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

var roi = table;
var startDate = ee.Date('2022-01-01');
var endDate = ee.Date('2023-12-31');

// ERA5-Land Monthly Aggregated dataset
var era5 = ee.ImageCollection('ECMWF/ERA5_LAND/MONTHLY_AGGR')
  .filterBounds(roi)
  .filterDate(startDate, endDate);

// Function to export ERA5-Land rasters
function exportERA5Rasters(bandName, labelPrefix, scale, folder, reducer) {
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

      var image = era5
        .filterDate(start, end)
        .select(bandName)
        .reduce(reducer)
        .clip(roi);

      // Convert temperature from Kelvin to Celsius
      if (bandName === 'temperature_2m') {
        image = image.subtract(273.15).rename(bandName);
      }

      image = image.set('month_label', labelPrefix + '_' + label);

      var bandNames = image.bandNames();
      bandNames.evaluate(function(bands) {
        if (bands && bands.length > 0) {
          print('✅ Exporting:', labelPrefix + '_' + label);
          print('📦 Preview Image Stats - ' + labelPrefix + '_' + label, image);

          var visParams;
          if (bandName === 'temperature_2m') {
            visParams = {
              min: 0,
              max: 50,
              palette: ['000080', '0000d9', '4000ff', '8000ff', '0080ff', '00ffff',
                        '00ff80', '80ff00', 'daff00', 'ffff00', 'fff500', 'ffda00',
                        'ffb000', 'ffa400', 'ff4f00', 'ff2500', 'ff0a00', 'ff00ff']
            };
          } else if (bandName === 'total_precipitation_sum') {
            visParams = {
              min: 0,
              max: 1,
              palette: ['ffffff', '87ceeb', '4682b4', '00008b']
            };
          } else {
            visParams = {
              min: 0,
              max: 1,
              palette: ['white', 'gray']
            };
          }

          // Add image layer to map for visual inspection
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

// Export ERA5-Land 2m temperature in Celsius
exportERA5Rasters('temperature_2m', 'ERA5_Temp', 1000, 'GEE_Kinshasa', ee.Reducer.mean());

// Export ERA5-Land total precipitation in meters (summed monthly)
exportERA5Rasters('total_precipitation_sum', 'ERA5_Precip', 1000, 'GEE_Kinshasa', ee.Reducer.sum());