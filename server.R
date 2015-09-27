library(shiny)
library(leaflet)
library(viridis)


# Leaflet bindings are a bit slow; for now we'll just sample to compensate
setwd("~/Dropbox/evolab/evolab-shinyapp/")
occdata <- readRDS("totalOcc.rds")
occdata <- occdata[occdata$genus == "Tetragnatha" & occdata$stateProvince == "Hawaii",]
occdata$Binomial <- paste(occdata$genus, occdata$specificEpithet)

colPara <- colorFactor(palette = viridis(18), occdata$Binomial)
#occdata <- merge(occdata, colPara, by= "Binomial")


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
      clearShapes() %>%
      setView(lng = -157, lat = 20.5, zoom = 8)
  })
  
  # To allow user to subset species
    observe({
      leafletProxy("map", data = targetSpecies()) %>%
        clearShapes() %>%
        addCircleMarkers(lng = ~decimalLongitude, lat = ~decimalLatitude, color = ~colPara(Binomial), fillOpacity = 1, stroke = FALSE)
    })
  
})