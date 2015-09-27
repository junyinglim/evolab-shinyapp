library(shiny)
library(leaflet)
library(viridis)


# Leaflet bindings are a bit slow; for now we'll just sample to compensate
setwd("~/Dropbox/evolab/evolab-shinyapp/")
occdata <- readRDS("totalOcc.rds")
occdata <- occdata[occdata$genus == "Tetragnatha" & occdata$stateProvince == "Hawaii",]
occdata$Binomial <- paste(occdata$genus, occdata$specificEpithet)

colPara <- data.frame(Binomial = unique(occdata$Binomial), Col = viridis(length(unique(occdata$Binomial))))
occdata <- merge(occdata, colPara, by= "Binomial")
occdata$Col <- as.vector(occdata$Col)

##todo## add reserve polygon
##todo## add raster maps
##todo## display collector and locality information when hovering over point
##todo## doesnt seem to be clearing shapes?
##todo## custom colours don't show?

shinyServer(function(input, output, session) {

  ## Interactive Map ###########################################
  
  targetSpecies <- reactive({
    if(input$species == "Show all"){
      return(occdata)
    } else {
      return(occdata[occdata$Binomial == input$species, ])  
    }
  })
  
  # Create the map
  output$map <- renderLeaflet({
    leaflet(data = occdata) %>%
      addTiles() %>%
#      addCircles(lng = ~decimalLongitude, lat = ~decimalLatitude, radius = 100, color = ~Col, fillOpacity = 0.2) %>%
      setView(lng = -157, lat = 20.5, zoom = 8)
  })
  
  # To allow user to subset species
    observe({
      leafletProxy("map", data = targetSpecies()) %>%
        clearShapes() %>%
        addCircles(lng = ~decimalLongitude, lat = ~decimalLatitude, fillOpacity = 0.4, fillColor = ~Col)
    })
  
})