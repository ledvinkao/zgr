
# Matematické operace s geometrií vektorových geodat ----------------------

# geometrický sloupec vektorových geodat je ve své podstatě třídy seznam
# lze s ním tedy provádět i matematické operace, jako je přičítání nebo násobení
# tato vlastnost se může hodit např. při systematickém posouvání bodů o několik metrů/kilometrů jakýmkoliv směrem

# demonstrujme s využitím metadat Úseku kvality ovzduší ČHMÚ
# (lze získat z https://opendata.chmi.cz/air_quality/historical/)

# načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "arrow",
                  "RCzechia", # balíček sf je načítán automaticky
                  "tmap")

# abychom se nezdržovali, metadata máme již připravená v Apache Parquet souboru airquality_metadata_pq
# s Apache Parquet soubory lze zacházet podobně jako s databázemi
# zavedeme pointer k souboru
aqmeta <- open_dataset("metadata/airquality_metadata_pq")

# řekněme, že se budeme chtít omezit jen na veličinu O3
o3 <- aqmeta |> 
  filter(VELICINA_ZKRATKA == "O3") |> 
  collect() # tímto dostaneme omezenou tabulku do RAM

# převedeme na sf collection
# a transformujeme na rovinný crs, kde lze hovořit o metrech
o3 <- o3 |> 
  st_as_sf(coords = c("ZEMEPISNA_DELKA",
                      "ZEMEPISNA_SIRKA"),
           crs = 4326) |> 
  st_transform(32633)

# zkusme vykreslit
tm_shape(republika() |> 
           st_transform(32633)) + # aby byly crs stejné
  tm_borders(lwd = 3,
             col = "purple") +
  tm_shape(o3) +
  tm_dots(col = "grey20",
          size = 0.2)

# zkusme posunout body o 10 km na západ a o 10 km na jih
o3_posun <- o3 |> 
  mutate(geometry = geometry + c(-10000, -10000)) |> 
  st_set_crs(32633) # zdá se, že díky přičítání se ztrácí údaj o crs, tak jej opět definujeme

# vykreslíme
tm_shape(republika() |> 
           st_transform(32633)) + 
  tm_borders(lwd = 3,
             col = "purple") +
  tm_shape(o3_posun) +
  tm_dots(col = "grey20",
          size = 0.2)
