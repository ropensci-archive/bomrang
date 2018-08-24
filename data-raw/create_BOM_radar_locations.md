Get BOM Radar Locations
================

Get BOM Radar Locations
-----------------------

BOM maintains a shapefile of radar site names and their geographic locations. For ease, we'll just use the .dbf file part of the shapefile to extract the product codes and radar locations. The file is available from BOM's anonymous FTP server with spatial data <ftp://ftp.bom.gov.au/anon/home/adfd/spatial/>, specifically the DBF file portion of a shapefile, <ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDR00007.dbf>

``` r
  utils::download.file(
    "ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDR00007.dbf",
    destfile = paste0(tempdir(), "radar_locations.dbf"),
    mode = "wb"
  )

  radar_locations <-
    foreign::read.dbf(paste0(tempdir(), "radar_locations.dbf"), as.is = TRUE)
  
  radar_locations$LocationID <- ifelse(test = nchar(radar_locations$LocationID) == 1, 
                                       yes = paste0("0", radar_locations$LocationID), 
                                       no = radar_locations$LocationID)
```

Save the radar locations to disk for use in the R package.

``` r
 if (!dir.exists("../inst/extdata")) {
      dir.create("../inst/extdata", recursive = TRUE)
    }

  save(radar_locations, file = "../inst/extdata/radar_locations.rda",
     compress = "bzip2")
```

Session Info
------------

``` r
sessionInfo()
```

    ## R version 3.4.3 (2017-11-30)
    ## Platform: x86_64-pc-linux-gnu (64-bit)
    ## Running under: Ubuntu 14.04.5 LTS
    ## 
    ## Matrix products: default
    ## BLAS: /usr/lib/libblas/libblas.so.3.0
    ## LAPACK: /usr/lib/lapack/liblapack.so.3.0
    ## 
    ## locale:
    ##  [1] LC_CTYPE=en_AU.UTF-8       LC_NUMERIC=C              
    ##  [3] LC_TIME=en_AU.UTF-8        LC_COLLATE=en_AU.UTF-8    
    ##  [5] LC_MONETARY=en_AU.UTF-8    LC_MESSAGES=en_AU.UTF-8   
    ##  [7] LC_PAPER=en_AU.UTF-8       LC_NAME=C                 
    ##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    ## [11] LC_MEASUREMENT=en_AU.UTF-8 LC_IDENTIFICATION=C       
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] compiler_3.4.3  backports_1.1.2 magrittr_1.5    rprojroot_1.3-2
    ##  [5] tools_3.4.3     htmltools_0.3.6 foreign_0.8-66  yaml_2.2.0     
    ##  [9] Rcpp_0.12.18    stringi_1.2.4   rmarkdown_1.10  knitr_1.20     
    ## [13] stringr_1.3.1   digest_0.6.15   evaluate_0.11
