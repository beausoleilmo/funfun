library(sf)
library(mapview)
library(dplyr)

# Generate random points 
set.seed(1123)
# Number of points 
n = 100
# Random x and y with epsg::4326 code 
x = runif(n = n, -74.0, -73.0)
y = runif(n = n, 45.0, 46.0)
# Data.frame of the positions 
d = data.frame(x, y)
# Make into sf object
s = st_as_sf(x = d, 
             coords = c('x','y')) |> 
  st_set_crs(value = 4326) |> 
  st_transform(32198)
# Buffer around the points changing the distance 
sp = s |> 
  st_buffer(
    # Distance is random 
    dist = runif(
      n = 10, min = 1000,
      max = 5000)) |> 
  # Get area 
  mutate(area = st_area(geometry))

# Plot values 
mapview(s) + # points 
  mapview(sp) # With buffer 

quantile(sp$area)

# Export the data 
st_write(
  obj = sp, 
  dsn = '~/Desktop/test_gis.gpkg', 
  append=FALSE)
