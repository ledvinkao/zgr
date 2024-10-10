
# Uložení do SHP souboru se standardním kódováním a projekcí --------------

# v ČHMÚ je standardní projekcí crs s EPSG kódem 32633
# navíc je žádoucí, aby soubor měl jasně tuto projekci po uložení jasně definovanou v .prj souboru
# budeme se též snažit o uložení informace o kódování znaků v textových atributech (soubor .cpg)

# nejprve načtení balíčků
xfun::pkg_attach("tidyverse",
                 "sf",
                 install = T)

# znamým způsobem načteme např. vodní nádrže
nadrze <- read_sf("geodata/dib_a05_vodni_nadrze/a05_vodni_nadrze.shp",
                  options = "ENCODING=WINDOWS-1250")

# uložíme do nového shapefilu se standardním kódováním a definicí projekce
# příponou určujeme, jaký driver se má použít pro ukládání
nadrze |> 
  st_transform(32633) |> 
  write_sf("geodata/vodni_nadrze_nove.shp",
           layer_options = "ENCODING=UTF-8")

# defaultně je umožněno uložit jen určitý počet znaků pro různé typy polí (viz https://gdal.org/drivers/vector/shapefile.html)
# říkají nám to i varování
warnings()

# tento problém by asi bylo možné obejít nastavením jiných šířek polí
# my se ale tímto nebudeme zdržovat, jelikož je vhodné se naučit ukládát do jiných, modernějších souborů
