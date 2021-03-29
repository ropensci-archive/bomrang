
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
  } # nocov end
