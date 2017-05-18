library(dplyr)
library(readr)
library(stringi)

bom_stations_raw <-
  read_lines("ftp://ftp.bom.gov.au/anon2/home/ncc/metadata/lists_by_element/alpha/alphaAUS_3.txt")

# This file is a pseudo-fixed width file.
# Line three contains the headers at fixed widths

bom_stations_header_line <- bom_stations_raw[3]

write_lines(bom_stations_raw[grep("^ +[0-9]", bom_stations_raw, perl = TRUE)],
            "./data-raw/bom-stations-no-header.txt")

column_widths <- stri_locate_all_boundaries(bom_stations_header_line)

col_names <- stri_split(bom_stations_raw[3], regex = "\\s+")[[1]]

if (FALSE) {
  # You can run these lines to verify the fwf widths
  underline <- rep(" ", nchar(bom_stations_header_line))
  underline[column_widths[[1]][, 1]] <- "."
  underline <- paste0(underline, collapse = "")

  cat(bom_stations_header_line,
      underline, sep = "\n")
}

starts <- column_widths[[1]][, 1]
ends <- column_widths[[1]][, 2]
ends[7] <- ends[7] - 1
starts[8] <- starts[8] - 1

bom_stations <-
  read_fwf("./data-raw/bom-stations-no-header.txt",
           col_positions = fwf_positions(start = starts,
                                         end = ends,
                                         col_names = col_names))

get_BOM_data <- function(url, filename, write = FALSE) {
  out <-
    rjson::fromJSON(file = url) %>%
    use_series("observations") %>%
    use_series("data") %>%
    lapply(as.data.table) %>%
    rbindlist(use.names = TRUE, fill = TRUE)

  if (write) {
    out %>%
    fwrite(paste0("./bom/",
                  gsub("[^0-9]", "-", as.character(the_time)),
                  filename))
  }
}

for (x in 90e3:100e3) {
  for (STATE in c("V", "N", "Q", "S", "W", "T", "D")) {
    url <- paste0("http://www.bom.gov.au/fwo/ID", STATE, "60901/ID", STATE, "60901.", x, ".json")
    out <- list()
    if ((x %% 1000) == 0) {
      cat(x, " ")
    }
    tryCatch(out <- rjson::fromJSON(file = url),
             error = function(e){
               NULL
             })
    if ("observations" %in% names(out)) {
      name <- out$observations$header[[1]]$name
      data.table(name = name,
                 url = url) %>%
        fwrite("./data-raw/name-by-url.csv", append = TRUE)

    }
  }

}


