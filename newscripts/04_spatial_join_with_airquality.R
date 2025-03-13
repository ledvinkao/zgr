
# Napojení atributů z jiné tabulky na podkladě prostorového joinu ---------

# načteme balíčky
xfun::pkg_attach("tidyverse",
                 "RCzechia", # měl by automaticky načítat i sf
                 "arrow")

# příklad opět zakládáme na metadatech kvality ovzduší ČHMÚ
meta <- open_dataset("metadata/airquality_metadata_pq") |> 
  collect() |> 
  janitor::clean_names() |> # dovolíme si upravit názvy souborů
  st_as_sf(coords = c("zemepisna_delka",
                      "zemepisna_sirka"),
           crs = 4326)

# info o okresech v bodové vrstvě není, tak ji dodáme prostorovým joinem
okresy <- okresy()

# vhodnější je omezit se na podmnožinu sloupců (polí), které pak mohou identifikovat příslušnost k okresu
okresy <- okresy |> 
  select(okres = NAZ_LAU1)

# zůstalo jen jedno pole (s přilepenou geometrií)
okresy

# nastaven je left_join() a st_intersects(), ale lze měnit
meta <- meta |> 
  st_join(okresy)

# připojila se informace o okresech
# opět lze zkoumat četnosti
meta |> 
  st_drop_geometry() |> 
  count(okres) |> 
  print(n = 77)

# zvláštní je, že dvě lokality se nepřipojily ani k jednomu okresu
# pomohla by funkce st_make_valid(), nebo st_buffer?
