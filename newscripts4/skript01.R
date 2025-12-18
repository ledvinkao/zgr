# nový R skript založen klávesovou zkratkou CTRL+SHIFT+N
# pro začátek předpokládáme, že pracujeme v R projektu, takže můžeme používat relativní cesty k souborům apod.


# Načítání balíčků --------------------------------------------------------

# postaru a zbytečně složitě, protože potřebujeme napřed mít balíček instalovaný
# když balíček není nainstalovaný, potřebujeme kombinovat s funkcí install.packages() či balíček instalovat prostřednictvím patřičné nabídky Install v RStudio
library(tidyverse) # jde o tzv. metapackage, který s sebou přináší devět jádrových balíčků světa tidyverse

# pro tidyverse obecně viz knihu R for Data Science (https://r4ds.hadley.nz/)

# moderní způsob, který navíc zaručuje v případě absence balíček rovnou instalovat a hned pak načítat
# zde potřebujeme mít nainstalovaný jen balíček xfun
xfun::pkg_attach2("tidyverse",
                  "sf")

# názvy sekcí v kódu tvoříme např. klávesovou zkratkou CTRL+SHIFT+R


# Práce s datasetem se stromy a představení pipe operátoru ----------------

# pipe operátor vkládáme klávesovou zkratkou CTRL+SHIFT+M
# nativní pipe vložíme až po přepnutí v Tools/Global options.../Code

# demonstrace pipe operátoru na datasetu přicházejícího přímo s R
# vezmeme např. tabuku trees
?trees

# dotaz na třídu bez pipe operátoru
class(trees)

# demonstrace nativního pipu
# pomáhá aplikovat funkce na výsledky funkce dodávané zleva
# musíme si dávat pozor na výstupy funkcí (prozradí většinou sekce Value v dokumentaci k funkci)
trees |> # tabulku trees vkládáme do funkce class() jako první argument
  class() |> # výsledek funkce class() vkládáme do funkce length() jako první argument
  length() # atp.


# Balíček sf a speciální operace nad geometrií ----------------------------

# příklad predikátu
# další predikáty najdeme v dokumentaci k této funkci
?st_intersects

# příklad míry
# další míry najdeme v dokumentaci k této funkci
?st_area

# příklad transformace
?st_transform

# dále můžeme s geometrií provádět sčítání i násobení (viz kap. 3 knihy Spatial Data Science na https://r-spatial.org/book/)


# Tvorba vlastní vektorové vrstvy (sf collection) počínaje vektorem -------

# např. funkce st_point() tvoří třídu sfg
bod <- st_point(c(15, 50)) # souřadnice konvertovaného vektoru musí být v tomto pořadí (např. zeměpisná délka a pak zeměpisná šířka)

# prohlédněme třídu vzniklého objektu
bod |> 
  class()

# nyní konvertujme na sfc
# zde již můžeme nastavit crs
bod <- bod |> 
  st_sfc(crs = "EPSG:4326") # ale v případě autority EPSG lze také použít jen číselný kód namísto řetězce

# kódy lze dohledávat např. na https://epsg.io/; pro Česko je uvádí např. ĆÚZK (https://geoportal.cuzk.cz/(S(rjwfqf3n55vg4urmf0eizs0y))/Default.aspx?lng=CZ&mode=TextMeta&text=souradsystemy&side=INSPIRE_SITsluzby&menu=43&head_tab=sekce-04-gp)
# nový kód pro S-42 je EPSG:3835 (pás 3 se středním poledníkem 15°) nebo EPSG:3836 (pás 4 se středním poledníkem 21°)

# funkcí st_crs() se lze na crs ptát
# a také ukládat do objektů, které lze pak vkládat do funkcí vyžadujících info o crs
wkt <- st_crs(bod)

bod <- bod |> 
  st_sfc(crs = wkt)

# když zapomeneme nastavit crs, lze jej nastavit funkcí st_set_crs()
# nebo také jejími variantami, záleží na situaci a našich zvycích při psaní kódu
# zde jen demonstrujeme, nic neukládáme
bod |> 
  st_set_crs(wkt)

# nyní tedy máme třídu sfc
bod |> 
  class()

# tuto třídu lze již konvertovat na sf collection
bod <- bod |> 
  st_sf()

bod |> 
  class()

# když se nám nelíbí automatické pojmenování geometrického sloupce, přejmenujeme ho (např. funkcí st_set_geometry())
bod <- bod |> 
  st_set_geometry("geometry")

# opět dle našich zvyků lze používat i varianty této funkce
st_geometry(bod) <- "geom"

# vrátíme se k názvu 'geometry'
bod <- bod |> 
  st_set_geometry("geometry")

# funkce st_geometry() dokáže více, než jen přejmenovávat
# např. s její pomocí můžeme extrahovat simple feature column
bod |> 
  st_geometry() |> 
  class()

# jakmile máme připravenou sf collection, lze ji doplňovat o atributy
# pro tyto účely lze využít funkci mutate()
bod <- bod |> 
  mutate(nm = "Kouřim",
         typ = "astronomický střed Evropy")

# geometrii lze odstraňovat, ale funkce select() nám pomůže až tehdy, je-li sf collection konvertována na tabulku
bod |> 
  select(-geometry) # toto tedy teď nefunguje

# normálně pro odstranění existuje funkce st_drop_geometry()
# nic neukládáme, jen si ukazujeme
bod |> 
  st_drop_geometry()

# do atributů lze přidávat jakékoliv další typy sloupců
# např. čas a datum
bod <- bod |> 
  mutate(dt = ymd_hms("2025-12-17 12:06:00"))

# nebo jen datum
bod <- bod |> 
  mutate(dtm = dmy("17.12.2025"))

# a klidně i čísla
bod <- bod |> 
  mutate(cislo = 2)

# nebo chybějící hodnoty
bod <- bod |> 
  mutate(miss = NA)

# sf collection lze převádět na tabulku
bod <- bod |> 
  as_tibble()

# což lze zjistit dotazem na třídu, ale i ztrátou hlavičky této vektorové vrstvy
bod |> 
  class()

# díky tomu lze již pro odstranění geometrie použít i funkci select()
# jen demonstrujeme, nic nepřepisujeme
bod |> 
  select(-geometry)

# z tabulky získáme sf collection zpět pomocí funkce st_sf()
# funkce st_sf() zde stačí, když si najde sloupec s geometrií
bod <- bod |> 
  st_sf()


# Základy kreslení pomocí funkcí balíčku tmap -----------------------------

# načtěme balíček tmap
xfun::pkg_attach("tmap")

# vrstvu, kterou chceme kreslit, vždy uvádíme funkcí tm_shape()
tm_shape(bod) + 
  tm_graticules() + # tato funkce přidá souřadnicovou síť
  tm_dots()  # po tm_shape() volíme způsob kreslení, zde tedy tečkami

# při kreslení můžeme přepínat na interaktivní (dynamický) mód
tmap_mode("view")

tm_shape(bod) + 
  tm_dots()

# zpět na statické kreslení můžeme rychle přepnout novou funkcí ttm()
# nebo aplikujeme postaru opět tmap_mode(), kde jako argument nastavíme 'plot'
ttm()

tm_shape(bod) + 
  tm_dots()

# funkcí tm_basemap() nebo tm_tiles() přidáváme podklady nebo vrstvíme nové dlaždice ze serverů, které je nabízejí
# lze aplikovat i pro podklady z Mapy.com, pokud máme kredity
?tm_basemap

# kreslit statické mapy lze i funkcemi balíčku ggplot2, který je součástí jádrového tidyverse
ggplot() + 
  geom_sf(data = bod) + # k tomu slouží hlavně funkce geom_sf(), když nám jde o kreslení vektorů
  coord_sf(crs = 5514) + # funkcí coord_sf() specifikujeme crs pro kreslení
  labs(title = "Astronomický střed Evropy") # labs() je funkce určená pro názvy, podnázvy, pojmenování legendy apod.

# změnu crs lze požadovat i při kreslení ve smyslu tmap
tm_shape(bod,
         crs = 5514) + # EPSG:5514 je pro S-JTSK (Křovákovo zobrazení)
  tm_graticules() +
  tm_dots() + 
  tm_labels("nm") + # původně jsme měli tm_text(), ale tm_labels() má lepší nastavení pro popisky v mapě; v uvozovkách volíme název sloupce, z něhož chceme brát popisky
  tm_scalebar() + # demonstrujeme přidání grafického měřítka
  tm_compass(position = c("top", "right")) # demonstrujeme přidání směrovky a nastavení její pozice

# pro přidání grafického měřítka v ggplot2 mapách lze využít anotace dodávané balíčkem ggspatial
xfun::pkg_attach2("ggspatial")

ggplot() + 
  geom_sf(data = bod |> 
            st_transform(5514)) + # můžeme zkusit transformovat crs ještě před samotným kreslením
  annotation_scale() +
  annotation_north_arrow(style = north_arrow_fancy_orienteering(),
                         location = "tr", # 'tr' znamená 'top and right'
                         which_north = "true") + # tímto zaručíme kreslení směrovky respektující skutečný sever
  labs(title = "Astronomický střed Evropy")

# měřítka ani souřadnice nejsou zmatené, máme jen zobrazené velmi malé území

# počet poledníků a rovnoběžek lze ladit argumenty funkce tm_graticules()
tm_shape(bod |> 
           st_transform(5514)) + 
  tm_graticules(n.x = 3,
                n.y = 3,
                labels.cardinal = F) + # tímto odstraníme značení směrů E, N apod.
  tm_dots() + 
  tm_labels("nm") + 
  tm_scalebar() + 
  tm_compass(position = c("top", "right"))


# Přidání další řádky do sf collection ------------------------------------

# zatím máme jen jednu řádku
bod

# vytvořme ještě jednu takovou kolekci s jednou řádkou
bod2 <- st_point(c(16, 51)) |> 
  st_sfc(crs = 4326) |> 
  st_sf() |> 
  st_set_geometry("geometry") |> 
  mutate(nm = "nevím", # nemusíme nastavovat všechny sloupce, vyplatí se však dodržovat stejné názvy
         typ = "nevím") |> 
  as_tibble() |> # toto uže je jen kosmetická úprava, konverze na třídu tibble
  st_sf() # a pak opět na sf collection

# funkcí bind_rows() řádky můžeme spojit
# kde není ekvivalentní sloupec, doplní se NA
body <- bind_rows(bod, bod2)

# prohlédneme
body

# a vykreslíme
tm_shape(body |> 
           st_transform(5514),
         bbox = st_bbox(RCzechia::republika())) + # takto můžeme nastavit tzv. bounding box polygonu území Česka (změníme tak rozsah kresleného území)
  tm_graticules(n.x = 3,
                n.y = 3,
                labels.cardinal = F) +
  tm_dots() + 
  tm_labels("nm") + 
  tm_scalebar() + 
  tm_compass(position = c("top", "right"))

# více o kreslení ve smyslu tmap probírá webová stránka https://r-tmap.github.io/tmap/
# tady najdeme odkaz na tzv. viněty a také na připravovanou knihu


# Načítání vektorových geodat ze souborů ----------------------------------

# pro cvičení jsme si stáhli polygony nádrží ze stránek DIBAVOD VÚV TGM (viz https://www.dibavod.cz/27/struktura-dibavod.html)
# stažený ZIP soubor jsme rozbalili do složky geodata (zároveň jsme vytvořili podsložku nazvanou po stejně jako SHP soubor - je to pro lepší přehled o všch souborech souvisejících s SHP souborem)

# soubory načítáme buď funkcí read_sf() - načítá jako tibble sf collection
# nebo funkcí st_read() - načítá jako data.frame sf collection
?read_sf

nadrze <- read_sf("geodata/dib_a05_vodni_nadrze/a05_vodni_nadrze.shp", # přípona určuje driver, který má být z externí knihovny GDAL využit
                  options = "encoding=windows-1250") # takto nastavíme správné kódování, pokud se trefíme (nezáleží na velikosti písmen)

# st_read() reportuje a zároveň načítá sf collection jako data.frame
nadrze2 <- st_read(readClipboard()) # pokud se nechceme zdržovat s psaním cest k souborům, lze použít funkci readClipboard(), která se postará i o správné nastavení lomítek (musíme však mít cestu k souboru nejprve nakopírovanou ve schránce)


# Ukládání vektorových geodat do souborů ----------------------------------

# zde naopak máme funkce write_sf() nebo st_write()
# když budeme chtít např. uložit shapefile a zároveň pro něj vytvořit CPG soubor s definicí kódování znaků, provedeme následující
nadrze |> 
  write_sf("geodata/results/nadrze_spravne_kodovani.shp", # složka results musí existovat
           layer_options = "encoding=utf-8") # zde se argument jmenuje layer_options

# načtením právě uloženého shapefilu se můžeme přesvědčit, že kódování je teď načteno správně
nadrze3 <- read_sf(readClipboard())

# pro ukládání je ale vhodnější využít modernější typy souborů
# geopackage má příponu GPKG
nadrze |> 
  write_sf("geodata/results/nadrze_spravne_kodovani.gpkg",
           layer = "nadrze") # lze u něj vhodně využít i argument layer, protože geopackage může obsahovat více vrstev s různými názvy

# funkcí st_layers() zjistíme obsah v geopackage
st_layers("geodata/results/nadrze_spravne_kodovani.gpkg")

# uložme do stejně pojmenovaného souboru ještě jinou vrstvu, třeba naše body
body |> 
  write_sf("geodata/results/nadrze_spravne_kodovani.gpkg",
           layer = "body")

# ale funkce st_layers() není určena jen k prohledávání obsahu v geopackage
# můžeme se zaměřit i na složku
st_layers("geodata/results")

# takto si můžeme povšimnout i kuriozity - ZIP soubor s nádržemi obsahoval dva DBF soubory
st_layers("geodata/dib_a05_vodni_nadrze")

# když někomu nebude fungovat geopackage, lze zvolit geojson
nadrze |> 
  write_sf("geodata/results/nadrze_spravne_kodovani.geojson")


# Tvorba polygonu - funkcemi balíčku sfheaders ----------------------------

# funkcemi balíčku sfheaders lze rovnou tvořit třídy, které jsou v hierarchii výše, např. sfc

# polygon lze tvořit na bázi sady souřadnic danými maticí
mat <- matrix(c(15, 50, # souřadnice zadáváme proti smeru hodinových ručiček
                15.1, 50,
                15.1, 50.1,
                15, 50.1,
                15, 50), # poslední bod se musí shodovat s prvním
              ncol = 2,
              byrow = T)

mat

ramecek <- sfheaders::sfc_polygon(mat)

# ramecek nemá nastavený crs, tak jej nastavíme
ramecek <- ramecek |> 
  st_set_crs(4326) |> 
  st_sf() |> 
  st_set_geometry("geometry") |> 
  as_tibble() |> 
  st_sf() |> 
  mutate(typ = "polygon") # a třeba dodáme ještě nějaké atributy

# můžeme vykreslit (ale potrvá delší dobu, protože jsme se neomezili na nějaké menší zájmové území)
tm_shape(ramecek) + 
  # tm_graticules() + # raději jsme zakomentovali, abychom se mohli soustředit na detaily
  tm_borders(col = "red", # polygony kreslíme buď funkcí st_borders() pro obrysy, nebo funkcí tm_polygons() pro obrysy i výplň
             lwd = 2) + # nastavujeme šířku čáry obrysu
  tm_shape(nadrze) + 
  tm_polygons(fill = "darkblue") + 
  tm_shape(body,
           is.main = T) + # argumentem is.main se zaměříme na detail daný touto vrstvou
  tm_dots()


# Funkce st_crop() --------------------------------------------------------

# toto je demonstrace zaměření se na oblast rámečku, pokud jde o nádrže, a to prostřednictvím funkce st_crop()
tm_shape(ramecek) + 
  tm_borders(col = "red",
             lwd = 2) + 
  tm_shape(nadrze |> 
             st_transform(4326) |> # musíme mít stejné crs, tak volíme např. EPSG:4326 i pro nádrže
             st_crop(ramecek)) + 
  tm_polygons(fill = "darkblue")

# varování se týká nenastavení vztahu mezi atributy a geometrií


# Tvorba bodové vektorové vrstvy ze souřadnic v tabulce -------------------

# do schránky jsme si napřed nakopírovali cestu k JSON souboru s metadaty vodoměrných stanic od ČHMÚ (viz https://opendata.chmi.cz/hydrology/historical/metadata/meta1.json)
# takto JSON načteme, ale musíme se postarat o výběr nejdůležitějších dat, která jsou zahnízděna uvnitř komplexnějšího seznamu
meta <- jsonlite::fromJSON(readClipboard())

meta <- meta$data$data$values |> # zajímáme se hlavně o matici s daty
  as.data.frame() |> # je osvědčené nejdříve převést na data.frame (kvůli efektivnější práci s názvy sloupců)
  as_tibble() |> 
  set_names(meta$data$data$header |> # pak se zajímáme o header, abychom mohli nastavit skutečné názvy sloupců
              str_split(",") |>  # řetězec musíme roztrhnout podle čárky
              unlist()) |> # výsledkem trhání řetězce je seznam, ale my chceme vektor
  janitor::clean_names() # tato funkce z balíčku janitor upravuje názvy sloupců na lepší

# tohle je jen k vysvětlení, co je obsahem objektu vzniklého funkcí jsonlite::fromJSON()
meta_puvodni <- jsonlite::fromJSON(readClipboard())

meta_puvodni

meta_puvodni$data$data$values |> 
  as.data.frame() |> 
  as_tibble()

meta_puvodni$data$data$header

# protože funkce st_as_sf(), která konvertuje tabulku se souřadnicemi, potřebuje mít souřadnice numerické, převádíme adekvátní sloupce právě z textu na numerické hodnoty
meta <- meta |> 
  mutate(across(geogr1:geogr2, # funkce across pomůže při úřevodu více sloupců najednou (nejdříve soupce vybíráme a pak aplikujeme stejnou funkci)
                as.numeric)) # aplikovaná funkce v tomto případě nemá za sebou závorky

meta <- meta |> 
  mutate(across(starts_with("geogr"), # i takto je možné vybrat sloupce uvnitř across()
                as.numeric))

# aplikace samotné funkce st_as_sf()
meta_sf <- meta |> 
  st_as_sf(coords = c("geogr2", "geogr1"), # potřebujeme minimálně určit vektor souřadnic (lze i indexy)
           crs = 4326) # navíc rovnou můžeme přidat info o crs

# funkce st_as_sf() má i argument remove, kterým můžeme zajistit, že v atributech nepřijdeme o sloupce se souřadnicemi

# nyní máme objekt třídy sf collection s vodoměrnými stanicemi
meta_sf

# stáhněme si polygon s územím Česka pro účely kreslení situace
# pokud jsme v rámci sezení již jednou hranice stáhly, načtou se z dočasného souboru
hranice <- RCzechia::republika()

# kreslíme
tm_shape(hranice) + 
  tm_graticules(n.x = 3,
                n.y = 3,
                labels.cardinal = F) + 
  tm_borders(col = "red",
             lwd = 2) +
  tm_shape(meta_sf) + 
  tm_dots(size = 0.1)


# Další možnosti stahování geodat z internetu -----------------------------

xfun::pkg_attach2("geodata", # funkcemi balíčku geodata můžeme stahovat i rastrová geodata (balíček geodata s sebou načítá i balíček terra)
                  "rnaturalearth") # protože nefungovala funkce geodata::world(), zkusili jsme i rnaturalearth

hranice2 <- countries110

# podíváme se, jak se jmenují sloupce (je jich hodně)

hranice2 |> 
  names() # lze aplikovat i funkci colnames()

# založme výběr země na bázi sloupce NAME_EN
hranice2 |> 
  pull(NAME_EN) |> # funkce pull() konvertuje vybraný sloupec na vektor
  str_subset("Czech") # takto se zaměříme regulárním výrazem na přibložnou shodu v textovém řetězci

# nakonec provedeme samotný výběr řádku
czechia <- hranice2 |> 
  filter(NAME_EN == "Czech Republic")

# a kreslíme
tm_shape(czechia) + 
  tm_borders(col = "red")

# zkusme ještě balíček rnaturalearthdata
# tento balíček samozřejmě před spuštěním následujícího řádku musí být nainstalován
hranice3 <- rnaturalearthdata::countries110

# zde není sloupec NAME_EN, ale sloupec name_en
# výsledek po vykrelsení je ale totožný
tm_shape(hranice3 |> 
           filter(name_en == "Czech Republic")) + 
  tm_borders(col = "red")

# balíček arcgislayers dokáže načíst geodata s ArcGIS REST API služby
xfun::pkg_attach("arcgislayers")

# z českého vodohospodářského portálu stáhněme např. osy voních linií
# odkaz získáme prohlížením detailů datovýh sad na https://voda.gov.cz/
toky <- arc_read("https://agrigis.gov.cz/public/rest/services/ISVS_Voda/osy_vodnich_linii/FeatureServer/0")

# provedeme kosmetickou úpravu
toky <- toky |> 
  as_tibble() |> 
  st_sf()

# prohlédneme
toky


# Ještě jednou funkce st_crop() a nově funkce st_intersection() -----------

# stáhněme si pro další analýzy ještě polygony 14 krajů Česka
kraje <- RCzechia::kraje()

# zaměřme se jen na Ústecký kraj
# dobředu víme, jaký sloupec k filtrování můžeme použít, jinak napoví třeba nahlédnutí na objekt po tisku do konzole
usti <- kraje |> 
  filter(NAZ_CZNUTS3 == "Ústecký kraj")

# přesvědčíme se, zda jsme se zaměřili na kraj správně
ggplot() + 
  geom_sf(data = usti)

# opět potřebujeme sjednotit crs
# abychom se nezdržovali s transformací komplexnější vrstvy s toky, přizpůsobíme tokům polygon kraje
usti <- usti |> 
  st_transform(5514)

# demonstrujme význam funkce st_crop(), tím, že výsledek vykreslíme třeba ve smyslu ggplot2
toky_cropped <- toky |> 
  st_crop(usti)

ggplot() + 
  geom_sf(data = usti) + 
  geom_sf(data = toky_cropped,
          col = "blue",
          lwd = 0.2) # lze použít i linewidth

# demonstrujme význam funkce st_intersection(), což je obdoba clippingu
# vycházíme zde z objektu toky_cropped, což je doporučováno, aby proces netrval moc dlouho
toky_clipped <- toky_cropped |> 
  st_intersection(usti)

# vykresleme situaci teď
ggplot() + 
  geom_sf(data = usti,
          col = "red",
          fill = NA) + 
  geom_sf(data = toky_clipped,
          col = "blue",
          lwd = 0.2)


# Subsety vektorových geodat prostřednictvím predikátů --------------------

# predikáty lze využít v hranatých závorkách, standardně bývá nastaven st_intersects()
toky_subset <- toky[usti,] # vlastně se zaměřujeme na řádky toků, které leží (aspoň zčásti) na území polygonu

# vykresleme
ggplot() + 
  geom_sf(data = usti,
          col = "red",
          fill = NA) + 
  geom_sf(data = toky_subset,
          col = "blue",
          lwd = 0.2)

# u čar výsledek není tototžný s výsledkem clippingu, u bodů ale nastává jiná situace

# když chceme aplikovat jiný predikát, musíme to upřesnit v argumentu op
toky_subset2 <- toky[usti,
                     op = st_disjoint]

ggplot() + 
  geom_sf(data = usti,
          col = "red",
          fill = NA) + 
  geom_sf(data = toky_subset2,
          col = "blue",
          lwd = 0.2)


# Míry a jednotky ---------------------------------------------------------

# vypočítejme délky vodních toků uvnitř Ústeckého kraje (vycházíme tedy z objektu toky_clipped)
# k výpočtu délek slouží funkce st_length() z balíčku sf
toky_clipped <- toky_clipped |> 
  mutate(len = st_length(geometry)) # argumentem funkce st_length() může být geometrie ale třeba i sf collection

# protože v atributech je hodně nepotřebných sloupců, tak pro tisk dokonzole vybereme jen, co nás zajímá 
toky_clipped |> 
  select(len)

# výsledek je v metrech, protože crs je také v metrech
# ukažme si, jak pomocí funkcí balíčku units lze jednotky převádět
toky_clipped <- toky_clipped |> 
  mutate(len = units::set_units(len, "km"))

# teď již máme km
toky_clipped |> 
  select(len)

# vypočítejme sumu všech délek
suma <- toky_clipped |> 
  pull(len) |> 
  sum()

suma

# někdy se vyplatí naopak jednotky zahodit
suma |> 
  units::drop_units()


# Funkce st_join() --------------------------------------------------------

# vraťme se k objektu meta_sf, který se vztahuje k vodoměrným stanicím
# funkcí st_join() připojujeme atributy z jiné sf collection na bázi prostrorového vztahu
# opět je zde standardně nastaven predikát st_intersects()
# také je nastaveno připojování zprava doleva
# ale vše se dá danými argumenty přenastavit
meta_sf <- meta_sf |> 
  st_join(kraje |> 
            select("NAZ_CZNUTS3")) # schválně jsme vybrali jen atribut, který nás z pravé tabulky zajímá nejvíce, jinak by se samozřejmě dalo připojit vše

# přesvěčíme se, jak výsledek vypadá
# omezíme se jen na klíčové sloupce
meta_sf |> 
  select(station_name, NAZ_CZNUTS3)

# řekněme, že teď budeme chtít zjistit počty stanic spadajících do jednotlivých krajů
meta_sf |> 
  st_drop_geometry() |> # zbavíme se nežádoucí geometrie, jinak by proces zbytečně trval dlouho
  count(NAZ_CZNUTS3) # cout() je zkratka kombinace funkcí group_by(), summarize() a n()


# Další funkce, které mohou být užitečné při hledání problémů -------------

st_geometry_type(kraje)

st_is_empty(kraje)

str(kraje)

glimpse(kraje)

# jak jsme si řekli vektorová geodata staršího data mohou obsahovat různé chyby týkající se topologie, a to i díky tomu, že data většinou vznikala v rovinném crs
# chybný ale může být i typ geometrie, jak je např. vidět i z následující vrstvy 
povodi <- arc_read("https://services1.arcgis.com/ZszVN9lBVA5x4VmX/arcgis/rest/services/rozvodnice5G_1_radu/FeatureServer/2") |> 
  as_tibble() |> 
  st_sf()

# proč se zde jedná o chybu z hlediska typu geometrie?
# řádky jsou jen tři, ale geometrie je u všeho jen typu POLYGON a správně má být někde MULTIPOLYGON, protože např. povodí Dunaje je reprezentováno více polygony
povodi

povodi |> 
  st_is_valid() # funkce se ptá na validitu geometrie

# jak tohle opravit?
povodi <- povodi |> 
  st_make_valid() |> # funkce se snaží opavit geometrii na validní
  st_cast("MULTIPOLYGON") |> # funkce st_cast() převádí jeden typ geometrie na druhý (pokud je to logicky možné)
  st_cast("POLYGON")

# varování se týká duplikování atributů pro jednotlivé polygony (převzaty z multipolygonů)

povodi |> 
  select(naz_pov)

# sjednocení polygonů lze pak provést následovně
povodi <- povodi |> 
  group_by(naz_pov) |> 
  summarize(geometry = st_union(geometry))

povodi

# pokud si již s opravou geometrie nebudeme vědět rady, můžeme zkusit vypnout sférickou geometrii funkcí sf_use_s2(FALSE)


# Dodatky k paralelizaci --------------------------------------------------

# asi nejosvědčenější postup paralelizace na OS Windows je dnes kombinace tzv. daemonů z balíčku mirai s vkládáním paralelizované funkce do dunkce in_parallel(), která je navíc vkládána do funkcí palíčku purrr, jako map(), walk() apod.
# počet logických jader (CPU), a tedy i počet nastavitelných daemonů můžeme zjistit následovně
parallelly::availableCores()

# nebo následovně
parallel::detectCores()

# daemony pak můžeme nastavit následovně (postup je takto i adaptován na stroj, se kterým jsme zatím nemuseli mít tu čest)
mirai::daemons(parallelly::availableCores() - 1) # doporučuje se jedno jádro si nechat na jiné procesy

# před spuštěním části kódu s funkcí in_parallel() je potřeba si daemony vyžádat
mirai::require_daemons()

# vše se resetuje nastavením nulového počtu daemonů nebo restartování sezení (session) - např. zkratkou CTRL+SHIFT+F10 v RStudio
mirai::daemons(0)
