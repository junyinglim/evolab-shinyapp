library(shiny)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)

# Leaflet bindings are a bit slow; for now we'll just sample to compensate
#setwd("~/Dropbox/evolab/evolab-shinyapp/")
occdata <- readRDS("totalOcc.rds")
occdata <- occdata[occdata$order == "Araneae" & occdata$stateProvince == "Hawaii",]

##todo## add species points
##todo## add reserve polygon
##todo## add raster maps

shinyServer(function(input, output, session) {

  ## Interactive Map ###########################################

  # Create the map
  output$map <- renderLeaflet({
    leaflet(data = occdata) %>%
      addTiles() %>%
      addCircleMarkers(lng = ~decimalLongitude, lat = ~decimalLatitude) %>%
      setView(lng = -157, lat = 20.5, zoom = 8)
  })
  
})