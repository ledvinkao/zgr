
# Výpočet indexu NDVI -----------------------------------------------------

# asi nečastější se satelitními snímky jsou výpočty spektrálích indexů
# jedním z nejužívanějších (a snad i nadužívaných) indexů je normalizovaný diferencovaný vegetační index (NDVI)
# ten vychází ze dvou pásem - blízkého infračerveného (u Landsatu 7 pásmo 4) a červeného (u Landsatu 7 pásmo 3)

# načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "terra",
                  "tidyterra")

# načteme Landsat data
landsat <- rast(system.file("tif/L7_ETMs.tif",
                            package = "stars"))

# za využití jednoduchého výrazu pro NDVI (viz https://en.wikipedia.org/wiki/Normalized_difference_vegetation_index), lze pokračovat následovně
ndvi <- (landsat[[4]] - landsat[[3]]) / (landsat[[4]] + landsat[[3]])

# výslednou vrstvu si ještě můžeme přejmenovat
names(ndvi) <- "ndvi"

# vrstvu si můžeme vykreslit funkcemi podporovanými v pojetí ggplot
ggplot() + 
  geom_spatraster(data = ndvi) +
  scale_fill_distiller(palette = "RdYlBu",
                       direction = -1) +
  labs(fill = "ndvi")
