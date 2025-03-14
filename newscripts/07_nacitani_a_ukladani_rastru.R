
# Načítání a ukládání rastrů do souborů -----------------------------------

# ukázali jsme si, že některé balíčky přicházejí s vlastními příkladovými daty
# ukázali jsme si hledání systémových souborů z bonusového skriptu 24
# abychom mohli aplikovat funkci system.file(), je nutné mít balíčky stars a terra nainstalované

# načteme balíčky
xfun::pkg_attach2("tidyverse",
                  "terra",
                  "sf",
                  "spgwr") # pro geograficky váženou regresi (kdybychom ji chtěli zprovoznit)

# je potřeba si uvědomit, že načítací funkce rast() se přepíná podle toho, co jí naservírujeme
# dokáže třeba i odstraňovat hodnoty z rastru a ponechat jen jeho konstrukci
?rast

# tato vlastnost je zmíněna např. v nápovědě k funkci terra::interlpolate()
# ta využívá integruje hlavně funkce z balíčků gstat a fields
?interpolate

# v příkladu s geograficky váženou regresí na https://rspatial.org/analysis/6-local_regression.html, je zmíněno využití balíčku spgwr
# tento balíček je poněkud staršího data
# někdy se tedy potřebujeme vrátit ke starším třídám prostorových dat, jako je SpatialPointsDataFrame
# a to lze dělat pomocí funkce sf::as_Spatial()
?as_Spatial

# autor balíčku terra volí záměrně zkracování názvů funkcí
?rast

# časové agregace rastrových vrstev
?tapp

# obecná funkce pro aplikování (třeba i anonymních funkcí); něco jako base::apply()
?app

# funkce pro zjištění rozsahu rastru; něco jako bounding boxu
?ext

# načteme pro ukázku vícevrstvý rastr
landsat <- rast(system.file("tif/L7_ETMs.tif",
                            package = "stars"))

ext(landsat)

# potřebujeme-li získat polygon z rozsahu rastru, lze aplikovat následující
polygon <- ext(landsat) |> 
  vect() |> # rozsah převádíme na nativní vektorový formát balíčku terra, který se nazývá SpatVector
  st_as_sf()

# podobně by mělo být možné tvořit polygony ohraničení po aplikaci st_bbox() u vektorových geodat třídy sf


# Další atributy rastrových vrstev ----------------------------------------

# bližší info o crs lze získat funkcí crs()
crs(landsat) |> 
  cat() # kvůli nepřehlednému textu ještě aplikujeme funkci cat()

crs(landsat) |> 
  str_view() # nebo lze aplikovat i toto (když máme načtený tidyverse)

names(landsat)

# SpatRaster se chová podobně jako seznam, takže můžeme extrahovat i vrstvy obdobně
landsat$L7_ETMs_4

landsat[["L7_ETMs_4"]]

# je tu i funkce pro práci s časem (dotaz, nastavení apod.)
?time

# teď nemáme nastavený žádný čas
time(landsat)

# tak ho nastavíme
time(landsat) <- seq(ymd("2025-03-13"), 
                     length.out = 6, 
                     by = "day")

landsat |> 
  time()

# snímky (vrstvy) lze vybírat i pomocí indexů
landsat_vyb <- landsat[[4]]

landsat_vyb

landsat_vyb |> 
  plot()

landsat_vyb |> 
  rast() |> # tady nám rast() odebere hodnoty a ponechá geometrickou konstrukci
  plot()

# můžeme se tím připravit na naplňování nových hodnot

# existují funkce values() a také as.data.frame(), která je prezentována později
values(landsat_vyb) # zde máme jednu vrstvu - proto matice s jedním sloupcem

values(landsat) # zde máme více vrstev - proto matice s více sloupci

# ukázali jsme si filtrování podle hodnot jednoho z pásem (viz bonusový skript 24)
# usnadňují funkce balíčku tidyterra
library(tidyterra)

# ale pozor na tidyterra::select() u velkých dat


# Ukládání ----------------------------------------------------------------

# pro ukládání klasických GeoTIFF (a vlastně toho, co zvládá GDAL, včetně komprese a signed, unsigned, INT a FLOAT)
?writeRaster

# pro ukládání do NetCDF souborů (.nc) je potřeba mít nainstalovaný balíček ncdf4
?writeCDF

# také balíček stars mé své funkce pro ukládání, ale je to poněkud složitější
# kromě stars::write_stars() také stars::write_mdim()
?stars::write_mdm

# pokud je žádoucí uložit každou vrstvu do individuálního GeoTIFF souboru, není vhodné paralelizovat
# místo toho si všimneme vlastnosti funkce writeRaster() při shodně nlyr s délkou vektu cest souborů
landsat |> 
  writeRaster(str_c("results/", names(landsat), ".tif"))


# Poznámka k časovým agregacím --------------------------------------------

# pokud např. chceme agregovat gridy průměrné denní teploty do měsíčních průměrů, lze použít funkci tapp()
# důležitým argumentem je pak index = "yearmonths"
# ve výsledku je však časový atribut uveden v desetinném vyjádření, takže je nutné najít způsob, jak se dostat ke klasickému vyjádření datumu
# samozřejmě může pomoci nastavení nové :-)
# jestli je časová řada neúplná, lze zjistit např. porovnáním našeho vektoru s datumy s nlyr()
