#####################
#Script: 01_manage_presence_absence.R
#Purpose: The purpose of this script is to thin occurrences, generate Pseudo-absence datasets, set aside 20% of occurrences and PA for later testing. Many of these steps can be done more efficiently through the biomod2 package, but I try to stay consistent with the sabinaNSDM package. This script is just an example of how I completed it and you will not be able to generate the exact same PA datasets as I did because there is no ability to set seeds. Instead, you can run the entire code in 03 by loading everything in. 
#Inputs: 
#Outputs: 
#Author:Kaleb M. Banks
#Date: 2025-09-03
#####################

#packages:
library(remotes)
remotes::install_github("N-SDM/covsel")
library(covsel)
remotes::install_github("geoSABINA/sabinaNSDM")
library(sabinaNSDM)
library(readxl)
library(biomod2)



#####Load occurrences
regional_occ <- read.csv("data/occurences_absences/occ_raw/regional_survey_occ.csv")
global_occ <- read.csv("data/occurences_absences/occ_raw/rangewide_gbif_occ.csv")

#####Load env var scenarios
expl.var.global <- rast("data/env_var/scenarios_spatraster/expl.var.global.tif")
expl.var.regional <- rast("data/env_var/scenarios_spatraster/expl.var.regional.tif")
future_scenario_1 <- rast("data/env_var/scenarios_spatraster/future_scenario_1.tif")
future_scenario_2 <- rast("data/env_var/scenarios_spatraster/future_scenario_2.tif")
future_scenario_3 <- rast("data/env_var/scenarios_spatraster/future_scenario_3.tif")
future_scenario_4 <- rast("data/env_var/scenarios_spatraster/future_scenario_4.tif")
future_scenario_5 <- rast("data/env_var/scenarios_spatraster/future_scenario_5.tif")
future_scenario_6 <- rast("data/env_var/scenarios_spatraster/future_scenario_6.tif")

######Need to create an nsdm_input output type in order to generate absences 
nsdm_input <-NSDM.InputData(SpeciesName = "R.areolata",
                            spp.data.global = global_occ,
                            spp.data.regional = regional_occ,
                            expl.var.global = expl.var.global,
                            expl.var.regional = expl.var.regional,
                            new.env = list(future_scenario_1, future_scenario_2, future_scenario_3, future_scenario_4, future_scenario_5, future_scenario_6),
                            new.env.names = c("future_scenario_1", "future_scenario_2", "future_scenario_3","future_scenario_4", "future_scenario_5", "future_scenario_6"),
                            Background.Global = NULL,
                            Background.Regional = NULL,
                            Absences.Global = NULL,
                            Absences.Regional = NULL
)

#####Need to figure out how many occurrences are left after spatial thinning. Points = , needs a value so just set to one right now 
nsdm_finput <- NSDM.FormattingData(nsdm_input,
                                   nPoints = 303, 
                                   Min.Dist.Global = "resolution", 
                                   Min.Dist.Regional = "resolution", 
                                   Background.method = "stratified",
                                   save.output = FALSE)

#####After spatial thinning we are left with 167 occ for global, and 237 occ for regional

#####Now we extract those coordinates
regional_occ_thinned <- nsdm_finput$SpeciesData.XY.Regional
global_occ_train <- nsdm_finput$SpeciesData.XY.Global

#####Now set aside 20% of regional data for independent testing. The global model will be tested on this data as well. 

num_occ <- floor(0.2 * nrow(regional_occ_thinned))
set.seed(815)
test_coords <- sample(seq_len(nrow(regional_occ_thinned)), size = num_occ)

regional_occ_test <- regional_occ_thinned[test_coords, ]
regional_occ_train <- regional_occ_thinned[-test_coords, ]


#save thinned and split presences 
write.csv(regional_occ_test, file = "data/occurences_absences/occ_thinned/regional_occ_test.csv", row.names = FALSE)
write.csv(regional_occ_train, file = "data/occurences_absences/occ_thinned/regional_occ_train.csv", row.names = FALSE)
write.csv(global_occ_train, file = "data/occurences_absences/occ_thinned/global_occ_train.csv", row.names = FALSE)



#####Next generate 10 PA data sets for global model using random generation. Make 1 to 1 presence to absence ratio

PA_random_global_datasets <- list()

nsdm_input <-NSDM.InputData(SpeciesName = "R.areolata",
                            spp.data.global = global_occ_train,
                            spp.data.regional = regional_occ_train,
                            expl.var.global = expl.var.global,
                            expl.var.regional = expl.var.regional,
                            new.env = list(future_scenario_1, future_scenario_2, future_scenario_3, future_scenario_4, future_scenario_5, future_scenario_6),
                            new.env.names = c("future_scenario_1", "future_scenario_2", "future_scenario_3","future_scenario_4", "future_scenario_5", "future_scenario_6"),
                            Background.Global = NULL,
                            Background.Regional = NULL,
                            Absences.Global = NULL,
                            Absences.Regional = NULL
)

for(i in 1:10){
  set.seed(587 + i)
  # Run NSDM.FormattingData to generate pseudo-absences
  nsdm_finput <- NSDM.FormattingData(nsdm_input,
                                     nPoints = 220, 
                                     Min.Dist.Global = "resolution", 
                                     Min.Dist.Regional = "resolution", 
                                     Background.method = "random",
                                     save.output = FALSE
  )
  
  # Extract pseudo-absence points
  PA_random_global_datasets[[i]] <- nsdm_finput$Background.XY.Global
}
names(PA_random_global_datasets) <- paste0("PA_rand_", 1:10)


#####Next generate 10 PA data sets for global model using stratified generation. Make 1 to 1 presence to absence ratio

PA_stratified_global_datasets <- list()

nsdm_input <-NSDM.InputData(SpeciesName = "R.areolata",
                            spp.data.global = global_occ_train,
                            spp.data.regional = regional_occ_train,
                            expl.var.global = expl.var.global,
                            expl.var.regional = expl.var.regional,
                            new.env = list(future_scenario_1, future_scenario_2, future_scenario_3, future_scenario_4, future_scenario_5, future_scenario_6),
                            new.env.names = c("future_scenario_1", "future_scenario_2", "future_scenario_3","future_scenario_4", "future_scenario_5", "future_scenario_6"),
                            Background.Global = NULL,
                            Background.Regional = NULL,
                            Absences.Global = NULL,
                            Absences.Regional = NULL
)

for(i in 1:10){
  # Run NSDM.FormattingData to generate pseudo-absences
  nsdm_finput <- NSDM.FormattingData(nsdm_input,
                                     nPoints = 220, 
                                     Min.Dist.Global = "resolution", 
                                     Min.Dist.Regional = "resolution", 
                                     Background.method = "stratified",
                                     save.output = FALSE
  )
  
  # Extract pseudo-absence points
  PA_stratified_global_datasets[[i]] <- nsdm_finput$Background.XY.Global
}
names(PA_stratified_global_datasets) <- paste0("PA_strat_", 1:10)



#####Next randomly generate 10 PA data sets for regional model. Make 1 to 1 presence to absence ratio

PA_random_regional_datasets <- list()

nsdm_input <-NSDM.InputData(SpeciesName = "R.areolata",
                            spp.data.global = global_occ_train,
                            spp.data.regional = regional_occ_train,
                            expl.var.global = expl.var.global,
                            expl.var.regional = expl.var.regional,
                            new.env = list(future_scenario_1, future_scenario_2, future_scenario_3, future_scenario_4, future_scenario_5, future_scenario_6),
                            new.env.names = c("future_scenario_1", "future_scenario_2", "future_scenario_3","future_scenario_4", "future_scenario_5", "future_scenario_6"),
                            Background.Global = NULL,
                            Background.Regional = NULL,
                            Absences.Global = NULL,
                            Absences.Regional = NULL
)
for(i in 1:10){
  set.seed(579 + i)
  # Run NSDM.FormattingData to generate pseudo-absences
  nsdm_finput <- NSDM.FormattingData(nsdm_input,
                                     nPoints = 190, 
                                     Min.Dist.Global = "resolution", 
                                     Min.Dist.Regional = "resolution", 
                                     Background.method = "random",
                                     save.output = FALSE
  )
  
  # Extract pseudo-absence points
  PA_random_regional_datasets[[i]] <- nsdm_finput$Background.XY.Regional
}
names(PA_random_regional_datasets) <- paste0("PA_rand_", 01:10)


#####Next stratify generate 10 PA data sets for regional model. Make 1 to 1 presence to absence ratio

PA_stratified_regional_datasets <- list()

nsdm_input <-NSDM.InputData(SpeciesName = "R.areolata",
                            spp.data.global = global_occ_train,
                            spp.data.regional = regional_occ_train,
                            expl.var.global = expl.var.global,
                            expl.var.regional = expl.var.regional,
                            new.env = list(future_scenario_1, future_scenario_2, future_scenario_3, future_scenario_4, future_scenario_5, future_scenario_6),
                            new.env.names = c("future_scenario_1", "future_scenario_2", "future_scenario_3","future_scenario_4", "future_scenario_5", "future_scenario_6"),
                            Background.Global = NULL,
                            Background.Regional = NULL,
                            Absences.Global = NULL,
                            Absences.Regional = NULL
)
for(i in 1:10){
  # Run NSDM.FormattingData to generate pseudo-absences
  nsdm_finput <- NSDM.FormattingData(nsdm_input,
                                     nPoints = 218, 
                                     Min.Dist.Global = "resolution", 
                                     Min.Dist.Regional = "resolution", 
                                     Background.method = "stratified",
                                     save.output = FALSE
  )
  
  # Extract pseudo-absence points
  PA_stratified_regional_datasets[[i]] <- nsdm_finput$Background.XY.Regional
}
names(PA_stratified_regional_datasets) <- paste0("PA_strat_", 01:10)






#set aside 47 PA for testing
nsdm_finput <- NSDM.FormattingData(nsdm_input,
                                   nPoints = 54, 
                                   Min.Dist.Global = "resolution", 
                                   Min.Dist.Regional = "resolution", 
                                   Background.method = "stratified",
                                   save.output = FALSE
)

regional_abs_test <- nsdm_finput$Background.XY.Regional

write.csv(regional_abs_test, file = "data/occurences_absences/abs_reg/regional_abs_test_10.csv", row.names = FALSE)

#Save all reg PA datasets 
for (n in names(PA_stratified_regional_datasets)) {
  df <- PA_stratified_regional_datasets[[n]]
  write.csv(df, file = file.path("data/occurences_absences/abs_reg/", paste0("reg_", n, ".csv")), row.names = FALSE)
}

#Save all glob PA datasets 
for (n in names(PA_stratified_global_datasets)) {
  df <- PA_stratified_global_datasets[[n]]
  write.csv(df, file = file.path("data/occurences_absences/abs_global/", paste0("glob_", n, ".csv")), row.names = FALSE)
}
