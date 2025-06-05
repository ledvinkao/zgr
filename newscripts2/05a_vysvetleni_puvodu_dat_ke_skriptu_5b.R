
# Původ metadat vodoměrných stanic ----------------------------------------

# zdojem metadat k vodoměrným stanicím ze skriptu 05b jsou otevřená data (časové řady) ČHMÚ

# načtěme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "jsonlite", # právě tento balíček potřebujeme pro získání tabulek z hierarchických dat typu JSON, tedy formátu, který si ČHMÚ vybral pro prezentování otevřených dat
                  "sf",
                  "arcgislayers")

# základem je načtení JSON souboru funkcí fromJSON() z balíčku jsonlite
meta <- fromJSON("https://opendata.chmi.cz/hydrology/historical/metadata/meta1.json")

# výsledkem je seznam, který má několik prvků, které mají další prvky
meta |> 
  names()

# nejdůležitější je prvek nazvaný "data", ale můžeme získat i info o datumu a času vytvoření souboru
meta$datumVytvoreni |> 
  ymd_hms() |> # toto je funkce balíčku lubridate (součást tidyverse)
  class() # ale v tabulkách typu tibble se pak tyto třídy jeví jako dttm

# načtěme hlouběji schovanou tabulku z daty (resp. textovou matici)
tab <- meta$data$data$values

# dobré bude se postarat i o názvy sloupců
nms <- meta$data$data$header

# rozdělme jednoprvkový vektor na vektor, který bude obsahovat tolik prvků, kolik je sloupců tabulky
nms <- nms |> 
  str_split(",") |> # funkce pochází z balíčku stringr (součást tidyverse)
  unlist() # protože výsledkem funkce str_split() je seznam, zjednodušme jej na vektor funkcí unlist()

# prohlédněme výsledný vektor připravený pro názvy sloupců
nms

# převedeme matici na tibble a nastavíme názvy sloupcům
tab <- tab |> 
  as.data.frame() |> # protože převádění na tibble je velmi citlivé na názvy sloupců, doporučuji nejprve převádět na typ data.frame
  as_tibble() |> 
  set_names(nms) # toto je funkce vhodná pro nastavování názvů za využití pipu (podobně jako st_set_crs() nebo st_set_geometry())

# všechny sloupce jsou ale textové vektory, některé je vhodné převést na typ numeric, resp. double
tab <- tab |> 
  mutate(across(GEOGR1:PLO_STA, # funkce across() dopomáhá funkci mutate() pracovat s více sloupci najednou
                as.numeric)) # obvykle následuje anonymní funkce, ale pokud ta nemá žádné další argumenty, lze takto spát jen její název (bez proměnných, bez prázdných závorek)

# tabulka je nyní připravena pro konverzi na simple feature collection
# (někdy se i hodí vylepšit si názvy sloupců pomocí funkce janitor::clean_names())
tab <- tab |> 
  st_as_sf(coords = c("GEOGR2", "GEOGR1"), # pozor! pořadí souřadnic je v podkladové tabulce obrácené
           crs = 4326)

# prohlédneme výsledek
# v souboru s metadaty vodomerných stanic (tedy "metadata/wgmeta2023.rds") je ještě crs transformován do EPSG:32633
tab


# Původ polygonů znázorňujících působnost poboček ČHMÚ --------------------

# nejde o stránku s otevřenými geodaty ČHMÚ, nýbrž o prezentaci dat (také ve formě webových mapových aplikací) prostřednictvím ArcGIS online
# jakmile je vrstva součástí webové mapové aplikace, je zřejme dohledatelná a dohledatelný je i odkaz, který potřebujeme pro funkci arc_read() balíčku arcgislayers
# číslo vrstvy za posledním lomítkem musíme odhadnout (často nula)
pobocky <- arc_read("https://services1.arcgis.com/ZszVN9lBVA5x4VmX/arcgis/rest/services/rozvodnice5G_hranice_pobocek/FeatureServer/0") |> 
  as_tibble() |> 
  st_sf()

# načtenou polygonovou vrstvu můžeme prohlížet i takto
pobocky |> 
  mapview::mapview()

# transformujme sf collection s metadaty stanic do crs polygonů
tab <- tab |> 
  st_transform(st_crs(pobocky))

# funkcí select se zaměříme jen na sloupec, který budeme potřebovat dále
pobocky <- pobocky |> 
  select(pobocka)

# geometrie zůstává, protože je tzv. přilepená (mluvíme o 'sticky geometry')
pobocky

# geometrie se zbavíme funkcí st_drop_geometry()
# taktéž funkce pull() vytáhne ven jen vybraný sloupec jako vektor (bez geometrie)
pobocky |> 
  pull(pobocka)

# ve skriptu 05b pak pokračuje demonstrace prostorového propojování dvou sf collections (na základě predikátů založených na geometriích) a i výpočtu ploch polygonů coby reprezentantů měr získávaných funkcemi balíčku sf
