# vignettes that depend on internet access need to be precompiled and take a
# while to run
library(knitr)
knit(input = "vignettes/bomrang.Rmd.orig",
     output = "vignettes/bomrang.Rmd")

knit(input = "vignettes/use_case.Rmd.orig",
     output = "vignettes/use_case.Rmd")

# remove file path such that vignettes will build with figures
replace <- readLines("vignettes/bomrang.Rmd")
replace <- gsub("<img src=\"vignettes/", "<img src=\"", replace)
fileConn <- file("vignettes/bomrang.Rmd")
writeLines(replace, fileConn)
close(fileConn)

# build vignettes
library(devtools)
build_vignettes()

# move resource files to /doc
resources <-
  list.files("vignettes/", pattern = ".png$", full.names = TRUE)
file.copy(from = resources,
          to = "doc",
          overwrite =  TRUE)
