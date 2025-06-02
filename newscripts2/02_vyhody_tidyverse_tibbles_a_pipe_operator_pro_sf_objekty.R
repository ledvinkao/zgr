
# Nejprve tabulky bez geometrického sloupce -------------------------------

# načtení balíčků najenou
xfun::pkg_attach2("tidyverse",
                  "sf")

# demonstrujme některé funkce tidyverse na tabulce s vlastnostmi aut
# tabulka je součástí balíčku datasets
data(mtcars)

# původní třída tabulky je data.frame, což zjistíme aplikací class()
class(mtcars)

# takto se můžeme podívat na detaily
str(mtcars)

# z tidyverse pochází i funkce glimpse() na prohlížení detailů o tabulkách
glimpse(mtcars)

# funkce summary() není totéž, vrací základní statistiky v závislosti na typu objektu 
summary(mtcars)


# Začínáme s pipe operátorem ----------------------------------------------

# vložení nativního pipe operátoru stisknutím kláves CTRL + SHIFT + M nastavíme v Tools/Global Options/Code zaškrtnutím patřičné volby
mtcars |> 
  str() # nativní pipe vyžaduje za funkcemi vždy oblé závorky (i kdybychom nenastavovali žádný další argument, musí být závorky prázdné)

# pomocí pipe operátoru a řetězením ve stylu objekt |> funkce s výsledkem |> další funkce s výsledkem, apod. kód zpřehledníme
# výhodou je i psaní na nové řádky a zarovnávání (když se náhodou kód rozhází, lze využít zkratku CTRL + I na zarovnání)
mtcars |> 
  as_tibble() |> # převádí data frame na tibble (vylepšené tabulky - kvůli tisku do konzole a mnohým dalším vlastnostem)
  pull(mpg) # vytáhne sloupec tabulky jako vektor (podobně jako operátor $)

# sledujme bedlivě argumenty funkce a hlavně jejich produkty (sekce Value v nápovědách)
# závisí na tom aplikovatelnost dalších funkcí
?pull


# Malá odbočka - rozdíl mezi maticí a data frame --------------------------

# u matic se očekává stejný typ sloupců
# zde tvoříme numerickou matici o dvou sloupcích
matice <- matrix(c(1, 2, 3, 4), 
                 ncol = 2)

# prohlédneme
matice

matice |> 
  str()

# když budeme chtít přidat nový sloupec jiného typu, budeme varováni o řešení převodem na seznam (list)
matice$zvire <- c("cat", "dog")

# zde se tvoří seznam o pěti prvcích - první čtyři nepojmenovány, poslední pojmenován (ten je sám o sobě vektor o dvou elementech)
matice

# je rozdíl mezi numerickými (numeric / double) a celočíselnými hodnotami
matice <- matrix(c(1L, 2L, # písmenem L za číslem určujeme, že chceme celá čísla
                   3L, 4L),
                 ncol = 2,
                 byrow = T) # parametr byrow mění defaultní tvorbu matice po sloupcích

matice |> 
  str()


# Základy práce s balíčkem sf pro vektorová geodata -----------------------

# vytvoříme bod, který bude reprezentovat astronomický střed Evropy
bod <- st_point(c(15, 50)) # předpokládáme nejprve zeměpisnou délku a pak šířku

# výsledkem je jen geometrie (třída sfg - simple feature geometry)
bod

# zatím bez souřadnicového systému
bod |> 
  class()

# sfg převádíme na sfc (simple feature column)
# a následně přidáváme info o souřadnicovém systému (pomocí řetězce AUTORITA:KÓD nebo WKT řetězce)
bod <- bod |> 
  st_sfc() |> 
  st_set_crs("epsg:4326") |> # autoritu můžeme psát i velkými písmeny (existují i jiné autority, třeba ESRI)
  st_transform(5514) # pokud se pohybujeme jen v EPSG kódech, je zde mozné psát jen kód; zde transformujeme na Křováka

# teď už máme třídu sfc a i info o souřadnicovém systému
bod |> 
  class()

# opakujeme jen s EPSG kódy (opravdu to funguje)
# pro EPSG kódy využívané Českým úřadem zeměměřickým a katastrálním na jeho geomortálu viz https://geoportal.cuzk.cz/(S(m1y0gad3uudcqoojvrommp1x))/Default.aspx?lng=CZ&mode=TextMeta&side=sit.trans&text=souradsystemy
bod <- st_point(c(15, 50)) |> 
  st_sfc() |> 
  st_set_crs(4326) |> 
  st_transform(5514)

bod |> 
  class()

# můžeme pokračovat konverzí na simple feature (collection)
# od toho je funkce st_sf() - ta musí vidět geometrii
bod <- bod |> 
  st_sf() |> 
  mutate(nazev = "Kouřim") # následně lze přidávat atributy např. funkcí mutate()

# opakujme vše ještě jednou, tentokrát s více řetězenými funkcemi
bod <- st_point(c(15, 50)) |> 
  st_sfc() |> 
  st_set_crs(4326) |> 
  st_transform(5514) |> 
  st_sf() |> 
  mutate(nazev = "Kouřim") |> 
  as_tibble() |> # pokud chceme měnit na tibble (ztratí se sf hlavička, ale zůstává sloupec s geometrií)
  st_sf() |> # opět převádíme na sf
  st_set_geometry("geometry") # pokud se porouhá název geometrického sloupce, lze to takto napravit (viz nápovědu funkce st_geometry() nebo st_set_geometry())

# co je výsledkem?
bod |> 
  class()

# funkcí st_crs() se lze dotazovat na souřadnicový systém (crs)
bod |> 
  st_crs()

# takto si lze info o crs klidně i uložit do nového objektu
system <- bod |> 
  st_crs()

# výsledkem je seznam s důležitým WKT řetězcem
# ten lze pak používat dále - pro definici, transformaci crs apod.
system

# existuje speciální konstanta pro chybějící crs
?NA_crs_

# podobně jako v base R existují další specifické missing-values konstanty
?NA_real_

?NA_integer_

# využijme toho a schválně si odstraňme crs z objektu s bodem
st_crs(bod) <- NA_crs_

# takto crs opět vrátíme
st_crs(bod) <- system


# Interaktivní kreslení geodat v R ----------------------------------------

# zásadní asi balíček mapview
library(mapview)

# stejnojmenná funkce otevře okno Viewer
# můžeme měnit podkladovou mapu (a možná si definovat i své za využití WMS služeb)
mapview(bod)


# Varianty funkcí vhodné pro pipe operátory -------------------------------

# odstraňme schválně opět crs z našeho bodu
st_crs(bod) <- NA_crs_

# k funkci st_crs() existuje varianta st_set_crs()
bod <- bod |> 
  st_set_crs(system)

# máme nastaveno
bod

# podobně je to s funkcemi st_geometry() a st_set_geometry()
# tyto funkce se navíc přepínají podle toho, co dostávají jako argument - text přejmenovává geometrický sloupec, sfg přidává geometrii jako takovou
?st_set_geometry

# funkce st_drop_geometry() slouží k zahození geometrie
# to se někdy hodí, pokud geometrii k výpočtům nepotřebujeme a máme za to, že nás geometrie bude zbytečně zdržovat
?st_drop_geometry

bod |> 
  st_drop_geometry()

# geometrii si můžeme také ukládat zvlášť
geometrie <- bod |> 
  st_geometry()

# jde o geometrický sloupec (tedy třídu sfc)
geometrie |> 
  class()

# zkusíme zahodit geometrii
bod2 <- bod |> 
  st_drop_geometry()

bod2

# a opět ji nastavit
bod2 <- bod2 |> 
  st_set_geometry(geometrie)

bod2


# Autor balíčku sf si potrpí na jednotky ----------------------------------

# nastavme vektor bez jednotek např. následovně
plochy <- seq(1,
              100, 
              by = 20)

# pro nastavování a konverzi jednotek je využíván balíček units
# nejprve nastavíme třeba m^2 - znak ^ pro umocňování lze vynechat (dokonce nemusíme psát jako text - stačí bez uvozovek)
plochy <- plochy |> 
  units::set_units("m2")

# a pak převedeme např. na čtvereční stopy (ft^2)
plochy |> 
  units::set_units("ft2") |> 
  units::drop_units() # tato funkce zahazuje jednotky (někdy potřebné, protože některé funkce vektory s jednotkami neakceptují)

# ukazovali jsme si také příklad s tvorbou našeho vlastního zájmového obdélníku prostřednictvím funkce sfheaders::sfc_polygon() - viz bonusový skript 07/40
# a byli jsme odkázáni na kap. 3 knihy Spatial Data Science, kde jsou popsány konvence pro směr vnější a vnitří hrany polygonu - viz https://r-spatial.org/book/03-Geometries.html
