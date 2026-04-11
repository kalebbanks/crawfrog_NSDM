#####################
#Script: 05_testing_models.R
#Purpose: Test models on independent data following model creation. 
#Inputs: The Biomod results folder that was created in 04. 
#Outputs: 
#Author:Kaleb M. Banks
#Date: 2025-09-23
#####################
#packages
#install.packages("terra")
#install.packages("PresenceAbsence")
#install packages("dplyr")
library(terra)
library(PresenceAbsence)
library(dplyr)


#Test data
test_abs <- read.csv("data/occurrences_absences/abs_reg/regional_abs_test.csv")
test_occ <- read.csv("data/occurrences_absences/occ_thinned/regional_occ_test.csv")

#Current predictions
reg_cur_pred <- rast("Results/Regional/Projections/R.areolata.Current.tif")
mult_cur_pred <- rast("Results/Multiply/Projections/R.areolata.Current.tif")
covar_cur_pred <- rast("Results/Covariate/Projections/R.areolata.Current.tif")
glob_cur_pred <- rast("Results/Global/Projections/R.areolata.Current.tif")

reg_TSS_cutoff <- read.csv("Results/Regional/Values/R.areolata_ensemble.csv")[2, 9]*0.001
mult_TSS_cutoff <- read.csv("Results/Multiply/Values/R.areolata_ensemble.csv")[3, 3]*0.001
covar_TSS_cutoff <- read.csv("Results/Covariate/Values/R.areolata_ensemble.csv")[2, 9]*0.001
glob_TSS_cutoff <- read.csv("Results/Global/Values/R.areolata_ensemble.csv")[2, 9]*0.001

#####_____Regional models_____

reg_pred <- as.data.frame(reg_cur_pred, cells = TRUE)
colnames(reg_pred)[1:2] <- c("cell_id", "reg")
reg_pred$reg <- pmax(0, reg_pred$reg * 0.001)

test_abs$cell_id  <- cellFromXY(reg_cur_pred, test_abs[, c("x", "y")])
test_occ$cell_id <- cellFromXY(reg_cur_pred, test_occ[, c("x", "y")])
test_abs$obs_value  <- 0
test_occ$obs_value <- 1
reg_test <- bind_rows(
  test_abs %>% select(cell_id, obs_value),
  test_occ %>% select(cell_id, obs_value)
)
reg_test <- reg_test %>%
  left_join(reg_pred, by = "cell_id") %>%
  select(cell_id, obs_value, reg)

reg_accuracy <- presence.absence.accuracy(reg_test, threshold = reg_TSS_cutoff, find.auc = TRUE, st.dev = FALSE)

#####______ Covariate model _____
covar_pred <- as.data.frame(covar_cur_pred, cells = TRUE)
colnames(covar_pred)[1:2] <- c("cell_id", "covar")
covar_pred$covar <- pmax(0, covar_pred$covar * 0.001)

test_abs$cell_id  <- cellFromXY(covar_cur_pred, test_abs[, c("x", "y")])
test_occ$cell_id <- cellFromXY(covar_cur_pred, test_occ[, c("x", "y")])
test_abs$obs_value  <- 0
test_occ$obs_value <- 1
covar_test <- bind_rows(
  test_abs %>% select(cell_id, obs_value),
  test_occ %>% select(cell_id, obs_value)
)
covar_test <- covar_test %>%
  left_join(covar_pred, by = "cell_id") %>%
  select(cell_id, obs_value, covar)

covar_accuracy <- presence.absence.accuracy(covar_test, threshold = covar_TSS_cutoff, find.auc = TRUE, st.dev = FALSE)


#####______ multiply model _____
mult_pred <- as.data.frame(mult_cur_pred, cells = TRUE)
colnames(mult_pred)[1:2] <- c("cell_id", "mult")
mult_pred$mult <- pmax(0, mult_pred$mult * 0.001)

test_abs$cell_id  <- cellFromXY(mult_cur_pred, test_abs[, c("x", "y")])
test_occ$cell_id <- cellFromXY(mult_cur_pred, test_occ[, c("x", "y")])
test_abs$obs_value  <- 0
test_occ$obs_value <- 1
mult_test <- bind_rows(
  test_abs %>% select(cell_id, obs_value),
  test_occ %>% select(cell_id, obs_value)
)
mult_test <- mult_test %>%
  left_join(mult_pred, by = "cell_id") %>%
  select(cell_id, obs_value, mult)

mult_test$mult[is.na(mult_test$mult)] <- 0

mult_accuracy <- presence.absence.accuracy(mult_test, threshold = mult_TSS_cutoff, find.auc = TRUE, st.dev = FALSE)

#####______ Global models _____
glob_pred <- as.data.frame(glob_cur_pred, cells = TRUE)
colnames(glob_pred)[1:2] <- c("cell_id", "glob")
glob_pred$glob <- pmax(0, glob_pred$glob * 0.001)

test_abs$cell_id  <- cellFromXY(glob_cur_pred, test_abs[, c("x", "y")])
test_occ$cell_id <- cellFromXY(glob_cur_pred, test_occ[, c("x", "y")])
test_abs$obs_value  <- 0
test_occ$obs_value <- 1
glob_test <- bind_rows(
  test_abs %>% select(cell_id, obs_value),
  test_occ %>% select(cell_id, obs_value)
)
glob_test <- glob_test %>%
  left_join(glob_pred, by = "cell_id") %>%
  select(cell_id, obs_value, glob)

glob_accuracy <- presence.absence.accuracy(glob_test, threshold = glob_TSS_cutoff, find.auc = TRUE, st.dev = FALSE)

#####______Combine the datasets and import the CV scores from model training

#These scores are from the biomod Results folder (Values/R.areolata_ensemble)
glob_cv_TSS <- read.csv("Results/Global/Values/R.areolata_ensemble.csv")[2, 12]
glob_cv_AUC <- read.csv("Results/Global/Values/R.areolata_ensemble.csv")[1, 12]
reg_cv_TSS <- read.csv("Results/Regional/Values/R.areolata_ensemble.csv")[2, 12]
reg_cv_AUC <- read.csv("Results/Regional/Values/R.areolata_ensemble.csv")[1, 12]
covar_cv_TSS <- read.csv("Results/Covariate/Values/R.areolata_ensemble.csv")[2, 12]
covar_cv_AUC <- read.csv("Results/Covariate/Values/R.areolata_ensemble.csv")[1, 12]
mult_cv_tss <- read.csv("Results/Multiply/Values/R.areolata_ensemble.csv")[3, 7]
mult_cv_AUC <- read.csv("Results/Multiply/Values/R.areolata_ensemble.csv")[2, 7]


accuracy <- bind_rows(glob_accuracy, reg_accuracy, covar_accuracy, mult_accuracy)

names(accuracy)[names(accuracy) == "sensitivity"] <- "sens_eval"
names(accuracy)[names(accuracy) == "specificity"] <- "spec_eval"
names(accuracy)[names(accuracy) == "threshold"] <- "TSS_cutoff"
names(accuracy)[names(accuracy) == "threshold"] <- "TSS_cutoff"
names(accuracy)[names(accuracy) == "PCC"] <- "PCC_eval"
names(accuracy)[names(accuracy) == "AUC"] <- "AUC_eval"
names(accuracy)[names(accuracy) == "Kappa"] <- "Kappa_eval"
accuracy$TSS_eval <- accuracy$sens_eval+ accuracy$spec_eval - 1
accuracy$TSS_cv <- c(glob_cv_TSS,reg_cv_TSS, covar_cv_TSS, mult_cv_tss)
accuracy$AUC_cv <- c(glob_cv_AUC, reg_cv_AUC, covar_cv_AUC, mult_cv_AUC)

write.csv(accuracy, file = ("Outputs/model_eval.csv"))

