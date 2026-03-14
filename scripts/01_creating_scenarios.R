#####################
#Script: 01_creating_scenarios.R
#Purpose: Edit, mask, and crop raw raster files and then assemble spatrasters for modeling. This script can be skipped and cleaned raster files can be directly loaded in 03_modeling.R
#Inputs: data/env_var/scenarios_raw
#Outputs: data/env_var/scenarios_spatraster
#Author:Kaleb M. Banks
#Date: 2025-09-03
#####################
#packages:
library(terra)
library(raster)
install.packages("ENMwrap")
library(ENMwrap)


#Prior to setting up scenarios we performed a spearmen correlation to decide which climatic variables to use in the model. 
#We discarded variables that had a higher correlation score of greater than 0.75. 
#the variables we decided to keep were bio_12, bio_10, bio_9, bio_8, bio_2. 
#rationale for selecting each variable can be seen in supplementary materials. Table 1
#to see the full correlation table run this code below: 
corr <- read_excel("outputs/cor_matrix_spearman.xlsx")


###I took out bio8 on 10/3

##########Set up scenarios


# ----- expl.var.regional ----- 
#Regional current climatic variables, current land use variables

regional_mask <- raster::shapefile('data/extent_shapefiles/ok_regional.shp')

bioclim_world_2.5sec <- raster::stack(list.files('data/env_var/scenarios_raw/expl.var.regional/worldclim'
                                          , pattern = 'bio_'
                                          , full.names = T)
                                          , RAT = FALSE)

expl.var.regional <- raster::stack(raster::subset(bioclim_world_2.5sec, c('bio_12','bio_9', 'bio_10', 'bio_2')))
expl.var.regional <- raster::mask(expl.var.regional, regional_mask)
expl.var.regional <- raster::crop(expl.var.regional, regional_mask)

percent_prairie <- raster("data/env_var/scenarios_raw/expl.var.regional/percent_prairie")
percent_prairie <- raster::mask(percent_prairie, regional_mask)
percent_prairie <- raster::crop(percent_prairie, regional_mask)

percent_clay <- raster("data/env_var/scenarios_raw/expl.var.regional/percent_clay.TIF")
percent_clay <- raster::mask(percent_clay, regional_mask)
percent_clay <- raster::crop(percent_clay, regional_mask)

expl.var.regional <- raster::stack(expl.var.regional, percent_clay, percent_prairie) 

expl.var.regional <- rast(expl.var.regional)

#eyeball test
terra::plot(expl.var.regional)

writeRaster(expl.var.regional, "data/env_var/scenarios_spatraster/expl.var.regional.tif", overwrite = TRUE)


# ----- expl.var.global ----- 
#Current global climatic variables, no land use variables in global model

rangewide_mask <- raster::shapefile('data/extent_shapefiles/rangewide.shp')

bioclim_world_10sec <- raster::stack(list.files('data/env_var/scenarios_raw/expl.var.global/worldclim'
                                          , pattern = 'bio_'
                                          , full.names = T)
                                          , RAT = FALSE)

expl.var.global <- raster::stack(raster::subset(bioclim_world_10sec, c('bio_12','bio_9', 'bio_10', 'bio_2')))
expl.var.global <- raster::mask(expl.var.global, rangewide_mask)
expl.var.global <- raster::crop(expl.var.global, rangewide_mask)
expl.var.global <- rast(expl.var.global)

#eyeball test
terra::plot(expl.var.global)

writeRaster(expl.var.global, "data/env_var/scenarios_spatraster/expl.var.global.tif", overwrite = TRUE)


# ----- future_scenario_1 ----- 
#Regional climate as projected (SSP245), current (no change) land use variables

regional_mask <- raster::shapefile('data/extent_shapefiles/ok_regional.shp')

bio_2 <- raster("data/env_var/scenarios_raw/future_scenario_1/bio_2")
#bio_8 <- raster("data/env_var/scenarios_raw/future_scenario_1/bio_8")
bio_10 <- raster("data/env_var/scenarios_raw/future_scenario_1/bio_10")
bio_9 <- raster("data/env_var/scenarios_raw/future_scenario_1/bio_9")
bio_12 <- raster("data/env_var/scenarios_raw/future_scenario_1/bio_12")
percent_prairie <- raster("data/env_var/scenarios_raw/future_scenario_1/percent_prairie")
percent_clay <- raster("data/env_var/scenarios_raw/future_scenario_1/percent_clay.TIF")

future_scenario_1 <- raster::stack(bio_12, bio_9, bio_10, bio_2)
names(future_scenario_1) <- c("bio_12", "bio_9", "bio_10", "bio_2")
future_scenario_1 <- raster::mask(future_scenario_1, regional_mask)
future_scenario_1 <- raster::crop(future_scenario_1, regional_mask)

percent_clay <- raster::mask(percent_clay, regional_mask)
percent_clay <- raster::crop(percent_clay, regional_mask)

percent_prairie <- raster::mask(percent_prairie, regional_mask)
percent_prairie <- raster::crop(percent_prairie, regional_mask)

future_scenario_1 <- raster::stack(future_scenario_1, percent_clay, percent_prairie)
future_scenario_1 <- rast(future_scenario_1)

terra::plot(future_scenario_1)

writeRaster(future_scenario_1, "data/env_var/scenarios_spatraster/future_scenario_1.tif", overwrite = TRUE)


# ----- future_scenario_2 ----- 
#Regional climate worsens (SSP585), current (no change) land use variables

regional_mask <- raster::shapefile('data/extent_shapefiles/ok_regional.shp')

bio_2 <- raster("data/env_var/scenarios_raw/future_scenario_2/bio_2")
#bio_8 <- raster("data/env_var/scenarios_raw/future_scenario_2/bio_8")
bio_10 <- raster("data/env_var/scenarios_raw/future_scenario_2/bio_10")
bio_9 <- raster("data/env_var/scenarios_raw/future_scenario_2/bio_9")
bio_12 <- raster("data/env_var/scenarios_raw/future_scenario_2/bio_12")
percent_prairie <- raster("data/env_var/scenarios_raw/future_scenario_2/percent_prairie")
percent_clay <- raster("data/env_var/scenarios_raw/future_scenario_2/percent_clay.TIF")

future_scenario_2 <- raster::stack(bio_12, bio_9, bio_10, bio_2)
names(future_scenario_2) <- c("bio_12", "bio_9", "bio_10", "bio_2")
future_scenario_2 <- raster::mask(future_scenario_2, regional_mask)
future_scenario_2 <- raster::crop(future_scenario_2, regional_mask)

percent_clay <- raster::mask(percent_clay, regional_mask)
percent_clay <- raster::crop(percent_clay, regional_mask)

percent_prairie <- raster::mask(percent_prairie, regional_mask)
percent_prairie <- raster::crop(percent_prairie, regional_mask)

future_scenario_2 <- raster::stack(future_scenario_2, percent_clay, percent_prairie)
future_scenario_2 <- rast(future_scenario_2)

terra::plot(future_scenario_2)

writeRaster(future_scenario_2, "data/env_var/scenarios_spatraster/future_scenario_2.tif", overwrite = TRUE)


# ----- future_scenario_3 ----- 
#Regional climate as projected (SSP245), Landuse change as projected (A1B)

regional_mask <- raster::shapefile('data/extent_shapefiles/ok_regional.shp')

bio_2 <- raster("data/env_var/scenarios_raw/future_scenario_3/bio_2")
#bio_8 <- raster("data/env_var/scenarios_raw/future_scenario_3/bio_8")
bio_10 <- raster("data/env_var/scenarios_raw/future_scenario_3/bio_10")
bio_9 <- raster("data/env_var/scenarios_raw/future_scenario_3/bio_9")
bio_12 <- raster("data/env_var/scenarios_raw/future_scenario_3/bio_12")
percent_prairie <- raster("data/env_var/scenarios_raw/future_scenario_3/percent_prairie")
percent_clay <- raster("data/env_var/scenarios_raw/future_scenario_3/percent_clay.TIF")

future_scenario_3 <- raster::stack(bio_12, bio_9, bio_10, bio_2)
names(future_scenario_3) <- c("bio_12", "bio_9", "bio_10", "bio_2")
future_scenario_3 <- raster::mask(future_scenario_3, regional_mask)
future_scenario_3 <- raster::crop(future_scenario_3, regional_mask)

percent_clay <- raster::mask(percent_clay, regional_mask)
percent_clay <- raster::crop(percent_clay, regional_mask)

percent_prairie <- raster::mask(percent_prairie, regional_mask)
percent_prairie <- raster::crop(percent_prairie, regional_mask)

future_scenario_3 <- raster::stack(future_scenario_3, percent_clay, percent_prairie)
future_scenario_3 <- rast(future_scenario_3)

terra::plot(future_scenario_3)

writeRaster(future_scenario_3, "data/env_var/scenarios_spatraster/future_scenario_3.tif", overwrite = TRUE)


# ----- future_scenario_4 ----- 
#Regional climate worsens (SSP585), land use as projected (A1B)

regional_mask <- raster::shapefile('data/extent_shapefiles/ok_regional.shp')

bio_2 <- raster("data/env_var/scenarios_raw/future_scenario_4/bio_2")
#bio_8 <- raster("data/env_var/scenarios_raw/future_scenario_4/bio_8")
bio_10 <- raster("data/env_var/scenarios_raw/future_scenario_4/bio_10")
bio_9 <- raster("data/env_var/scenarios_raw/future_scenario_4/bio_9")
bio_12 <- raster("data/env_var/scenarios_raw/future_scenario_4/bio_12")
percent_prairie <- raster("data/env_var/scenarios_raw/future_scenario_4/percent_prairie")
percent_clay <- raster("data/env_var/scenarios_raw/future_scenario_4/percent_clay.TIF")

future_scenario_4 <- raster::stack(bio_12, bio_9, bio_10, bio_2)
names(future_scenario_4) <- c("bio_12", "bio_9", "bio_10", "bio_2")
future_scenario_4 <- raster::mask(future_scenario_4, regional_mask)
future_scenario_4 <- raster::crop(future_scenario_4, regional_mask)

percent_clay <- raster::mask(percent_clay, regional_mask)
percent_clay <- raster::crop(percent_clay, regional_mask)

percent_prairie <- raster::mask(percent_prairie, regional_mask)
percent_prairie <- raster::crop(percent_prairie, regional_mask)

future_scenario_4 <- raster::stack(future_scenario_4, percent_clay, percent_prairie)
future_scenario_4 <- rast(future_scenario_4)

terra::plot(future_scenario_4)

writeRaster(future_scenario_4, "data/env_var/scenarios_spatraster/future_scenario_4.tif", overwrite = TRUE)


# ----- future_scenario_5 ----- 
#Regional climate as projected (SSP245), land use worsebs (A2)

regional_mask <- raster::shapefile('data/extent_shapefiles/ok_regional.shp')

bio_2 <- raster("data/env_var/scenarios_raw/future_scenario_5/bio_2")
#bio_8 <- raster("data/env_var/scenarios_raw/future_scenario_5/bio_8")
bio_10 <- raster("data/env_var/scenarios_raw/future_scenario_5/bio_10")
bio_9 <- raster("data/env_var/scenarios_raw/future_scenario_5/bio_9")
bio_12 <- raster("data/env_var/scenarios_raw/future_scenario_5/bio_12")
percent_prairie <- raster("data/env_var/scenarios_raw/future_scenario_5/percent_prairie")
percent_clay <- raster("data/env_var/scenarios_raw/future_scenario_5/percent_clay.TIF")

future_scenario_5 <- raster::stack(bio_12, bio_9, bio_10, bio_2)
names(future_scenario_5) <- c("bio_12", "bio_9", "bio_10", "bio_2")
future_scenario_5 <- raster::mask(future_scenario_5, regional_mask)
future_scenario_5 <- raster::crop(future_scenario_5, regional_mask)

percent_clay <- raster::mask(percent_clay, regional_mask)
percent_clay <- raster::crop(percent_clay, regional_mask)

percent_prairie <- raster::mask(percent_prairie, regional_mask)
percent_prairie <- raster::crop(percent_prairie, regional_mask)

future_scenario_5 <- raster::stack(future_scenario_5, percent_clay, percent_prairie)
future_scenario_5 <- rast(future_scenario_5)

terra::plot(future_scenario_5)

writeRaster(future_scenario_5, "data/env_var/scenarios_spatraster/future_scenario_5.tif", overwrite = TRUE)


# ----- future_scenario_6 ----- 
#Regional climate worsens (SSP585), land use worsens (A2)

regional_mask <- raster::shapefile('data/extent_shapefiles/ok_regional.shp')

bio_2 <- raster("data/env_var/scenarios_raw/future_scenario_6/bio_2")
#bio_8 <- raster("data/env_var/scenarios_raw/future_scenario_6/bio_8")
bio_10 <- raster("data/env_var/scenarios_raw/future_scenario_6/bio_10")
bio_9 <- raster("data/env_var/scenarios_raw/future_scenario_6/bio_9")
bio_12 <- raster("data/env_var/scenarios_raw/future_scenario_6/bio_12")
percent_prairie <- raster("data/env_var/scenarios_raw/future_scenario_6/percent_prairie")
percent_clay <- raster("data/env_var/scenarios_raw/future_scenario_6/percent_clay.TIF")

future_scenario_6 <- raster::stack(bio_12, bio_9, bio_10, bio_2)
names(future_scenario_6) <- c("bio_12", "bio_9", "bio_10", "bio_2")
future_scenario_6 <- raster::mask(future_scenario_6, regional_mask)
future_scenario_6 <- raster::crop(future_scenario_6, regional_mask)

percent_clay <- raster::mask(percent_clay, regional_mask)
percent_clay <- raster::crop(percent_clay, regional_mask)

percent_prairie <- raster::mask(percent_prairie, regional_mask)
percent_prairie <- raster::crop(percent_prairie, regional_mask)

future_scenario_6 <- raster::stack(future_scenario_6, percent_clay, percent_prairie)
future_scenario_6 <- rast(future_scenario_6)

terra::plot(future_scenario_6)

writeRaster(future_scenario_6, "data/env_var/scenarios_spatraster/future_scenario_6.tif", overwrite = TRUE)










