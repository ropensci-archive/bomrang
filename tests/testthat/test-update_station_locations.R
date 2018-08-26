
context("update_station_locations")

# If input is no, don't proceed ------------------------------------------------
test_that("update_station_locations() stops if 'no'", {
  skip_on_cran()
  
  f <- file()
  options(bomrang_connection = f)
  ans <- "no"
  write(ans, f)
  expect_error(update_station_locations())
  options(bomrang_connection = stdin())
  close(f)
})

# update_station_locations downloads and imports the proper file ---------------

test_that("update_station_locations() downloads and imports the proper file",
          {
            skip_on_cran()
            
            f <- file()
            options(bomrang_connection = f)
            ans <- "yes"
            write(ans, f)
            update_station_locations()
            
            # Load AAC code/town name list to join with final output
            load(system.file("extdata",
                             "stations_site_list.rda",
                             package = "bomrang"))
            
            # Load JSON URL list
            load(system.file("extdata",
                             "JSONurl_site_list.rda",
                             package = "bomrang"))
            
            expect_equal(ncol(stations_site_list), 11)
            expect_named(
              stations_site_list,
              c(
                "site",
                "dist",
                "name",
                "start",
                "end",
                "lat",
                "lon",
                "state",
                "elev",
                "bar_ht",
                "wmo"
              )
            )
            
            expect_equal(ncol(JSONurl_site_list), 13)
            expect_named(
              JSONurl_site_list,
              c(
                "site",
                "dist",
                "name",
                "start",
                "end",
                "lat",
                "lon",
                "state",
                "elev",
                "bar_ht",
                "wmo",
                "state_code",
                "url"
              )
            )
            
            # reset connection
            options(bomrang_connection = stdin())
            # close the file
            close(f)
          })
