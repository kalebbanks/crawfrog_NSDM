#####################
#Script: 07_figures.R
#Purpose: Create figures 4, 6, and supplementary figures. Other figures were created in ARCGIS
#Inputs: 
#Outputs: 
#Author:Kaleb M. Banks
#Date: 2025-09-30
#####################
#packages
#install.packages("rprojroot")
#install.packages("biomod2")
#install.packages("dplyr")
#install.packages("ggplot2")
#install.packages("tidyterra")
library(biomod2)
library(rprojroot)
library(dplyr)
library(ggplot2)
library(tidyterra)


#_____Figure 4______#
#####Find response curves
#First load biomod2 output files for each model. 
load("Results/Regional/Models/R.areolata/R.areolata.AllModels.ensemble.models.out")
reg_ensemble_BIOMOD_output <- R.areolata.AllModels.ensemble.models.out
rm(R.areolata.AllModels.ensemble.models.out)

load("Results/Covariate/Models/R.areolata/R.areolata.AllModels.ensemble.models.out")
covar_ensemble_BIOMOD_output <- R.areolata.AllModels.ensemble.models.out
rm(R.areolata.AllModels.ensemble.models.out)

load("Results/Global/Models/R.areolata/R.areolata.AllModels.ensemble.models.out")
glob_ensemble_BIOMOD_output <- R.areolata.AllModels.ensemble.models.out
rm(R.areolata.AllModels.ensemble.models.out)

#This is a pain but for biomod to find the right model outputs the working directory has to be set the Models folder 
setwd("Results/Covariate/Models/")

covar_response_curves <- biomod2::bm_PlotResponseCurves(
  bm.out = covar_ensemble_BIOMOD_output
  , models.chosen = biomod2::get_built_models(covar_ensemble_BIOMOD_output)
  , fixed.var = 'median')

covar_response_curves <- covar_response_curves$plot$data
covar_response_curves <- covar_response_curves[covar_response_curves$pred.name != "R.areolata_EMcvByROC_mergedData_mergedRun_mergedAlgo", ]
covar_response_curves <- covar_response_curves[, !(names(covar_response_curves) %in% c("pred.name", "id"))]
covar_response_curves$model <- "Covariate"
setwd(find_rstudio_root_file())


setwd("Results/Regional/Models/")

reg_response_curves <- biomod2::bm_PlotResponseCurves(
  bm.out = reg_ensemble_BIOMOD_output
  , models.chosen = biomod2::get_built_models(reg_ensemble_BIOMOD_output)
  , fixed.var = 'median')

reg_response_curves <- reg_response_curves$plot$data
reg_response_curves <- reg_response_curves[reg_response_curves$pred.name != "R.areolata_EMcvByROC_mergedData_mergedRun_mergedAlgo", ]
reg_response_curves <- reg_response_curves[, !(names(reg_response_curves) %in% c("pred.name", "id"))]
reg_response_curves$model <- "Regional"
setwd(find_rstudio_root_file())


setwd("Results/Global/Models/")

glob_response_curves <- biomod2::bm_PlotResponseCurves(
  bm.out = glob_ensemble_BIOMOD_output
  , models.chosen = biomod2::get_built_models(glob_ensemble_BIOMOD_output)
  , fixed.var = 'median')

glob_response_curves <- glob_response_curves$plot$data
glob_response_curves <- glob_response_curves[glob_response_curves$pred.name != "R.areolata_EMcvByROC_mergedData_mergedRun_mergedAlgo", ]
glob_response_curves <- glob_response_curves[, !(names(glob_response_curves) %in% c("pred.name", "id"))]
glob_response_curves$model <- "Global"

#reset working directory back to project root
setwd(find_rstudio_root_file())

response_curves <- rbind(glob_response_curves, reg_response_curves, covar_response_curves)


training_ranges <- data.frame(
  expl.name = c("bio_12", "bio_10", "bio_8", "bio_2", "bio_9"),  # Replace with actual names of expl.name values
  training_min = c(753,24.338,14.579, 12.193, 2.209),         # Replace with actual minimums for each expl.name
  training_max = c(1378,27.876,24.408, 13.840, 25.821)             # Replace with actual maximums for each expl.name
)

custom_labels <- c(
  "bio_12" = "Annual rainfall (mm)",
  "bio_10" = "Mean Temp of Warmest Quarter (°C)",
  "bio_9" = "Mean Temp of Driest Quarter (°C)",
  "bio_8" = "Mean Temp of Wettest Quarter (°C)",
  "bio_2" = "Mean Diurnal Range (°C)",
  "percent_prairie" = "Percent Prairie",
  "percent_clay" = "Percent Clay",
  "SDM.global" = "Global SDM"
)

response_curves <- response_curves %>%
  left_join(training_ranges, by = "expl.name") %>%
  mutate(
    training_min = ifelse(is.na(training_min), -Inf, training_min),  # Set to -Inf if missing
    training_max = ifelse(is.na(training_max), Inf, training_max)    # Set to Inf if missing
  )

response_curves$expl.name <- factor(
  response_curves$expl.name, 
  levels = c("bio_12", "bio_10", "bio_9", "bio_8", "bio_2", "percent_prairie", "percent_clay", "SDM.global")  # Define the order you want
)


ggplot(response_curves, aes(x = expl.val, y = pred.val, color = model)) +
      geom_line(size = 1.2) +
      geom_segment(
        data = subset(response_curves, training_min != -Inf & training_max != Inf),
        aes(x = training_min, xend = training_max, y = 0, yend = 0),
        color = "black", size = 1
      ) +
      facet_wrap(~ expl.name, scales = "free_x", labeller = labeller(expl.name = custom_labels)) +
      scale_x_continuous(breaks = scales::pretty_breaks(n = 7)) +
      labs(
        x = "",
        y = "Habitat Suitability",
        color = "Model"
      ) +
      theme_minimal(base_family = "Times New Roman") +  # Keep this once
      theme(
        axis.title.x = element_text(size = 16),
        axis.title.y = element_text(size = 16),
        axis.text.x = element_text(size = 15),
        axis.text.y = element_text(size = 15),
        legend.text = element_text(size = 17),
        legend.title = element_text(size = 0),
        strip.text = element_text(size = 18),
        legend.position = "top",
        panel.grid = element_blank(),
        axis.line = element_line(color = "black", linewidth = 0.5)
      )

ggsave(
  filename = "figures/figure_4.pdf",
  plot = last_plot(),
  device = cairo_pdf,
  width = 12,
  height = 7,
  units = "in"
)

######Table 2: Variable importance scores

#Global
glob_models_var_import <- read.csv("Results/Global/Values/R.areolata_indvar.csv")
glob_indiv_models <- read.csv("Results/Global/Values/R.areolata_replica.csv")
glob_indiv_models <- glob_indiv_models[glob_indiv_models$metric.eval == "ROC", ]
glob_indiv_models <- glob_indiv_models[glob_indiv_models$validation >= 0.85, ]
glob_models_var_import <- glob_models_var_import[
  glob_models_var_import$full.name %in% glob_indiv_models$full.name, 
]
glob_ensemble_var_import <- aggregate(var.imp ~ expl.var, data = glob_models_var_import, FUN = mean, na.rm = TRUE)

#regional 
reg_models_var_import <- read.csv("Results/Regional/Values/R.areolata_indvar.csv")
reg_indiv_models <- read.csv("Results/Regional/Values/R.areolata_replica.csv")
reg_indiv_models <- reg_indiv_models[reg_indiv_models$metric.eval == "ROC", ]
reg_indiv_models <- reg_indiv_models[reg_indiv_models$validation >= 0.85, ]
reg_models_var_import <- reg_models_var_import[
reg_models_var_import$full.name %in% reg_indiv_models$full.name, 
]
reg_ensemble_var_import <- aggregate(var.imp ~ expl.var, data = reg_models_var_import, FUN = mean, na.rm = TRUE)

#covariate
covar_models_var_import <- read.csv("Results/Covariate/Values/R.areolata_indvar.csv")
covar_indiv_models <- read.csv("Results/Covariate/Values/R.areolata_replica.csv")
covar_indiv_models <- covar_indiv_models[covar_indiv_models$metric.eval == "ROC", ]
covar_indiv_models <- covar_indiv_models[covar_indiv_models$validation >= 0.85, ]
covar_models_var_import <- covar_models_var_import[
covar_models_var_import$full.name %in% covar_indiv_models$full.name, 
]
covar_ensemble_var_import <- aggregate(var.imp ~ expl.var, data = covar_models_var_import, FUN = mean, na.rm = TRUE)

#######Figure 6

#future_scenarios <- read_excel("outputs/future_scenarios.xlsx")

df_long <- future_scenarios %>%
  pivot_longer(cols = c(habitat_gained, habitat_lost, habitat_retained),
               names_to = "habitat_change",
               values_to = "value")

df_long$Projection <- factor(df_long$Projection,
                             levels = unique(df_long$Projection[order(df_long$scenario)]))

df_long$habitat_change <- factor(
  df_long$habitat_change,
  levels = c("habitat_gained", "habitat_retained", "habitat_lost")
)

line_data <- data.frame(
  y = c(2149, 2516, 2370),
  line_type = c("Regional-only","Multiply", "Covariate")  # Names for legend
)


ggplot(df_long, aes(x = Projection, y = value, fill = habitat_change)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(
    values = c(
      "habitat_gained" = rgb(46, 164, 0, maxColorValue = 255),
      "habitat_retained" = rgb(0, 77, 168, maxColorValue = 255),
      "habitat_lost" = rgb(237, 0, 0, maxColorValue = 255)
    ),
    labels = c(
      "habitat_gained" = "Habitat Gained",
      "habitat_retained" = "Habitat Retained",
      "habitat_lost" = "Habitat Lost"
    )
  ) +
  geom_hline(
    data = line_data,
    aes(yintercept = y, linetype = line_type, color = line_type),
    size = 1.5
  ) +
  scale_color_manual(
    name = "Current Total Habitat",  # Legend title for lines
    values = c("Regional-only" = "antiquewhite4",
               "Multiply" = "black",
               "Covariate" = "azure3")
  ) +
  scale_linetype_manual(
    name = "Current Total Habitat",
    values = c("Regional-only" = "dashed",
               "Multiply" = "dashed",
               "Covariate" = "dashed")
  ) +
  theme_minimal(base_family = "Times New Roman") +
  labs(x = "", y = "Raster Cells", fill = "") +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 20, color = "black"),
    axis.text.y = element_text(size = 20, color = "black"),
    axis.title.x = element_text(size = 12, color = "black"),
    axis.title.y = element_text(size = 20, color = "black"),
    legend.text = element_text(size = 17, color = "black"),
    legend.title = element_text(size = 15, color = "black"),
    panel.grid = element_blank(),
    axis.line = element_line(color = "black", linewidth = 0.5)
  ) +
  scale_y_continuous(
    breaks = c(-1000, -500, 0, 500, 1000, 1500, 2000, 2500, 3000),
    labels = c("-1000", "-500", "0", "500", "1000", "1500", "2000", "2500", "3000")
  )

ggsave(
  filename = "figures/figure_6.pdf",
  plot = last_plot(),
  device = cairo_pdf,
  width = 12,
  height = 7,
  units = "in"
)


##############Global model projection
setwd("Results/Global/Models/")

load("R.areolata/R.areolata.AllModels.ensemble.models.out")
glob_ensemble_BIOMOD_output <- R.areolata.AllModels.ensemble.models.out


range_wide <- BIOMOD_EnsembleForecasting(
  glob_ensemble_BIOMOD_output,
  proj.name = 'CurrentEM',
  new.env = expl.var.global,
  new.env.xy = NULL,
  models.chosen = "all",
  metric.binary = NULL,
  metric.filter = NULL,
  compress = TRUE,
  nb.cpu = 1,
  na.rm = TRUE,
)

setwd(find_rstudio_root_file())


biomod2::plot(range_wide,
              main="Crawfish Frog Species Distribution Model Map")

r_data <- range_wide@proj.out@val

r_layer <- rast(r_data)

writeRaster(r_layer, filename = "Outputs/range_wide_sdm.tif")
######################################
###Supplementart material section 1: 

glob_sens_results <- read.csv("outputs/global_sens_results.csv")
glob_sens_results <- glob_sens_results %>% filter(skipped == FALSE)
glob_sens_results_long <- glob_sens_results %>%
  pivot_longer(cols = c(AUC_train, TSS_train, AUC_test, TSS_test),
               names_to = "metric",
               values_to = "value")



reg_sens_results <- read.csv("outputs/regional_sens_results.csv")
reg_sens_results <- reg_sens_results %>% filter(skipped == FALSE)
reg_sens_results_long <- reg_sens_results %>%
  pivot_longer(cols = c(AUC_train, TSS_train, AUC_test, TSS_test),
               names_to = "metric",
               values_to = "value")


ggplot(reg_sens_results_long, aes(x = threshold, y = value, color = metric, linetype = metric)) +
  geom_line(size = 1) +
  facet_wrap(~PA_dataset) +
  labs(x = "Threshold",
       y = "Performance",
       color = "Metric",
       linetype = "Metric",
       title = "Regional-only Sensitivity Analysis") +
  theme_minimal(base_size = 14)

summary_reg_sens_results <- reg_sens_results %>%
  group_by(PA_dataset) %>%
  summarise(
    mean_AUC_cv   = mean(AUC_cv, na.rm = TRUE),
    mean_TSS_cv   = mean(TSS_cv, na.rm = TRUE),
    mean_AUC_eval = mean(AUC_eval, na.rm = TRUE),
    mean_TSS_eval = mean(TSS_eval, na.rm = TRUE)
  ) %>%
  arrange(desc(mean_AUC_eval), desc(mean_TSS_eval))

ggsave(
  filename = "figures/supp_mat_1a.png",   # can also use .tiff, .pdf, .jpg, .svg, etc.
  plot = last_plot(),           # or a ggplot object, e.g. plot = my_plot
  dpi = 600,                    # resolution (high quality = 300–600)
  width = 12, height = 7,        # size in inches
  units = "in"
)



#Visualize results
library(ggplot2)
dev.off()
ggplot(glob_sens_results_long, aes(x = threshold, y = value, color = metric, linetype = metric)) +
  geom_line(size = 1) +
  facet_wrap(~PA_dataset) +
  labs(x = "Threshold",
       y = "",
       color = "Metric",
       linetype = "Metric",
       title = "Global Sensitivity Analysis") +
  theme_minimal(base_size = 14) 


summary_global_sens_results <- global_sens_results %>%
  group_by(PA_dataset) %>%
  summarise(
    mean_AUC_cv   = mean(AUC_cv, na.rm = TRUE),
    mean_TSS_cv   = mean(TSS_cv, na.rm = TRUE),
    mean_AUC_eval = mean(AUC_eval, na.rm = TRUE),
    mean_TSS_eval = mean(TSS_eval, na.rm = TRUE)
  ) %>%
  arrange(desc(mean_AUC_eval), desc(mean_TSS_eval))

ggsave(
  filename = "figures/supp_mat_1b.png",   # can also use .tiff, .pdf, .jpg, .svg, etc.
  plot = last_plot(),           # or a ggplot object, e.g. plot = my_plot
  dpi = 600,                    # resolution (high quality = 300–600)
  width = 12, height = 7,        # size in inches
  units = "in"
)




#############################################################################

#####This is from the old project once i moved the working directory. Not sure if you need any of this code, just double check before you delete it below 

library(biomod2)
install.packages("rprojroot")  # if not installed
library(rprojroot)
library(dplyr)
library(ggplot2)


#_____Figure 4______#

#####Find response curves
#First load biomod2 output files for each model. 
load("Results/Regional/Models/R.areolata/R.areolata.AllModels.ensemble.models.out")
reg_ensemble_BIOMOD_output <- R.areolata.AllModels.ensemble.models.out
rm(R.areolata.AllModels.ensemble.models.out)

load("Results/Covariate/Models/R.areolata/R.areolata.AllModels.ensemble.models.out")
covar_ensemble_BIOMOD_output <- R.areolata.AllModels.ensemble.models.out
rm(R.areolata.AllModels.ensemble.models.out)

load("Results/Global/Models/R.areolata/R.areolata.AllModels.ensemble.models.out")
glob_ensemble_BIOMOD_output <- R.areolata.AllModels.ensemble.models.out
rm(R.areolata.AllModels.ensemble.models.out)

#This is a pain but for biomod to find the right model outputs the working directory has to be set the Models folder 
setwd("Results/Covariate/Models/")

covar_response_curves <- biomod2::bm_PlotResponseCurves(
  bm.out = covar_ensemble_BIOMOD_output
  , models.chosen = biomod2::get_built_models(covar_ensemble_BIOMOD_output)
  , fixed.var = 'median')

covar_response_curves <- covar_response_curves$plot$data
covar_response_curves <- covar_response_curves[covar_response_curves$pred.name != "R.areolata_EMcvByROC_mergedData_mergedRun_mergedAlgo", ]
covar_response_curves <- covar_response_curves[, !(names(covar_response_curves) %in% c("pred.name", "id"))]
covar_response_curves$model <- "Covariate"
setwd(find_rstudio_root_file())


setwd("Results/Regional/Models/")

reg_response_curves <- biomod2::bm_PlotResponseCurves(
  bm.out = reg_ensemble_BIOMOD_output
  , models.chosen = biomod2::get_built_models(reg_ensemble_BIOMOD_output)
  , fixed.var = 'median')

reg_response_curves <- reg_response_curves$plot$data
reg_response_curves <- reg_response_curves[reg_response_curves$pred.name != "R.areolata_EMcvByROC_mergedData_mergedRun_mergedAlgo", ]
reg_response_curves <- reg_response_curves[, !(names(reg_response_curves) %in% c("pred.name", "id"))]
reg_response_curves$model <- "Regional"
setwd(find_rstudio_root_file())


setwd("Results/Global/Models/")


glob_response_curves <- biomod2::bm_PlotResponseCurves(
  bm.out = glob_ensemble_BIOMOD_output
  , models.chosen = biomod2::get_built_models(glob_ensemble_BIOMOD_output)
  , fixed.var = 'median')

glob_response_curves <- glob_response_curves$plot$data
glob_response_curves <- glob_response_curves[glob_response_curves$pred.name != "R.areolata_EMcvByROC_mergedData_mergedRun_mergedAlgo", ]
glob_response_curves <- glob_response_curves[, !(names(glob_response_curves) %in% c("pred.name", "id"))]
glob_response_curves$model <- "Global"

#reset working directory back to project root
setwd(find_rstudio_root_file())

response_curves <- rbind(glob_response_curves, reg_response_curves, covar_response_curves)


#May have to adjust these
training_ranges <- data.frame(
  expl.name = c("bio_12", "bio_10", "bio_8", "bio_2", "bio_9"),  # Replace with actual names of expl.name values
  training_min = c(753,24.338,14.579, 12.193, 2.209),         # Replace with actual minimums for each expl.name
  training_max = c(1378,27.876,24.408, 13.840, 25.821)             # Replace with actual maximums for each expl.name
)



custom_labels <- c(
  "bio_12" = "Annual rainfall (mm)",
  "bio_10" = "Mean Temp of Warmest Quarter (°C)",
  "bio_9" = "Mean Temp of Driest Quarter (°C)",
  "bio_8" = "Mean Temp of Wettest Quarter (°C)",
  "bio_2" = "Mean Diurnal Range (°C)",
  "percent_prairie" = "Percent Prairie",
  "percent_clay" = "Percent Clay",
  "SDM.global" = "Global SDM"
)

response_curves <- response_curves %>%
  left_join(training_ranges, by = "expl.name") %>%
  mutate(
    training_min = ifelse(is.na(training_min), -Inf, training_min),  # Set to -Inf if missing
    training_max = ifelse(is.na(training_max), Inf, training_max)    # Set to Inf if missing
  )

response_curves$expl.name <- factor(
  response_curves$expl.name, 
  levels = c("bio_12", "bio_10", "bio_9", "bio_8", "bio_2", "percent_prairie", "percent_clay", "SDM.global")  # Define the order you want
)



install.packages("extrafont")
library(extrafont)
font_import(prompt = FALSE)  # May take a few minutes the first time
loadfonts(device = "win") 






ggplot(response_curves, aes(x = expl.val, y = pred.val, color = model)) +
  geom_line(size = 1.2) +
  geom_segment(
    data = subset(response_curves, training_min != -Inf & training_max != Inf),
    aes(x = training_min, xend = training_max, y = 0, yend = 0),
    color = "black", size = 1
  ) +
  facet_wrap(~ expl.name, scales = "free_x", labeller = labeller(expl.name = custom_labels)) +
  scale_x_continuous(breaks = scales::pretty_breaks(n = 7)) +
  labs(
    x = "",
    y = "Habitat Suitability",
    color = "Model"
  ) +
  theme_minimal(base_family = "Times New Roman") +  # Keep this once
  theme(
    axis.title.x = element_text(size = 16),
    axis.title.y = element_text(size = 16),
    axis.text.x = element_text(size = 15),
    axis.text.y = element_text(size = 15),
    legend.text = element_text(size = 17),
    legend.title = element_text(size = 0),
    strip.text = element_text(size = 18),
    legend.position = "top",
    panel.grid = element_blank(),
    axis.line = element_line(color = "black", linewidth = 0.5)
  )


ggsave(
  filename = "figures/figure_4.png",   # can also use .tiff, .pdf, .jpg, .svg, etc.
  plot = last_plot(),           # or a ggplot object, e.g. plot = my_plot
  dpi = 600,                    # resolution (high quality = 300–600)
  width = 12, height = 7,        # size in inches
  units = "in"
)



######Get Variable importance scores
#Global
glob_models_var_import <- read.csv("Results/Global/Values/R.areolata_indvar.csv")
glob_indiv_models <- read.csv("Results/Global/Values/R.areolata_replica.csv")
glob_indiv_models <- glob_indiv_models[glob_indiv_models$metric.eval == "ROC", ]
glob_indiv_models <- glob_indiv_models[glob_indiv_models$validation >= 0.85, ]
glob_models_var_import <- glob_models_var_import[
  glob_models_var_import$full.name %in% glob_indiv_models$full.name, 
]
glob_ensemble_var_import_mean <- aggregate(var.imp ~ expl.var, data = glob_models_var_import, FUN = mean, na.rm = TRUE)
glob_ensemble_var_import_sd <- aggregate(var.imp ~ expl.var, data = glob_models_var_import, FUN = sd, na.rm = TRUE)

glob_ensemble_var_import <- merge(glob_ensemble_var_import_mean, glob_ensemble_var_import_sd, by = "expl.var")
colnames(glob_ensemble_var_import) <- c("Variable", "MeanVarImp", "SDVarImp")

glob_ensemble_var_import

#regional 
reg_models_var_import <- read.csv("Results/Regional/Values/R.areolata_indvar.csv")
reg_indiv_models <- read.csv("Results/Regional/Values/R.areolata_replica.csv")
reg_indiv_models <- reg_indiv_models[reg_indiv_models$metric.eval == "ROC", ]
reg_indiv_models <- reg_indiv_models[reg_indiv_models$validation >= 0.80, ]
reg_models_var_import <- reg_models_var_import[
  reg_models_var_import$full.name %in% reg_indiv_models$full.name, 
]

reg_ensemble_var_import_mean <- aggregate(var.imp ~ expl.var, data = reg_models_var_import, FUN = mean, na.rm = TRUE)
reg_ensemble_var_import_sd <- aggregate(var.imp ~ expl.var, data = reg_models_var_import, FUN = sd, na.rm = TRUE)

reg_ensemble_var_import <- merge(reg_ensemble_var_import_mean, reg_ensemble_var_import_sd, by = "expl.var")
colnames(reg_ensemble_var_import) <- c("Variable", "MeanVarImp", "SDVarImp")

reg_ensemble_var_import


#covariate
covar_models_var_import <- read.csv("Results/Covariate/Values/R.areolata_indvar.csv")
covar_indiv_models <- read.csv("Results/Covariate/Values/R.areolata_replica.csv")
covar_indiv_models <- covar_indiv_models[covar_indiv_models$metric.eval == "ROC", ]
covar_indiv_models <- covar_indiv_models[covar_indiv_models$validation >= 0.80, ]
covar_models_var_import <- covar_models_var_import[
  covar_models_var_import$full.name %in% covar_indiv_models$full.name, 
]

covar_ensemble_var_import_mean <- aggregate(var.imp ~ expl.var, data = covar_models_var_import, FUN = mean, na.rm = TRUE)
covar_ensemble_var_import_sd <- aggregate(var.imp ~ expl.var, data = covar_models_var_import, FUN = sd, na.rm = TRUE)

covar_ensemble_var_import <- merge(covar_ensemble_var_import_mean, covar_ensemble_var_import_sd, by = "expl.var")
colnames(covar_ensemble_var_import) <- c("Variable", "MeanVarImp", "SDVarImp")

covar_ensemble_var_import







#######Figure 6

#plot to make bar graphs of habitat shifts
library(ggplot2)
library(dplyr)
library(tidyr)
library(readxl)

future_scenarios <- read_excel("outputs/future_scenarios.xlsx")
future_scenarios <- future_scenarios[-c(19:22), -c(6)]

df_long <- future_scenarios %>%
  pivot_longer(cols = c(habitat_gained, habitat_lost, habitat_retained),
               names_to = "habitat_change",
               values_to = "value")

df_long$Projection <- factor(df_long$Projection,
                             levels = unique(df_long$Projection[order(df_long$scenario)]))

df_long$habitat_change <- factor(
  df_long$habitat_change,
  levels = c("habitat_gained", "habitat_retained", "habitat_lost")
)

hline_data <- data.frame(
  y = c(2149, 2516, 2370),
  line_type = c("Regional-only","Multiply", "Covariate")  # Names for legend
)


ggplot(df_long, aes(x = Projection, y = value, fill = habitat_change)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(
    values = c(
      "habitat_gained" = rgb(46, 164, 0, maxColorValue = 255),
      "habitat_retained" = rgb(0, 77, 168, maxColorValue = 255),
      "habitat_lost" = rgb(237, 0, 0, maxColorValue = 255)
    ),
    labels = c(
      "habitat_gained" = "Habitat Gained",
      "habitat_retained" = "Habitat Retained",
      "habitat_lost" = "Habitat Lost"
    )
  ) +
  geom_hline(
    data = line_data,
    aes(yintercept = y, linetype = line_type, color = line_type),
    size = 1.5
  ) +
  scale_color_manual(
    name = "Current Total Habitat",  # Legend title for lines
    values = c("Regional-only" = "antiquewhite4",
               "Multiply" = "black",
               "Covariate" = "azure3")
  ) +
  scale_linetype_manual(
    name = "Current Total Habitat",
    values = c("Regional-only" = "dashed",
               "Multiply" = "dashed",
               "Covariate" = "dashed")
  ) +
  theme_minimal(base_family = "Times New Roman") +
  labs(x = "", y = "", fill = "") +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 20, color = "black"),
    axis.text.y = element_text(size = 20, color = "black"),
    axis.title.x = element_text(size = 12, color = "black"),
    axis.title.y = element_text(size = 12, color = "black"),
    legend.text = element_text(size = 17, color = "black"),
    legend.title = element_text(size = 15, color = "black"),
    panel.grid = element_blank(),
    axis.line = element_line(color = "black", linewidth = 0.5)
  ) +
  scale_y_continuous(
    breaks = c(-1000, -500, 0, 500, 1000, 1500, 2000, 2500, 3000),
    labels = c("-1000", "-500", "0", "500", "1000", "1500", "2000", "2500", "3000")
  )

ggsave(
  filename = "figures/figure_6.png",   # can also use .tiff, .pdf, .jpg, .svg, etc.
  plot = last_plot(),           # or a ggplot object, e.g. plot = my_plot
  dpi = 600,                    # resolution (high quality = 300–600)
  width = 12, height = 7,        # size in inches
  units = "in"
)


##############Global model projection
load("Results/Global/Models/R.areolata/R.areolata.AllModels.ensemble.models.out")
glob_ensemble_BIOMOD_output <- R.areolata.AllModels.ensemble.models.out

global_ensemble_BIOMOD_output <- R.areolata.AllModels.ensemble.models.out

BIOMOD_Projection(
  global_ensemble_BIOMOD_output,
  proj.name,
  new.env.xy = expl.var.global,
  models.chosen = "all",
  metric.binary = NULL,
  metric.filter = NULL,
  compress = TRUE,
  build.clamping.mask = TRUE,
  nb.cpu = 1,
  seed.val = NULL,
)

range_wide <- BIOMOD_EnsembleForecasting(
  global_ensemble_BIOMOD_output,
  proj.name = 'CurrentEM',
  new.env = expl.var.global,
  new.env.xy = NULL,
  models.chosen = "all",
  metric.binary = NULL,
  metric.filter = NULL,
  compress = TRUE,
  nb.cpu = 1,
  na.rm = TRUE,
)

biomod2::plot(range_wide,
              main="Crawfish Frog Species Distribution Model Map")

r_data <- range_wide@proj.out@val

r_layer <- rast(r_data)

writeRaster(r_layer, filename = "range_wide_sdm.tif")






