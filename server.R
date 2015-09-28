library(shiny)
library(leaflet)
library(raster)
library(rgdal)

## Import data
#setwd("~/Dropbox/evolab/evolab-shinyapp/")
occdata <- readRDS(file.path("data", "totalOcc.rds"))
occdata <- occdata[occdata$genus == "Tetragnatha" & occdata$stateProvince == "Hawaii",]
occdata$Binomial <- paste(occdata$genus, occdata$specificEpithet)

## Import maps
crs <- CRS("+init=epsg:4326")
rainfallmap <- raster(x = file.path("maps", "rfgrid_mm_state_ann.txt"), crs = crs)
tempmap <- raster(x = file.path("maps", "tair_ann.txt"), crs = crs)

##todo## add reserve polygon
##todo## add legend
##todo## CRS does not seem right; unless the points were incorrectly georeferenced?
##todo## option to choose colour?

## USEFUL FUNCTION FOR TROUBLESHOOTING ##
# shinyapps::showLogs()

shinyServer(function(input, output, session) {

  ## REACTIVES

  filteredData <- reactive({
    if(input$species %in% "Show all"){
      occdata
    } else {
      occdata[occdata$Binomial %in% input$species, ]  
    }
  })
  
  envMap <- reactive({
    if(input$envmap %in% "rainfall"){
      rainfallmap
    }
    else if(input$envmap %in% "temperature"){
      tempmap
    }
  })
  
  ## BASE MAP
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(occdata) %>% addTiles() %>%
      setView(lng = -157, lat = 20.5, zoom = 8)
      #addRasterImage(rainfallmap, opacity = 0.7, colors = "YlGnBu") 
      #setMaxBounds(~min(decimalLongitude), ~min(decimalLatitude), ~max(decimalLongitude), ~max(decimalLatitude))
  })  
  
  ## SPECIES
  # To allow user to subset species
  observe({
    leafletProxy("map", data = filteredData()) %>%
      clearShapes() %>%
      addCircles(lng = ~decimalLongitude,
                 lat = ~decimalLatitude,
                 layerId=~catalogNumber, fillOpacity = 0.5,color = "red")
  })
  
  ## ENVIRONMENTAL MAPS (https://rstudio.github.io/leaflet/raster.html)
  observe({
    if(input$envmap %in% "None"){
      leafletProxy("map") %>%
        clearImages() %>%
        removeShape("legend")
    } else {
      pal <- colorNumeric(
        palette = "YlGnBu",
        domain = values(envMap()),
        na.color = "transparent"
      )
      
      leafletProxy("map") %>%
        clearImages() %>%
        removeShape("legend") %>% 
        addRasterImage(envMap(), opacity =  0.5, colors = pal, layerId = "raster") %>%
        addLegend(position = "bottomleft",
                  pal = pal,
                  values = values(envMap()),
                  title = input$envmap,
                  layerId = "legend")
    }
  })
  
  ## POPUPS
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
