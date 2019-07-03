
manage_cache <- NULL # nocov start

.onLoad <-
  function(libname = find.package("bomrang"),
           pkgname = "bomrang") {
    # CRAN Note avoidance
    if (getRversion() >= "2.15.1") {
      utils::globalVariables(c("."))

      x <- hoardr::hoard()
      x$cache_path_set(path = "bomrang", type = "user_cache_dir")
      manage_cache <<- x
    }
    options(bomrang.connection = stdin())
  }

"%||%" <- function(a, b) if (!is.null(a)) a else b

# This function is never called.
# It only supresses the "Namespaces in Imports field not imported from:" check
# Suggested by @jeroen in rOpenSci Slack
# https://github.com/opencpu/opencpu/blob/10469ee3ddde0d0dca85bd96d2873869d1a64cd6/R/utils.R#L156-L165

stub <- function(){
  rgdal::readGDAL()
} 
# nocov end