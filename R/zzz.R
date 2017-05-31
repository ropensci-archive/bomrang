
.onLoad <- function(libname = find.package("bomrang"), pkgname = "bomrang"){

  # CRAN Note avoidance
  if (getRversion() >= "2.15.1") {
    utils::globalVariables(c("."))
  }

  packageStartupMessage(
    paste(
      "bomrang is not associated with the Australian Bureau of Meteorology (BOM).\n",
      "BOM aims to make public sector information available on an open and\n",
      "reusable basis where possible, including on its websites. bomrang retrieves\n",
      "these data and formats them for use in R.\n",
      "For full terms and conditions of the use of BOM data, please see:\n",
      "http://www.bom.gov.au/other/copyright.shtml\n")
  )
}
