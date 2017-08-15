
.onLoad <-
  function(libname = find.package("bomrang"),
           pkgname = "bomrang") {
    # CRAN Note avoidance
    if (getRversion() >= "2.15.1") {
      utils::globalVariables(c("."))
    }
  }

.onAttach <- function(libname, pkgname) {
  msg <- paste0("\nData (c) Australian Government Bureau of Meteorology,\n",
                "Creative Commons (CC) Attribution 3.0 licence or\n",
                "Public Access Licence (PAL) as appropriate.\n",
                "See http://www.bom.gov.au/other/copyright.shtml\n")
  packageStartupMessage(msg)
}

# This function is never called.
# It only supresses the "Namespaces in Imports field not imported from:" check
# Suggested by @jeroen in ROpenSci Slack
# https://github.com/opencpu/opencpu/blob/10469ee3ddde0d0dca85bd96d2873869d1a64cd6/R/utils.R#L156-L165

stub <- function(){
  rgdal::readGDAL()
}
