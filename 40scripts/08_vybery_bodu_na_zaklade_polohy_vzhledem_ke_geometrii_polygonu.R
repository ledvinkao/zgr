
# Výběr bodů na základě polohy vhledem k polygonu -------------------------

# dejme tomu, že jsme se rozhodli vybrat vodoměrné stanice, které leží uvnitř daného obdélníku
# pak provedeme opačný výběr
# balíček sf nabízí zakládat takovéto výběry hned na několika funkcích
# ukážeme si to na funkcích st_intersects() a st_disjoint()
# pro výběry pomocí geometrie existuje zjednodušený postup s využitím hranatých závorek

# načteme balíčky
xfun::pkg_attach2("tidyverse",
                 "RCzechia", # sf je načten automaticky s tímto balíčkem
                 "sfheaders")

# nejprve práce s metadaty vodoměrných stanic
meta <- read_rds("metadata/qdmeta2023.rds") |> 
  st_as_sf(coords = c("UTM_X", "UTM_Y"),
           crs = 32633) |> 
  st_transform(4326) # potřebujeme mít stejný crs

# tvorba obdélníka
obdelnik <- sfc_polygon(matrix(c(16.35, 49.3,
                                18.85, 49.3,
                                18.85, 50.2,
                                16.35, 50.2,
                                16.35, 49.3),
                              ncol = 2,
                              byrow = T)) |> 
  st_sf() |> 
  st_set_crs(4326) |> 
  st_set_geometry("geom") |> 
  as_tibble() |> 
  st_sf()

# vybereme jen stanice, které jsou uvnitř obdélníka
# práce připomíná starý známý výběr řádků
stanice_v_obdelniku <- meta[obdelnik, ]

# standardně se vybírá to, co je uvnitř (tiše je aplikována funkce st_intersects())
# pro opačný výběr je nutné nastavit argument op
stanice_vne_obdelnika <- meta[obdelnik, op = st_disjoint]

# vykreslime prvni i druhou situaci
hranice <- republika()

ggplot() + 
  geom_sf(data = hranice,
          col = "purple",
          fill = NA,
          linewidth = 1.5) +
  geom_sf(data = obdelnik,
          col = "black",
          fill = "grey30",
          alpha = 0.6,
          linewidth = 1.5) +
  geom_sf(data = stanice_v_obdelniku,
          col = "red",
          size = 1)

ggplot() + 
  geom_sf(data = hranice,
          col = "purple",
          fill = NA,
          linewidth = 1.5) +
  geom_sf(data = obdelnik,
          col = "black",
          fill = "grey30",
          alpha = 0.6,
          linewidth = 1.5) +
  geom_sf(data = stanice_vne_obdelnika,
          col = "red",
          size = 1)
