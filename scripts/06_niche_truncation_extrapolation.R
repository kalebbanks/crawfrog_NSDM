#####################
#Script: 06_niche_tuncation_extrapolation.R
#Purpose: Calculate Niche truncation and extrapolation using the Ecospat and modeva packages
#Inputs: 
#Outputs: 
#Author:Kaleb M. Banks
#Date: 2025-09-30
#####################
install.packages("modEvA")
library(modEvA)
library(ecospat)
library(ade4)
library(terra)
library(dplyr)


#####Load env var scenarios
expl.var.global <- rast("data/env_var/scenarios_spatraster/expl.var.global.tif")
expl.var.regional <- rast("data/env_var/scenarios_spatraster/expl.var.regional.tif")
future_scenario_1 <- rast("data/env_var/scenarios_spatraster/future_scenario_1.tif")
future_scenario_2 <- rast("data/env_var/scenarios_spatraster/future_scenario_2.tif")
future_scenario_3 <- rast("data/env_var/scenarios_spatraster/future_scenario_3.tif")
future_scenario_4 <- rast("data/env_var/scenarios_spatraster/future_scenario_4.tif")
future_scenario_5 <- rast("data/env_var/scenarios_spatraster/future_scenario_5.tif")
future_scenario_6 <- rast("data/env_var/scenarios_spatraster/future_scenario_6.tif")


#####Load all CF occ
reg_occ <- read.csv("data/occurences_absences/occ_raw/regional_survey_occ.csv")
glob_occ <- read.csv("data/occurences_absences/occ_raw/rangewide_gbif_occ.csv")


#####Extrapolation

#To find regional-only extrapolation to future conditions 
#Compare regional-only var to future regional conditions (SSP 245 and SSP 585)
reg_curr <- as.data.frame(expl.var.regional, xy = FALSE, na.rm = TRUE)
reg_245 <- as.data.frame(future_scenario_1, xy = FALSE, na.rm = TRUE)
reg_585 <- as.data.frame(future_scenario_2, xy = FALSE, na.rm = TRUE)

reg_curr_to_reg_245 <- MESS(reg_curr, reg_245, id.col = NULL, verbosity = 2)
MESS_percent_reg_curr_to_reg_245 <- mean(reg_curr_to_reg_245$TOTAL < 0) * 100

reg_curr_to_reg_585 <- MESS(reg_curr, reg_585, id.col = NULL, verbosity = 2)
MESS_percent_reg_curr_to_reg_585 <- mean(reg_curr_to_reg_585$TOTAL < 0) * 100

#To find NSDM extrapolation that use global models to inform preditions 
#compare current global var to future regional var (SSp 245 and SSP 585)
global_curr <-  as.data.frame(expl.var.global, xy = FALSE, na.rm = TRUE)
reg_245 <- as.data.frame(future_scenario_1, xy = FALSE, na.rm = TRUE)
reg_585 <- as.data.frame(future_scenario_2, xy = FALSE, na.rm = TRUE)
reg_245[c("percent_clay", "percent_prairie")] <- NULL
reg_585[c("percent_clay", "percent_prairie")] <- NULL

glob_curr_to_reg_245 <- MESS(global_curr, reg_245, id.col = NULL, verbosity = 2)
MESS_percent_glob_curr_to_reg_245 <- mean(glob_curr_to_reg_245$TOTAL < 0) * 100

glob_curr_to_reg_585 <- MESS(global_curr, reg_585, id.col = NULL, verbosity = 2)
MESS_percent_glob_curr_to_reg_245 <- mean(glob_curr_to_reg_585$TOTAL < 0) * 100

######Niche truncation using ecospat package 
#convert current environment variables to dataframes, this time keeping the XY
global_curr <-  as.data.frame(expl.var.global, xy = TRUE, na.rm = TRUE)
reg_curr <- as.data.frame(expl.var.regional, xy = TRUE, na.rm = TRUE)

#convert occ points to spatital vector obj
points_regional <- vect(reg_occ, geom = c("x", "y"), crs = crs(expl.var.regional))
points_global <- vect(glob_occ, geom = c("x", "y"), crs = crs(expl.var.global))

#convert points into a raster file where values are 1 if there is a point in the cell. Max makes it so if there are multiple points in the same cell the value will stay 1. 
pres_regional <- rasterize(points_regional, expl.var.regional, field = 1, fun = "max", background = 0)
pres_global <- rasterize(points_global, expl.var.global, field = 1, fun = "max", background = 0)

#converts the presence raster to a dataframe with X,y, and presence values, joins it with environmental variables
occ_join_regional <- left_join(reg_curr,
                               as.data.frame(pres_regional, xy = TRUE),
                               by = c("x", "y"))
occ_join_regional[c("percent_clay", "percent_prairie")] <- NULL

occ_join_global <- left_join(global_curr,
                             as.data.frame(pres_global, xy = TRUE),
                             by = c("x", "y"))


#combines regional and global data vertically and make PCA. 
combined_env <- rbind(occ_join_regional, occ_join_global)
pca_env <- dudi.pca(combined_env[, 3:6], scannf = FALSE, nf = 2)

#how much do each envir variable contribute to PCA axes?
ecospat.plot.contrib(contrib = pca_env$co, eigen = pca_env$eig)

#all pca scores for cells used in analysis 
scores_glob <- pca_env$li
#all regional and global environmental cells in PCA space
scores_env_reg <- suprow(pca_env, occ_join_regional[, 3:6])$li
scores_env_glob <- suprow(pca_env, occ_join_global[, 3:6])$li
#where occurences equal 1 in pca space
scores_sp_reg <- suprow(pca_env, occ_join_regional[occ_join_regional$max == 1, 3:6])$li
scores_sp_glob <- suprow(pca_env, occ_join_global[occ_join_global$max == 1, 3:6])$li

#smoothed density of density of species occurence in pca space 
grid_reg <- ecospat.grid.clim.dyn(
  glob = scores_glob,
  glob1 = scores_env_reg,
  sp = scores_sp_reg,
  R = 100,
  th.sp = 0
)

grid_glob <- ecospat.grid.clim.dyn(
  glob = scores_glob,
  glob1 = scores_env_glob,
  sp = scores_sp_glob,
  R = 100,
  th.sp = 0
)

#Testing if the regional niche has significantly less of the global niche occupied than expected by chance
sim_test <- ecospat.niche.similarity.test(
  z1 = grid_glob,
  z2 = grid_reg,
  rep = 1000,
  rand.type = 2,
  unfilling.alternative = "lower"
)

sim_test$obs$unfilling
#33.5% of global species niche not represented in regional range. 

sim_test$p$unfilling
#p-value 0.038, this is significant 


