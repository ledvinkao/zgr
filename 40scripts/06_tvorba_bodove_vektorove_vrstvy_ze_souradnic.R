
# Tvorba (bodových) vektorových geodat z daných souřadnic -----------------

# někdy se stane, že nemáme k dispozici přímo vektorovou vrstvu
# můžeme ale využít znalosti souřadnic a souřadnicového referenčního systému (crs)
# mějme metadata vodoměrných stanic, které se dají získat z JSON souboru s adresou https://opendata.chmi.cz/hydrology/historical/metadata/meta1.json
# tato metadata obsahují dva sloupce se souřadnicemi a přitom víme, že crs je ten s EPSG kódem 4326

# načteme balíčky
# zde ještě navíc jsonlite pro jednodušší práci s JSON soubory
xfun::pkg_attach2("tidyverse",
                  "jsonlite",
                  "sf")

# soubor si upravíme do tabulky
# využijeme přitom znalost o struktuře (kde jsou data a kde jsou hlavičky)
url <- "https://opendata.chmi.cz/hydrology/historical/metadata/meta1.json"

meta <- jsonlite::fromJSON(url) # někdy je nutné nastavit v souboru .Renviron CURL_SSL_BACKEND=openssl

meta <- meta$data$data$values |> 
  as.data.frame() |> 
  as_tibble() |> 
  set_names(meta$data$data$header |> 
              str_split(",") |> 
              unlist()) |> 
  janitor::clean_names() # názvy sloupců upravíme na rozumnější (musí být nainstalován balíček janitor)

# vektorovou vrstvu (simple feature collection) získáme pomocí funkce st_as_sf()
# funkce st_as_sf() je rozdílná od funkce st_sf()
# funkce st_as_sf() tvoří geometrii nově, kdežto funkce st_sf() již nějakou geometrii v tabulce vyžaduje
meta <- meta |> 
  mutate(across(geogr1:plo_sta, # měníme typ některých sloupců (u kterých to má smysl, převedeme na numeric)
                as.numeric)) |> 
  st_as_sf(coords = c("geogr2", "geogr1"), # nejdřív délka a pak šířka
           crs = 4326) |> 
  st_transform(32633) # raději transformujeme, abychom předešli problémům se záměnou pořadí souřadnic, jak to dělají dnešní verze knihovny PROJ

# může se stát, že některé sloupce s textem budou mít nesprávně označené chybějící hodnoty
# to lze před ukládáním ošetřit následovně
meta <- meta |> 
  mutate(across(where(is.character),
                \(x) if_else(x == "", NA, x))
  )

# a uložíme pro další práci
meta |> 
  write_rds("metadata/wgmeta2024.rds",
            compress = "gz")
