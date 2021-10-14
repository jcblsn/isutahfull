
# isutahfull

This repository contains code for the Twitter bot [`isutahfull`](https://twitter.com/isutahfull).

# Attribution

`isutahfull` is part of the ['mapbotverse'](https://github.com/matt-dray/londonmapbot). The author of the original template wrote a very helpful guide to his workflow, which can be found [here](https://www.rostrum.blog/2020/09/21/londonmapbot/).

# Differences from londonmapbot

1. I added code to constrain points within a geographic area using a given shape file.
2. Using RSelenium, I query Wikipedia using the random coordinates to find points of interest. The first is added to the body of the tweet.
3. emo::ji() :)
4. I am working on an image classification model to categorize satellite images as either have "evidence" or "no evidence" of human settlement.

# Image credits

Posted images are copyright of Mapbox/OpenStreetMap/Maxar. This information is embedded in every image.
