

# setup -------------------------------------------------------------------

library(tidyverse)
library(sf)

# pick point within utah state boundaries ---------------------------------

# https://gis.utah.gov/data/boundaries/citycountystate/
ut_state_boundaries <- sf::read_sf("/Users/jacobeliason/Files/Code/Repos/utmapbot/DATA/Utah_State_Boundary-shp/Utah.shp")

set.seed(20211008)
for(i in 1:5000) {
  
  test_result <- F
  while(!test_result){
    lat <- round(runif(1, 36.9, 42.1), 4)
    lon <- round(runif(1, -114.1, -109.1), 4)
    rand_pt <- data.frame(lon, lat) 
    rand_pt_sf <- st_as_sf(rand_pt, coords = c("lon", "lat"), crs = "+proj=longlat +datum=WGS84 +no_defs")
    test <- sf::st_intersection(ut_state_boundaries, rand_pt_sf)
    test_result <- test$STATE == "Utah"
  }
  
  zoom <- 17
  w <- 512*2
  h <- 512*2
  
  (img_url <- paste0(
    "https://api.mapbox.com/styles/v1/mapbox/satellite-v9/static/",
    paste0(lon, ",", lat),
    # ",",zoom,",0/",w,"x",h,"@2x?access_token=", # first digit on this line is zoom level (between 0 and 22)
    ",",zoom,",0/",w,"x",h,"?access_token=", # first digit on this line is zoom level (between 0 and 22)
    # Sys.getenv("MAPBOX_PUBLIC_ACCESS_TOKEN")
    token
  ))
  
  download.file(img_url, str_c(getwd(),"/DATA/training-images/", "mapbox_",i,"_",lon,"x",lat,"_z",zoom,"_w",w,"_h",h,".jpeg"))
  
}

