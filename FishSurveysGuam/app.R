library(shiny)
library(tidyverse)
library(dplyr)
library(readr)
library(ggplot2)
library(tidyr)
library(bslib)
library(here)
library(leaflet)
library(leaflet.extras)
library(sf)
library(htmltools)

###----- Read in data ----------------  ###
guMPAshp <- st_read("gu_mpa.shp") #shapefile of the MPAs on Guam
guHABITATshp <- st_read("guam_habitat.shp")
cnmiFS <- read_csv("CRCP_Reef_Fish_Surveys_CNMI_Guam.csv") #NCRMP surveys in the Marianas Islands
guHABITATshp <- st_read("guam_habitat.shp")
 


###-----Tidy data for the leaflet ----------------  ### 
guamFS <- cnmiFS %>% 
  filter(ISLAND == "Guam", #we only want to look at species on Guam
         COMMON_NAME %in% c("Pacific longnoseparrotfish", "Humphead wrasse",
                            "Steephead parrots", "Tan-faced parrotfish",
                            "Filament-finned parrotfish","Ember parrotfish")) %>% #filter common names of the FMP targeted species
  mutate(COMMON_NAME = recode(COMMON_NAME, #rename for clear legend/select bar
                              "Pacific longnoseparrotfish" = "Pacific Longnose Parrotfish",
                              "Humphead wrasse" = "Humphead Wrasse",
                              "Steephead parrots" = "Steephead Parrotfish",
                              "Tan-faced parrotfish" = "Tan-faced Parrotfish",
                              "Filament-finned parrotfish" = "Filament-finned Parrotfish",
                              "Ember parrotfish" = "Ember Parrotfish")) %>%
  mutate(latitude = as.numeric(latitude), #the lat and long columns were character values, mutate to numeric
         longitude = as.numeric(longitude),
         MPA_STATUS = 0) #create column indicating if coords are within a MPA

mypalette <- colorFactor(palette = "Paired", guamFS$COMMON_NAME) #establish color system for the leaflet

guHABITATshp <- st_read("guam_habitat.shp") %>% 
  st_transform(crs = 4326) %>% #need to be same datum for shiny
  filter(POLYGONID != 1061, #return values except giant ocean polygon layer that covers the island 
         D_STRUCT != c("Land", "Unknown")) #return values all except land and unknown that covers the island
habitatPalette <- colorFactor("Set1", domain = guHABITATshp$M_COVER) #color palette for habitat


###-----Tidy data for the occurrence of fish inside vs outside of MPAs ------ ###
## for the map
MPApoints <- st_as_sf(guamFS, #convert dataframe to sf object
                      coords = c("longitude", "latitude"),
                      crs = 4326) %>%
  mutate(longitude = st_coordinates(.)[,1], #extract long bc it will disappear when converted to shp
         latitude = st_coordinates(.)[,2], #extract lat bc it will disappear when converted to shp
         MPA_STATUS = 1) %>% #if coords are in MPA, MPA_STATUS = 1
  st_filter(guMPAshp) %>% #filter for the points within the MPA/shp
  st_drop_geometry() %>% #convert back to df from an sf object
  select(OBJECTID, MPA_STATUS)

#establish a df to assign the colors to a specific species - we do not want them to be reactive since it is visually confusing for the user
species_colors <- c(
  "Ember Parrotfish" = "#E41A1C",           # Red
  "Filament-finned Parrotfish" = "#377EB8", # Blue
  "Humphead Wrasse" = "#4DAF4A",            # Green
  "Pacific Longnose Parrotfish" = "#984EA3", # Purple
  "Steephead Parrotfish" = "#FF7F00",          # Orange
  "Tan-faced Parrotfish" = "#FFFF33"        # Yellow
)

#join the fish survey data with data that reflects if coords fall in MPA or are unprotected  
MPApoints_joined <- left_join(guamFS, MPApoints, by = "OBJECTID") %>%
  mutate(MPA_STATUS = if_else(!is.na(MPA_STATUS.y), #if MPA_STATUS.y is not an NA (values are either NA or 1, while MPA_STATUS.x = 0)
                              "MPA", #set value to 1 IF TRUE, coords occur within the MPA
                              "Unprotected")) %>%  #set to 0 IF FALSE, coords occur outside of the MPA
  select(-MPA_STATUS.x, -MPA_STATUS.y) %>% #remove columns that needed to be joined
  drop_na(COUNT) %>%
  mutate(COMMON_NAME = factor(COMMON_NAME, levels = names(species_colors))) #COMMON_NAME factor for colors/categories and organization in plot


  
######## for the bar plot 
MPApointsbarplotdata <- MPApoints_joined %>%
  group_by(OBS_YEAR, MPA_STATUS, COMMON_NAME) %>% #group we want for fish counts/observations
  summarise(TOTAL_COUNT = sum(COUNT)) %>% #summarise counts based on the grouping above
  mutate(OCCURRENCE = TOTAL_COUNT / sum(TOTAL_COUNT)) #calculate the occurrence and new column

############## for the line graph 
speciessize <- MPApoints_joined %>%
  drop_na(SIZE_) %>% #drop NA for size
  group_by(COMMON_NAME, MPA_STATUS, HABITAT_TYPE, SIZE_) %>% #groupings we want
  summarise(TOTAL_COUNT = sum(COUNT)) %>% #summarise counts based on grouping above
  mutate(OCCURRENCE = TOTAL_COUNT / sum(TOTAL_COUNT)) #calculate occurrence and new column

#unique values for our reactive
unique_species <- unique(speciessize$COMMON_NAME)
unique_habitats <- unique(speciessize$HABITAT_TYPE)



###----------------- UI ----------------------------- ###

ui<- navbarPage(
  title = "Fisheries Management Plan Species on Guam",
  tabPanel(
    title = "Species Map",

      leafletOutput("map", height = 800) #map take up most of page with 800 height
    
  ),
  
  #tab for the barplot
  tabPanel(
    title = "Fish Occurrence within MPAs on Guam",
    checkboxGroupInput("selected_species", #checkbox so we can select multiple species and compare change over time
                       label = "Select Species", #label above input
                       choices = unique(MPApointsbarplotdata$COMMON_NAME),
                       selected = unique(MPApointsbarplotdata$COMMON_NAME)[1]), #automatic selection for first species
    plotOutput("barplot")),
  
  #tab for species size
  tabPanel(
    title = "Fish Size across Species and Habitat",
    layout_sidebar(
      sidebar = sidebar(
        width = 300,
        checkboxGroupInput("selected_species_size", #checkbox to select multiple species 
          label = "Select Species", #label above input
          choices = unique_species, #species chosen
          selected = unique_species[1:2] #automatic selection for 1st and 2nd species
        ),
        selectInput(inputId = "selected_habitat", #dropdown list to select habitat
                    label = "Select Habitat Type", #label above the input
                    choices = unique_habitats,
                    selected = unique_habitats[1] #automatic selection for 1st habitat choice
                    )
        ),
      plotOutput("size_plot", height = 700) #plot take up most of page w 700 height
 
  )
  ) 
)



### ---- SERVER ----------- ###

server<-function(input, output) {
  output$map <- renderLeaflet({
    
    leaflet(guamFS) %>% #guamFS data used for leaflet
      addProviderTiles("Esri.WorldImagery") %>% #add base layer for map
      setView(lng = 144.6973, lat = 13.45, zoom = 11) %>% #set location of map 
      addPolygons(data = guMPAshp,
                  color = "red", #border color
                  weight = 1, #thickness of border
                  dashArray = "10, 5", #make line dashed
                  opacity = 1.0, #solid line color              
                  fillOpacity = 0.15, #make MPA transparent           
                  fillColor = "red",
                  popup = ~name) %>% #show the name of the MPA if user clicks
      addPolygons(data = guHABITATshp,
                  color = "black",           
                  weight = 1,                  
                  opacity = 1.0, #solid outline color              
                  fillOpacity = 1,         
                  fillColor = ~colorFactor("Paired",D_STRUCT)(D_STRUCT)) %>% #color 
      addCircleMarkers(lng = ~longitude, #coordinates using column name
                       lat = ~latitude,  #coordinates using column name
                       color = ~mypalette(COMMON_NAME), #color based on palette made
                       #              popup = mytext_popup,
                       popup = paste0("Common Name: ", guamFS$COMMON_NAME, "<br/>", #text for popup species name, next line
                                      "Year: ", guamFS$OBS_YEAR), #text for year
                       clusterOptions = markerClusterOptions() #use markerCluster because there are multiple duplicates of lat/long 
      ) %>%
      addLegend(
        title = "Habitat Type",
        position = "bottomright",
        pal = colorFactor("Set1", domain = guHABITATshp$D_STRUCT), #color palette
        values = guHABITATshp$D_STRUCT, #D_STRUCT assigned to colors
        opacity = 1) %>%
      addScaleBar(position = "bottomleft") #add scale bar
  
  })
  
  #reactive bar plot based on species chosen
  fishoccurrence <- reactive({                         
    req(input$selected_species) 
    
    MPApointsbarplotdata %>%
      filter(COMMON_NAME %in% input$selected_species) #filter output based on species selected (can be multiple)
  })
  
  #reactive data for the size plot
  filterforsize <- reactive({
    req(input$selected_species_size)
    req(input$selected_habitat)
    
    speciessize %>%
      filter(COMMON_NAME %in% input$selected_species_size, #filter output based on species name (can be multiple)
             HABITAT_TYPE == input$selected_habitat) %>% #filter output based on single habitat type
      droplevels() #drop factors used for categories/colors in previous plot
  })
  
  #render a bar plot
  output$barplot <- renderPlot({                         

    ggplot(fishoccurrence(),
           aes(x = MPA_STATUS, y = OCCURRENCE, 
               fill = COMMON_NAME)) + #make species colors distinct when plotting
      geom_bar(stat="identity", position="dodge") + #columns separateed
      facet_wrap(~OBS_YEAR) + #facet by year to compare change over time
      scale_fill_manual(values = species_colors) + #assigned species colors so colors are not reactive
      labs(title = "Occurrence by MPA Status, Species, and Year",
           x="MPA Status",
           y="Occurrence (Proportion of Total Count for Species/Year)",
           fill="Species") +
      theme_minimal() + #assign a theme
      theme(plot.title = element_text(size = 18,
                                      face = "bold"),
            axis.title = element_text(size = 14,
                                         face = "bold"),
            strip.background = element_rect(fill= "lightgrey"), #background color for facetwrap year
            strip.text = element_text(face = "bold", #bold text
                                      size = 13))
  })
  
  #render a line graph
  output$size_plot <- renderPlot({
    
    filterforsizemessage <- filterforsize() 
    if(nrow(filterforsizemessage) == 0) { #if a row is 0 (there is no count for species and habitat)
      return(ggplot() + #must use ggplot to display text
               annotate("text", x = 0.5, y = 0.5, #center the text 
                        label = "No data found for the selected combination of Species and Habitat.") + 
               theme_void()) #remove plot
    }
    
    ggplot(filterforsizemessage,
           aes(x = SIZE_, y = OCCURRENCE)) +
      geom_smooth(aes(group = COMMON_NAME, #smooth line for common name
                      color = COMMON_NAME, #line color 
                      fill = COMMON_NAME), #se color
                  method = "loess", #smoothing method
                  alpha = 0.2, #transparency of se
                  linewidth = 1.3) + #width of line
      facet_wrap(~MPA_STATUS, #facet wrap by MPA status
                 ncol = 1, #place plots in one column 
                 scales = "free_y") + #free y scales to react to data
      labs(title = paste0("Fish Size Structure by MPA Status in: ", input$selected_habitat),
           x = "Fish Size (cm)",
           y = "Occurrence (Proportion of Total Count)",
           color = "Species", 
           fill = "Species") +
      theme_minimal() +
      theme(legend.position = "bottom", #place legend at bottom of plot
            plot.title = element_text(hjust = 0.5, #position title in the middle
                                      face = "bold",
                                      size = 18),
            strip.background = element_rect(fill= "lightgrey"), #background color
            strip.text = element_text(face = "bold", #bold text
                                      size = 16) #size of text
            )
    })
  output$value <- renderPrint({ input$checkGroup })
  
  
  
}
shinyApp(ui = ui, server = server)
