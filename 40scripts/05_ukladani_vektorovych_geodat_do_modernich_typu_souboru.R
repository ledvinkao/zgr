
# Ukládání vektorových geodat do modernějších typů souborů ----------------

# ve světě GIS existují mnohem modernější a vhodnější typy souborů na ukládání geodat
# doporučovány jsou např. formáty geojson nebo geopackage (přípona .gpkg), v současnosti i geoparquet (přípona .parquet)

# nejprve načteme balíčky
xfun::pkg_attach2("tidyverse",
                  "sf")

# opět načteme správně polygony nádrží
nadrze <- read_sf("geodata/dib_a05_vodni_nadrze/a05_vodni_nadrze.shp",
                  options = "ENCODING=WINDOWS-1250")

# uložíme nejprve do souboru geojson
nadrze |> 
  st_transform(32633) |> 
  write_sf("geodata/vodni_nadrze_nove.geojson")

# poté uložíme ještě do souboru typu geopackage
nadrze |> 
  st_transform(32633) |> 
  write_sf("geodata/vodni_nadrze_nove.gpkg")

# vektorová geodata lze však uchovávat i v RDS souborech
# což je šikovné právě tehdy, chceme-li naplno využít potenciálu R (např. se hnízděním sloupců apod.)
nadrze |> 
  st_transform(32633) |> 
  write_rds("geodata/vodni_nadrze_nove.rds")
