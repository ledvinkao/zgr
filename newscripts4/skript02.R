# opět předpokládáme, že pracujeme v R projektu, díky čemuž se pak můžeme odkazovat na soubory relativně

# Načtení prvních balíčků, pak budeme načítat další -----------------------

xfun::pkg_attach2("tidyverse",
                  "sf",
                  "arcgislayers")


# Chyby v geometrii vektorových geodat ------------------------------------

# zopakujeme si demonstraci opravy geometrie vektorových geodat
# pro tento účel stáhneme vrstvu rozvodnic 1. řádu ze stránek s otevřenými prostorovými daty ČHMÚ (viz https://open-data-chmi.hub.arcgis.com/)
povodi <- arc_read("https://services1.arcgis.com/ZszVN9lBVA5x4VmX/arcgis/rest/services/rozvodnice5G_1_radu/FeatureServer/2") |> 
  as_tibble() |> 
  st_sf()

# při prohlížení dat se omezme jen na sloupec s názvy
povodi |> 
  select(naz_pov)

# existije funkce st_is_valid(), která vrací logické hodnoty
# zde vidíme, že ani jeden řádek neobsahuje validní geometrii; může to být spojeno s typem geometriie, ale důvody mohou být i jiné (např. topologie)
povodi |> 
  st_is_valid()

# něco spravíme funkcí st_make_valid()
povodi <- povodi |> 
  st_make_valid()

# a pak je možné si ještě hrát s konverzemi na odpovídající typy geometrie (minimáně povodí Dunaje by mělo být MULTIPOLYGON)
povodi <- povodi |> 
  st_cast("MULTIPOLYGON")

# teď je možné sledovat, co se bude dít, když budeme chtít geometrii zjednodušit
# varování si nemusíme všímat
povodi <- povodi |> 
  st_cast("POLYGON")

# prohlédneme
povodi

# následující řádky opět geometrii sloučí do geometrie typu MULTIPOLYGON (kde je to nutné)
povodi2 <- povodi |> 
  group_by(naz_pov) |> 
  summarize(geometry = st_union(geometry))

# všechno se po vykreslení ukáže v mapě, pokud je vše v pořádku
ggplot() + 
  geom_sf(data = povodi2,
          fill = NA,
          col = "red")


# Interaktivní editace geometrie - balíček mapedit ------------------------

# načteme balíček mapedit
xfun::pkg_attach("mapedit")

# jeho funkcí editFeatures() se v okně Viewer otevře prostředí pro interaktivní editaci s různými tlačítky
povodi3 <- povodi |> # po ukončení editace se díky kódu napsanému takto změny rovnou ukládají do přiřazeného objektu
  editFeatures()

# jak se můžeme ostatně přesvědčit např. ze změny počtu řádků, poku např. nějaké polygony v editačním módu smažeme
povodi3


# Rastrová geodata - úvod -------------------------------------------------

# když načteme balíček geodata, načte se rovnou i balíček terra
# není tedy nutné balíček terra načítat znovu
# pozor na pořadí načítaných balíčků, existují stejně pojmenované funkce a přednost má tak z posledního načítaného balíčku
# a to je i případ funkce extract() z balíčku terra
xfun::pkg_attach("geodata")

# funkce pro ukládání rastrových geodat do souborů
# writeRaster() je závislá na driverech externí knihovny GDAL
?writeRaster

# pokud chceme ukládat do souborů NetCDF (např. soubor .nc) velmi oblíbených v klimatologii, musíme použít funkci writeCDF(), která umožnuje ukládat i jiné atributy (např. varname, longname)
?writeCDF

# jinak má nalíček terra i podporu pro vektorová geodata - viz funkci writeVector()

# kam se budou ukládat dočasné soubory a jiná nastavení balíčku terra, ovládáme funkcí terraOptions()
?terraOptions

# terra má i podporu pro načítání rastrových a vektorových geodat - viz funkce rast() a vect()
# ale jsou případy, kdy geodata můžeme načítat a ukládat pomocí funkcí read_rds() a write_rds()

# dejme tomu, že jsme si stáhli do složky našeho R projektu data nabízená na stránkách https://rspatial.org/rs/1-introduction.html#data
# máme teď v geodatech složku rs a v ní nějaké RDS soubory
# zkusme načíst hned první RDS soubor
lc <- read_rds("geodata/rs/lcsamples.rds")

# v Globálním prostředí se objeví popis Formal class PackedSpatVector
# takové soubory vznikají aplikací funkce terra::wrap()
# pokud k hodnotám chceme získat přístup, musíme použít funkci terra::unwrap()
lc <- unwrap(lc)

## funkce wrap() a unwrap() se používají, chceme-li dostat data do paměti a pak je zase rozbalit (např. při paralelizaci potřebujeme tako data poskytnout otrokům, i když je master zná)

# teď lze kreslit polygony, které představují trénovací množinu pro klasifikační modely, jako jsou rozhodovací stromy v balíčku rpart (viz také https://rspatial.org/rs/5-supclassification.html)
ggplot() + 
  geom_sf(data = st_as_sf(lc)) # funkce st_as_sf() konvertuje i SpatVector na sf collection

# proč v tidyverse existují podobné funkce, když jejich protějšky najdeme i v základním R?
# jde o vektorizované funkce vhodné pro funkcionální programování
# dále mají tyto nové funkce jinak nastavené defaultní hodnoty argumentů
?write_rds

# vs.
?saveRDS

# dále třeba
?if_else

# vs.
?ifelse


# Základy práce s rastrovými objekty ve smyslu balíčku terra --------------

# pro načítání rastrových geodat existuje sice funkce rast(), ale rastrová geodata lze získávat i jinak - stahovacími funkcemi, jako je RCzechia::vyskopis() nebo geodata::elevation_30s()
# stáhněme např. digitální model reliéfu (dem) Česka pomocí funkce RCzechia::vyskopis()
dem1 <- RCzechia::vyskopis("actual") # když nechceme typ 'rayshaded', přenastavíme argument na 'actual'

# rastrová geodata po vytištění do konzole ukazují typickou hlavičku, obdobnou tomu, co vidéme po vitištění sf collection
dem1

# když se nám nelíbí názvy jednotlivých vrstev, můžeme je nastavit znovu pomocí funkce names()
# touto funkcí se ale také můžeme na názvy ptát
names(dem1)

# terra nabízí mnohé dotazovací funkce
nlyr(dem1) # počet vrstev

# počet sloupců
ncol(dem1)

# počet řádků
nrow(dem1)

# prostorové rozlišení
res(dem1)

# takto se ptáme na crs
crs(dem1) |> 
  cat() # funkce cat() nám pomáhá lépe nahlédnout na textový řetězec

# tidyverse nabízí také vhodnou funkci str_view()
crs(dem1) |> 
  str_view()

# toto je dotaz na rozsah rastrové vrstvy
ext(dem1)

# příklad přejmenování vrstvy
names(dem1) <- "dem"

names(dem1) <- "elv"

# vidíme, že tady je i atribut 'varname'
dem1

# funkce writeCDF() umožňuje nastavovat další atributy jako tyto (varname, longname)
?writeCDF

# existují ale i funkce varnames() a longnames() pro jejich nastavování separátně (ne varname(), jak jsme spolu nemohli vypátrat)

# k přidání atributu nebo k dotazu na atribut související s datumem a časem slouží funkce time()
time(dem1) <- ymd(20251218) # funkce ymd() pochází z balíčku lubridate

# za využití tohoto atributu nyní můžeme nastavit jiný název vrstvy
names(dem1) <- str_c("elv_",
                     format(time(dem1),
                            "%Y%m%d"))

# prohlédneme výsledek
dem1


# Kreslení rastrů ---------------------------------------------------------

# rastry můžeme kreslit pomocí funkce tmap::tm_raster(), tak načtěme balíček tmap
xfun::pkg_attach2("tmap")

# zde opět musíme začínat funkcí tm_shape()
tm_shape(dem1) + 
  tm_raster() # funkce tm_raster() vybírá nějakou barevou paletu automaticky a také se automaticky stará o vybrané měřítko pro vykreslování

# paletu barev ale lze přenastavit, vybereme nějakou vhodnou pro terén (doporučováno je soustředit se na palety z balíčku cols4all)
cols4all::c4a_palettes(type = "seq") |> # vybereme sekvenční typ
  str_subset("terrain") # takto se můžeme omezit na konkrétní palety pro terén

# nakresleme dem pomocí vybrané palety barev
tm_shape(dem1) + 
  tm_raster(col.scale = tm_scale_continuous(values = "matplotlib.terrain",
                                            ticks = c(54, 500, 1000, 1560), # takto se ještě postaráme o popisky v legendě
                                            labels = c(54, 500, 1000, 1560)), 
            col.legend = tm_legend(reverse = T,
                                   title = "Elevation\n[m a.s.l.]"))

# nastavování legendy někdy není součástí funkce tm_legend(), ale přímo funkce tm_scale_continuous()

# ukládání map vytvořených tmap funkcemi provádíme pomocí funkce tmap_save(), kde jsou první dva argumenty prohozené oproti ggsave()
?tmap_save

?ggsave

# terra poskytuje i svoji vlastní funkci pro kreslení
# jakmile funkce plot() rozezná, že jí byl předložen SpatRaster, funguje, jak má
plot(dem1)

# rastry lze kreslit i ve smyslu ggplot2
# balíček tidyterra s sebou přináší potřebné funkce pro manipulaci s rastry ve smyslu tidyverse, a to včetně těch umožňujících rastry kreslit ve smyslu ggplot2
xfun::pkg_attach2("tidyterra")

# právě funkce geom_spatraster() je zde velmi důležitá
# palety barev lze nastavovat funkcmi, jejichž název začíná na scale_fill_ nebo scale_color_
ggplot() + 
  geom_spatraster(data = dem1) + 
  scale_fill_hypso_tint_c(palette = "wiki-schwarzwald-cont",
                          direction = 1) + 
  labs(fill = "Elevation\n[m a.s.l.]")

ggplot() + 
  geom_spatraster(data = dem1) + 
  scale_fill_hypso_tint_c(palette = "wiki-schwarzwald-cont",
                          direction = -1) + # paletu barev můžeme takt obrátit
  labs(fill = "Elevation\n[m a.s.l.]")

# paletu barev při tmap kreslení lze obrátit pouhým psaním znaménka minus před názvem palety (vše musí být v uvozovkách)
tm_shape(dem1) + 
  tm_raster(col.scale = tm_scale_continuous(values = "-matplotlib.terrain",
                                            ticks = c(54, 500, 1000, 1560),
                                            labels = c(24, 500, 1000, 1560)),
            col.legend = tm_legend(reverse = T,
                                   title = "Elevation\n[m a.s.l.]"))

# takto lze získat jiný dem pomocí funkce geodata::elevation_30s
# rpzlišení je horší, ale pro výuku postačuje (procesy nad ním netrvají dlouho)
dem2 <- elevation_30s(country = "CZE", # kód země najdeme pomocí geodata::country_codes()
                      path = "geodata", # můžeme vybrat složku R projektu, kam se geodata uloží (a pokud jsou stažena, již se načítají odtud)
                      mask = F) # hydrologové jistě nebudou chtít maskovat, zajímají je povodí přesahující hranice

tm_shape(dem2) + 
  tm_raster(col.scale = tm_scale_continuous(values = "matplotlib.terrain",
                                            ticks = c(50, 500, 1000, 1530),
                                            labels = c(50, 500, 1000, 1530)),
            col.legend = tm_legend(reverse = T,
                                   title = "Elevation\n[m a.s.l.]"))


# Rastrová geodata s více vrstvami ----------------------------------------

# jako příklad rastrových geodat s více vrstvami uveďme rastry WorldClim
# vybereme např. dlouhodobé průměrné měsíční hodnoty teploty vzduchu (tavg) za období 1970-2000
tavg <- worldclim_country(country = "CZE",
                          var = "tavg",
                          path = "geodata")

# případně lze již stažený dataset načíst funkcí rast()
# provedli jsme, protože server pro stažení geodat pomocí funkce worldclim_country() nefungoval
tavg <- rast("geodata/climate/wc2.1_country/cze_wc2.1_30s_tavg.tif")

# podobně jako u jedné vrstvy i zde lze nastavovat nové názvy vrstev
names(tavg) <- str_c("month_",
                     str_pad(1:12, width = 2, pad = "0")) # funkce str_pad() pochází z balíčku stringr a pomáhá nastavit vodící znaky k textu

# SpatRaster se, pokud jde o výběry jednotlivých vrstev, chová jako seznam
# proto lze pro výběry versev používat dvojité hranaté závorky
tavg[[7]]

# ale existují i jiné postupy
tavg$month_07

tavg[["month_07"]]

subset(tavg, "month_07")

# nakresleme např. červencovou vrstvu a vyberme k tomu vhodnou paletu barev z balíčku cols4all
tm_shape(tavg[[7]]) + 
  tm_raster(col.scale = tm_scale_continuous(values = "brewer.reds")) # viz americkou kartografku Cynthii Brewer (https://en.wikipedia.org/wiki/Cynthia_Brewer)

# lze opět přiřazovat atribut související s datumem a časem
time(tavg) <- 1:12


# Funkce rast() a její další významy --------------------------------------

# funkce rast() se přepíná podle toho, co ji vložíme jako první argument

# převeďme vícevrstvý rastr na tabulku, k tomu slouží funkce as.data.frame()
tavg_df <- as.data.frame(tavg,
                         xy = T) # tímto do tabulky dostaneme také souřadnice centroidů buněk

# prohlédneme
tavg_df |> 
  as_tibble()

# nyní můžeme z tabulky funkcí rast() raster postavit znovu
tavg2 <- tavg_df |> 
  rast(type = "xyz",
       crs = crs(tavg)) # rovnou můžeme dědit crs

# povšimněme si, že nyní zdrojem není soubor na disku, nýbrž paměť, nebo možná lépe dočasný soubor
tavg2

# rastry s více vrstvami lze převést na seznam, kdy každý prvek seznamu bude obsahovat jednu vrstvu
# funkcí rast() pak seznam můžeme převést zpět na Spatraster
# zůstaňme ale ještě chvíli u seznamu s rastrovými vrstvami
tavg_list <- as.list(tavg)

tavg_list

# řekněme, že nás někdo požádal o uložení rastrových vrstev do separátních souborů
# porovnejme dva postupy a funkcemi balíčku tictoc zjistěme, který postup je rychlejší na našem počítači
tictoc::tic(); walk(tavg_list, # protože jde o seznam, lze na něj aplikovat funkci walk(), což je funkce map() určená k tzv. vedlejším efektům, jako je ukládání souborů
                    \(x) writeRaster(x,
                                     str_c("results/", names(x), ".tif"), # stavíme vektor s cestami k novým souborům pomocí funkce stringr::str_c(), což je obdoba základního paste()
                                     overwrite = T)); tictoc::toc() # overwrite nastavujeme ,abychom se pak nepotýkali s problémy s již existujícími soubory

# nyní využijme vlastnosti funkce writeRaster(), a sice, že můžeme do separátních souborů ukládat pokud je vektor názvů nových souborů stejně dlouhý, jako je počet vrstev rastru
tictoc::tic(); writeRaster(tavg,
                           str_glue("geodata/results/{names(tavg)}.tif"), # zde využíváme fuknci stringr::str_glue(), a využíváme tzv. glueing textových řetězců, kde jsou typické složené závorky s funkcemi uvnitř stavění textového řetězce
                           overwrite = T); tictoc::toc()

# někdy se vyplatí z objektů typu SpatRaster stavět objekt typu SpatRasterDataset
tavg_sds <- sds(tavg,
                tavg) # tady jsme uměle sestavili SpatRasterDataset o dvou prvcích ze stejného SpatRasteru

class(tavg_sds)

# při výběrech elementů tu opět máme cosi jako seznam
class(tavg_sds[[2]]) # jednotlivé elementy jsou opět typu SpatRaster

# funkce rast() nám v tomto přpadě natáhne původní SpatRasterDataset do objektu SpatRaster s větším počtem vrstev
nlyr(rast(tavg_sds))

# převeďme vícevrstvý rastr na bodovou vektorovou vrstvu
# body jsou centroidy původních buněk rastru, hodnoty jsou pak sloupce atributové tabulky
tavg_points <- as.points(tavg)

# i z takových objektů dokáže funkce rast() stavět rastry
tavg3 <- rast(tavg_points,
              type = "xyz")

tavg3

# funkce rast() dokonce umí odstraňovat hodnoty z rastru
# výsledkem je geometrická konstrukce připravena na naplňování novými hodnotami
tavg |> 
  rast()

# v průběhu lekce bylo zjištěno, že i na objekty třídy SpatVector lze aplikovat funkci glimpse()
tavg_points |> 
  glimpse()

# a jde to i se SpatRasterem
tavg |> 
  glimpse()


# Funkce terra::extract() - vysvětlení ------------------------------------

# terra odlišuje extrahování hodnot od zonálních statistik
# funkce terra::extract() se typicky používá na extrahování hodnot rastru do bodů linií či polygonů daných vektorovými geodaty
?terra::extract

# na druhou stranu se funkce terra::zonal() používá typicky pro dva rastry, jedním kategorickým udávajícím regiony (zóny) a druhým často se spojitou veličinou, ze kterého potřebujeme dostat statistiky pro zóny
?terra::zonal # pro aplikaci viz také bonusový skript 32


# Funkce app() a jí podobné -----------------------------------------------

# tyto funkce provádí agregace hodnot napříč vrstvami a vytváří opět rastr (klidně vícevrstvý)
# tyto funkce připomínají svými názvy názvy funkcí, které známe ze základního R
# tedy obdoba apply()
?app

# obdoba tapply(), kde je navíc argument index, jímž lze nastavit časové jednotky
?tapp

# obdoba lapply()
# tato funkce je vhodná pro objekty typu SpatRasterDataset, ale akceptuje i SpatRaster
?lapp

# protože tyto funkce lze chápat jako jakýsi for cyklus, který probíhá přes všechny buňky, lze do funkcí vkládat i dotazy na hodnoty vektoru
?any

?all

# funkce app() a jí podobné akceptují funkce implementované v C++
# ale lze vkládat i jiné funkce, a to včetně anonymních
# porovnejme dva postupy výpočtu průměrné roční teploty vzduchu z hlediska stráveného času
tictoc::tic(); tavg_annual <- app(tavg,
                                  fun = mean) |> 
  round(1); tictoc::toc()

# u anonymních funkcí si můžeme pomoci argumentem cores (ten nemá u funkcí implementovaných v C++ význam)
tictoc::tic(); tavg_annual <- app(tavg,
                                  fun = \(x) mean(x) |> 
                                    round(1),
                                  cores = 3); tictoc::toc()

# korektnější je ale počítat vážený průměr podle počtu dnů
# i tato funkce v balíčku terra existuje, stejně jako mean(), stdev() apod.
?weighted.mean

# nejprve určíme váhy jednotlivých měsíců pro naše období 1970-2000
vahy <- tibble(dt = seq(ymd(19710101),
                        ymd(20001231),
                        "day")) |> 
  count(month = month(dt))

vahy

# nyní počítejme pomocí vážených průměrů
tavg_annual_weighted <- weighted.mean(tavg,
                                      w = vahy$n) |> 
  round(1)

# ještě si upravíme názvy vrstev na lepší
names(tavg_annual_weighted) <- "tavg"

names(tavg_annual) <- "tavg"

# a porovnáme, např. tiskem do konzole
tavg_annual_weighted

tavg_annual


# Funkce global() ---------------------------------------------------------

# tato funkce je učena k výpočtům statistik napříč celými rastrovými vrstvami
?global

# tohle bude fungovat jako odhad pro celé území Česka, protože rastr je omezen jen na toto území
dem_avg <- global(dem1,
                  fun = mean,
                  na.rm = T) # musíme ale nastavit argument na.rm = T

dem_avg

# u teploty bychom napřed měli omezit výpočet jen na území Česka (funkcemi crop() a mask() - viz později)


# Funkce terra::extract() - aplikace --------------------------------------

# uložme si polygony krajů Česka do objektu kraje
kraje <- RCzechia::kraje()

# jsou crs krajů a rastru teploty identické?
identical(crs(kraje), crs(tavg)) # pošimněme si, že jsme aplikovali funkci crs() na vektorová geodata

# vypadá to, že tady nemusíme nic transformovat, ale jinak se doporučuje transformovat vektorová geodata na crs rastru, což dnešní verze terra umí dělat za nás

# demonstrujme funkci terra::extract() a její důležité argumenty
tavg_months_kraje <- extract(tavg, # na prvním míste rastr
                             kraje |> # na druhém místě vektor, kde si ještě můžeme vybrat sloupce
                               select(NAZ_CZNUTS3),
                             fun = mean, # u polygonů a linií musíme ještě specifikovat funkci, která bude agregovat hodnoty rastru
                             bind = T) |> # tímto argumentem připojíme extrahované rastrové hodnoty do atributové tabulky vektorové vrstvy
  st_as_sf() |> # protože vzniká SpatVector, převádíme na sf collection
  as_tibble() |> # a nakonec již jen kosmetické úpravy
  st_sf()

# prohlédneme výsledek
tavg_months_kraje

# ještě zbývá zaokrouhlit
tavg_months_kraje <- tavg_months_kraje |> 
  mutate(across(starts_with("month_"),
                \(x) round(x, 1)))

tavg_months_kraje

# dodejme, že pokud vyžadujeme přesnější výpočty pro polygony zohledňující podíl buněk, který do polygonu patří, nebo neplochojevnost buněk, je doporučována funkce exactextractr::exact_extract()


# Kreslení pomocí facet ---------------------------------------------------

# ukažme, že je možné i vektorová geodata převést na dlouhý formát
# hodí se to před kreslením, kde jsou zejm. facety velmi silným nástrojem
tavg_months_kraje_longer <- tavg_months_kraje |> 
  as_tibble() |> # pokud nebude fungovat funkce pivot_longer na objekty s geometrií, doporučuje se nejprve převést na tabulku (geometrie zůstává uchována)
  pivot_longer(cols = starts_with("month_"), # výběr narovnávaných sloupců 
               names_to = "mesic", # nastavujeme název nového sloupce s názvy
               values_to = "hodnota", # nastavujeme název nového sloupce s hodnotami
               names_prefix = "month_") |> # odstraníme prefix
  st_sf() # převedeme zpět na sf collection

tavg_months_kraje_longer

# kresmeme a předveďme sílu facet (nejprve ggplot2)
ggplot() + 
  geom_sf(data = tavg_months_kraje_longer,
          aes(fill = hodnota),
          col = "white") + # dnes velmi oblíbené, pokud jde o obrysy polygonů
  scale_fill_distiller(palette = "Reds", # vybíráme jinou paletu barev
                       direction = 1) + 
  theme_bw() + # vybíráme jiný podklad
  facet_wrap(~mesic, ncol = 3) + # nastavujeme facety se třemi sloupci
  labs(fill = "teplota\n[°C]")

# ukažme, jak si podobně počínat ve smyslu funkcí tmap
tm_shape(tavg_months_kraje_longer) + 
  tm_polygons(fill = "hodnota",
              fill.scale = tm_scale_continuous(values = "brewer.reds"),
              fill.legend = tm_legend(title = "teplota\n[°]",
                                      reverse = T)) + 
  tm_facets(by = "mesic", # zde je namísto tildy používán argument by
            ncol = 3)


# Funkce crop() a mask() --------------------------------------------------

# funkce crop() omezuje na bounding box vektorové vrstvy
tavg_cropped <- crop(tavg,
                     RCzechia::republika())

# nakresleme situaci pro červenec
# nejprve pro původní rastr
ggplot() + 
  geom_spatraster(data = tavg[[7]]) + 
  scale_fill_distiller(palette = "Reds",
                       direction = 1) + 
  geom_sf(data = RCzechia::republika(),
          fill = NA,
          col = "white")

# pak pro rastr po aplikaci crop()
ggplot() + 
  geom_spatraster(data = tavg_cropped[[7]]) + 
  scale_fill_distiller(palette = "Reds",
                       direction = 1) + 
  geom_sf(data = RCzechia::republika(),
          fill = NA,
          col = "white")

# nyní aplikujme funkci mask()
# doporučuje se nejprve aplikovat crop() pro omezení se na zájmové území (maskování je pak mnohem rychlejší)
tavg_cropped_masked <- mask(tavg_cropped,
                            RCzechia::republika())

# nyní máme již omezení provedeno jemněji, podle polygonu
ggplot() + 
  geom_spatraster(data = tavg_cropped_masked[[7]]) + 
  scale_fill_distiller(palette = "Reds",
                       direction = 1,
                       na.value = NA) # tohle je nutné specifikovat, jinak bychom měli nakreslený nechtěný šedivý rámeček

?mask

# všimněme si, že funkce crop() nabízí argument mask
# to se vyplatí, pokud maskujeme pomocí stejného vektorového objektu, jako máme u funkce crop(), což je dosti častý případ
?crop


# Interaktivní mapy pomocí funkcí balíčku mapview -------------------------

# autor balíčku mapedit je také autorem balíčku mapview
# podobně jako u interaktivního módu balíčku tmap, se zobrazí v okně Viewer náhled na data (ale máme zde více podkladových map, které lze i přidávat)
mapview::mapview(kraje)

# viz také videa autora těchto balíčků, např. https://www.youtube.com/watch?v=hUzVvGezwo8&t=18s


# Buffer ------------------------------------------------------------------

# preferovány jsou rovinné crs
# latlong je ve finále kostrbatý a ani záporný buffer není podporovaný
# přiřadíme si definitivně hranice Česka nějakému objektu
hranice <- RCzechia::republika() |> 
  st_transform(32633) # trasnformujeme na rovinný crs

# ukažme nejprve fungování bufferu na kladných číslech
hranice_buf <- st_buffer(hranice,
                         units::set_units(10, km)) # můžeme zaměstnávat i balíček units, abychom rovnou nastavovali km (můžeme, ale není třeba nastavovat uvozovnky kolem zkratek jednotek)

# ukažme na záporných číslech
hranice_minusbuf <- st_buffer(hranice,
                              units::set_units(-10, km))

# vykresleme
ggplot() + 
  geom_sf(data = hranice,
          fill = NA) + 
  geom_sf(data = hranice_buf,
          col = "red",
          fill = NA) + 
  geom_sf(data = hranice_minusbuf,
          col = "green",
          fill = NA)


# Převod rozsahu rastru na polygon ----------------------------------------

# tohle se může velmi dobře hodit při stahování dat z různých internetových služeb, které zájmové území vyžadují specifikovat
ramecek2 <- ext(tavg) |> 
  vect() |> # funkce převede extent na SpatVector
  st_as_sf() |> 
  st_set_crs(crs(tavg)) # musíme nastavit i crs

ggplot() + 
  geom_sf(data = ramecek2,
          fill = NA,
          col = "darkolivegreen", # rámeček je v jiném crs než zbytek, ale to ggplot2 zřejme nevadí
          lwd = 2) + 
  geom_sf(data = hranice,
          fill = NA) + 
  geom_sf(data = hranice_buf,
          col = "red",
          fill = NA) + 
  geom_sf(data = hranice_minusbuf,
          col = "green",
          fill = NA)


# Další užitečné funkce balíčku terra -------------------------------------

# přidá několik rastrových buněk okolo rastru
# může se hodit při kreslení
?terra::expand

# podobné jako sf::st_transform()
# akceptuje jak SpatVecror, tak SpatRaster
# v případě rastru jde o tzv. warping
# druhým argumentem může být klidně další rastr, ke kterému se s prvním rastrem snažíme přimknout (rozlišením, projekcí apod.)
?terra::project

# funkce pro tzv. resampling pomocí agregování
# specifikujeme tzv. faktor
?terra::aggregate

# funkce pro odvození rastru sklonitosti, orientace svahu apod.
# další parametry terénu (např. konvexitu, konkávitu) lze získat funkcemi balíčku spatialEco
?terra::terrain

# do družicových snímků typických pro více pásem, lze přidávat informaci o RGB kombinacích
?terra::RGB

# a pak i kreslit v pravých barvách
?terra::plotRGB

# na prostorové interpolace je dnes doporučována funkce terra::interpolate()
# akceptuje jak funkce balíčku fields(), tak funkce balíčku gstat()
?terra::interpolate
