library(tidyverse)
library(sf)

# https://gis.utah.gov/data/boundaries/citycountystate/
ut_state_boundaries <- sf::read_sf("/Users/jacobeliason/Files/Code/Repos/utmapbot/DATA/Utah_State_Boundary-shp/Utah.shp")

# nw 41.993715, -114.041721
# sw 37.000390, -114.050597
# se 36.999098, -109.045222
# ~ ne 42.028203, -108.923187

st_crs(ut_state_boundaries)$proj4string




wy_pt <- data.frame(lon = -110.758202, lat = 41.195179)
wy_pt_sf <- st_as_sf(wy_pt, coords = c("lon", "lat"), crs = "+proj=longlat +datum=WGS84 +no_defs")

mn_pt <- data.frame(lon = -95.278193, lat = 46.765721)
mn_pt_sf <- st_as_sf(mn_pt, coords = c("lon", "lat"), crs = "+proj=longlat +datum=WGS84 +no_defs")

# Generate random coordinates within specific limits
lat <- round(runif(1, 36.9, 42.1), 4)
lon <- round(runif(1, -114.1, -109.1), 4)
rand_pt <- data.frame(lon, lat) 
rand_pt_sf <- st_as_sf(rand_pt, coords = c("lon", "lat"), crs = "+proj=longlat +datum=WGS84 +no_defs")

sf::st_intersection(ut_state_boundaries, mn_pt_sf)
sf::st_intersection(ut_state_boundaries, wy_pt_sf)
sf::st_intersection(ut_state_boundaries, rand_pt_sf)

test <- sf::st_intersection(ut_state_boundaries, rand_pt_sf)
(test_result <- test$STATE == "Utah")


test_result <- F
while(!test_result){
  lat <- round(runif(1, 36.9, 42.1), 4)
  lon <- round(runif(1, -114.1, -109.1), 4)
  rand_pt <- data.frame(lon, lat) 
  rand_pt_sf <- st_as_sf(rand_pt, coords = c("lon", "lat"), crs = "+proj=longlat +datum=WGS84 +no_defs")
  test <- sf::st_intersection(ut_state_boundaries, rand_pt_sf)
  test_result <- test$STATE == "Utah"
}
