#####################
#Script: 04_nsdm_modeling.R
#Purpose: train final models after sensitivity analysis
#Inputs: data/occurrences_absences
#        data/env_var
#Outputs: Biomod result folder of each model.
#Author:Kaleb M. Banks
#Date: 2025-09-03
#####################
#packages: 
#install.packages("remotes")
#remotes::install_github("N-SDM/covsel")
#remotes::install_github("geoSABINA/sabinaNSDM")
#install.packages("terra")
#install.packages("biomod2")
#install.packages("sp")
#install.packages("raster")
#install.packages("dplyr")
#install.packages("PresenceAbsence")
#install.packages("ggplot2")
#install.packages("tidyr")
library(remotes)
library(covsel)
library(sabinaNSDM)
library(terra)
library(biomod2)
library(sp)
library(raster)
library(dplyr)
library(PresenceAbsence)
library(ggplot2)
library(tidyr)

#####Load occurrences
R.areolata_reg_train_occ <- read.csv("data/occurrences_absences/occ_thinned/regional_occ_train.csv")
R.areolata_glob_train_occ <- read.csv("data/occurrences_absences/occ_thinned/global_occ_train.csv")

#####Load pseudo-absences
global_PA_train <- read.csv("data/occurrences_absences/abs_global/glob_PA_strat_1.csv")
regional_PA_train <- read.csv("data/occurrences_absences/abs_reg/reg_PA_strat_1.csv")

#####Load env var scenarios
expl.var.global <- rast("data/env_var/scenarios_spatraster/expl.var.global.tif")
expl.var.regional <- rast("data/env_var/scenarios_spatraster/expl.var.regional.tif")
future_scenario_1 <- rast("data/env_var/scenarios_spatraster/future_scenario_1.tif")
future_scenario_2 <- rast("data/env_var/scenarios_spatraster/future_scenario_2.tif")
future_scenario_3 <- rast("data/env_var/scenarios_spatraster/future_scenario_3.tif")
future_scenario_4 <- rast("data/env_var/scenarios_spatraster/future_scenario_4.tif")
future_scenario_5 <- rast("data/env_var/scenarios_spatraster/future_scenario_5.tif")
future_scenario_6 <- rast("data/env_var/scenarios_spatraster/future_scenario_6.tif")

#####Models

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
                               method = "Geometric", 
                               rescale = FALSE, 
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




