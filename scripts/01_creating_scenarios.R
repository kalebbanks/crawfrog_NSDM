#####################
#Script: 01_creating_scenarios.R
#Purpose: Edit, mask, and crop raw raster files and then assemble spatrasters for modeling. 
#Inputs: data/env_var/scenarios_raw
#Outputs: data/env_var/scenarios_spatraster
#Author:Kaleb M. Banks
#Date: 2025-09-03
#####################
#packages:
#install.packages("readxl")
#install.packages("terra")
#install.packages("raster")
#install.packages("ENMwrap")
#install.packages("geodata")
library(readxl)
library(terra)
library(raster)
library(ENMwrap)
library(geodata)

#Download rasterfiles and get in correct place

#Current worldclim variables
worldclim_global(var = "bio", res = 2.5,path = "data/env_var/scenarios_raw/bioclim_2.5")
files <- list.files("data/env_var/scenarios_raw/bioclim_2.5", 
                    pattern = "\\.tif$", 
                    full.names = TRUE)
file.rename(from = files,
            to   = file.path(dirname(files),
                             paste0(gsub(".*_(bio_\\d+).*", "\\1", basename(files)), ".tif")))


worldclim_global(var = "bio", res = 10,path = "data/env_var/scenarios_raw/bioclim_10")

#Future worldclim variables
models  <- c("MIROC6", "MPI-ESM1-2-HR", "CMCC-ESM2")
ssps    <- c("245", "585")
bio_idx <- c(2, 9, 10, 12)

for (ssp in ssps) {
    model_rasts <- lapply(models, function(model) {
    model_path <- paste0("data/env_var/scenarios_raw/future_bioclim/", model)
    dir.create(model_path, recursive = TRUE, showWarnings = FALSE)
    
    r <- cmip6_world(var = "bioc", res = 2.5,
                     model = model, ssp = ssp, time = "2061-2080",
                     path = model_path)
    return(r[[bio_idx]])
  })
  
  for (i in seq_along(bio_idx)) {
    var_stack    <- rast(lapply(model_rasts, function(r) r[[i]]))
    var_ensemble <- mean(var_stack)
    
    out_file <- paste0("data/env_var/ensemble/bio", 
                       bio_idx[i], "_ssp", ssp, "_2061-2080.tif")
    writeRaster(var_ensemble, out_file, overwrite = TRUE)
    message("Saved: ", out_file)
  }
}




#Prior to setting up scenarios we performed a spearmen correlation to decide which climatic variables to use in the model. 
#We discarded variables that had a higher correlation score of greater than 0.75. 
#the variables we decided to keep were bio_12, bio_10, bio_9, bio_2. 
#rationale for selecting each variable can be seen in supplementary materials. Table 1
#to see the full correlation table run this code below: 
corr <- read_excel("data/env_var/correlation_test/cor_matrix_spearman.xlsx")


##########Set up scenarios

# ----- expl.var.regional ----- 
#Regional current climatic variables, current land use variables

regional_mask <- raster::shapefile('data/extent_shapefiles/ok_regional.shp')

bioclim_world_2.5sec <- raster::stack(list.files('data/env_var/scenarios_raw/bioclim_2.5/climate/wc2.1_2.5m/'
                                          , pattern = 'bio_'
                                          , full.names = T)
                                          , RAT = FALSE)

expl.var.regional <- raster::stack(raster::subset(bioclim_world_2.5sec, c('wc2.1_2.5m_bio_12','wc2.1_2.5m_bio_9', 'wc2.1_2.5m_bio_10', 'wc2.1_2.5m_bio_2')))
expl.var.regional <- raster::mask(expl.var.regional, regional_mask)
expl.var.regional <- raster::crop(expl.var.regional, regional_mask)

percent_prairie <- raster("data/env_var/scenarios_raw/percent_prairie_current/percent_prairie")
percent_prairie <- raster::mask(percent_prairie, regional_mask)
percent_prairie <- raster::crop(percent_prairie, regional_mask)

percent_clay <- raster("data/env_var/scenarios_raw/percent_clay.TIF")
percent_clay <- raster::mask(percent_clay, regional_mask)
percent_clay <- raster::crop(percent_clay, regional_mask)

expl.var.regional <- raster::stack(expl.var.regional, percent_clay, percent_prairie) 
names(expl.var.regional) <- c("bio_12", "bio_9", "bio_10", "bio_2", 
                              "percent_clay", "percent_prairie")
expl.var.regional <- rast(expl.var.regional)

#writeRaster(expl.var.regional, "data/env_var/scenarios_spatraster/expl.var.regional.tif", overwrite = TRUE)


# ----- expl.var.global ----- 
#Current global climatic variables, no land use variables in global model

rangewide_mask <- raster::shapefile('data/extent_shapefiles/rangewide.shp')

bioclim_world_10sec <- raster::stack(list.files('data/env_var/scenarios_raw/bioclim_10/climate/wc2.1_10m/'
                                          , pattern = 'bio_'
                                          , full.names = T)
                                          , RAT = FALSE)

expl.var.global <- raster::stack(raster::subset(bioclim_world_10sec, c('wc2.1_10m_bio_12','wc2.1_10m_bio_9', 'wc2.1_10m_bio_10', 'wc2.1_10m_bio_2')))
expl.var.global <- raster::mask(expl.var.global, rangewide_mask)
expl.var.global <- raster::crop(expl.var.global, rangewide_mask)
expl.var.global <- rast(expl.var.global)

#writeRaster(expl.var.global, "data/env_var/scenarios_spatraster/expl.var.global.tif", overwrite = TRUE)


# ----- future_scenario_1 ----- 
#Regional climate as projected (SSP245), current (no change) land use variables

regional_mask <- raster::shapefile('data/extent_shapefiles/ok_regional.shp')

bio_2 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio2_ssp245_2061-2080.tif")
bio_10 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio10_ssp245_2061-2080.tif")
bio_9 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio9_ssp245_2061-2080.tif")
bio_12 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio12_ssp245_2061-2080.tif")
percent_prairie <- raster("data/env_var/scenarios_raw/percent_prairie_current/percent_prairie")
percent_clay <- raster("data/env_var/scenarios_raw/percent_clay.TIF")


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

#writeRaster(future_scenario_1, "data/env_var/scenarios_spatraster/future_scenario_1.tif", overwrite = TRUE)


# ----- future_scenario_2 ----- 
#Regional climate worsens (SSP585), current (no change) land use variables

regional_mask <- raster::shapefile('data/extent_shapefiles/ok_regional.shp')

bio_2 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio2_ssp585_2061-2080.tif")
bio_10 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio10_ssp585_2061-2080.tif")
bio_9 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio9_ssp585_2061-2080.tif")
bio_12 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio12_ssp585_2061-2080.tif")
percent_prairie <- raster("data/env_var/scenarios_raw/percent_prairie_current/percent_prairie")
percent_clay <- raster("data/env_var/scenarios_raw/percent_clay.TIF")

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

#writeRaster(future_scenario_2, "data/env_var/scenarios_spatraster/future_scenario_2.tif", overwrite = TRUE)


# ----- future_scenario_3 ----- 
#Regional climate as projected (SSP245), Landuse change as projected (A1B)

regional_mask <- raster::shapefile('data/extent_shapefiles/ok_regional.shp')

bio_2 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio2_ssp245_2061-2080.tif")
bio_10 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio10_ssp245_2061-2080.tif")
bio_9 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio9_ssp245_2061-2080.tif")
bio_12 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio12_ssp245_2061-2080.tif")
percent_prairie <- raster("data/env_var/scenarios_raw/future_percent_prairie/percent_prairie_A1B/percent_prairie")
percent_clay <- raster("data/env_var/scenarios_raw/percent_clay.TIF")

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

#writeRaster(future_scenario_3, "data/env_var/scenarios_spatraster/future_scenario_3.tif", overwrite = TRUE)


# ----- future_scenario_4 ----- 
#Regional climate worsens (SSP585), land use as projected (A1B)

regional_mask <- raster::shapefile('data/extent_shapefiles/ok_regional.shp')

bio_2 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio2_ssp585_2061-2080.tif")
bio_10 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio10_ssp585_2061-2080.tif")
bio_9 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio9_ssp585_2061-2080.tif")
bio_12 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio12_ssp585_2061-2080.tif")
percent_prairie <- raster("data/env_var/scenarios_raw/percent_prairie_current/percent_prairie")
percent_clay <- raster("data/env_var/scenarios_raw/percent_clay.TIF")

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

#writeRaster(future_scenario_4, "data/env_var/scenarios_spatraster/future_scenario_4.tif", overwrite = TRUE)


# ----- future_scenario_5 ----- 
#Regional climate as projected (SSP245), land use worsens (A2)

regional_mask <- raster::shapefile('data/extent_shapefiles/ok_regional.shp')

bio_2 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio2_ssp245_2061-2080.tif")
bio_10 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio10_ssp245_2061-2080.tif")
bio_9 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio9_ssp245_2061-2080.tif")
bio_12 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio12_ssp245_2061-2080.tif")
percent_prairie <- raster("data/env_var/scenarios_raw/future_percent_prairie/percent_prairie_A2/percent_prairie")
percent_clay <- raster("data/env_var/scenarios_raw/percent_clay.TIF")

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

#writeRaster(future_scenario_5, "data/env_var/scenarios_spatraster/future_scenario_5.tif", overwrite = TRUE)


# ----- future_scenario_6 ----- 
#Regional climate worsens (SSP585), land use worsens (A2)

regional_mask <- raster::shapefile('data/extent_shapefiles/ok_regional.shp')

bio_2 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio2_ssp585_2061-2080.tif")
bio_10 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio10_ssp585_2061-2080.tif")
bio_9 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio9_ssp585_2061-2080.tif")
bio_12 <- raster("data/env_var/scenarios_raw/future_bioclim/ensemble/bio12_ssp585_2061-2080.tif")
percent_prairie <- raster("data/env_var/scenarios_raw/future_percent_prairie/percent_prairie_A2/percent_prairie")
percent_clay <- raster("data/env_var/scenarios_raw/percent_clay.TIF")

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

#writeRaster(future_scenario_6, "data/env_var/scenarios_spatraster/future_scenario_6.tif", overwrite = TRUE)
















