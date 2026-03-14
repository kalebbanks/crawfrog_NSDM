#####################
#Script: 03_nsdm_modeling.R
#Purpose: train final models after sensitivity analysis
#Inputs: occurence, absence, environmental conditions
#Outputs: Biomod result folder of each model, raster file of all predictions
#Author:Kaleb M. Banks
#Date: 2025-09-03
#####################
#packages:
library(remotes)
remotes::install_github("N-SDM/covsel")
library(covsel)
remotes::install_github("geoSABINA/sabinaNSDM")
library(sabinaNSDM)
library(terra)
library(readxl)
library(biomod2)
library(sp)
library(raster)
install.packages("PresenceAbsence")


#####Load occurrences
R.areolata_reg_train_occ <- read.csv("data/occurences_absences/occ_thinned/regional_occ_train.csv")
R.areolata_glob_train_occ <- read.csv("data/occurences_absences/occ_thinned/global_occ_train.csv")

#####Load pseudo-absences
global_PA_train <- read.csv("data/occurences_absences/abs_global/glob_PA_strat_1.csv")
regional_PA_train <- read.csv("data/occurences_absences/abs_reg/reg_PA_strat_1.csv")

#####Load env var scenarios
expl.var.global <- rast("data/env_var/scenarios_spatraster/expl.var.global.tif")
expl.var.regional <- rast("data/env_var/scenarios_spatraster/expl.var.regional.tif")
future_scenario_1 <- rast("data/env_var/scenarios_spatraster/future_scenario_1.tif")
future_scenario_2 <- rast("data/env_var/scenarios_spatraster/future_scenario_2.tif")
future_scenario_3 <- rast("data/env_var/scenarios_spatraster/future_scenario_3.tif")
future_scenario_4 <- rast("data/env_var/scenarios_spatraster/future_scenario_4.tif")
future_scenario_5 <- rast("data/env_var/scenarios_spatraster/future_scenario_5.tif")
future_scenario_6 <- rast("data/env_var/scenarios_spatraster/future_scenario_6.tif")

#####Start here

nsdm_input <- NSDM.InputData(
  SpeciesName = "R.areolata",
  spp.data.global = R.areolata_glob_train_occ,
  spp.data.regional = R.areolata_reg_train_occ,
  expl.var.global = expl.var.global,
  expl.var.regional = expl.var.regional,
  new.env = list(future_scenario_1, future_scenario_2, future_scenario_3,
                 future_scenario_4, future_scenario_5, future_scenario_6),
  new.env.names = c("future_scenario_1", "future_scenario_2", "future_scenario_3",
                    "future_scenario_4", "future_scenario_5", "future_scenario_6"),
  Background.Global = NULL,
  Background.Regional = NULL,
  Absences.Global = global_PA_train,
  Absences.Regional = regional_PA_train
)

nsdm_finput <- NSDM.FormattingData(
  nsdm_input,
  Min.Dist.Global = "resolution", 
  Min.Dist.Regional = "resolution", 
  Background.method = "stratified",
  save.output = FALSE
)

nsdm_selvars <- NSDM.SelectCovariates(
  nsdm_finput,
  maxncov.Global = 6,
  maxncov.Regional = 8,
  corcut = 0.7,
  algorithms = c("glm","gam","rf"),
  ClimaticVariablesBands = NULL,
  save.output = FALSE
)


nsdm_global <- NSDM.Global(
  nsdm_selvars,
  algorithms = c("MAXNET", "GBM", "MARS"),
  CV.nb.rep = 20,
  CV.perc = 0.8,
  metric.select.thresh = 0.85,
  CustomModelOptions = NULL,
  save.output = TRUE,
  rm.biomod.folder = FALSE
)

######Eyeball test
#Current predictions
plot(terra::unwrap(nsdm_global$current.projections$Pred))
plot(terra::unwrap(nsdm_global$current.projections$Pred.bin.TSS))

#CV metrics 
summary(nsdm_global)

#Future global predictions 
plot(terra::unwrap(nsdm_global$new.projections$Pred.Scenario[[1]]))
plot(terra::unwrap(nsdm_global$new.projections$Pred.bin.TSS.Scenario[[1]]))
plot(terra::unwrap(nsdm_global$new.projections$Pred.Scenario[[2]]))
plot(terra::unwrap(nsdm_global$new.projections$Pred.bin.TSS.Scenario[[2]]))
plot(terra::unwrap(nsdm_global$new.projections$Pred.Scenario[[3]]))
plot(terra::unwrap(nsdm_global$new.projections$Pred.bin.TSS.Scenario[[3]]))
plot(terra::unwrap(nsdm_global$new.projections$Pred.Scenario[[4]]))
plot(terra::unwrap(nsdm_global$new.projections$Pred.bin.TSS.Scenario[[4]]))
plot(terra::unwrap(nsdm_global$new.projections$Pred.Scenario[[5]]))
plot(terra::unwrap(nsdm_global$new.projections$Pred.bin.TSS.Scenario[[5]]))
plot(terra::unwrap(nsdm_global$new.projections$Pred.Scenario[[6]]))
plot(terra::unwrap(nsdm_global$new.projections$Pred.bin.TSS.Scenario[[6]]))



nsdm_regional <- NSDM.Regional(nsdm_selvars,
                               algorithms = c("MAXNET", "MARS", "GBM"),
                               CV.nb.rep = 20,
                               CV.perc = 0.8,
                               metric.select.thresh = 0.8,
                               CustomModelOptions = NULL,
                               save.output = TRUE,
                               rm.biomod.folder = FALSE)



#####Eyeball test
#Current predictions
plot(terra::unwrap(nsdm_regional$current.projections$Pred))
plot(terra::unwrap(nsdm_regional$current.projections$Pred.bin.TSS))

#CV metrics 
summary(nsdm_regional)

#Future global predictions 
plot(terra::unwrap(nsdm_regional$new.projections$Pred.Scenario[[1]]))
plot(terra::unwrap(nsdm_regional$new.projections$Pred.bin.TSS.Scenario[[1]]))
plot(terra::unwrap(nsdm_regional$new.projections$Pred.Scenario[[2]]))
plot(terra::unwrap(nsdm_regional$new.projections$Pred.bin.TSS.Scenario[[2]]))
plot(terra::unwrap(nsdm_regional$new.projections$Pred.Scenario[[3]]))
plot(terra::unwrap(nsdm_regional$new.projections$Pred.bin.TSS.Scenario[[3]]))
plot(terra::unwrap(nsdm_regional$new.projections$Pred.Scenario[[4]]))
plot(terra::unwrap(nsdm_regional$new.projections$Pred.bin.TSS.Scenario[[4]]))
plot(terra::unwrap(nsdm_regional$new.projections$Pred.Scenario[[5]]))
plot(terra::unwrap(nsdm_regional$new.projections$Pred.bin.TSS.Scenario[[5]]))
plot(terra::unwrap(nsdm_regional$new.projections$Pred.Scenario[[6]]))
plot(terra::unwrap(nsdm_regional$new.projections$Pred.bin.TSS.Scenario[[6]]))



nsdm_covariate <- NSDM.Covariate(nsdm_global,
                                   algorithms = c("MAXNET", "MARS", "GBM"),
                                   CV.nb.rep = 20,
                                   CV.perc = 0.8,
                                   metric.select.thresh = 0.8,
                                   CustomModelOptions = NULL,
                                   save.output = TRUE,
                                   rm.biomod.folder = FALSE,
                                   rm.corr = TRUE)


#####Eyeball test
#Current predictions
plot(terra::unwrap(nsdm_covariate$current.projections$Pred))
plot(terra::unwrap(nsdm_covariate$current.projections$Pred.bin.TSS))

#CV metrics 
summary(nsdm_covariate)

#Future global predictions 
plot(terra::unwrap(nsdm_covariate$new.projections$Pred.Scenario[[1]]))
plot(terra::unwrap(nsdm_covariate$new.projections$Pred.bin.TSS.Scenario[[1]]))
plot(terra::unwrap(nsdm_covariate$new.projections$Pred.Scenario[[2]]))
plot(terra::unwrap(nsdm_covariate$new.projections$Pred.bin.TSS.Scenario[[2]]))
plot(terra::unwrap(nsdm_covariate$new.projections$Pred.Scenario[[3]]))
plot(terra::unwrap(nsdm_covariate$new.projections$Pred.bin.TSS.Scenario[[3]]))
plot(terra::unwrap(nsdm_covariate$new.projections$Pred.Scenario[[4]]))
plot(terra::unwrap(nsdm_covariate$new.projections$Pred.bin.TSS.Scenario[[4]]))
plot(terra::unwrap(nsdm_covariate$new.projections$Pred.Scenario[[5]]))
plot(terra::unwrap(nsdm_covariate$new.projections$Pred.bin.TSS.Scenario[[5]]))
plot(terra::unwrap(nsdm_covariate$new.projections$Pred.Scenario[[6]]))
plot(terra::unwrap(nsdm_covariate$new.projections$Pred.bin.TSS.Scenario[[6]]))



nsdm_multiply <- NSDM.Multiply(nsdm_global,
                               nsdm_regional,
                               method = "Geometric", # method for averaging global and regional model outputs: "Arithmetic" or "Geometric"
                               rescale = FALSE, # whether to rescale global and regional model predictions before combining them
                               save.output=TRUE)


#####Eyeball test
#Current predictions
plot(terra::unwrap(nsdm_multiply$current.projections$Pred))
plot(terra::unwrap(nsdm_multiply$current.projections$Pred.bin.TSS))

#CV metrics 
summary(nsdm_multiply)

#Future global predictions 
plot(terra::unwrap(nsdm_multiply$new.projections$Pred.Scenario[[1]]))
plot(terra::unwrap(nsdm_multiply$new.projections$Pred.bin.TSS.Scenario[[1]]))
plot(terra::unwrap(nsdm_multiply$new.projections$Pred.Scenario[[2]]))
plot(terra::unwrap(nsdm_multiply$new.projections$Pred.bin.TSS.Scenario[[2]]))
plot(terra::unwrap(nsdm_multiply$new.projections$Pred.Scenario[[3]]))
plot(terra::unwrap(nsdm_multiply$new.projections$Pred.bin.TSS.Scenario[[3]]))
plot(terra::unwrap(nsdm_multiply$new.projections$Pred.Scenario[[4]]))
plot(terra::unwrap(nsdm_multiply$new.projections$Pred.bin.TSS.Scenario[[4]]))
plot(terra::unwrap(nsdm_multiply$new.projections$Pred.Scenario[[5]]))
plot(terra::unwrap(nsdm_multiply$new.projections$Pred.bin.TSS.Scenario[[5]]))
plot(terra::unwrap(nsdm_multiply$new.projections$Pred.Scenario[[6]]))
plot(terra::unwrap(nsdm_multiply$new.projections$Pred.bin.TSS.Scenario[[6]]))

#############################################################################

#BlockCV stuff


crs(expl.var.regional)


ext <- ext(expl.var.global)
mean_lon <- (ext[1] + ext[2]) / 2
utm_zone <- floor((mean_lon + 180) / 6) + 1
utm_zone

g_meters <- project(expl.var.global, "EPSG:32615")
crs(g_meters)
crs(r_meters)

species_pts_utm <- st_transform(R.areolata_reg_train_occ, crs = 32614)

cv_block_size(r_meters, x = species_pts_utm, column = NULL, min_size = NULL, max_size = NULL)

cv_spatial_autocor(
  r_meters,
  species_pts_utm,
  column = "presence",
  num_sample = 5000L,
  deg_to_metre = 111325,
  plot = TRUE,
  progress = TRUE,
)



spp.sf <- st_as_sf(R.areolata_reg_train_occ, coords = c("x", "y"), crs = 4326)  # WGS84
spp.utm <- st_transform(spp.sf, crs = crs(r_meters))
spp.utm.df_reg <- as.data.frame(st_coordinates(spp.utm))
colnames(spp.utm.df_reg) <- c("x", "y")

spp.sf <- st_as_sf(R.areolata_glob_train_occ, coords = c("x", "y"), crs = 4326)  # WGS84
spp.utm <- st_transform(spp.sf, crs = crs(g_meters))
spp.utm.df_glob <- as.data.frame(st_coordinates(spp.utm))
colnames(spp.utm.df_glob) <- c("x", "y")

spp.sf <- st_as_sf(regional_PA_train, coords = c("x", "y"), crs = 4326)  # WGS84
spp.utm <- st_transform(spp.sf, crs = crs(r_meters))
spp.utm.df_reg_abs <- as.data.frame(st_coordinates(spp.utm))
colnames(spp.utm.df_reg_abs) <- c("x", "y")

spp.sf <- st_as_sf(global_PA_train, coords = c("x", "y"), crs = 4326)  # WGS84
spp.utm <- st_transform(spp.sf, crs = crs(g_meters))
spp.utm.df_glob_abs <- as.data.frame(st_coordinates(spp.utm))
colnames(spp.utm.df_glob_abs) <- c("x", "y")





NSDM.InputData(
  SpeciesName = "R.areolata",
  spp.data.global = spp.utm.df_reg,
  spp.data.regional = spp.utm.df_glob,
  expl.var.global = g_meters,
  expl.var.regional = r_meters, 
  Background.Global = spp.utm.df_glob_abs,
  Background.Regional = spp.utm.df_reg_abs)

res(r_meters)
res(g_meters)

nsdm_finput <- NSDM.FormattingData(
  nsdm_input,
  Min.Dist.Global = 100, 
  Min.Dist.Regional = 100, 
  Background.method = "stratified",
  save.output = FALSE
)

nsdm_selvars <- NSDM.SelectCovariates(
  nsdm_finput,
  maxncov.Global = 6,
  maxncov.Regional = 8,
  corcut = 0.99,
  algorithms = c("glm","gam","rf"),
  ClimaticVariablesBands = NULL,
  save.output = FALSE
)

nsdm_regional <- NSDM.Regional(nsdm_selvars,
                               algorithms = c("MAXNET", "MARS", "GBM", "GLM", "RF", "GAM"),
                               CV.nb.rep = 20,
                               CV.perc = 0.8,
                               metric.select.thresh = 0.8,
                               CustomModelOptions = NULL,
                               save.output = TRUE,
                               rm.biomod.folder = FALSE)

g_r <- terra::unwrap(g_meters)
r_r <- terra::unwrap(r_meters)

g_r <- terra::unwrap(g_meters)
r_r <- terra::unwrap(r_meters)

# Convert your points to SpatVector
pts_global <- terra::vect(spp.utm.df_glob, geom = c("x","y"), crs = terra::crs(g_r))
pts_regional <- terra::vect(spp.utm.df_reg, geom = c("x","y"), crs = terra::crs(r_r))

# Check which points fall inside the raster
inside_global <- !is.na(terra::extract(g_r[[1]], pts_global))
inside_regional <- !is.na(terra::extract(r_r[[1]], pts_regional))

sum(inside_global)   # number of points inside global raster
sum(inside_regional)


sf_points <- st_as_sf(R.areolata_reg_train_occ, coords = c("x", "y"), crs = 4326)  # 4326 = WGS84

cv_block_size(expl.var.regional, x = sf_points, column = NULL, min_size = NULL, max_size = NULL)
cv_plot()
############################################

#Tune model types

myBiomodData <- BIOMOD_FormatingData(
  resp.var = myResp,
  expl.var = expl.var.regional,
  resp.xy = myRespXY,
  resp.name = myRespName
)



