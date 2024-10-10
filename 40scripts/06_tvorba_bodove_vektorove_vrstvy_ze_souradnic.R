
# Tvorba (bodových) vektorových geodat z daných souřadnic -----------------

# někdy se stane, že nemáme k dispozici přímo vektorovou vrstvu
# můžeme ale využít znalosti souřadnic a souřadnicového referenčního systému (crs)
# mějme např. metadata vodoměrných stanic, které se dají získat z https://isvs.chmi.cz/
# tato metadata obsahují dva sloupce se souřadnicemi a přitom víme, že crs je ten s EPSG kódem 32633

# načteme balíčky
xfun::pkg_attach("tidyverse",
                 "sf",
                 install = T)

# načteme metadata z RDS souboru (ze složky R projektu s názvem metadata)
qdmeta <- read_rds("metadata/qdmeta2023.rds")

# vektorovou vrstvu (simple feature collection) získáme pomocí funkce st_as_sf()
# funkce st_as_sf() je rozdílná od funkce st_sf()
# funkce st_as_sf() tvoří geometrii nově, kdežto funkce st_sf() již nějakou geometrii v tabulce vyžaduje
qdmeta <- qdmeta |> 
  st_as_sf(coords = c("UTM_X", "UTM_Y"),
                      crs = 32633)
