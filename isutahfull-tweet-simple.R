
# setup -------------------------------------------------------------------

library(sf)

# create twitter token ----------------------------------------------------

isutahfull_token <- rtweet::rtweet_bot(
  api_key       = Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  api_secret    = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token  = Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret = Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

# pick point within utah state boundaries ---------------------------------

# https://gis.utah.gov/data/boundaries/citycountystate/
ut_state_boundaries <- sf::read_sf("Utah.shp")

# nw 41.993715, -114.041721
# sw 37.000390, -114.050597
# se 36.999098, -109.045222
# ~ ne 42.028203, -108.923187

# st_crs(ut_state_boundaries)$proj4string

test_result <- F
while(!test_result){
  lat <- round(runif(1, 36.9, 42.1), 4)
  lon <- round(runif(1, -114.1, -108.9), 4)
  rand_pt <- data.frame(lon, lat) 
  rand_pt_sf <- st_as_sf(rand_pt, coords = c("lon", "lat"), crs = "+proj=longlat +datum=WGS84 +no_defs")
  test <- sf::st_intersection(ut_state_boundaries, rand_pt_sf)
  test_result <- test$STATE == "Utah"
}

lon <- format(lon, scientific = FALSE)


# build URL and fetch image from Mapbox API -----------------------------

zoom <- 17

# note from https://docs.mapbox.com/help/glossary/zoom-level/
# zoom level 17 corresponds to 1.5 feet/pixel for 512x512
# w*1.5*1.5/ 5280 = 1/3 of a mile wide

scale <- 2.5
w <- 512*scale
h <- 512*scale

(img_url <- paste0(
  "https://api.mapbox.com/styles/v1/mapbox/satellite-v9/static/",
  paste0(lon, ",", lat),
  ",",zoom,",0/",w,"x",h,"@2x?access_token=", # first digit on this line is zoom level (between 0 and 22)
  Sys.getenv("MAPBOX_PUBLIC_ACCESS_TOKEN")
))

# download the image to a temporary location ------------------------------

temp_file <- tempfile(fileext = ".jpeg")
download.file(img_url, temp_file)

# add hashtag -------------------------------------------------------------

keywords <- c("utah","maps","lifeelevated","satellite","landsat","mapbox","rstats","tidyverse","github","wikipedia","openstreetmap", "sentinel2", "utpol", "bot", "opensource")
prob_ut <- .25

(samp_word <- sample(keywords, 1, prob = c(prob_ut,rep(((1-prob_ut)/(length(keywords)-1)),length(keywords)-1))))

# build the status message (text and URL) ---------------------------------

latlon_details <- paste0(
  emo::ji("pin"), " ",lat, ", ", lon, "\n\n",
  emo::ji("map"), " https://www.openstreetmap.org/#map=17/", lat, "/", lon, "/","\n\n",
  paste0("#",samp_word)
)

latlon_details

# post the image to Twitter -----------------------------------------------

rtweet::post_tweet(
  status = latlon_details,
  media = temp_file, 
  media_alt_text = "A satellite capture of a 2000'x2000' plot somewhere in the Beehive State.",
  token = isutahfull_token
)
