library(shiny)
library(leaflet)

#setwd("~/Dropbox/evolab/evolab-shinyapp/")
occdata <- readRDS("totalOcc.rds")
occdata <- occdata[occdata$genus == "Tetragnatha" & occdata$stateProvince == "Hawaii",]
occdata$Binomial <- paste(occdata$genus, occdata$specificEpithet)

##todo## add reserve polygon
##todo## add raster maps?
##todo## CRS does not seem right; unless the points were incorrectly georeferenced
## USEFUL FUNCTION FOR TROUBLESHOOTING ##
# shinyapps::showLogs()

shinyServer(function(input, output, session) {

  ## Interactive Map ###########################################
  
  filteredData <- reactive({
    occdata[occdata$Binomial %in% input$species, ]
  })

  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(occdata) %>% addTiles() %>%
      setView(lng = -157, lat = 20.5, zoom = 8)
      #setMaxBounds(~min(decimalLongitude), ~min(decimalLatitude), ~max(decimalLongitude), ~max(decimalLatitude))
  })  

  # To allow user to subset species
  observe({
    leafletProxy("map", data = filteredData()) %>%
      clearShapes() %>%
      addCircles(lng = ~decimalLongitude, lat = ~decimalLatitude, layerId=~catalogNumber, fillOpacity = 0.5,color = "red")
  })
  
  # Define popup
  showCollectionInfo <- function(event){
    selectedCollection <- occdata[occdata$catalogNumber == event$id,]
    # Content of popup
    content <- as.character(tagList(
      tags$h4(tags$em(sprintf("%s", selectedCollection$Binomial))),
      tags$br(),
      tags$b(selectedCollection$family),
      tags$br(),
      sprintf("Locality: %s", selectedCollection$locality),
      tags$br(),
      sprintf("Collector: %s", selectedCollection$recordedBy),
      tags$br(),
      sprintf("Date: %s", selectedCollection$eventDate),
      tags$br(),
      selectedCollection$catalogNumber)
    )
    
    leafletProxy("map") %>% addPopups(event$lng, event$lat, popup = content)
  }
  
  # Create a popup when clicking on a map "shape"
  observe({
    leafletProxy("map") %>% clearPopups()
    event <- input$map_shape_click
    if(is.null(event)){
      return()
    } else {
      isolate({
        showCollectionInfo(event)
      })  
    }
  })
  
})
