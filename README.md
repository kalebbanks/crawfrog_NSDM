# Using spatially-nested hierarchical species distribution models to estimate current and future distributions of a cryptic species at a regional scale

\================================================================================

## Authors

* Kaleb M. Banks
* Owen M. Edwards
* Bo Zhang
* Michael S. Reichert

**Contact:** [kaleb.banks@okstate.edu](mailto:kaleb.banks@okstate.edu)\
**Date:** 4/7/2026

**Paper:** Banks, K. M., Edwards, O. M., Zhang, B., & Reichert, M. S. (2026). Using
spatially-nested hierarchical species distribution models to estimate current and future
distributions of a cryptic species at a regional scale. Journal of Animal Ecology, 00,
1–16. [https://doi.org/10.1111/1365-2656.70248](https://doi.org/10.1111/1365-2656.70248)

**Dataset:** [https://doi.org/10.5061/dryad.zw3r228nh](https://doi.org/10.5061/dryad.zw3r228nh)\
**License:** CC0 1.0 — [https://creativecommons.org/publicdomain/zero/1.0/](https://creativecommons.org/publicdomain/zero/1.0/)

\================================================================================

## Description

Species distribution models (SDMs) for *Rana areolata* under current and future climate
scenarios. Models were built in R using the sabinaNSDM package with three algorithms
(GBM, MARS, MAXNET) and 20 cross-validation replicates, applied across three modelling
approaches (Global, Regional, Covariate) plus a Multiply ensemble model which is the
average of the global and regional model. Full detailed methods are described in the
associated paper and its supplementary files.

All coordinates are in WGS84.

\================================================================================

## How To Use

1. Download data.zip and Place the unzipped `data/` folder in the root of an R project.
2. Download GBIF data from [https://doi.org/10.15468/dl.u77byy](https://doi.org/10.15468/dl.u77byy). Reformat so the data
   frame contains columns labeled `X` for longitude and `Y` for latitude values and name
   the file `rangewide_gbif_occ.csv`. Place in `data/occurrences_absences/occ_raw/`.
3. Download soil data from [https://www.arcgis.com/home/item.html?id=1bfc47d2a0d544bea70588f81aac8afb](https://www.arcgis.com/home/item.html?id=1bfc47d2a0d544bea70588f81aac8afb).
   Resample and mask to match the extent and resolution of the 2.5 arc-minute bioclim
   variables. Name the file `percent_clay` and place in
   `data/env_var/scenarios_raw/expl.var.regional/`.
4. All script file paths are relative to the project root — do not change the folder
   structure.
5. Download R scripts from GitHub: [https://github.com/kalebbanks/crawfrog_NSDM](https://github.com/kalebbanks/crawfrog_NSDM)
6. Run scripts in numbered order (01_, 02_, etc.) to recreate the model workflow.

**R version:** 4.5.1\
**Relevant R packages:**

* sabinaNSDM (1.1.0)
* terra (1.8)
* covsel (1.0)
* biomod2 (4.2)
* PresenceAbsence (1.1.11)

\================================================================================

## Environmental Variables

### Climatic Variables

We used the 19 bioclim variables from the WorldClim database (version 2.1; Fick &
Hijmans, 2017; [https://www.worldclim.org/data/bioclim.html](https://www.worldclim.org/data/bioclim.html)).

* **Global model:** 10 arc-minute resolution
* **Regional models:** 2.5 arc-minute resolution
* **Future scenarios:** 2070 (average of 2061–2080), 2.5 arc-minute resolution,
  downloaded from WorldClim

Future climate data used two socioeconomic pathways (SSP2-4.5 and SSP5-8.5) and is the average of three global climate models:

* MIROC6
* MPI-ESM1-2-HR
* CMCC-ESM2

### Percent Clay

We used the World Soils 250 m percent clay raster (Esri 2020;
[https://www.arcgis.com/home/item.html?id=1bfc47d2a0d544bea70588f81aac8afb](https://www.arcgis.com/home/item.html?id=1bfc47d2a0d544bea70588f81aac8afb)), which
quantifies the proportion of clay particles (< 0.002 mm) in the fine earth fraction in
g/100g (%) at −80 cm. This variable was used only at the regional extent and was
resampled to 2.5 arc-minute resolution. The same dataset was used for future scenarios.

### Percent Prairie

We used a high-resolution land cover raster from the Oklahoma Biological Survey (OBS)
that categorized 167 habitat types at 10-meter resolution for the year 2015 (Oklahoma
Biological Survey 2015; [https://www.wildlifedepartment.com/lands-and-minerals/oklahoma-ecological-system-mapping](https://www.wildlifedepartment.com/lands-and-minerals/oklahoma-ecological-system-mapping)).
We reclassified these categories to identify areas of undisturbed prairie, defined as
open canopy prairies or rangelands with limited soil horizon disturbance. Low-intensity
agriculture such as cattle ranching was assumed untilled and included as suitable habitat
for *R. areolata* (see Supplementary Table 2). After reclassification, we calculated the
percentage of undisturbed prairie within each 2.5 arc-minute cell and saved it as a
separate raster.

For future scenarios, we used the USGS land use projections for 2070 (Sohl et al., 2014)
as the OBS dataset is not available for future time periods. Two land use scenarios were
tested:

* **A1B:** Rapid economic and technological growth, moderate land use change, balanced
  energy mix and efficient resource management
* **A2:** High population growth, slower economic development, limited technological
  advancement, resulting in intensive land use change due to agricultural expansion and
  urban sprawl

The USGS land use datasets were reclassified to match the OBS classifications.

\================================================================================

## Occurrence Data

* **Global model:** Downloaded from GBIF (10/18/2024); 405 occurrences
* **Regional model:** Field surveys conducted by the authors in 2023 and 2024; 303
  occurrences

\================================================================================

## Future Scenario Key

| Scenario ID              | SSP      | Land Use                             | Year |
| ------------------------ | -------- | ------------------------------------ | ---- |
| future\_scenario\_1 (S1) | SSP2-4.5 | Current land use (OBS)               | 2070 |
| future\_scenario\_2 (S2) | SSP5-8.5 | Current land use (OBS)               | 2070 |
| future\_scenario\_3 (S3) | SSP2-4.5 | Projected land use change (USGS A1B) | 2070 |
| future\_scenario\_4 (S4) | SSP5-8.5 | Projected land use change (USGS A1B) | 2070 |
| future\_scenario\_5 (S5) | SSP2-4.5 | Severe land use change (USGS A2)     | 2070 |
| future\_scenario\_6 (S6) | SSP5-8.5 | Severe land use change (USGS A2)     | 2070 |

\================================================================================

## Folder Structure

* **data/extent_shapefiles/** — Shapefiles defining the global and regional model extents. The global extent covers the southern plains and southern USA. The regional extent covers central and eastern Oklahoma counties.
* **data/env_var/**
  * **correlation_test/** — Spearman correlation matrix CSV of the 19 bioclim variables and two landscape variables at the regional extent.
  * **scenarios_raw/** — Raw climate rasters used to create the scenarios.
  * **scenarios_spatraster/** — Processed SpatRaster stacks used as model inputs.
* **data/occurrences_absences/**
  * **occ_raw/** — Raw *Rana areolata* occurrence records (global and regional).
  * **occ_thinned/** — Spatially thinned occurrences used for modelling.
  * **abs_global/** — Randomly generated pseudoabsences for the global model.
  * **abs_reg/** — Randomly generated pseudoabsences for the regional model.

\================================================================================

## Citations

**Dataset:**\
Banks, K., Edwards, O., Zhang, B., & Reichert, M. (2026). Using spatially-nested
hierarchical species distribution models to estimate current and future distributions of
a cryptic species at a regional scale [Dataset]. Dryad.
[https://doi.org/10.5061/dryad.zw3r228nh](https://doi.org/10.5061/dryad.zw3r228nh)

**Paper:**\
Banks, K. M., Edwards, O. M., Zhang, B., & Reichert, M. S. (2026). Using
spatially-nested hierarchical species distribution models to estimate current and future
distributions of a cryptic species at a regional scale. Journal of Animal Ecology, 00,
1–16. [https://doi.org/10.1111/1365-2656.70248](https://doi.org/10.1111/1365-2656.70248)

**Environmental Variables:**\
Esri. (2020). World Soils 250m Percent Clay. Retrieved July 17, 2023, from
[https://www.arcgis.com/home/item.html?id=1bfc47d2a0d544bea70588f81aac8afb](https://www.arcgis.com/home/item.html?id=1bfc47d2a0d544bea70588f81aac8afb)

Fick, S. E., & Hijmans, R. J. (2017). WorldClim 2: New 1-km spatial resolution climate
surfaces for global land areas. International Journal of Climatology, 37(12), 4302–4315.
[https://doi.org/10.1002/joc.5086](https://doi.org/10.1002/joc.5086)

Oklahoma Biological Survey. (2015). Oklahoma Ecological System Mapping [Raster file].
Retrieved August 22, 2024, from [https://www.wildlifedepartment.com/lands-and-minerals/oklahoma-ecological-system-mapping](https://www.wildlifedepartment.com/lands-and-minerals/oklahoma-ecological-system-mapping)

Sohl, T. L., Sayler, K. L., Bouchard, M. A., Reker, R. R., Friesz, A. M., Bennett, S.
L., Sleeter, B. M., Sleeter, R. R., Wilson, T., Soulard, C., Knuppe, M., & Van Hofwegen,
T. (2014). Spatially explicit modeling of 1992–2100 land cover and forest stand age for
the conterminous United States. Ecological Applications, 24(5), 1015–1036.
[https://doi.org/10.1890/13-1245.1](https://doi.org/10.1890/13-1245.1)

**Occurrence Data:**\
GBIF.org (18 October 2024) GBIF Occurrence Download. [https://doi.org/10.15468/dl.u77byy](https://doi.org/10.15468/dl.u77byy)

**sabinaNSDM:**\
Mateo, R. G., Morales-Barbero, J., Zarzo-Arias, A., Lima, H., Gómez-Rubio, V., &
Goicolea, T. (2024). sabinaNSDM: An R package for spatially nested hierarchical species
distribution modelling. Methods in Ecology and Evolution, 15(10), 1796–1803.
[https://doi.org/10.1111/2041-210X.14417](https://doi.org/10.1111/2041-210X.14417)

\================================================================================
