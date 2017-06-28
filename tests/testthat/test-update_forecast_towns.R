 context("update_forecast_locations")

 # Timeout options are reset on update_forecast_locations() exit ---------------
 test_that("Timeout options are reset on update_forecast_towns() exit", {
   skip_on_cran()
   update_forecast_towns()
   expect_equal(options("timeout")[[1]], 60)
 })

 # update_forecast_locations() downloads and imports the proper file -----------
 test_that("update_forecast_towns() downloads and imports proper file", {
   skip_on_cran()

   update_forecast_towns()

   expect_equal(ncol(AAC_codes), 5)
   expect_named(AAC_codes, c("AAC", "PT_NAME", "LON", "LAT", "ELEVATION"))
 })
#
