 context("update_precis_locations")

 # Timeout options are reset on update_precis_locations() exit -------------------------
 test_that("Timeout options are reset on update_precis_locations() exit", {
   skip_on_cran()
   update_precis_locations()
   expect_equal(options("timeout")[[1]], 60)
 })

 # update_precis_locations() downloads and imports the proper file ---------------------

 test_that("update_precis_locations() downloads and imports the proper file", {
   skip_on_cran()
   curl::curl_download(
     "ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00013.dbf",
     destfile = paste0(tempdir(), "AAC_codes.dbf"),
     mode = "wb"
   )

   # import BOM dbf file
   AAC_codes <-
     foreign::read.dbf(paste0(tempdir(), "AAC_codes.dbf"), as.is = TRUE)
   AAC_codes <- AAC_codes[, c(2:3, 7:9)]

   expect_equal(ncol(AAC_codes), 5)
   expect_named(AAC_codes, c("AAC", "PT_NAME", "LON", "LAT", "ELEVATION"))
 })
#
