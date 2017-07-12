
`%notin%` <- Negate("%in%")

force_double <- function(v) {
  suppressWarnings(as.double(v))
}

# Distance over a great circle. Reasonable approximation.
haversine_distance <- function(lat1, lon1, lat2, lon2) {
  # to radians
  lat1 <- lat1 * pi / 180
  lat2 <- lat2 * pi / 180
  lon1 <- lon1 * pi / 180
  lon2 <- lon2 * pi / 180

  delta_lat <- abs(lat1 - lat2)
  delta_lon <- abs(lon1 - lon2)

  # radius of earth
  6371 * 2 * asin(sqrt(`+`((sin(delta_lat / 2)) ^ 2,
                           cos(lat1) * cos(lat2) * (sin(delta_lon / 2)) ^ 2
  )))
}
