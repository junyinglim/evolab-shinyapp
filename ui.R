library(shiny)
library(leaflet)

speciesvars <- c("Show all",
          "Tetragnatha acuta", 
          "Tetragnatha anuenue",
          "Tetragnatha brevignatha",
          "Tetragnatha eurychasma",
          "Tetragnatha hawaiensis",
          "Tetragnatha kamakou",
          "Tetragnatha kauaiensis",
          "Tetragnatha lena",
          "Tetragnatha macracantha",
          "Tetragnatha paludicola",
          "Tetragnatha perkinsi",
          "Tetragnatha pilosa",
          "Tetragnatha polychromata",
          "Tetragnatha quasimodo",
          "Tetragnatha restricta",
          "Tetragnatha stelarobusta",
          "Tetragnatha waikamoi")

mapvars <- c("Show all" = "None",
             "Mean Annual Rainfall (mm)" = "rainfall",
             "Mean Air Temperature (C)" = "temperature")

shinyUI(navbarPage("Evolab-Berkeley", id="nav",
                   
                   tabPanel("Interactive map",
                            div(class="outer",
                                
                                tags$head(
                                  # Include our custom CSS
                                  includeCSS("styles.css")
                                ),
                                
                                leafletOutput("map", width="100%", height="100%"),
                                
                                # Shiny versions prior to 0.11 should use class="modal" instead.
                                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                              draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                              width = 330, height = "auto",
                                              
                                              h2("Spiders of Hawai'i"),
                                              
                                              selectInput(inputId = "species",
                                                          label = "Choose a species to display",
                                                          choices = speciesvars),
                                              selectInput(inputId = "envmap",
                                                          label = "Choose an environmental map to overlay",
                                                          choices = mapvars,
                                                          selected = "None"))
                                ),
                                
                                tags$div(id="cite",
                                         'Data from Essig Museum of Entomology database'
                                )
                            )
                   )
                   

)