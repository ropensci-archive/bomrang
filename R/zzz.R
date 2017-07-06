
.onLoad <-
  function(libname = find.package("bomrang"),
           pkgname = "bomrang") {
    # CRAN Note avoidance
    if (getRversion() >= "2.15.1") {
      utils::globalVariables(c("."))

      utils::data(
        "JSONurl_latlon_by_station_name",
        package = pkgname,
        envir = parent.env(environment())
      )
    }
  }

.onAttach <- function(libname, pkgname) {
  msg <- paste0("\nData (c) Australian Government Bureau of Meteorology,\n",
                "Creative Commons (CC) Attribution 3.0 licence or\n",
                "Public Access Licence (PAL) as appropriate.\n",
                "See http://www.bom.gov.au/other/copyright.shtml\n")
  packageStartupMessage(msg)
}
