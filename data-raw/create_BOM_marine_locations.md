Get BOM Marine Zones
================

## Get BOM Forecast Marine Zones

BOM maintains a shapefile of forecast marine zone names and their
geographic locations. For ease, we’ll just use the .dbf file part of the
shapefile to extract AAC codes that can be used to add locations to the
forecast `data.frame` that `get_coastal_forecast()` returns. The file is
available from BOM’s anonymous FTP server with spatial data
<ftp://ftp.bom.gov.au/anon/home/adfd/spatial/>, specifically the DBF
file portion of a shapefile,
<ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00003.dbf>

``` r
  utils::download.file(
    "ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00003.dbf",
    destfile = paste0(tempdir(), "marine_AAC_codes.dbf"),
    mode = "wb"
  )

  marine_AAC_codes <-
    foreign::read.dbf(paste0(tempdir(), "marine_AAC_codes.dbf"), as.is = TRUE)
  
  marine_AAC_codes <- marine_AAC_codes[, c(1,3,4,5,6,7)]
```

Save the marine zones to disk for use in the R package.

``` r
 if (!dir.exists("../inst/extdata")) {
      dir.create("../inst/extdata", recursive = TRUE)
    }

  save(marine_AAC_codes, file = "../inst/extdata/marine_AAC_codes.rda",
     compress = "bzip2")
```

## Session Info

``` r
sessionInfo()
```

    ## R version 3.5.1 (2018-07-02)
    ## Platform: x86_64-apple-darwin17.7.0 (64-bit)
    ## Running under: macOS High Sierra 10.13.6
    ## 
    ## Matrix products: default
    ## BLAS/LAPACK: /usr/local/Cellar/openblas/0.3.2/lib/libopenblas_haswellp-r0.3.2.dylib
    ## 
    ## locale:
    ## [1] en_AU.UTF-8/en_AU.UTF-8/en_AU.UTF-8/C/en_AU.UTF-8/en_AU.UTF-8
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] compiler_3.5.1  backports_1.1.2 magrittr_1.5    rprojroot_1.3-2
    ##  [5] tools_3.5.1     htmltools_0.3.6 foreign_0.8-70  yaml_2.2.0     
    ##  [9] Rcpp_0.12.18    stringi_1.2.4   rmarkdown_1.10  knitr_1.20     
    ## [13] stringr_1.3.1   digest_0.6.15   evaluate_0.11
