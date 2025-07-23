
# Spojení rastrových geodat -----------------------------------------------

# někdy se hodí přidání výsledné vrstvy k datům, ze kterých byla tato vrstva počítána
# pro tento účel lze využít jednoduše funkci c(), jako bychom skládali vektory či seznamy

# načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "terra",
                  "tidyterra")

# postupujme podobně jako ve skriptu 27
landsat <- rast(system.file("tif/L7_ETMs.tif",
                            package = "stars"))

ndvi <- (landsat[[4]] - landsat[[3]]) / (landsat[[4]] + landsat[[3]])

names(ndvi) <- "ndvi"

# přidáme vrstvu ndvi do objektu landsat a přesvědčíme se, zda jsme postupovali správně
landsat <- landsat |> 
  c(ndvi)

names(landsat)

# můžeme opět kreslit
ggplot() + 
  geom_spatraster(data = landsat$ndvi) +
  scale_fill_distiller(palette = "RdYlBu",
                       direction = -1) +
  labs(fill = "ndvi")

# podmínkou pro spojení je samozřejmě stejná geometrie (crs, horizontální rozlišení, rozsah apod.)
