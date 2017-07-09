context("update_station_locations")

# update_station_locations() downloads and imports the proper file ------------

test_that("update_station_locations() downloads and imports the proper file",
          {
            skip_on_cran()

            update_station_locations()

            # Load AAC code/town name list to join with final output
            load(system.file("extdata", "stations_site_list.rda",
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

            expect_equal(ncol(JSONurl_latlon_by_station_name), 14)
            expect_named(
              JSONurl_latlon_by_station_name,
              c(
                "site",
                "dist",
                "name",
                "start",
                "end",
                "lat",
                "lon",
                "source",
                "state",
                "elev",
                "bar_ht",
                "wmo",
                "state_code",
                "url"
              ))
          })
