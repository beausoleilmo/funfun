library(sf)
library(dplyr)
library(mapview)
#' Convert Google maps point to sf 
#'
#' @param coords Set of coordinates (Numeric) in a vector of 2 values copied from Gooogle Maps
#'
#' @returns
#' A formated sf point. 
#' 
#' @export
#'
#' @examples
#' pt = gmaps2sf(coords = c(45.506263131235286, -73.59679476541764))
gmaps2sf <- function(coords) {
  # Invert the order (google maps still has the old format)
  cs = coords[c(2,1)]
  # Make st_point
  pt = sf::st_point(cs) |> 
    # Geometry list 
    sf::st_sfc()  |> 
    # to sf 
    sf::st_as_sf(crs = 4326)
  # Get the points out
  return(pt)
}

pt = gmaps2sf(coords = c(45.506263131235286, -73.59679476541764))
mapview::mapview(pt)
