// var pkg_ET = {};
// var pkg_ET = require('users/kongdd/gee_PML2:src/pkg_forcing.js');
var pkg_ET = require('users/kongdd/gee_PML2:src/pkg_ET.js');

/** tidy ERA5L data for PML */
pkg_ET.ERA5L_hourly = function (img) {
    var bands_m = [
        "total_precipitation_hourly",  // m
        "runoff_hourly",               // m
        "total_evaporation_hourly", "potential_evaporation_hourly",
        "evaporation_from_bare_soil_hourly", "evaporation_from_open_water_surfaces_excluding_oceans_hourly",
        "evaporation_from_the_top_of_canopy_hourly", "evaporation_from_vegetation_transpiration_hourly"];
    var bands_perc = [
        // soil volume, 0-7, 7-28, 28-100, 100-289 cm
        "volumetric_soil_water_layer_1", "volumetric_soil_water_layer_2", //m3/m3
        "volumetric_soil_water_layer_3", "volumetric_soil_water_layer_4"];

    var Tair = img.select(['temperature_2m'], ['T']).subtract(273.15);
    var Tdew = img.select(['dewpoint_temperature_2m'], ['Tdew']).subtract(273.15);
    var Pa = img.select('surface_pressure').rename('Pa').divide(1000); //Pa to kPa
    var U10 = img.select(["u_component_of_wind_10m", "v_component_of_wind_10m"], ['u', 'v'])
        .expression("sqrt(b('u')*b('u') + b('v')*b('v'))");
    var U2 = img.expression('U10*4.87/log(67.8*10-5.42)', { U10: U10 }).rename('U2');

    var q = ee.Image(pkg_ET.Tdew2q(Tdew, Pa)).rename('q'); // kg/kg
    var Rn = img.select([
        'surface_net_solar_radiation_hourly', // note: Rns not Rn,
        'surface_solar_radiation_downwards_hourly',
        'surface_thermal_radiation_downwards_hourly'], ['Rn', 'Rs', 'Rln'])
        .divide(3600); // J m-2 h-1 to W m-2

    var img_mm = img.select(bands_m).multiply(1000 * 24) // m/h -> mm/d, hourly to daily
        .rename(['Prcp', 'R', 'ET', 'PET', 'Es', 'ET_water', 'Ei', 'Ec']);
    var img_perc = img.select(bands_perc, ['S_l1', 'S_l2', 'S_l3', 'S_l4']);
    
    var time_start = ee.Date(img.get('system:time_start'));
    return ee.Image([Tair, Pa, U2, q, Rn, img_mm, img_perc])
        .copyProperties(img, img.propertyNames())
        .set('date', time_start.format('yyyy-MM-dd'));
}

// extra variables for ET_CR
pkg_ET.ERA5L_hourly_extra = function (img) {
    var Tdew = img.select(['dewpoint_temperature_2m'], ['Tdew']).subtract(273.15);
    var Tskin = img.select(['skin_temperature'], ['Tskin']).subtract(273.15);

    var Ra = img.select([
        'surface_net_thermal_radiation_hourly',
        'surface_net_solar_radiation_hourly'
        // 'surface_solar_radiation_downwards_hourly',
        // 'surface_thermal_radiation_downwards_hourly'
    ], ['Rnl', 'Rns']).divide(3600); // J m-2 h-1 to W m-2
    var Rn = Ra.expression("b('Rnl') + b('Rns')").rename('Rn')

    var time_start = ee.Date(img.get('system:time_start'));
    var ans = ee.Image([Tdew, Tskin, Rn])
        .copyProperties(img, img.propertyNames())
        .set('date', time_start.format('yyyy-MM-dd'));
    return ee.Image(ans);
}

pkg_ET.CFSV2_hourly = function (img) {
    img = ee.Image(img);
    var bands_perc = [
        // soil volume, 0-7, 7-28, 28-100, 100-289 cm
        "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_5_cm",
        "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_25_cm",
        "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_70_cm",
        "Volumetric_Soil_Moisture_Content_depth_below_surface_layer_150_cm"]; // volume fraction, m3/m3
    var img_perc = img.select(bands_perc, ['S_l1', 'S_l2', 'S_l3', 'S_l4']);
    var Tair = img.select([
        'Temperature_height_above_ground',
        'Maximum_temperature_height_above_ground_6_Hour_Interval',
        'Minimum_temperature_height_above_ground_6_Hour_Interval'],
        ['Tavg', 'Tmax', 'Tmin']).subtract(273.15);
    var Pa = img.select('Pressure_surface').rename('Pa').divide(1000); //Pa to kPa
    var U10 = img.select(["u-component_of_wind_height_above_ground",
        "v-component_of_wind_height_above_ground"], ['u', 'v'])
        .expression("sqrt(b('u')*b('u') + b('v')*b('v'))");
    var U2 = img.expression('U10*4.87/log(67.8*10-5.42)', { U10: U10 }).rename('U2');

    var q = img.select('Specific_humidity_height_above_ground').rename('q'); // kg/kg
    var Rn = img.expression("Rln - Rl_out + Rs - Rs_out", {
        Rln: img.select("Downward_Long-Wave_Radp_Flux_surface_6_Hour_Average"),
        Rl_out: img.select("Upward_Long-Wave_Radp_Flux_surface_6_Hour_Average"),
        Rs: img.select("Downward_Short-Wave_Radiation_Flux_surface_6_Hour_Average"),
        Rs_out: img.select("Upward_Short-Wave_Radiation_Flux_surface_6_Hour_Average"),
    }).rename('Rn');
    var Ra = img.select([
        'Downward_Long-Wave_Radp_Flux_surface_6_Hour_Average',
        'Downward_Short-Wave_Radiation_Flux_surface_6_Hour_Average',
        'Sensible_heat_net_flux_surface_6_Hour_Average'],
        ['Rs', 'Rln', 'H']); // W m-2
    var Prcp = img.select('Precipitation_rate_surface_6_Hour_Average').multiply(86400).rename('Prcp'); // kg/m^2/s^1 -> mm/d
    var ET = pkg_ET.W2mm(img.select(['Latent_heat_net_flux_surface_6_Hour_Average',
        'Potential_Evaporation_Rate_surface_6_Hour_Average']),
        Tair.select('Tavg')).rename(['ET', 'PET']); // mm/d

    var time_start = ee.Date(img.get('system:time_start'));
    var ans = ee.Image([Tair, q, Pa, U2, Prcp, Ra, Rn, ET, img_perc])
        .copyProperties(img, img.propertyNames())
        .set('date', time_start.format('yyyy-MM-dd'));
    return ee.Image(ans);
};

pkg_ET.GLDASv2_hourly = function (img) {
    // change unit into daily
    var Prcp = img.select(['Rainf_f_tavg', 'Evap_tavg']).rename(['Prcp', 'ET']).multiply(86400); // kg/m^2/s to mm/d
    var Tair = img.select('Tair_f_inst').subtract(273.15).rename('Tair');   // 2m air mean temperature
    var Ra = img.select(['LWdown_f_tavg', 'SWdown_f_tavg', 'Lwnet_tavg', 'Swnet_tavg', 'Qg_tavg'])
        .rename(['Rln', 'Rs', 'Rnl', 'Rns', 'G']); // W m^-2
    var Rn = Ra.expression("b('Rnl') + b('Rns')").rename('Rn');
    var lambda = img.expression('2500 - 2.2*Tair', { Tair: Tair }); //2500 KJ/kg
    var coef_W2mm = lambda.divide(86.4); // ET./lambda*86400*10^-3;
    var ET = img.select(['PotEvap_tavg', 'ECanop_tavg', 'ESoil_tavg', 'Tveg_tavg'])
        .divide(coef_W2mm)
        .rename(['PET', 'Ei', 'Es', 'Ec'])
        .copyProperties(img)
        .copyProperties(img, ['system:time_start']);
    var img_perc = img.select([
        'SoilMoi0_10cm_inst',
        'SoilMoi10_40cm_inst',
        'SoilMoi40_100cm_inst',
        'SoilMoi100_200cm_inst'
    ], ['S_l1', 'S_l2', 'S_l3', 'S_l4']);

    var q = img.select(['Qair_f_inst']).rename('q');                               // [kg/kg]
    var Pa = img.select(['Psurf_f_inst']).divide(1000).rename('Pa');                  // [Pa] to [kPa]
    var U2 = img.expression('U10*4.87/log(67.8*10-5.42)', { U10: img.select(['Wind_f_inst']) })
        .rename('U2'); // 10m to 2m
    
    var time_start = ee.Date(img.get('system:time_start'));
    var ans = ee.Image([Tair, q, Pa, U2, Ra, Rn, Prcp, ET, img_perc])
        .copyProperties(img, img.propertyNames())
        .set('date', time_start.format('yyyy-MM-dd'));
    return ee.Image(ans);
};

exports = pkg_ET;
