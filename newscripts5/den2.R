# opět předpokládáme, že pracujeme v R pojektu, což nám umožní odkazovat se na soubory relativně


# Načtení prvních balíčků -------------------------------------------------

xfun::pkg_attach2("tidyverse",
                  "RCzechia", # RCzechia s sebou přináší i sf, takže sf není nutné specifikovat znovu
                  "geodata", # geodata s sebou přináší i terra, takže terra není nutné specifikovat znovu
                  "tmap") # pro názorné kreslení


# Od vektoru k sf collection ----------------------------------------------

# demonstrujme na tvorbě jednoduchého bodu, k čemuž slouží funkce st_point() balíčku sf
?st_point

# nejprve simple feature geometry (sfg)
bod <- st_point(c(15, 50))

bod |> 
  class()

# pak simple feature columns
# zde již můžeme nastavovat crs
bod_sfc <- st_sfc(bod,
                  crs = 4326)

bod_sfc

bod_sfc |> 
  class()

# nic nepřepisuji, jen demonstruji, jak bychom se asi zbavili crs
bod_sfc |> 
  st_set_crs(NA)

# nakonec tvoříme asi nejvyšší třídu simple feature collection (sf)
bod_sf <- bod_sfc |> 
  st_sf()

bod_sf |> 
  class()

bod_sf

# geometrie má divný název, tak to napravíme
# a rovnou již můžeme přidávat i atributy
bod_sf <- bod_sf |> 
  st_set_geometry("geom") |> 
  mutate(nazev = "Kouřim")

# nakonec provedeme jen kosmetickou úpravu, abychom měli třídu tibble
bod_sf <- bod_sf |> 
  as_tibble() |> 
  st_sf()

bod_sf

# vykreslíme dynamicky
ttm()

# tím zjistíme, že podle map jsme u Astronomického středu Evropy
tm_shape(bod_sf) + 
  tm_dots(fill = "grey10",
          size = 0.5)


# Míry - začátek ----------------------------------------------------------

# vypočítejme např. plochu všech 14 administrativních krajů v Česku
# funkce RCzechia::kraje() dopomůže získat polygony krajů, jak již víme z předchozího dne
kraje <- kraje()

kraje <- kraje |> 
  as_tibble() |> 
  st_sf()

kraje

# k výpočtu ploch polygonů slouží funkce st_area()
# podle dokumentace velmi záleží na crs a díky využití knihovny S2 Geometry od Google lze též počítat plochy na sféře
?st_area

# starší GIS sférickou geometrii příliš nepodporovaly, takže se mohou ve starších vrstvách vyskytnout nevalidity
# což napravuje funkce st_make_valid(); na validitu se lze naopak ptát funkcí st_is_valid()
?st_make_valid

# touto funkcí lze vypnout sférickou geometrii
?sf_use_s2


# Odbočka - cestující na zastávkách v Olomouci ----------------------------

# měli jsme k dispozici dva geopackge soubory s vrstvami reprezentujícími:

# 1) hranice města Olomouce
olomouc <- read_sf("geodata/olomouc_obec.gpkg")

# 2) zastávky (navíc atributy s nastupujícími a vystupujícími cestujícími)
stops <- read_sf("geodata/centroidy_stops_snapped.gpkg")

# nastavme opět statické kreslení a prohlédněme si geometrie obou verstev
ttm()

tm_shape(olomouc) + 
  tm_borders() + 
  tm_shape(stops) +
  tm_dots()

# prostudujme názvy sloupců
# zdá se, že tu máme příklad atributů v neuklizené tabulce a rovněž redundantních dat
# zároveň názvy nejsou ve formátu přívětivém pro R (obsahují pomlčky, mezery apod.)
colnames(stops)

# polygon byl převzat z OpenStreetMap
colnames(olomouc)

# především u zastávek si budeme muset vytvořit lepší tabulku atributů, aby bylo možné kreslit grafy
stops2 <- stops |> 
  as_tibble() |> 
  pivot_longer(cols = `Zastavky_pocty_PD — GIS_N_4`:`Zastavky_pocty_PD — GIS_C_23`,
               names_to = "cas",
               values_to = "val_num")

# stále ještě musíme něco udělat
# odstranit zbytečné sloupce, přejmenovat sloupce tak, aby s nimi bylo možné efektivně pracovat, apod.
stops2 |> 
  colnames()

stops2 <- stops2 |> 
  select(-4) |> 
  rename(gis_poc_odjezd = `Zastavky_pocty_PD — GIS_POC_ODJEZ`)

# zjistěme, které elementy (pořadí) po rozdělení řetězce potřebujeme dostat do nových sloupců
stops2 |> 
  slice(1) |> 
  pull(cas) |> 
  str_split("_")

stops2 <- stops2 |> 
  mutate(typ = str_split_i(cas,
                           "_",
                           4),
         hodina = str_split_i(cas,
                              "_",
                              5),
         cas = NULL) # teď je sloupec cas již k ničemu, tak se ho zbavme

# jen se ještě díváme, zda nepotřebujeme upravit nic dalšího
stops2 |> 
  pull(gis_poc_odjezd) |> 
  unique()

# jelikož bylo nakonec zadáno tvořit liniové grafy, práce s faktory byla vlastně zbytečná
# ale i tak ukažme, jak kreslit sloupcový graf za všechny zastávky podle hodin a podle typu cestujícího

# přenastavme nejprve hodiny na faktorovou veličinu
stops3 <- stops2 |> 
  mutate(hodina = fct(hodina))

# a nastavme pro potřeby kreslení pořadí levelů od nejmenšího po největší
stops3 <- stops3 |> 
  mutate(hodina = fct_inseq(hodina))

# a kresleme
ggplot(data = stops3,
       aes(x = hodina,
           y = val_num)) + 
  geom_col(aes(fill = typ)) + 
  labs(y = "počet cestujících",
       fill = "typ\ncestujícího")

# lze ovšem kreslit i tak, aby sloupce byly vedle sebe
ggplot(data = stops3,
       aes(x = hodina,
           y = val_num)) + 
  geom_col(aes(fill = typ)) + 
  labs(y = "počet cestujících",
       fill = "typ\ncestujícího")

# zdá se, že v tabulce se nachází i nějaké řádky s chybějícími hodnotami
# je to skutečně neznámá hodnota, nebo má jít o nulu?
stops3 |> 
  filter(is.na(val_num))

# ale chybějící hodnoty máme i v jiných sloupcích, např. u některých zastávek nemáme id
stops3 |> 
  filter(if_any(everything(), is.na)) |> 
  print(n = 61)

# zastávek je celkem 183
stops3 |> 
  distinct(stop_name) |> 
  nrow()

# tak potom, jestli budeme chtít použít facety, budeme se muset postarat o rozumné rozělení stránek
# na stránkování musíme použít funkci facet_wrap_paginate() z balíčku ggforce
library(ggforce)

ggplot(data = stops3 |> 
         mutate(hodina = as.numeric(format(hodina))), # nejprve měníme třídu u sloupce s hodinami
       aes(x = hodina,
           y = val_num)) + 
  geom_line(aes(col = typ)) + 
  geom_point(aes(col = typ)) + 
  facet_wrap_paginate(~stop_name,
                      ncol = 2,
                      nrow = 3,
                      page = 31,
                      scales = "free") + 
  labs(y = "počet cestujících",
       col = "typ\ncestujícího")

# kreslení je samozřejmě možné po jednom
# podívejme se na názvy zastávek a vyberme jednu
stops2 |> 
  pull(stop_name) |> 
  unique()

ggplot(data = stops3 |> 
         filter(stop_name == "Nová Ulice") |> 
         mutate(hodina = as.numeric(format(hodina))),
       aes(x = hodina,
           y = val_num)) + 
  geom_line(aes(col = typ)) + 
  geom_point(aes(col = typ,
                 size = typ)) + # jak praví hláška, tohle není vhodné pro diskrétní veličinu, chtěli jsme jen ukázat, že to také funguje
  labs(title = "Cestující Nová Ulice",
       caption = "zdroj: Adam",
       y = "počet cestujících",
       col = "typ\ncestujícího")

# bylo by možné vytvořit grafy pro každou zastávku a pak je jako tzv. grobs (graphical objects) lokalizovat do bodů zastávek (viz např. dokumentaci k funkci tm_dots())
# protože jsou však zastávky blízko vedle sebe, tato technika by zřejmě byla nevhodná
# zkusme to tedy jinak - slučme graf a mapu na jednu stránku
# k tomu můžeme využít např. funkci plot_grid() z balíčku cowplot
library(cowplot)

# grafy můžeme uložit do objeků a pak je sloučit
p1 <- ggplot(data = stops3 |> 
               filter(stop_name == "Nová Ulice") |> 
               mutate(hodina = as.numeric(format(hodina))),
             aes(x = hodina,
                 y = val_num)) + 
  geom_line(aes(col = typ)) + 
  geom_point(aes(col = typ,
                 size = typ)) + # jak praví hláška, tohle není vhodné pro diskrétní veličinu, chtěli jsme jen ukázat, že to také funguje
  labs(title = "Cestující Nová Ulice",
       caption = "zdroj: Adam",
       y = "počet cestujících",
       col = "typ\ncestujícího")

# vytvořme jednoduchou přehledovou mapu
# kde vybranou zastávku označíme větším bodem a červenou barvou
p2 <- ggplot() + 
  geom_sf(data = olomouc) +
  geom_sf(data = stops,
          size = 1) + 
  geom_sf(data = stops |> 
            filter(stop_name == "Nová Ulice"),
          col = "red",
          size = 3)

# využijme nakonec výtečnou funkci balíčku cowplot pro sloučení obou grafů
plot_grid(p1,
          p2,
          nrow = 2,
          align = "v")

# takto by bylo možné tvořit více stránek, třeba pro každou zastávku jednu
# netřeba poznamenat, že při této tvorbě jakéhosi atlasu by nám hodně pomohlo funkcionální programování
# existují i jiné R balíčky, které nám umožňují něco podobného (např. patchwork)


# Míry - dokončení --------------------------------------------------------

# vypočítejme tedy plochy jednotlivých krajů
kraje <- kraje |> 
  mutate(a = st_area(geometry), # funkce st_area() akceptuje např. třídu sfc, tedy i geometrický sloupec
         .before = NAZ_CZNUTS3) # argumenty .before a .after určujeme, kde má být nový sloupec umístěn

# standardně jsou plochy počítány v m2, ale funkcemi balíčku units lze tyto jednotky převádět
kraje <- kraje |> 
  mutate(a = units::set_units(a, "km2"))

# jednotky lze i zahazovat pro případ, že je některé funkce nesnáší
kraje <- kraje |> 
  mutate(a = units::drop_units(a),
         a = round(a, 2)) # nakonec třeba i zaokrouhlíme


# Kreslení kartogramů pomocí ggplot2 --------------------------------------

# vezmeme si na pomoc další balíčky
xfun::pkg_attach2("ggtext", # podporuje markdown v popiscích (dobře se pak pracuje s horními a dolními indexy a jinou matematickou notací)
                  "ggspatial") # pomáhá přidat grafické měřítko a směrovku

# nakresleme např. kartogram s plochami v krajích
ggplot() + 
  geom_sf(data = kraje,
          aes(fill = a), # budeme vyplňovat podle plochy v km2
          col = "white") + # bílé hranice jsou dobře vidět
  geom_sf_label(data = kraje, # ukazuje, jak pracovat s popisky, i když by to ještě některé chtělo od sebe posunout
               aes(label = NAZ_CZNUTS3),
               size = 2) + 
  coord_sf(crs = 5514) + # při kreslení takto můžeme změnit crs, abychom demonstrovali význam směrovky, která si je vědoma severu
  scale_fill_distiller(palette = "Reds", # měníme paletu barev
                       direction = 1) + # a také směr intenzity
  scale_x_continuous(breaks = 12:19, # zbavujeme se zkratek směrů u os
                     labels = \(x) str_c(x, "°")) +
  scale_y_continuous(breaks = 49:51, # viz také bonusový skript 38
                     labels = \(x) str_c(x, "°")) +
  labs(title = "Plocha krajů",
       fill = "plocha\n[km<sup>2</sup>]", # právě tady, v popiscích můžeme využít markdown
       x = "", # také my mělo být možné psát NULL pro zbavení se názvů os
       y = "") + 
  theme_bw() + # nastavujeme černobílé pozadí (existuje hned několik takových přednastavených pozadí; pro další viz např. balíček ggthemes)
  theme(legend.title = element_markdown()) + 
  annotation_scale(style = "ticks", # přidáváme grafické měřítko
                   location = "br") + 
  annotation_north_arrow(style = north_arrow_fancy_orienteering(text_col = "black", # a ještě ladíme směrovku
                                                                text_size = 0), # aby se nezobrazovalo anglické N
                         location = "tl",
                         width = unit(1, "cm"),
                         height = unit(1, "cm"),
                         which_north = "true")

# jak bychom si obdobně počínali pomocí tmap funkcí?
tm_shape(kraje,
         crs = 5514) + 
  tm_graticules() +
  tm_polygons(col = "white",
              fill = "a",
              fill.scale = tm_scale_continuous(values = "brewer.reds", # vybíráme vlastně stejnou paletu barev jako u ggplot2, jen tady se jmenuje jinak
                                               ticks = c(0, 2000, 4000, 6000, 8000, 10000),
                                               labels = as.character(c(0, 2000, 4000, 6000, 8000, 10000))),
              fill.legend = tm_legend(reverse = T,
                                      title = "Plocha\n[km2]")) + # zde není možné použít markdown, ale věřím, že to půjde nějak upravit
  tm_shape(stops) + # schválně jsme přidali body zastávek v Olomouci
  tm_dots(size = 0.01) + # a nastavili jejich velikost, aby tolik nerušily
  tm_scalebar(position = c("LEFT", "BOTTOM")) + # na velikosti písma záleží
  tm_compass(position = c("right", "top"), # malá písmena nejsou tak striktní pro přimknutí k okraji mapy
             show.labels = F) + # aby se nezobrazovalo anglické N
  tm_title("Plocha krajů")


# Ukládání pracně vytvořených map -----------------------------------------

# před ukládáním je vhodné přiřadit si mapu k nějakému objektu
map01 <- tm_shape(kraje,
                  crs = 5514) + 
  tm_graticules() +
  tm_polygons(col = "white",
              fill = "a",
              fill.scale = tm_scale_continuous(values = "brewer.reds",
                                               ticks = c(0, 2000, 4000, 6000, 8000, 10000),
                                               labels = as.character(c(0, 2000, 4000, 6000, 8000, 10000))),
              fill.legend = tm_legend(reverse = T,
                                      title = "Plocha\n[km2]")) + 
  tm_shape(stops) + 
  tm_dots(size = 0.01) + 
  tm_scalebar(position = c("LEFT", "BOTTOM")) + 
  tm_compass(position = c("right", "top"),
             show.labels = F) + 
  tm_title("Plocha krajů")

# pro mapy tvořené ve smyslu tmap využijeme pro uložení funkci tmap_save()
?tmap_save

# možná se vyplatí hrát si i s měřítkem pro vyladění adekvátních poměrů
tmap_save(tm = map01, # nejprve objekt (ggsave() to má obráceně)
          filename = "figs/mapa_plochy_kraju.png", # pak cesta k souboru
          width = 297, # nastavujeme velikost A4 (na šířku)
          height = 210,
          units = "mm",
          dpi = 300)

# poznamenejme, že palety barev tmap bere z balíčku cols4all
# tako např. najdeme palety vhodné pro terén
cols4all::c4a_palettes(type = "seq") |> 
  str_subset("terrain")


# Načítání vektorových geodat z ArcGIS REST API služeb --------------------

# asi nejlepší je pro tento účel balíček arcgislayers
# ten je součástí metabalíčku arcgis
library(arcgislayers)

# ukázali jsme si, jak z ArcGIS Online prezentací map a vrstev získat odkaz, který potřebuje funkce arc_read()
# je nutné, aby odkaz končil číslem vrstvy
toky <- arc_read("https://agrigis.gov.cz/public/rest/services/ISVS_Voda/osy_vodnich_linii/FeatureServer/0") |> 
  as_tibble() |> # tohle je opět už jen kvůli převodu na třídu sf typu tibble
  st_sf()

# po získání kolekce do paměti již můžeme klasicky aplikovat tidyverse funkce
# tady např. pro výběr toku Teplé Vltavy
toky |> 
  filter(str_detect(NAZ_TOK, "Teplá Vltava"))

# přepněme tmap na mód kreslení dynamických map
ttm()

# a nakresleme si tento tok
tm_shape(toky |> 
           filter(str_detect(NAZ_TOK, "Teplá Vltava"))) + 
  tm_lines(col = "blue")

# jsou i takové služby nabízené ČHMÚ
rozvodnice <- arc_read("https://services1.arcgis.com/ZszVN9lBVA5x4VmX/arcgis/rest/services/rozvodnice5G_4_radu/FeatureServer/5/") |> 
  as_tibble() |> 
  st_sf()

# někdy se stane, že techtové řetězce správně neukazují chybějící hodnoty NA
# tak si je můžeme nastavit správně
rozvodnice <- rozvodnice |> 
  mutate(across(where(is.character), # tady tidy selection využívá pomocníky na výběr textových sloupců
                \(x) if_else(x == "", NA, x))) # touto anonymní funkcí kýženou práci nastavení hodnot NA dokončíme poměrně rychle

# přesvědčíme se, zda ke konverzi "" na NA skutečně došlo
rozvodnice

# některé datasety jsou poměrně velké a není vhodné je načítat do RAM celé
# proto existuje funkce arc_open() s následnou aplikací funkce arc_select()
toky2 <- arc_open("https://agrigis.gov.cz/public/rest/services/ISVS_Voda/osy_vodnich_linii/FeatureServer/0")

# takto se podíváme na prvních 10 řádků
arc_select(toky2,
           n_max = 10)

# argument where akceptuje SQL dotazy
tepla_vltava <- toky2 |> 
  arc_select(where = "NAZ_TOK LIKE 'Teplá Vltava'") # když nevíme jak je tok v databázi uveden, jistější jsou regulární výrazy

tepla_vltava <- tepla_vltava |> 
  as_tibble() |> 
  st_sf()

tepla_vltava


# Centroidy a buffery -----------------------------------------------------

# centroidy získáme funkcí sf::st_centroid()
kraje_centroidy <- kraje |> 
  st_centroid()

# varování se týká nenastavení vztahu mezi atributy a geometrií (agr)

# jak to vypadá?
ggplot() + 
  geom_sf(data = kraje) + 
  geom_sf(data = kraje_centroidy)

# když centroid padá mimo území, lze využít funkci st_point_on_surface()

# k dalším funkcím, které tvoří body na povrchu jiných útvarů, patří třeba st_sample()
# tato funkce tvoří náhodně rozmístěné nebo pravidelně rozmístěné body (ale i jinak umístěné)
?st_sample

# tvorba bufferů je vhodnější při rovinných crs
kraje_buffers <- kraje |> 
  st_transform(32633) |> 
  st_buffer(dist = units::set_units(10, km)) # takto můžeme šikovně nastavit vzdálenosti v jednotkách, ve kterých standardně přemýšlíme

# co právě vzniklo?
ggplot() + 
  geom_sf(data = kraje_buffers)

# při tvorbě bufferů nejsme omezení na kladné vzdálenosti
kraje_buffers <- kraje |> 
  st_transform(32633) |> 
  st_buffer(dist = units::set_units(-10, km))

# Praha asi úpně zmizela
ggplot() + 
  geom_sf(data = kraje_buffers)


# Úplné základy rastrových geodat v R (balíček terra) ---------------------

# rastrová geodata jsou často velká
# proto vyžadují speciální zacházení, jako je nenačítání dat do RAM, dokud to není nezbytně nutné, složka s dočasnými soubory apod.
# nastavení chování balíčku terra lze ovládat následující funkcí
?terraOptions

# načítání rastrových geodat ze souborů probíhá pomocí funkce rast()
# ta nachází i jiné aplikace
?rast

# funkce rast() akceptuje vektor s cestami k souborům
# ten tradičně získáváme fukcemi list.files() nebo dir()
?list.files

# takto se podíváme do složky (i do jejích podsložek) na všechny soubory končící příponou '.tif'
tifs <- dir("geodata",
            pattern = "[.]tif$",
            recursive = T,
            full.names = T) # velmi často potřebujeme nastavit tento argument na TRUE, abychom mohli soubory načítat

tifs

# stáhli jsme soubor scénáře SSP2-4.5 regionálního klimatického modelu ALADIN-CLIMATE/CZ s průměrnou teplotou vzduchu za několik 20letých období
# webové stránky, ze kterých geodata pochází, jsou https://www.perun-klima.cz/results.html (zvolili jsme soubor .asc)
# následující řádek ukazuje, že i funkce rast() umožňuje načítat rastrová geodata ze ZIP souboru bez rozbalení
r <- rast("/vsizip/c:/Users/ledvinka/Documents/RProjects/zgr/geodata/SSP245_T_year_asc.zip/SSP245_T_2021-2040_year.asc")

# můžeme však načíst vše najednou, když si napřed sestavíme následující vektor
obdobi <- c("2021-2040",
            "2041-2060",
            "2061-2080",
            "2081-2100")

# tento vektor pak využijeme při mapování načítací funkce
# str_glue() je obdobou str_c(), funkce se liší způsobem lepení textových řetězců
r <- map(obdobi,
         \(x) rast(str_glue("/vsizip/c:/Users/ledvinka/Documents/RProjects/zgr/geodata/SSP245_T_year_asc.zip/SSP245_T_{x}_year.asc")))

# když jsme líní psát dlouhé cesty k souborům, můžeme využít funkci readClipboard()
?readClipboard

# další aplikací rast() odstraníme z rastru hodnoty
r <- rast(r)

# což vidíme i po tisku hlavičky do konzole
r

# vidíme, že není nastavený crs
# takto ho nastavíme
crs(r) <- "epsg:32633"

r

# můžeme se ptát na určité vlastnosti rastru
names(r)

sources(r)

# datum / čas chybí
time(r)

# ale můžeme si něco nastavit, např. začátky 20letých období
time(r) <- seq(ymd("2021-01-01"),
               length.out = 4,
               by = "20 years")

# prohlédneme
r

# pro přehled si můžeme nastavit i info o proměnných
?varnames

varnames(r) <- "tavg"

r

# počet vrstev
nlyr(r)

# počet sloupců
ncol(r)

# počet řádků
nrow(r)

varnames(r)

time(r)

# funkcí writeRaster ukládáme rastrová data do souboru (až na NetCDF soubory)
# typy souborů jsou závislé na driverech knihovny GDAL (https://gdal.org/en/stable/drivers/raster/index.html)
writeRaster(r,
            "geodata/tavg_aladin_climate_cz_ssp245.tif",
            overwrite = T) # toto je dobré nastavit pro případy, kdy máme podezření, že soubor se stejným názvem již existuje

# existují funkce pro konverzi rastru do tabulky
r_tibble <- r |> 
  as.data.frame(xy = T) |> # xy = T zaručí, že v tabulce budeme mít i souřadnice středů buněk
  as_tibble() 

# skládat z takových tabulek opět rastr je otázka funkce rast()
r_rastr <- rast(r_tibble,
                type = "xyz",
                crs = "epsg:32633") # můžeme nastavit i crs

# vidíme, že jde opět o SpatRaster
r_rastr

# při převodu do tabulky si lze speciálně vyžádat i práci s časem
# co to nakonec udělá s názvy sloupců?
r_tibble2 <- r |> 
  as.data.frame(xy = T,
                time = T) |> 
  as_tibble()

# při opětovné stavbě rastru z tabulky se však čas dostane do názvů vrstev
r_rastr2 <- rast(r_tibble2,
                 type = "xyz",
                 crs = "epsg:32633")

r_rastr2

# z názvů vrstev však můžeme snadno dostat atribut datumu / času
time(r_rastr2) <- ymd(names(r_rastr2))

# a za využití datumu přenastavit trochu jinak i názvy 
names(r_rastr2) <- str_c("ymd_",
                         time(r_rastr2))

r_rastr2

# rastr lze konvertovat do vrstvy bodů s atributy (SpatVector)
r_body <- as.points(r_rastr2)

# tohle nemá smysl kreslit, viděli bychom stejně jen černé mračno nerozeznatelných bodů

# funkce crds() je u SpatVectoru využívána pro získání souřadnic (podobně jako st_coordinates() u balíčku sf)
r_body |> 
  crds()

# i z takového mračna bodů lze zpětně zskat rastr, pokud jsou jejich rozestupy pravidelné
# opět vidíme v akci funkci rast()
r_rastr3 <- rast(r_body,
                 type = "xyz") # zde pak není nutné nastavovat crs (funkce rast() si ho vezme přímo z bodů, kde je nastaven)

r_rastr3

# funkce app() je obdoba základní funkce apply
# přitom v terra existují i jiné obdoby takových funkcí, jako jsou tapp() a lapp()
?app

# některé funkce není třeba řešit pomocí app()
# např. mean() nebo weighted.mean() existují samostatně
?mean

r_prumer <- mean(r_rastr3)

r_prumer |> 
  rast()

# co dělat, když jednotlivé vrstvy na sebe nesedí a stejně bychom je potřebovali v jednom SpatRasteru?
?resample

# funkcí resample se můžeme chytit geometrické konstrukce jiného rastru a do nové konstrukce přepočítat původní hodnoty (musíme zvolit techniku přepočtu argumentem 'method')

# když potřebujeme při resamplování pracovat i stransformací crs, jsme pak nuceni použít funkci project(), kde pak jde o tzv. warping
