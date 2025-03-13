
# Práce s vektorovými geodaty ---------------------------------------------

# opět načteme potřebné balíčky
xfun::pkg_attach("tidyverse",
                 "arrow", # kvůli otevírání Apache Parquet souborů
                 "sf")

# metadatový soubor otevřeme funkcí open_dataset()
# odkazujeme se jen na složku, uvnitř které je soubor s příponou parquet
meta <- open_dataset("metadata/airquality_metadata_pq")

# objekt meta je tzv pointer (není nic načteno v RAM, ale po výběru řádků, sloupců apod. se po aplikaci collect() výsledek načte do RAM)
meta |> 
  head(3) |> # prohlédneme jen tři první řádky; dále také viz nativní pipe a jeho odlišnost od starého pipu (https://www.tidyverse.org/blog/2023/04/base-vs-magrittr-pipe/)
  collect()

# následující funkce na nejpodstatnější argument někde vzadu (nativnímu pipu vadí, i když se to dá obejít)
?gsub

# obdoba funkce base::gsub() pro potřeby přístupu tidyverse 
?str_replace_all

# metadat je málo, tak se nebojíme sebrat do RAM vše
# ale jindy bacha na množství dat a před collect() aplikovat nějaký výběr
meta <- meta |> 
  collect()

# jak by vypadaly data třídy tibble, kdybychom měli jen obyčejnou tabulku typu data frame
meta |> 
  as.data.frame()

# díváme se jen na sloupce tabulky, které nás zajímají
meta |> 
  select(LOKALITA_NAZEV,
         ZEMEPISNA_DELKA,
         ZEMEPISNA_SIRKA,
         AKTIVNI_OD,
         AKTIVNI_DO)

# v tabulce není vidět časové pásmo, ale když si vytáhneme sloupec do vektoru (zde jen první prvek), ukazuje se i časové pásmo
meta |> 
  slice(1) |> 
  pull(AKTIVNI_OD)

# existují různé způsoby dotazování se na třídu
# k základům patří i str()
# tidyverse poskytuje také glimpse()
meta |> 
  class()

# jedna ze zásadních funkcí konvertující cizí objekt (zde tabulku se souřadnicemi) na simple feature collection (neplést se zkratkou sfc!)
?st_as_sf

# z důvodu možnosti vrátit se zpět, zakládáme objekt meta2
meta2 <- meta |> 
  st_as_sf(coords = c("ZEMEPISNA_DELKA",
                      "ZEMEPISNA_SIRKA"),
           crs = "epsg:4326") # u autority nezáleží na velikosti písmen; jinak lze specifikovat WKT stringem

# jen prohlížíme
# specifikem je terminologie a rozdílná počet polí od počtu sloupců v globálním prostředí
meta2

# když je polí moc, pomůže i colnames()
colnames(meta2)

# přejmenovávání sloupců s geometrií vyžaduje speciální funkce
meta2 <- meta2 |> 
  st_set_geometry("geoms") # funkce se chová různě podle toho, co jí předložíme (viz help)

# geometrický sloupce je již přejmenovaný; v žádném případě nepoužíváme colnames() <- 
colnames(meta2)


# Odbočka k tvorbě vlastního bodu -----------------------------------------

# ale jinak v praxi využíváme dat se souřadnicemi:-)

# střed Evropy se souřadnicemi 15 a 50 (crs WGS 84)
stred <- st_point(c(15, 50))

# výsledkem je sfg (pozor na zkratky a jejich dezinerpretace)
stred |> 
  str()

stred |> 
  st_sfc() |> # z obyčené geometrie se stává geometrický sloupec (určitě by snesl přidávání dalších geometrií)
  st_set_crs(4326) |> # nastavujeme crs
  st_sf() |> # převádíme na simple feature collection (zde jen jeden řádek)
  st_set_geometry("geom") |> # sloupec s geometrií je žádoucí přejmenovat
  mutate(nm = "Kouřim") |> # do tabulky přidáme další pole s názvem Kouřim
  as_tibble() |> # data frame je žádoucí převést na tibble
  st_sf() # a pak zase na simple feature collection

stred |> 
  st_sfc() |> 
  st_set_crs(4326) |> 
  st_sf() |> 
  st_set_geometry("geom") |> 
  mutate(nm = "Kouřim") |> 
  as_tibble() |> 
  st_sf() |> 
  mutate(desc = "střed Evropy") |> 
  select(desc) # vybíráme sice jen jeden sloupec, ale geometrie pořád zůstává; jde o tzv. sticky geometry, kterou lze odstranit až funkcí str_drop_geometry()

# ale třeba funkce pull() se také zbavuje geometrie, když tvoří vektor ze sloupce


# Návrat k metadatům kvality ovzduší --------------------------------------

# jak se mění typ geometrie s operacemi typu summarize()
meta2 |> 
  group_by(KRAJ_NAZEV) |> 
  summarize(n = n()) |> # tímto dotáváme MULTIPOINT; lze i zkratkovitě použít funkci count()
  st_cast("POINT") # původních řádků bylo mnohem víc, ale je možné, že v několika případech šlo o naprosto stejné lokality dané stejnými souřadnicemi

# můžeme se podívat v na chyby v mmodelu vodních toků 
# takto můžeme stáhnout celou vrstvu ze služby ArcGIS REST API (voda.gov.cz)
url <- "https://agrigis.cz/server/rest/services/ISVSVoda/osy_vodnich_linii/FeatureServer/0"

# funkce arc_read() pochází z balíčku arcgislayers
library(arcgislayers)

toky <- arc_read(url) |> 
  as_tibble() |> # jen kvůli převodu na sf typu tibble
  st_sf()

# následující může trvat dost dlouho
# takže měříme čas a necháme se zavolat fanfárou
tictoc::tic(); toky |> 
  st_cast("LINESTRING") |> # převádíme na obyčejné linie; tohle možná bude lepší následovat zahozením geometrie pro urychlení
  count(idvt) |> # jeden idvt by měl znamenat jen jednu geometrii
  filter(n > 1); tictoc::toc(); beepr::beep(3)


# Ukázky s jiným kódováním textových řetězců než je UTF-8 -----------------

# můžeme stáhnout ZIP, rozbalit jej a načíst vrtsvu na podkladě kopírování cesty k .shp souboru do schránky (bez uvozovek okolo)
nadrze <- read_sf(readClipboard(),
                  options = "ENCODING=windows-1250") # nastavování options závisí driver od driveru knihovny GDAL (z přípony souboru v dsn se již ví, jaký driver je potřebný)

# můžeme ukládat do existující složky R projektu relativně
nadrze |> 
  st_transform(32633) |> # takto můžeme transformovat crs
  write_sf("results/vodni_nadrze_nove.shp", # přípona udává typ souboru, do kterého chceme ukádat
           layer_options = "ENCODING=UTF-8") # nové kódování znaků takto uložíme do .cpg souboru

# kromě definice typu 'autorita:kód' se doporučuje použití WKT řetězce
wkt <- st_crs(nadrze)

# objekt wkt lze pak použít třeba pro definici crs, pokud chybí
# ale lze také dědit, pokud uvnitř st_set_crs() bude funkce dotaz st_crs()
nadrze |> 
  st_set_crs(wkt)

# ukázka opětovného načtení
nadrze2 <- read_sf("results/vodni_nadrze_nove.shp")


# Jiné vektorové soubory --------------------------------------------------

# uložení do GPKG
# v tompto případě lze ukládat do stejného souboru (se stejným názvem) více vektorových vrstev
nadrze2 |> 
  write_sf("results/nadrze2.gpkg")

# pak už ale při načítání musíme specifikovat layer
?read_sf

# napřed lze se podívat, jaké vrstvy uvnitř souboru GPKG máme 
st_layers("results/nadrze2.gpkg")

nadrze_gpkg <- read_sf(dsn = "results/nadrze2.gpkg",
                       layer = "nadrze2")

# je vidět, že kódování ani crs není potřeba tolik řešit v případě GPKG
nadrze_gpkg
