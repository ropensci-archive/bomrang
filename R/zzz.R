
.onLoad <-
  function(libname = find.package("bomrang"),
           pkgname = "bomrang") {
    # CRAN Note avoidance
    if (getRversion() >= "2.15.1") {
      utils::globalVariables(c("."))

      utils::data(
        "AAC_codes",
        "stations_site_list",
        "JSONurl_latlon_by_station_name",
        package = pkgname,
        envir = parent.env(environment())
      )
    }
  }
