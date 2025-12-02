# Malilay_Final_Project
This repository contains the contents for Ally's Final OCN 682 Project. 

# Background
A ban on commercial sales for the Ember Parrotfish, Filament-finned Parrotfish, Humphead Wrasse, Pacific Longnose Parrotfish, Steephead Parrotfish, and Tan-faced Parrotfish is being considered for Guam's first Fisheries Management Plan. Data from NOAA Pacific Islands Fisheries Science Center (PIFSC), the Pacific Islands Ocean Observing System (PacIOOS), and National Centers for Coastal Ocean Science (NCCOS) were used to show the occurrence of these six species around the island from 2014, 2017, and 2022. 

# Shiny Application
View the interactive application [here](https://amalilay.shinyapps.io/FishSurveysGuam/).

# Data Dictionary
**Three datasets** were used this final project.

## 1. CRCP_Reef_Fish_Surveys_CNMI_Guam.csv
NOAA PIFSC leads the National Coral Reef Monitoring Program (NCRMP) missions around the Mariana Archipelago.
These surveys include stationary point count (SPC) protocol for fish count surveys where a pair of divers conduct simultaneous counts in adjacent, 15-m-diameter cylindrical plots extending from the substrate to the limits of vertical visibility. Each count consists of two components. This table reflects all variables used from the dataset.

| Variable | Definition |
|----|----|
| `latitude` | Site latitude in decimal degrees |
| `longitude` | Site longitude in decimal degrees |
| `OBJECTID` | Unique identifier for an observation |
| `ISLAND` | Island or atoll surveyed |
| `OBS_YEAR` | Year the survey was conducted |
| `HABITAT_TYPE` | Benthic habitat classification observed (e.g., Aggregate Patch Reef, Spur and Groove) |
| `COMMON_NAME` | Common name of the species in the sample |
| `COUNT` | Number of fish observed for that segment |
| `SIZE_` | Total length of fish, measured from tip of snout to tip of longer lobe of caudal fin in cm |


## 2. gu_mpa.shp
NOAA PacIOOS updated the boundaries for the Marine Protected Areas (MPAs) on Guam. 

| Variable | Definition |
|----|----|
| `fid` | identification number of the geometry |
| `name` | Site longitude in decimal degrees |
| `area_km2` | area of the MPA |
| `desig` | the level of protection of the preserve (e.g., Marine Protected Area, Sanctuary) |
| `gov_type` | the governmental agency that oversees the MPA  |
| `geometry` | spatial features containing polygons |

## 3. guam_habitat.shp
NOAA NCCOS mapped the coral reef habitats of Guam by visual interpretation and manual delineation of IKONOS satellite imagery. This table reflects all variables used from the dataset. 

| Variable | Definition |
|----|----|
| `POLYGONID` | Unique identifier for a polygon |
| `D_STRUCT` | Detailed structure of benthic habitat (e.g., Aggregate Reef, Sand ) |
| `geometry` | spatial features containing polygons |
| `POLYGONID` | Unique identifier for a polygon |

# Manipulated Data Dictionary

# 1. guamFS

| Variable | Definition |
|----|----|
| `latitude` | Site latitude in decimal degrees |
| `longitude` | Site longitude in decimal degrees |
| `OBJECTID` | Unique identifier for an observation |
| `ISLAND` | Island or atoll surveyed |
| `OBS_YEAR` | Year the survey was conducted |
| `HABITAT_TYPE` | Benthic habitat classification observed (e.g., Aggregate Patch Reef, Spur and Groove) |
| `COMMON_NAME` | Common name of the Fisheries Management Plan species in the sample |
| `COUNT` | Number of fish observed for that segment |
| `SIZE_` | Total length of fish, measured from tip of snout to tip of longer lobe of caudal fin in cm |
| `MPA_STATUS` | Indicates whether location of coordinates are within or outside the MPA  |

# 2. MPApointsbarplotdata

| Variable | Definition |
|----|----|
| `OBS_YEAR` | Year the survey was conducted  |
| `MPA_STATUS` | Indicates whether location of coordinates are within or outside the MPA  |
| `COMMON_NAME` | Common name of the species in the sample |
| `TOTAL_COUNT` | Number of fish observed for that segment grouped by OBS_YEAR, MPA_STATUS, COMMON_NAME |
| `OCCURRENCE` | Proportion of total count for species/year |

# 3. speciessize

| Variable | Definition |
|----|----|
| `COMMON_NAME` | Common name of the species in the sample |
| `MPA_STATUS` | Indicates whether location of coordinates are within or outside the MPA  |
| `HABITAT_TYPE` | Benthic habitat classification observed (e.g., Aggregate Patch Reef, Spur and Groove) |
| `SIZE_` | Total length of fish, measured from tip of snout to tip of longer lobe of caudal fin in cm |
| `TOTAL_COUNT` | Number of fish observed for that segment grouped by COMMON_NAME, MPA_STATUS, HABITAT_TYPE, SIZE_ |
| `OCCURRENCE` | Proportion of total count for species |
