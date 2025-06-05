
# Načítání vektorových geodat ze souboru a internetových služeb 01---------

# nejprve opět balíčky, o kterých tušíme, že je budeme potřebovat
xfun::pkg_attach2("tidyverse",
                  "sf")

# předpokládáme, že jsme si v našem R projektu vytvořili složku geodata a že jsme do ní uložili ZIP soubor s nádržemi
# zdroj souboru s nádržemi: http://www.dibavod.cz/index.php?id=27
# shapefile jsme rozbalili do složky pojmenované jako ZIP soubor - někdy vhodnější, protože ve skutečnosti jde o více souborů najednou
# následně se odkážeme na shp soubor (funkce read_sf() si vezme všechny další potřebné údaje ze souborů dbf apod.)
nadrze <- read_sf("geodata/dib_a05_vodni_nadrze/a05_vodni_nadrze.shp")

# ale ještě se k tomu budeme muset vrátit z důvodu kódování textu v atributech
nadrze


# Odbočka k vysvětlení sloupců se seznamy ---------------------------------

data(mtcars)

# funkce nest() tvoří tzv. list-column, tedy podobný efekt, který je využíván ve sloupcích s geometrií
mtcars <- mtcars |> 
  group_by(cyl) |> 
  nest(zbytek = -cyl) # znaménkem minus vybíráme proměnnou, kterou nechceme zahnízdit

mtcars


# Načítání vektorových geodat ze souboru a internetových služeb 02 --------

# načteme poměrně nový R balíček pro tyto účely
# nejprve samozřejmě musí být nainstalován (alterenativně lze využít xfun::pkg_attach2())
library(arcgislayers)

# využíváme otevřených geodat ČHMÚ
# a v detailech vrstvy rozvodnic 1. řádu najdeme odkaz na GeoService (sekce View API Resources)
# z odkazu umažeme vše, co je za číslem vrstvy
povodi <- arc_read("https://services1.arcgis.com/ZszVN9lBVA5x4VmX/arcgis/rest/services/rozvodnice5G_1_radu/FeatureServer/2/")

# tohle je jen pro změnu tabulky s atributy na třídu tibble
povodi <- povodi |> 
  as_tibble() |> 
  st_sf()

# prohlédneme a už můžeme tušit, že je zde něco v nepořádku
povodi

# je skutečně geometrie validní?
povodi |> 
  st_is_valid()

# jak je možné, že některé multipolygony byly reprezentovány jako polygony?
# tak tedy napravíme funkcí st_make_valid()
povodi <- povodi |> 
  st_make_valid()

# teď už by mělo být vše v pořádku
povodi |> 
  st_is_valid()

# zaměřme se jen na povodí Dunaje
# při výběru patřičného řádku nám pomůže funkce filter(), která očekává logickou odpověď - proto ==
dunaj <- povodi |> 
  filter(naz_pov == "povodí Dunaje")

# funkce st_cast() konvertuje na jiný typ geometrie - zde MULTIPOLYGON na POLYGON
dunaj <- dunaj |> 
  st_cast("POLYGON") # zde musíme doržet psaní velkých písmen

# zjistíme, co se stalo
# počet řádků se zvětšil podle počtu jednoduchých polygonů v původním multipolygonu
# varování nás tedy upozornilo na násobení atributů
dunaj


# Odbočka - interaktivní editace vektorových geodat -----------------------

# potřebujeme balíček mapedit (od stejného autora jako u balíčku mapview)
library(mapedit)

# po spuštění funkce editFetaures() se otevře okno Viewer, kde můžeme např. některé polygony mazat tak, aby zůstal jen ten největší
# skončíme tak, že u koše stiskneme Save a pak dole vpravo Done
# tím se do nového objektu morava uloží zbylý polygon
morava <- dunaj |> 
  editFeatures()


# Načítání vektorových geodat ze souboru a internetových služeb 03 --------

# následuje uložení do souboru typu geopackage
morava |> 
  write_sf("geodata/morava.gpkg") # podle přípony funkce pozná, jaký GDAL driver mám využít

# pro kontrolu ze souboru opět načteme
morava_znovu <- read_sf("geodata/morava.gpkg")

# skutečně jsme byli úspěšní
morava_znovu

# lze ukládat i do jiných moderních typů souborů, jako je geojson
morava |> 
  write_sf("geodata/morava.geojson")

# u shapefilu si musíme dát pozor na kódování znaků v atributech
morava |> 
  write_sf("geodata/morava.shp",
           layer_options = "ENCODING=UTF-8")

# návrat k načtání shapefilu nahoře: i zde je doporučováno dávat si pozor na kódování znaků
nadrze <- read_sf("geodata/dib_a05_vodni_nadrze/a05_vodni_nadrze.shp",
                  options = "ENCODING=WINDOWS-1250")

# nyní by mělo být vše v pořádku
nadrze

# uložíme ještě nádrže
# hláška se týká zkracování názvů sloupců - jedna z nevýhod ukládání do shapefilu
nadrze |> 
  write_sf("geodata/nadrze_utf8/nadrze_utf8.shp",
           layer_options = "ENCODING=UTF-8")

# vektorové vrstvy lze ukládat i do RDS souborů - můžeme volit příponu RDS i rds
nadrze |> 
  write_rds("geodata/nadrze_utf8.rds") # funkce write_rds() pochází z balíčku readr (součást tidyverse) a defaultně nepoužívá kompresi

# toto je base-R funkce pro ukládání objektů z Globálního prostředí do RDS souboru
?saveRDS

# pro jistotu zkusíme nádrže opět načíst - base-R funkce je readRDS()
nadrze_znovu <- read_rds("geodata/nadrze_utf8.rds")

# prohlížíme v konzoli
nadrze_znovu

# vektorové vrstvy v ZIP souboru není ani třeba rozbalovat, lze se podívat rovnou na vrstvy schované v ZIP souboru
# a za určitých podmínek i do souborů na internetu, bez předhozího stažení - viz popis řetězení na: https://gdal.org/en/stable/user/virtual_file_systems.html
nadrze2 <- read_sf("/vsizip/geodata/dib_a05_vodni_nadrze.zip",
                   options = "ENCODING=WINDOWS-1250")

# funkcí st_layers() lze prohlížet vrstvy uvnitř souboru
st_layers("/vsizip/geodata/dib_a05_vodni_nadrze.zip")

# a díky tomu i konkrétní vrstvu specifikovat
nadrze2 <- read_sf("/vsizip/geodata/dib_a05_vodni_nadrze.zip",
                   options = "ENCODING=WINDOWS-1250",
                   layer = "A05_Vodni_nadrze") # můžeme vybrat i "druhou" vrstvu - díky tomu lze takto načítat i samostatnou dbf tabulku se správným kódováním (jako data frame)

# mnohem lépe lze s více vrstvami zacházet za využítí geopackage
st_layers("geodata/morava.gpkg")

# zapíšeme první vrstvu
write_sf(morava,
         "geodata/morava.gpkg")

# můžeme uložit druhou vrstvu, ale je potřeba specifikovat nový název argumentem layer
write_sf(nadrze,
         "geodata/morava.gpkg",
         layer = "nadrze")

# zde je důkaz o dvou vrstvách geopackage, dokonce s různým crs
st_layers("geodata/morava.gpkg")


# Odpověď na dotaz s kreslením dvou vrstev s různým crs -------------------

# z otevřených geodat ČHMÚ si vezmeme vrstvu s vodoměrnými stanicemi
stanice <- arc_read("https://services1.arcgis.com/ZszVN9lBVA5x4VmX/arcgis/rest/services/vodomerne_stanice/FeatureServer/0/")

# atributy převedeme na tibble
stanice <- stanice |> 
  as_tibble() |> 
  st_sf()

# prohlížíme - crs je s EPSG:32633
stanice

# omezíme se u nádrží na řádky obsahující slovo Lipno ve sloupci s názvem nádrže
lipno <- nadrze |> 
  filter(str_detect(NAZ_NA, "Lipno")) # funkce str_detect() je tzv. helper, který se často vkládá do funkce filter(), když chceme hledat přibližně (i za pomoci regulárních výrazů)

# demonstrujme, jaký má vliv pořadí vrstev při kreslení s různými crs
ggplot() + 
  geom_sf(data = lipno,
          fill = "blue",
          col = "blue") + 
  geom_sf(data = stanice)

ggplot() + 
  geom_sf(data = stanice) +
  geom_sf(data = lipno,
          fill = "blue",
          col = "blue")

# je vidět, že je děděn crs první vrstvy
