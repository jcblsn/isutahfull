

# setup -------------------------------------------------------------------

library(sf)
library(RSelenium)

# create twitter token ----------------------------------------------------

isutahfull_token <- rtweet::create_token(
  app = "isutahfull",
  consumer_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
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

w <- 512*1.5
h <- 512*1.5

(img_url <- paste0(
  "https://api.mapbox.com/styles/v1/mapbox/satellite-v9/static/",
  paste0(lon, ",", lat),
  ",",zoom,",0/",w,"x",h,"@2x?access_token=", # first digit on this line is zoom level (between 0 and 22)
  Sys.getenv("MAPBOX_PUBLIC_ACCESS_TOKEN")
))

# download the image to a temporary location ------------------------------

temp_file <- tempfile()
download.file(img_url, temp_file)




# identify nearby points of interest --------------------------------------
nearby_point_of_interest <- NA
wiki_link <- paste0("https://en.wikipedia.org/wiki/Special:Nearby#/coord/",lat,",",lon)

rD <- rsDriver(browser="firefox", port=4545L, verbose=F)

# wait a sec
for (i in 1:5){
  print(i)
  date_time<-Sys.time()
  while((as.numeric(Sys.time()) - as.numeric(date_time))<2){} #dummy while loop
}
remDr <- rD[["client"]]
remDr$navigate(wiki_link)

# wait a sec
for (i in 1:5){
  print(i)
  date_time<-Sys.time()
  while((as.numeric(Sys.time()) - as.numeric(date_time))<2){} #dummy while loop
}


# out_text <- remDr$findElement(using = "xpath", value = "/html/body/div[3]/div[3]/div[4]/div[2]/div/ul/li/a/h3")
# out_link <- remDr$findElement(using = "xpath", "/@href")

tmp <- remDr$findElement(using = "tag name", value = "li"); tmp$getElementText()
nearby_point_of_interest <- gsub(as.character(x = tmp$getElementText()), pattern = "\n",replacement = " - ")

if(is.numeric(ifelse(grep("[0-9] km|[0-9] m", nearby_point_of_interest)>0, 1, 0))) {
  nearby_point_of_interest <- paste0(nearby_point_of_interest, " away")
}

# build the status message (text and URL) ---------------------------------

if(nearby_point_of_interest != "Not logged in" & !is.na(nearby_point_of_interest)){

  latlon_details <- paste0(
    emo::ji("pin"), " ",lat, ", ", lon, "\n\n",
    emo::ji("i"), " Nearby point of interest: ",nearby_point_of_interest,"\n\n",
    emo::ji("link"), " ", wiki_link, "\n\n",
    emo::ji("map"), " https://www.openstreetmap.org/#map=17/", lat, "/", lon, "/","\n\n",
    "#utah"
  )
  
} else {
  
  latlon_details <- paste0(
    emo::ji("pin"), " ",lat, ", ", lon, "\n\n",
    emo::ji("i"), " No nearby points of interest","\n\n",
    emo::ji("map"), " https://www.openstreetmap.org/#map=17/", lat, "/", lon, "/","\n\n",
    "#utah"
  )

}

latlon_details

# post the image to Twitter -----------------------------------------------

rtweet::post_tweet(
  status = latlon_details,
  media = temp_file, 
  token = isutahfull_token
)

rD$server$stop()

rm(list = ls())
