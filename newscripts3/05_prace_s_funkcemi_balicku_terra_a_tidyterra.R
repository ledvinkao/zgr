
# Základy práce s balíčkem terra ------------------------------------------

# na začátku práce opět načteme balíčky, které zřejmě budeme potřebovat
# konfliktů si nevšímáme, ale je zapotřebí dbát na pořadí načítání balíčků, aby se nám důležité funkce 'nezamaskovaly'
xfun::pkg_attach2("tidyverse", # již klasika
                  "RCzechia", # již víme, že sf se načítá automaticky s tímto
                  "arcgislayers", # pro stahování geodat z ArcGIS REST API
                  "terra", # budeme demonstrovat funkce balíčku terra
                  "geodata", # občas potřebujeme pro stažení geodat (rastrových i vektorových) z internetu
                  "tidyterra", # jelikož původní funkce balíčku terra nemusí být dobře uspůsobeny pro přístup tidyverse
                  "tmap", # rastrové vrstvy bude nakonec nejlepší kreslit funkcemi balíčku tmap
                  "cols4all") # pro barevné paltey, které využívají funkce balíčku tmap (nutné jen pro prohlížení seznamu palet; před kreslením není nutné balíček načítat)

# balíček terra je určen především pro práci s rastry (třída SpatRaster), ale má i svou třídu pro podporu vektorových geodata (SpatVector)
# protože rastrová geodata jsou tradičně velká, často namísto toho pracujeme s tzv. formálními třídou SpatRaster, která značí jen odkaz na soubor na disku (klidně i jen dočasný)


# Nastavení balíčku terra, kde atypicky pracujeme s odkazy na soubory -----

# existuje možnost si původní nastavení změnit
# viz nápovědu k funkci terraOptions()
?terraOptions

# vidíme zde různé možnosti pro práci pamětí, ale také třeba nastavení vlastní cesty k dočasným souborům

# funkce write_rds() funguje pro rozumně velká vektorová geodata, ale na 99 % ji nebudeme používat pro rastrová geodata
?write_rds()

# funkce write_rds() pochází z balíčku readr, který je součástí tidyvrese
# existuje ale i base-R funkce pro ukládání RDS souborů, které slouží k tzv. serializaci R objektu do souboru
?saveRDS


# Načítání rastrových geodat z internetu pomocí vestavěných funkcí --------

# načteme např. dem Česka
dem <- vyskopis(format = "actual", # měníme z původní hodnoty "rayshaded"
                cropped = F) # tímto dáváme najevo, že se nechceme omezovat jen na území Česka, ale zajímáme se i o jeho okolí, což je např. v hydrologii tipycké

# balíček terra má svoji funkci pro kreslení rastrů
plot(dem)

# jak vypadá hlavička takového rastrového objektu vytištěná do konzole?
dem

# pokud se chceme ptát detailněji na dimenze, využíváme následujících funkcí (podobně jako u tabulek)
ncol(dem)

nrow(dem)

nlyr(dem)

dim(dem)

# podobně, jako je funkce st_bbox() u balíčku sf, máme tady funkci ext() pro zjištění okrajových souřadnic rastru
# tento rámeček lze dokonce převádět na polygon a využívat ho dále (např. pro stahování dat ze zájmového území) - pište dotazy, pokud vás tohle zajímá
ext(dem)

# někdy se hodí ptát se na názvy jednotlivých vrstev; zde tedy máme jen vektor o jedné hodnotě
names(dem)

# výhodná je i práce s časovými atributy
# zde však zatím nemáme žádný takový atribut
time(dem)

# takto se nastavují nová jména vrstev
# délka vektoru napravo musí odpovídat počtu vrstev rastrového objektu
names(dem) <- "dem1"

# a můžeme se opět rovnou ptát na názvy a ověřovat, zda bylo přejmenování provedeno 
names(dem)

# takto lze nastavovat časový atribut
# zde k tomu využíváme funkci ymd() z balíčku lubridate, což je vlastně něco jako year-month-day
time(dem) <- ymd(20251016)

# prohlédneme opět hlavičku objektu v konzoli, kde již máme přejmenovanou vrstvu a i datum/čas
dem


# Odbočka k tvorbě vektorů s datumy ---------------------------------------

# fukce ymd() akceptuje celá čísla nebo textové řetězce
# pořadí komponent však musí odpovídat použité zkratce
ymd("2025-10-16") |> 
  class()

# v balíčku lubridate existuje i funkce make_date() nebo make_datetime(), které využívají numerických komponent
make_date(year = 2025,
          month = 10,
          day = 16)

# k tomu, abychom sestavili měsíční nebo roční datum (myšleno s měsíčním či ročním krokem), není třeba vyplňovat všechny komponenty
make_date(2025,
          10)

# protože funkcí format() si můžeme nastavit jiný formát datumu, můžeme toho využít i při tvorbě nových názvů rastrových vrstev s částmi, které lze využít k identifikaci datumu
names(dem) <- str_c("dem_",
                    format(time(dem[[1]]),
                           "%Y%m%d"))
# prohlédněme výsledek
dem


# Další funkce pro načítání rastrových geodat z internetu -----------------

# namísto dem, který poskytuje balíček RCzechia, můžeme využít dem, který poskytuje balíček geodata
# balíček geodata oficiálně doprovází balíček terra
# ke stažení dem (ovšem s horším rozlišením) zde existuje např. funkce elevation_30s()
# zde se můžeme zaměřit na různé země podle jejich třímístných kódů
dem2 <- elevation_30s(country = "CZE",
                      path = "geodata", # nastavujeme složku R projektu, kam se dem uloží (možná se vytvoří ještě nějaká podsložka - sledujte, co se děje se soubory v projektu)
                      mask = F) # opět se snažíme neomezovat se jen na území Česka

# pokud tento dem máme již stažený, nic se nestahuje, nýbrž se načte to, co již stažené je

# prohlédněme výsledek ve formě hlavičky
# jaké jsou rozdíly mezi dem a dem2?
dem2

# horizontální rozlišení dem2 je skutečně 30 úhlových vteřin
1 / 60 / 2

# prozkoumejme dem2 i jednoduchým kreslením
plot(dem2)

# balíček geodata ale nabízí i rastry klimatologických prvků
# takto získáme srážkové úhrny - dlouhodobé průměry sum za jednotlivé měsíce za období 1970-2000 (jak praví odkazy v nápovědě)
prec <- worldclim_country(country = "CZE",
                          var = "prec",
                          path = "geodata")


# Kreslení rastrů pomocí funkcí balíčku tmap ------------------------------

# přestože balíček terra nabízí kreslit rastry rovnou, využijeme univerzálnějšího kreslení funkcemi balíčku tmap
# vykresleme např. rastr červencových srážkových úhrnů

# raději ještě napřed opět stáhněme polygon s územím Česka
hranice <- republika(res = "low")

# a kreslíme
tm_shape(prec[[7]]) + # vrstvy vícevrstvého rastru vybíráme podobně jako prvky seznamu, tj. třeba dvojitými hranatými závorkami
  tm_graticules() + 
  tm_raster(col.scale = tm_scale_continuous(values = "blues"), # nastavujeme spojitou škálu sytosti modré
            col.legend = tm_legend(title = "Precipitation in July\n[mm]", # nastavujeme název legendy
                                   reverse = T)) + # nastavujeme opačný běh barvy, aby byl přirozeněji zespoda nahoru
  tm_shape(hranice) + 
  tm_borders(col = "red",
             lwd = 1.5)

# je vhodné prostudovat nápovědu k funkci tm_scale(), kde se dozvíme, jaké transformace pro jaké veličiny je možné využít
# jinak viz také kapitolu připravované knihy o tmap na https://tmap.geocompx.org/scales
# nebo také vinětu o měřítcích na https://r-tmap.github.io/tmap/articles/basics_scales.html


# Načítání rastrových geodat ze souboru -----------------------------------

# vůdčí postavení zde má funkce terra::rast(), která ale umí mnohem více (viz nápovědu)
?rast

# takto načteme již stažený soubor, který máme v našem projektu
dem_from_file <- rast("geodata/elevation/cze_elv.tif")

# zde navíc dlužím informaci, že není třeba každý soubor načítat zvlášť, pokud se jedná o soubory se stejnými geometrickými vlastnostmi (extent, resolution, crs)
# totiž, pokud funkci rast() nabídneme vektor cest k souborům se stejnou geometrií, dojde k načtení všech souborů najednou


# Konverze rastru na tabulku ----------------------------------------------

# obecně lze s rastry provádět i converze do tabulek (nebo do bodů reprezentujících centroidy buněk - tady viz funkci as.points())
dem_df <- dem_from_file |> 
  as.data.frame(cell = T, # když cheme v tabulce mít identifikátory buňek (nemusí jít vždy od čísla 1, záleží na maskování)
                xy = T) # když chceme mít v tabulce souřadnice centroidů buněk 

# a, jak známo, tabulky třídy data.frame lze převádět na třídu tibble
dem_tibble <- dem_df |> 
  as_tibble()

dem_tibble

# při konverzi na tabulku nemusí jít jen o rastr s jednou vrstvou
# zkusme takový převod pro srážky
prec_tibble <- prec |> 
  as.data.frame(cell = T,
                xy = T) |> 
  as_tibble()

prec_tibble


# Souřadnicový referenční systém ------------------------------------------

# funkce terra::crs() může být využita k více účelům
# opět by se měl při tisku do konzole vypisovat WKT řetězec, ale zde je původní tisk dosti nepřehledný
# k přehlednosti dopomůže např. funkce cat()
crs(prec) |> 
  cat()

# nebo také funkce stringr::str_view()
crs(prec) |> 
  str_view()

# funkci crs() můžeme využít i tehdy, pokud budeme chtít crs nějakého rastru dědit
# transformaci crs u rastrů provádíme jen v krajních případech, protože je v naprosté většině případů ztátová, pokud jde o původní hodnoty rastru
# jinak viz funkci project() pro tzv. warping


# Zapisování rastrového objektu do souboru --------------------------------

# předpokládejme, že máme v našem R projektu složku results
# pro zápis rastrového objektu do souboru (s příponou, kterou podporuje knihovna GDAL) zde máme funkci writeRaster()
writeRaster(prec,
            "results/precipitation/prec_1970-2020_01-12.tif", # asi nejčastěji ukládáme do GeoTIFF souborů
            overwrite = T) # tento argument zajistí přepsání již existujících souborů

# demonstrujme důležitou vlastnost funkce writeRaster(), a sice, že pokud se počet vrstev shoduje s počtem cest daných ve textovém vektoru, dojde k uložení vrstev do separátních souborů
# vytvořme nejprve vektor cest pro uložení souborů
vek <- str_c("prec_1970-2020_",
             1:12)

vek <- str_c("results/precipitation/",
             vek,
             ".tif")

vek

vek |> 
  class()

# alternativně si lze ulehčit život pomocí funkce str_glue()
vek <- str_c("prec_1970-2020_",
             1:12)

vek <- str_glue("results/precipitation/{vek}.tif")

vek

vek |> 
  class()

# zapišme tedy nyní každou vrstvu zvlášť
writeRaster(prec,
            vek,
            overwrite = T)

# pokud má někdo raději funkcionální programování, lze namísto toho pro ukládání do separátních souborů, využít i funkci walk() či její varianty
tab <- tibble(years = 2024:2025,
              files = list(prec, prec)) # uměle tvoříme seznam se dvěma stejnými rastry

# jaká tabulka nám vlastně vznikla?
tab

# výsledek zde nebude totožný jako u právě ukázaného trhání vrstev pomocí pouhé funkce writeRaster()
# důvodem je fakt, že teď funkcionalitu demonstrujeme jen pro dva rastrové objekty
walk2(tab$files,
      tab$years,
      \(x, y) writeRaster(x,
                          str_c("results/precipitation/prec_",
                                y,
                                ".tif"),
                          overwrite = T))

# pokud budeme chtít docílit stejného výsledku jako u samotné funkce writeRaster(), lze si napřed rastrový objekt rozdělit na seznam s prvky reprezentujícími jednotlivé vrstvy - např. funkcí terra::as.list()
# tento způsob může být někdy rychlejší, a to zejm. tehdy, nakombinujeme-li ho s anonymní funkcí uzavřenou ve funkci in_parallel() - viz její nápovědu

# pokud budeme chtít ukládat do NetCDF souborů, oblíbených např. v klimatologii, pak je zde funkce writeCDF()
# aby funkce pracovala, jak má, musíme mít nainstalovaný balíček ncdf4
?writeCDF

time(prec) <- seq(ym(202401),
                  ym(202412),
                  "month")

# zde máme možnost nastavovat další atributy, které se týkají především určení jednotek
writeCDF(prec,
         filename = "results/precipitation/prec2_2024.nc",
         varname = "prec",
         longname = "monthly precipitation totals in mm",
         unit = "mm",
         overwrite = T)

# pro zpětné načení souboru je určena opět funkce rast()
prec_from_file <- rast("results/precipitation/prec2_2024.nc")

# vidíme, že se názvy vrstvev se jaksi přenastavily
prec_from_file


# Další vlastnosti funkce rast() ------------------------------------------

# mějme objekt prec_tibble, který jsme si připravili dříve
prec_tibble

# demonstrujme, jak z tabulky se souřadnicemi a dalšími hodnotami vytvořit nový rastr (klidně s více vrstvami)
prec_from_tibble <- rast(prec_tibble[, -1], # odstraňujeme identifikátor buňky
                         type = "xyz", # přepínáme
                         crs = "EPSG:4326") # rovnou lze přiřadit i crs; zde tedy musí být textový řetězec ve formě AUTORITA:KÓD

prec_from_tibble |> 
  plot() # když klasické funkci plot() nespecifikujeme, kterou vrstvu chceme kreslit, vykreslí se všechny

# podobně jako do tabulky lze rastr převádět na body, tedy centroidy buněk
prec_points <- prec |> 
  as.points()

# výsledkem je objekt třídy SpatVector (zde formální)
prec_points |> 
  class()

# ten lze převést na sf collection
prec_points_sf <- prec_points |> 
  st_as_sf()

# kreslení nám moc nepomůže
# uvidíme jen mračno neroznatelných bodů
ggplot() + 
  geom_sf(data = prec_points_sf)

# při převodu na tibble se geometrický sloupec jaksi schová do jakéhosi seznamového sloupce
prec_points_sf <- prec_points_sf |> 
  as_tibble()

# pokud ten je nalezen funkcí st_sf(), dostaneme opět sf collection
prec_points_sf <- prec_points_sf |> 
  st_sf()

prec_points_sf

# pro převod do třídy SpatVector máme v balíčku terra funkci vect()
?vect

# rast() také umí z takového pravidelného mračna bodů dostat zpátky SpatRaster
?rast

prec_points_sf_rast <- prec_points_sf |> 
  vect() |> 
  rast(type = "xyz")

# crs je pak převzatý, jak se můžeme přesvědčit
prec_points_sf_rast


# Matematické operace nad rastry ------------------------------------------

# můžeme např. počítat sumy srážek přes všechny buňky
# hodnoty každé buňky jsou uvažovány jako vektor
prec_year <- sum(prec)

# takto vzniká jen jedna výsledná vrstva
prec_year

# u teplot je korektní namísto obyčejného průměru použít vážený průměr
# taková funkce existuje i v balíčku terra
?weighted.mean

# nejprve ale potřebujeme získat váhy, kterými jsou dlouhodobé délky měsíců ve dnech
datumy <- tibble(date = seq(ymd(19700101),
                            ymd(20001201),
                            "day")) |> 
  mutate(month = month(date))

vahy <- datumy |> 
  count(month)

vahy

# načtěme rastrová geodata s dlouhodobou teplotou vzduchu (pro každý měsíc)
tavg <- worldclim_country(country = "CZE",
                          path = "geodata",
                          var = "tavg")

# aplikujme vážený průměr s nastavením správných vah
tavg_year <- weighted.mean(tavg,
                           w = vahy$n) |> 
  round(1) # rovnou lze aplikovat i funkci round() pro zaokrouhlení

# zobrazme výsledek ve škále červených barev
tm_shape(tavg_year) + 
  tm_raster(col.scale = tm_scale_continuous(values = "reds"),
            col.legend = tm_legend(title = "air temperature\n 1970-2000 [°C]",
                                   reverse = T))


# Funkce app(), tapp() a jejich příbuzné ----------------------------------

# při aplikaci složitějších funkcí, kde jsou hodnoty buněk napříč vrtsvami uvažovány jako vektory, mají svůj význam funkce terra::app(), terra::tapp() aj.

# funkce app() je obdobou base-R funkce apply()
?app

# funkce tapp() je obdobou base-R funkce tapply()
# tato funkce má speciální argument index, který umožňuje agregovat hodnoty buněk podle času do měsíců, rokoměsíců apod.
?tapp


# Funkce extract() --------------------------------------------------------

# tato funkce extrahuje hodnoty buněk rastru podle bodů, linií či polygonů, reprezentovaných vektorovými geodaty, a příp. je i agreguje (u bodů nemá moc smysl, ale třeba se hodí i hodnoty z okolních buněk)
?extract

# nejprve demonstrujme s bodou vektorovou vrstvou
wgmeta <- read_rds("metadata/wgmeta2024.rds")

# ukažme, že není nutné provádět extrakci s každou vrstvou zvlášť
# naopak si ještě přiděláme práci tím, že si spojíme dva různé klimatologické prvky
# ke spojování dvou rastrových objektů se stejnými geometrickými vlastnostmi zde slouží funkce c()
climate <- c(tavg,
             prec)

# nejprve ukažme, jak extrahovat do tabulky
# varování vlastně informuje, že dnešní verze balíčku terra si dokáží poradit se situacemi, kdy zapomínáme transformovat, abychom měli stejný crs
extrahovani1 <- extract(climate,
                        wgmeta,
                        cells = T,
                        xy = T)

extrahovani1 <- extrahovani1 |> 
  as_tibble()

# prohlédneme
extrahovani1

colnames(extrahovani1)

extrahovani1 |> 
  select(c(ID, # ID zde označuje pořadí řádku v původní vektorové vrstvě (sf collection)
           cell:y))

# existuje možnost dostat extrahované hodnoty přímo do vektorové vrstvy jako další atributy
# k tomu slouží argument bind = T
extrahovani2 <- extract(climate,
                        wgmeta,
                        bind = T) |> 
  st_as_sf() |> # výsledkem je SpatVector, tak jej konvertujeme na sf collection
  as_tibble() |> # protože zároveň požadujeme objekt třídy tibble, aplikujeme ještě tyto poslední dvě funkce
  st_sf()

# zajímavostí je, že transformace crs u vektorových geodat proběhla jen jaksi vnitřně a byl vrácen opět původní crs
extrahovani2

# upravme výsledné atributy
extrahovani2b <- extrahovani2 |> 
  select(c(dbc,
           matches("tavg|prec"))) # pomocí regulárních výrazů vybíráme jen sloupce, jejich názvy obsahují buď 'tavg', nebo 'prec'

# demonstrujme význam pivotingu
extrahovani2b <- extrahovani2b |> 
  as_tibble() |> # kvůli geometrii je vhodné nejprve sf collection převést na tibble
  pivot_longer(cols = -c(dbc, geometry)) # negujeme sloupce, které nechceme natahovat do dlouhého formátu

# z původního sloupce 'name' tvoříme dva nové sloupce, které budou značit jak měsíc, tak proměnnou
extrahovani2b <- extrahovani2b |> 
  mutate(month = str_split_i(name,
                             pattern = "_",
                             5),
         variable = str_split_i(name,
                                pattern = "_",
                                4))

# opět si pomůžeme tím, že geometrie v tabulce ukrytá je, a aplikujeme rovnou funkci st_sf() abychom opět získali sf collection
extrahovani2b <- extrahovani2b |> 
  st_sf()

extrahovani2b


# Kreslení funkcemi tmap a facety -----------------------------------------

# nyní máme připravenou tabulku (resp. sf collection) tak, že můžeme využít mapové facety
tm_shape(extrahovani2b) + 
  tm_symbols(shape = 24, # vybíráme symbol, který lze vyplňovat
             size = 0.4,
             fill = "value") + # zde vyplňujeme pomocí proměnné, takže barva výplně není statická (tady necháváme barvy vybrat automaticky)
  tm_facets_wrap(by = "variable")

# asi by to chtělo ještě zdůraznit jednotlivé měsíce
# proto využijeme funkci tm_facets_grid(), kde jsou facety rozděleny podle dvou proměnných (neuvažujeme-li různé stránky, tj. argument pages)
tm_shape(extrahovani2b |> 
           mutate(month = fct(month, # funkce fct() pochází z balíčku forcats, který je součástí tidyverse
                              levels = as.character(1:12)))) + # tohle provádíme proto, že chceme správné řazení měsíců
  tm_symbols(shape = 24,
             size = 0.4,
             fill = "value",
             fill.scale = tm_scale_continuous(values = "brewer.reds")) + # paleta vybraná z balíčku cols4all
  tm_facets_grid(rows = "variable",
                 columns = "month")

# nakonec by to chtělo pohrát si ještě s legendou, abychom neměli pro srážky a teplotu stejná měřítka barev

# extrahování hodnot rastru do polygonů proveďme např. pro polygony představující působnosti poboček ČHMÚ (z hlediska režimové hydrologie)
# online zdroj těchto polygonů jsme diskutovali během prvního dne
pobocky <- arc_read("https://services1.arcgis.com/ZszVN9lBVA5x4VmX/arcgis/rest/services/rozvodnice5G_hranice_pobocek/FeatureServer/0") |> 
  as_tibble() |> 
  st_sf()

# raději provedeme validaci geometrie
pobocky <- pobocky |> 
  st_make_valid()

# extrahujme hodnoty nadmořské výšky a proveďme jejich agregaci funkcí mean()
extrahovani_dem <- extract(dem,
                           pobocky,
                           fun = mean,
                           bind = T) |> # rovnou extrahované a agregované hodnoty přidáváme jako atributy do tabulky polygonů
  st_as_sf() |> 
  as_tibble() |> 
  st_sf()

# prohlédneme, naše nové sloupce (fields) máme až na konci tabulky (před geometrií)
extrahovani_dem

# funkcí slice_max() vybereme řádku, kde se nachází maximum podle nějakého sloupce
extrahovani_dem |> 
  slice_max(dem_20251016)

# slice_min() zajistí opak
extrahovani_dem |> 
  slice_min(dem_20251016)


# V R existuje rozdíl mezi extrahováním a zonálními statistikami ----------

# extract() je ideální, když máme zdrojový rastr a jednotky, pro které chceme extrahovat, jsou reprezentovány vektorovými geodaty
?extract

# funkce zonal() je naopak určena pro výpočty agregovaných hodnot získaných ze zdrojového rastru pro zóny dané druhým, kategorickým rastrem
# existují i funkce pro tvorbu kategorického rastru (viz také bonusové R skripty 30 a 32)
?zonal


# Pomocné funkce balíčku tidyterra ----------------------------------------

# funkce tidyterra::filter() dopomáhá zaměřit se jen na buňky rastru (ve všech vrstvách rastru), kde je splněna nějaká podmínka
# zjistěme si přesný název červencové vrstvy objektu tavg
names(tavg)[[7]]

# filtrujme na buňky rastru za využití názvu této vrstvy a nějaké hodnoty teploty
tavg_filtered <- tavg |> 
  filter(CZE_wc2.1_30s_tavg_7 > 20)

# kresleme výslednou situaci nejprve klasicky, zde pro červen
plot(tavg_filtered[[6]])

# nyní kresleme např. pomocí ggplot funkcí, zde pro červenec
ggplot() + 
  geom_spatraster(data = tavg_filtered[[7]]) + # toto je speciální funkce pro kreslení rastrů, ketrá pochází z balíčku tidyterra
  scale_fill_distiller(palette = "Reds", # nakonec si můžeme hrát s měřítky barev (třeba pomocí funkce scale_fill_distiller())
                       direction = 1, # takto se při kreslení ve smyslu ggplot mění směr palety barev
                       na.value = NA) + # tohle musíme zadat, pokud nechceme kreslit i chybějící hodnoty vzniklé maskováním (tmavě šedý rámeček)
  labs(fill = "tavg [°C]") # pro změnu názvu legendy

# tidyterra přichází i s vlastními paletami barev
# ukažme si to na příkladu nadmořských výšek
ggplot() + 
  geom_spatraster(data = dem) + 
  scale_fill_hypso_tint_c(palette = "wiki-schwarzwald-cont") + 
  labs(fill = "Elevation\n[m a.s.l.]")

# poznamenejme, že ukázky barevných palet jsou uvedeny na stránkách balíčku tidyterra
# viz https://dieghernan.github.io/tidyterra/articles/palettes.html


# Tmap a palety barev pro rastry ------------------------------------------

# funkce tmap namísto toho využívají barevných palet z balíčku cols4all
# takto si např. vyhledáme všechny palety pro spojité veličiny, které v názvu obsahují slovo 'terrain'
c4a_palettes(type = "seq") |> 
  as_tibble() |> 
  filter(str_detect(value, "terrain"))

# lze samozřejmě hledat i takto
c4a_palettes(type = "seq") |> 
  str_subset("terrain")

# za využití této znalosti kreslíme ve smyslu tmap
tm_shape(dem) + 
  tm_raster(col.scale = tm_scale_continuous(values = "matplotlib.terrain"),
            col.legend = tm_legend(reverse = T,
                                   title = "elevation\n[m a.s.l.]"))


# Odbočka k interaktivním mapám s vlastními podklady ----------------------

# některé funkce balíčku tmap fungují jen v interaktivním módu (tj. po přepnutí tmap_mode("view))
# funkce tm_tiles() umožňuje natáhnout další podkladové mapy prostřednictvím odkazů na WMS služby
# jde to i s mapy.com, ty si ale sledují čerpání kreditů placeného účtu
?tm_tiles


# Další analýzy terénu ----------------------------------------------------

# rastr sklonitosti terénu lze z dem získat funkcí terra::terrain()
# není třeba nic dalšího nastavovat, abychom tento rastr dostali
sklon <- terrain(dem)

plot(sklon)

# pro rastr orientace svahu však již musíme přepnout argument v na 'aspect'
orientace <- terrain(dem,
                     v = "aspect")

plot(orientace)


# Krátce k DPZ aplikacím --------------------------------------------------

# někdy si soubor můžeme nahrát přímo z adresářů R balíčků
# to je i následující případ, kdy za využití funkce system.file() odkazujeme funkci rast() na soubor, který přichází s balíčkem stars
# abychom se k souboru dostali, musí být balíček stars nainstalovaný
olinda <- rast(system.file("tif/L7_ETMs.tif", package = "stars"))

# tvorba RGB kompozitu pomocí funkce terra::RGB()
RGB(olinda) <- c(3, 2, 1) # máme po ruce snímek z Landsat 7, takže pásma nastavujeme takto (jinak je to specifické)

# terra obsahuje funkci pro kreslení RGB kompozitů
plotRGB(olinda)

# můžeme se ptát, zda již RGB kompozit máme přiřazený
has.RGB(olinda)

# typické je u družicových snímků sestavovat rastrové vrstvy různých spektrálních indexů
# načtěme si L7 snímek ještě jednou
olinda2 <- rast(system.file("tif/L7_ETMs.tif", package = "stars"))

# takto můžeme sestavit vrstvu NDVI indexu
# dvojitými hranatými závorkami se odkazujeme na příslušné vrstvy (pásma/kanály) snímku (opět specifické pro různé přístroje)
ndvi <- (olinda[[4]] - olinda[[3]]) / (olinda[[4]] + olinda[[3]])

plot(ndvi)

# za využití příkladu uvedeného na https://rspatial.org/rs/2-exploration.html kreslíme zájmové územý v nepravých barvách
landsatFCC <- c(olinda[[5]], olinda[[4]], olinda[[3]])

plotRGB(landsatFCC, stretch = "lin")


# Cropping a maskování rastru ---------------------------------------------

# zatím jsem vždy požadovali, aby se nám stahovaly rastry nemaskované
# někdy se však hodí omezit se jen na území dané polygonem či jiným objektem u něhož lze uvažovat nějaký (obdélníkový) rozsah
# demonstrujme s polygonem území Česka

# nejprve funkce terra::crop()
# funguje pro všechny vrstvy rastru najednou
tavg_cropped <- tavg |> 
  crop(hranice)

# poté funke terra::mask()
# funguje pro všechny vrstvy rastru najednou
tavg_masked <- tavg_cropped |> 
  mask(hranice)

# vykresleme teplotu pro červenec a zkusme si vyměňovat objekty tavg_masked a tavg_cropped
ggplot() + 
  geom_spatraster(data = tavg_masked[[7]]) + 
  scale_fill_distiller(palette = "Reds",
                       na.value = NA,
                       direction = 1)

ggplot() + 
  geom_spatraster(data = tavg_cropped[[7]]) + 
  scale_fill_distiller(palette = "Reds",
                       na.value = NA,
                       direction = 1)

# prostudujte také nápovědu k funkci crop() a speciálně si povšimněte možnosti přenastavení argumentu mask
# často totiž ve funkcích crop() a mask() aplikujeme jeden a tentýž polygon, takže u funkce crop() existuje zkratka jak se ke kýženému zamaskovanému rastru dostat

# poznamenejme, že funkce terra::extend() naopak zajišťuje zvětšení rozsahu (s funkcí crop() se toto hodí, pokud se chceme s různými soubory s rastrovými geodaty o různém rozsahu dostat na společný rozsah)

# funkce balíčku tmap nám pohodlně umožňují paletu barev podle hodnot transformovat
tm_shape(tavg_masked[[7]]) + 
  tm_raster(col.scale = tm_scale_continuous_sqrt(values = "-reds")) # znaménkem - uvnitř řetězce s názvem palety můžeme paletu obrátit
