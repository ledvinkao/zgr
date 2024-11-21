
# Funkce extract() pro body -----------------------------------------------

# jak již bylo naznačeno, funkci extract lze využívat i pro jiné typy vektorových dat, než jsou polygony
# ukažme význam této funkce pro body (např. lokality vodoměrných stanic v Česku)

# načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "sf",
                  "terra",
                  "geodata")

# načteme soubor s metadaty vodoměrných stanic
qdmeta <- read_rds("metadata/qdmeta2023.rds")

# převedeme na simple feature collection
qdmeta <- st_as_sf(qdmeta,
                   coords = c("UTM_X",
                              "UTM_Y"),
                   crs = 32633)

# u bodů nemá argument fun opodstatnění, jako spíše argument method
# my ale ponecháme jednoduché extrahování
# raději pamatujeme i na rozdílné crs (i když dnešní verze balíčku terra různé crs povolují)
dem <- elevation_30s(country = "CZE",
                     path = "geodata",
                     mask = F)

qdmeta <- extract(dem,
                  qdmeta |> 
                    st_transform(crs(dem)), # dědíme crs rastru
                  bind = T) |> 
  st_as_sf()
