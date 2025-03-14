
# Kreslení rastrů ---------------------------------------------------------

# načteme základní balíčky pro práci s geodaty
# všimneme si speciálně balíčků obsahujících funkce pro zisk rastrových geodat
xfun::pkg_attach2("tidyverse",
                  "terra",
                  "geodata",
                  "RCzechia")

dem <- elevation_30s(country = "CZE", # bereme Česko
                     path = "geodata", # nastavujeme jen složku pro uložení (tj. ne s názvem souboru)
                     mask = F) # v hydrologii se to nedělá (nemáme povodí, která končí hranicemi)

# pokud chceme kreslit rastry ve smyslu ggplot, máme tady balíček tidyterra s funkcí geom_spatraster()
library(tidyterra)

# kreslíme digitální model reliéfu
ggplot() +
  geom_spatraster(data = dem) + 
  scale_fill_hypso_tint_c(palette = "wiki-schwarzwald-cont") + # takto nastavíme vhodnou paletu barev (pozor na nastavení extrémů!)
  geom_sf(data = republika(), # bereme pro orientaci
          col = "purple",
          lwd = 1,
          fill = NA) + # takto polygon zprůhledníme
  labs(fill = "elevation\n[m n. m.]") # v žádném případě ne slovo 'Legenda' :-)
  
# asi nepropracovanější pro kreslení map v R je dnes balíček tmap
library(tmap)

# vždy, když přidáváme novou vektorovou nebo rastrovou vrstvu, uvedeme přidání funkcí tm_shape()
# také vrstvíme operátorem +
?tm_shape

tm_shape(dem) + # vespod obvykle rastry
  tm_raster(col.scale = tm_scale_continuous(values = terrain.colors(9))) + # následně určujeme funkci, kterou vrstvu kreslíme (je vhodné nastavit nějakou paletu)
  tm_graticules() + # přidání souřadnicové sítě
  tm_shape(republika()) + # pro orientaci přidáme polygon
  tm_polygons(col = "red", # je rozdíl mezi tm_polygons() a tm_borders()
              fill = "grey20",
              fill_alpha = 0.3) # míra průhlednosti

# přidáme ještě body z metadat kvality ovzduší
meta <- arrow::open_dataset("metadata/airquality_metadata_pq") |> 
  collect() |> 
  st_as_sf(coords = c("ZEMEPISNA_DELKA",
                      "ZEMEPISNA_SIRKA"),
           crs = 4326)

tm_shape(dem) + 
  tm_raster(col.scale = tm_scale_continuous(values = terrain.colors(9))) + 
  tm_graticules() +
  tm_shape(republika()) + 
  tm_polygons(col = "red",
              fill = "grey20",
              fill_alpha = 0.3) + 
  tm_shape(meta) + # zde již přidáváme body
  tm_dots() + 
  tm_compass() + # přidáme směrovku
  tm_scalebar(position = c("bottom", "left")) # přidáme měřítko (u pozice rozlišujeme velká a malá písmena)

# pro neprobrané facety viz bonusový skript 36


# Funkce extract(), zonal() a as.data.frame() -----------------------------

# aplikujeme na rastr výšek a body
meta <- extract(dem, meta,
                bind = T) # takto přidáme nové sloupce k vektorové vrstvě

# SpatVector lze takto převést na sf
meta <- meta |> 
  st_as_sf() 

# ještě převedeme na sf s třídou tibble
meta <- meta |> 
  as_tibble() |> 
  st_sf()

# rastry lze převádět data frame
# od počtu vrstev závisí počet sloupců (dalších mimo x a y)
dem_df <- as.data.frame(dem,
                        xy = T) |> 
  as_tibble()

# teď jde o tibble
dem_df

# i z tibble lze konvertovat zpět do rastru
# musíme nastavit typ u funkce rast()
dem_xyz <- rast(dem_df,
                type = "xyz",
                crs = "epsg:4326") # je vhodné specifikovat i crs

# jde skutečně o rastr
dem_xyz |> 
  plot()

# pro demonstraci funkce extract() pro polygony si připravujeme polygony obcí
obce <- obce_polygony()

obce <- obce |> 
  as_tibble() |> 
  st_sf()

# vybereme jen jeden zájmový sloupec
obce <- obce |> 
  select(NAZ_OBEC)

# to abychom nakonec rovnou dostali sf s třídou tibble
obce <- extract(dem,
                obce,
                fun = mean,
                bind = T) |> 
  st_as_sf() |> 
  as_tibble() |> 
  st_sf()

# přejmenujeme a zaokrouhlíme
obce <- obce |> 
  rename(elv = CZE_elv) |> 
  mutate(elv = round(elv, 1))

# dodejme sloupce se souřadnicemi centroidů polygonů
obce <- obce |> 
  bind_cols(st_coordinates(st_centroid(obce)))

# jak vypadá linární model závislosti nadmořské výšky na souřadnicích?
model <- lm(elv ~ X + Y, data = obce)

summary(model)

# následovala ukázka zonálních statistik podle bonusového skriptu 32

# též proběhla ukázka práce s Google Earth Engine

# a na závěr dynamické zobrazování geodat
kraje <- kraje()

mapview::mapview(kraje)

# i tmap to umí
tmap_mode("view")

tm_shape(kraje) + 
  tm_borders()
