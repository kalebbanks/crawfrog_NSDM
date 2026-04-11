#####################
#Script: 03_threshold_sensitivty_analysis.R
#Purpose: The purpose of this sensitivity analysis is decide what selection threshold and precense absence dataset to use for our final models. Details are in supplementary files section 1/ 
#Inputs: data/occurrences_absences
#        data/env_var
#Outputs: 
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
global_PA_1_train <- read.csv("data/occurrences_absences/abs_global/glob_PA_strat_1.csv")
global_PA_2_train <- read.csv("data/occurrences_absences/abs_global/glob_PA_strat_2.csv")
global_PA_3_train <- read.csv("data/occurrences_absences/abs_global/glob_PA_strat_3.csv")
global_PA_4_train <- read.csv("data/occurrences_absences/abs_global/glob_PA_strat_4.csv")
global_PA_5_train <- read.csv("data/occurrences_absences/abs_global/glob_PA_strat_5.csv")
global_PA_6_train <- read.csv("data/occurrences_absences/abs_global/glob_PA_strat_6.csv")
global_PA_7_train <- read.csv("data/occurrences_absences/abs_global/glob_PA_strat_7.csv")
global_PA_8_train <- read.csv("data/occurrences_absences/abs_global/glob_PA_strat_8.csv")
global_PA_9_train <- read.csv("data/occurrences_absences/abs_global/glob_PA_strat_9.csv")
global_PA_10_train <- read.csv("data/occurrences_absences/abs_global/glob_PA_strat_10.csv")


regional_PA_1_train <- read.csv("data/occurrences_absences/abs_reg/reg_PA_strat_1.csv")
regional_PA_2_train <- read.csv("data/occurrences_absences/abs_reg/reg_PA_strat_2.csv")
regional_PA_3_train <- read.csv("data/occurrences_absences/abs_reg/reg_PA_strat_3.csv")
regional_PA_4_train <- read.csv("data/occurrences_absences/abs_reg/reg_PA_strat_4.csv")
regional_PA_5_train <- read.csv("data/occurrences_absences/abs_reg/reg_PA_strat_5.csv")
regional_PA_6_train <- read.csv("data/occurrences_absences/abs_reg/reg_PA_strat_6.csv")
regional_PA_7_train <- read.csv("data/occurrences_absences/abs_reg/reg_PA_strat_7.csv")
regional_PA_8_train <- read.csv("data/occurrences_absences/abs_reg/reg_PA_strat_8.csv")
regional_PA_9_train <- read.csv("data/occurrences_absences/abs_reg/reg_PA_strat_9.csv")
regional_PA_10_train <- read.csv("data/occurrences_absences/abs_reg/reg_PA_strat_10.csv")

#####Load Test Pseduo-absences
regional_abs_test <- read.csv("data/occurrences_absences/abs_reg/regional_abs_test.csv")

######Load test occurrences
R.areolata_reg_test_occ <- read.csv("data/occurrences_absences/occ_thinned/regional_occ_test.csv")


#####Load env var
expl.var.global <- rast("data/env_var/scenarios_spatraster/expl.var.global.tif")
expl.var.regional <- rast("data/env_var/scenarios_spatraster/expl.var.regional.tif")
future_scenario_1 <- rast("data/env_var/scenarios_spatraster/future_scenario_1.tif")
future_scenario_2 <- rast("data/env_var/scenarios_spatraster/future_scenario_2.tif")
future_scenario_3 <- rast("data/env_var/scenarios_spatraster/future_scenario_3.tif")
future_scenario_4 <- rast("data/env_var/scenarios_spatraster/future_scenario_4.tif")
future_scenario_5 <- rast("data/env_var/scenarios_spatraster/future_scenario_5.tif")
future_scenario_6 <- rast("data/env_var/scenarios_spatraster/future_scenario_6.tif")

###############Regional threshold analysis#####################################
regional_PA_list <- list(regional_PA_1_train, regional_PA_2_train,regional_PA_3_train,regional_PA_4_train,regional_PA_5_train, regional_PA_6_train, regional_PA_7_train, regional_PA_8_train, regional_PA_9_train, regional_PA_10_train)

thresholds <- seq(0.50, 0.95, by = 0.05)

regional_sens_results <- data.frame(
  PA_dataset = integer(),
  threshold = numeric(),
  AUC_cv = numeric(),
  TSS_cv = numeric(),
  TSS_cutoff = numeric(),
  AUC_eval = numeric(),
  TSS_eval = numeric(),
  skipped = logical(),
  skip_reason = character(),
  stringsAsFactors = FALSE
)

for(i in seq_along(regional_PA_list)) {
  
  message("Running models for PA dataset ", i)
  
  nsdm_regional <- NSDM.InputData(
    SpeciesName = "R.areolata",
    spp.data.global = R.areolata_glob_train_occ,
    spp.data.regional = R.areolata_reg_train_occ,
    expl.var.global = expl.var.global,
    expl.var.regional = expl.var.regional,
    new.env = list(future_scenario_1, future_scenario_2, future_scenario_3,
                   future_scenario_4, future_scenario_5, future_scenario_6),
    new.env.names = c("future_scenario_1", "future_scenario_2", "future_scenario_3",
                      "future_scenario_4", "future_scenario_5", "future_scenario_6"),
    Background.Global = global_PA_1_train,
    Background.Regional = regional_PA_list[[i]],
    Absences.Global = NULL,
    Absences.Regional = NULL
  )
  
  nsdm_finput <- NSDM.FormattingData(
    nsdm_regional,
    Min.Dist.Global = "resolution", 
    Min.Dist.Regional = "resolution", 
    Background.method = "random",
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
  for (thresh in thresholds) {
    message("---Running threshold: ", thresh)
    
    warn_store <- character()
    
    res <- tryCatch({
      withCallingHandlers({
        
        # ---- run the model ----
        nsdm_regional <- NSDM.Regional(
          nsdm_selvars,
          algorithms = c("MAXNET", "MARS", "GBM"),
          CV.nb.rep = 20,
          CV.perc = 0.8,
          metric.select.thresh = thresh,
          CustomModelOptions = NULL,
          save.output = FALSE,
          rm.biomod.folder = FALSE
        )
        
        if (is.null(nsdm_regional)) stop("NSDM.Regional returned NULL")
        
        # ---- extract predictions ----
        r <- terra::unwrap(nsdm_regional$current.projections$Pred)
        pred_r <- as.data.frame(r, cells = TRUE)
        colnames(pred_r)[1:2] <- c("cell_id", "pred")
        pred_r$pred <- pred_r$pred / 1000
        
        # ---- extract CV metrics ----
        TSS_cutoff <- as.numeric(nsdm_regional$myEMeval.Ensemble$cutoff[2]) / 1000
        TSS_CV     <- as.numeric(nsdm_regional$Summary$Values[5])
        AUC_CV     <- as.numeric(nsdm_regional$Summary$Values[4])
        
        # ---- prepare test observations ----
        pa_test_tmp <- regional_abs_test
        occ_test_tmp <- R.areolata_reg_test_occ
        
        pa_test_tmp$cell_id  <- cellFromXY(r, pa_test_tmp[, c("x", "y")])
        occ_test_tmp$cell_id <- cellFromXY(r, occ_test_tmp[, c("x", "y")])
        
        pa_test_tmp$obs_value  <- 0
        occ_test_tmp$obs_value <- 1
        
        obs_combined <- bind_rows(
          pa_test_tmp %>% select(cell_id, obs_value),
          occ_test_tmp %>% select(cell_id, obs_value)
        )
        
        test_df <- obs_combined %>%
          left_join(pred_r, by = "cell_id") %>%
          select(cell_id, obs_value, pred)
        
        if (all(is.na(test_df$pred))) stop("All predicted values are NA for this model")
        
        # ---- compute test meterics ----
        accuracy <- presence.absence.accuracy(test_df, threshold = TSS_cutoff, find.auc = TRUE)
        
        sen  <- as.numeric(accuracy[1, 4])
        spec <- as.numeric(accuracy[1, 5])
        TSS_eval <- (sen + spec) - 1
        AUC_eval <- as.numeric(accuracy[1, 7])
        
        list(
          ok = TRUE,
          TSS_cutoff = TSS_cutoff,
          TSS_CV = TSS_CV,
          AUC_CV = AUC_CV,
          TSS_eval = TSS_eval,
          AUC_eval = AUC_eval,
          warnings = warn_store
        )
        
      }, warning = function(w) {
        warn_store <<- c(warn_store, conditionMessage(w))
        invokeRestart("muffleWarning")
      })
    },
    error = function(e) {
      list(ok = FALSE, error = conditionMessage(e), warnings = warn_store)
    })
    
    # ---- store results ----
    if (!isTRUE(res$ok)) {
      regional_sens_results <- rbind(regional_sens_results, data.frame(
        PA_dataset = i,
        threshold = thresh,
        AUC_cv = NA_real_,
        TSS_cv = NA_real_,
        TSS_cutoff = NA_real_,
        AUC_eval = NA_real_,
        TSS_eval = NA_real_,
        skipped = TRUE,
        skip_reason = res$error,
        stringsAsFactors = FALSE
      ))
    } else {
      regional_sens_results <- rbind( regional_sens_results, data.frame(
        PA_dataset = i,
        threshold = thresh,
        AUC_cv = res$AUC_CV,
        TSS_cv = res$TSS_CV,
        TSS_cutoff = res$TSS_cutoff,
        AUC_eval = res$AUC_eval,
        TSS_eval = res$TSS_eval,
        skipped = FALSE,
        skip_reason = paste(res$warnings, collapse = " || "),
        stringsAsFactors = FALSE
      ))
    }
  }
}

regional_sens_results <- regional_sens_results[ , -9]

#write.csv(regional_sens_results, "outputs/regional_sens_results_3.csv")



################Global threshold analysis######################################
global_PA_list <- list(global_PA_1_train, global_PA_2_train, global_PA_3_train, global_PA_4_train, global_PA_5_train,global_PA_6_train,global_PA_7_train,global_PA_8_train,global_PA_9_train,global_PA_10_train)
thresholds <- seq(0.50, 0.95, by = 0.05)

global_sens_results <- data.frame(
  PA_dataset = integer(),
  threshold = numeric(),
  AUC_cv = numeric(),
  TSS_cv = numeric(),
  TSS_cutoff = numeric(),
  AUC_eval = numeric(),
  TSS_eval = numeric(),
  skipped = logical(),
  skip_reason = character(),
  stringsAsFactors = FALSE
)

for(i in seq_along(global_PA_list)) {
  
  message("Running models for PA dataset ", i)
  
  nsdm_global <- NSDM.InputData(
    SpeciesName = "R.areolata",
    spp.data.global = R.areolata_glob_train_occ,
    spp.data.regional = R.areolata_reg_train_occ,
    expl.var.global = expl.var.global,
    expl.var.regional = expl.var.regional,
    new.env = list(future_scenario_1, future_scenario_2, future_scenario_3,
                   future_scenario_4, future_scenario_5, future_scenario_6),
    new.env.names = c("future_scenario_1", "future_scenario_2", "future_scenario_3",
                      "future_scenario_4", "future_scenario_5", "future_scenario_6"),
    Background.Global = global_PA_list[[i]],
    Background.Regional = regional_PA_1_train,
    Absences.Global = NULL,
    Absences.Regional = NULL
  )
  
  nsdm_finput <- NSDM.FormattingData(
    nsdm_global,
    Min.Dist.Global = "resolution", 
    Min.Dist.Regional = "resolution", 
    Background.method = "random",
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
  for (thresh in thresholds) {
    message("---Running threshold: ", thresh)
    
    warn_store <- character()
    
    res <- tryCatch({
      withCallingHandlers({
        
        # ---- run the model ----
        nsdm_global <- NSDM.Global(
          nsdm_selvars,
          algorithms = c("MAXNET", "MARS", "GBM", "GAM", "GLM"),
          CV.nb.rep = 20,
          CV.perc = 0.8,
          metric.select.thresh = thresh,
          CustomModelOptions = NULL,
          save.output = FALSE,
          rm.biomod.folder = FALSE
        )
        
        if (is.null(nsdm_regional)) stop("NSDM.Regional returned NULL")
        
        # ---- extract predictions ----
        r <- terra::unwrap(nsdm_global$current.projections$Pred)
        pred_r <- as.data.frame(r, cells = TRUE)
        colnames(pred_r)[1:2] <- c("cell_id", "pred")
        pred_r$pred <- pred_r$pred / 1000
        
        # ---- extract CV metrics ----
        TSS_cutoff <- as.numeric(nsdm_global$myEMeval.Ensemble$cutoff[2]) / 1000
        TSS_CV     <- as.numeric(nsdm_global$Summary$Values[5])
        AUC_CV     <- as.numeric(nsdm_global$Summary$Values[4])
        
        # ---- prepare test observations ----
        pa_test_tmp <- regional_abs_test
        occ_test_tmp <- R.areolata_reg_test_occ
        
        pa_test_tmp$cell_id  <- cellFromXY(r, pa_test_tmp[, c("x", "y")])
        occ_test_tmp$cell_id <- cellFromXY(r, occ_test_tmp[, c("x", "y")])
        
        pa_test_tmp$obs_value  <- 0
        occ_test_tmp$obs_value <- 1
        
        obs_combined <- bind_rows(
          pa_test_tmp %>% select(cell_id, obs_value),
          occ_test_tmp %>% select(cell_id, obs_value)
        )
        
        test_df <- obs_combined %>%
          left_join(pred_r, by = "cell_id") %>%
          select(cell_id, obs_value, pred)
        
        if (all(is.na(test_df$pred))) stop("All predicted values are NA for this model")
        
        # ---- compute test metrics ----
        accuracy <- presence.absence.accuracy(test_df, threshold = TSS_cutoff, find.auc = TRUE)
        
        sen  <- as.numeric(accuracy[1, 4])
        spec <- as.numeric(accuracy[1, 5])
        TSS_eval <- (sen + spec) - 1
        AUC_eval <- as.numeric(accuracy[1, 7])
        
        list(
          ok = TRUE,
          TSS_cutoff = TSS_cutoff,
          TSS_CV = TSS_CV,
          AUC_CV = AUC_CV,
          TSS_eval = TSS_eval,
          AUC_eval = AUC_eval,
          warnings = warn_store
        )
        
      }, warning = function(w) {
        warn_store <<- c(warn_store, conditionMessage(w))
        invokeRestart("muffleWarning")
      })
    },
    error = function(e) {
      list(ok = FALSE, error = conditionMessage(e), warnings = warn_store)
    })
    
    # ---- store results ----
    if (!isTRUE(res$ok)) {
      global_sens_results <- rbind(global_sens_results, data.frame(
        PA_dataset = i,
        threshold = thresh,
        AUC_cv = NA_real_,
        TSS_cv = NA_real_,
        TSS_cutoff = NA_real_,
        AUC_eval = NA_real_,
        TSS_eval = NA_real_,
        skipped = TRUE,
        skip_reason = res$error,
        stringsAsFactors = FALSE
      ))
    } else {
      global_sens_results <- rbind(global_sens_results, data.frame(
        PA_dataset = i,
        threshold = thresh,
        AUC_cv = res$AUC_CV,
        TSS_cv = res$TSS_CV,
        TSS_cutoff = res$TSS_cutoff,
        AUC_eval = res$AUC_eval,
        TSS_eval = res$TSS_eval,
        skipped = FALSE,
        skip_reason = paste(res$warnings, collapse = " || "),
        stringsAsFactors = FALSE
      ))
    }
  }
}

global_sens_results <- global_sens_results[ , -9]

#write.csv(global_sens_results, "outputs/global_sens_results_3.csv")

global_sens_results <- global_sens_results %>% filter(skipped == FALSE)

global_sens_results_long <- global_sens_results %>%
  pivot_longer(cols = c(AUC_cv, TSS_cv, AUC_eval, TSS_eval),
               names_to = "metric",
               values_to = "value")



reg_summary <- reg_sens_results%>%
  group_by(threshold) %>%
  summarise(
    mean_AUC = mean(AUC_eval, na.rm = TRUE),
    n = n()
  )
#For regional models 0.80 seems to be best compromise between high mean AUC and models being retained. 

glob_summary <- glob_sens_results%>%
  group_by(threshold) %>%
  summarise(
    mean_AUC = mean(AUC_eval, na.rm = TRUE),
    n = n()
  )
#For global 0.85 seems to be a good compromise

glob_sens_results_085 <- glob_sens_results[glob_sens_results$threshold == 0.85, ]
reg_sens_results_085 <- reg_sens_results[reg_sens_results$threshold == 0.80, ]
#PA dataset 1, is best AUC Eval score for both regional and global models

