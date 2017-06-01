 context("update_precis_locations")

 # Timeout options are reset on update_precis_locations() exit -----------------
 test_that("Timeout options are reset on update_precis_locations() exit", {
   skip_on_cran()
   update_precis_locations()
   expect_equal(options("timeout")[[1]], 60)
 })

 # update_precis_locations() downloads and imports the proper file -------------
 test_that("update_precis_locations() downloads and imports the proper file", {
   skip_on_cran()

   update_precis_locations()

   expect_equal(ncol(AAC_codes), 5)
   expect_named(AAC_codes, c("AAC", "PT_NAME", "LON", "LAT", "ELEVATION"))
 })
#
