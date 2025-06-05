
# Rastrová data lze načítat i funkcemi balíčků RCzechia a geodata ---------

# tak pojďme načíst nejdůležitější balíček terra a další pomocníky
xfun::pkg_attach("tidyverse",
                 "terra",
                 "RCzechia", # s tímto balíčkem se automaticky načítá i balíček sf, jak ukazuje hláška v konzoli
                 "geodata")

# pokud si nevystačíme s defaultním nastavením balíčku terra, ladíme funkcí terraOptions()
# jde např. o nastavení cesty pro dočasné soubory, využívání paměti apod.
?terraOptions

# využijme např. klimatologická data pro demonstraci práce s vícevrstvým rastrovým souborem
# pro detaily o tom, co funkce stahuje a odkud, prohlédneme nápovědu
tavg <- worldclim_country(country = "CZE", # podle nápovědy lze Česko vybrat i jinak, ale raději volíme vybírání třímístným kódem
                          var = "tavg", # podle nápovědy k funkci si schválně vybíráme průměrnou teplotu vzduchu (dlouhodobou za jednotlivé měsíce za 31 let období 1970-2000)
                          path = "geodata") # jakmile ale máme dataset již v námi zvolené složce, stahování dat se již nekoná

# po načtení lze prohlížet hlavičku a maxima a minima hodnot v jednotlivých vrstvách
# ale lze se tázat na jednotlivé dimenze
tavg |> 
  dim() # dohromady

tavg |> 
  nlyr() # pouze na počet vrstev (layerů)

tavg |> 
  ncol() # na počet sloupců

tavg |> 
  nrow() # na počet řádků

# takto se ptáme na názvy vrstev
names(tavg)

# takto se ptáme na datum / datum a čas
# zde ale nemáme nastaveno nic, takže odpovědí je 12 x NA
time(tavg)


# Kreslení rastrových vrstev pomocí funkcí ggplot2 ------------------------

# doporučuje se načíst balíček tidyterra, který obsahuje skvělé funkce pro kreslení i barevné palety
library(tidyterra)

# a kreslíme
# přitom vybíráme jen vrstvu pro červenec
ggplot() + 
  geom_spatraster(data = tavg[[7]]) + # rastrová geodata se zde chovají podobně jako sezamy, a proto vrstvy vybíráme pomocí dvojitých hranatých závorek
  scale_fill_distiller(palette = "Reds", # pro teplotu se hodí třeba paleta různě intenzivní červené
                       direction = 1) + # vhodnější nastavit směr 1 oproti původnímu -1 (aby intenzivnější červená odpovídala větší teplotě)
  labs(fill = "°C",
       title = "Průměrná teplota vzduchu v červenci",
       subtitle = "(období 1970-2000)")


# Agregace napříč rastrovými vrstvami -------------------------------------

# základní je zde funkce app()
?app

# pokud chceme aplikovat nějaké funkce po částech vrstev, které spadají např. do kýženého časového intervalu (nebo obecně do skupin daných argumentem INDEX), aplikujeme funkci tapp()
?tapp

# v balíčku terra existuje i funkce lapp()
?lapp

# nebo sapp()

?sapp


# Zapisování rastrů do souborů --------------------------------------------

# zapisování pracně získaných výsledků je nesmírně důležité
# základem pro zapisování rastrových souborů je funkce writeRaster()
?writeRaster

# někdy můžeme zapisovat přímo po aplikaci nějaké terra funkce
# takové funkce mají argument filename a další potřebné argumenty pro nastavení ukládání souboru podobně jako writeRaster()
# vypočítejme dlouhodobou průměrnou teplotu vzduchu aplikací funkce mean napříč všemi měsíčními vrstvami a rovnou zapišme do GeoTIFF souboru výsledek 
tavg_annual <- app(x = tavg,
                   fun = mean, # můžeme a nemusíme použít uvozovky ohraničující název funkce; navíc takto spouštíme funkci implementovanou v C++, takže rychlost nepřekvapuje
                   filename = "geodata/tavg_annual.tif", # udáním přípony v názvu souboru dáváme najevo, jaký driver má být zvolen (opět využívána externí knihovna GDAL)
                   overwrite = T) # přepisování souborů nastavujeme, máme-li podezření, že již soubor se stejným názvem ve stejné složce existuje

# ještě chybí zaokrouhlení na jedno desetinné místo
# sice bychom zaokrouhlení mohli požadovat hned v předchozí funkci (např. definováním anonymní funkce), ale to by situaci zpomalilo
tavg_annual <- tavg_annual |> 
  round(1) |> 
  writeRaster("geodata/tavg_annual_rounded.tif",
              overwrite = T)

# v následujícím je zapotřebí mít nainstalované balíčky tictoc a beepr
# funkcemi balíčku tictoc měříme čas strávený od začátku do konce procesování
# funkce balíčku beepr dávají fanfárou na vědomí, že proces byl dokončen
tictoc::tic(); tavg_annual <- tavg_annual |> 
  round(1) |> 
  writeRaster("geodata/tavg_annual_rounded.tif",
              overwrite = T); tictoc:toc(); beepr::beep(3)


# Skládání objektů s rastrovými vrstvami ----------------------------------

# protože rastrové objekty třídy SpatRaster se chovají podobně jako seznamy, můžeme je také obdobně skládat (kombinovat) pomocí funkce c()
skladani <- c(tavg_annual,
              tavg_annual) # klidně můžeme přidat tentýž objekt (nebo jej napřed podrobit nějaké matematické operaci, jako je umocňování, násobení apod.)

# vůbec nevadí, když spojíme vrstvy měsíční teploty s roční teplotou
# jak nápověda funkce terra::c() říká, podmínkou je, aby kombinované vrstvy měly stejný rozsah a rozlišení
skladani2 <- c(tavg,
               tavg_annual)

# můžeme se přesvědčit, že skládání proběhlo podle očekávání
names(skladani2)

# takto můžeme nastavit nová jména s tzv. vodícími nulami v indexech měsíců
names(skladani2) <- c(str_c("mesic_", 
                            str_pad(1:12, # využívám zkrácený zápis posloupnosti s diferencí 1
                                    width = 2, 
                                    pad = "0")
                            ),
                      "rok")

# přesvědčme se, že názvy byly přenastaveny
names(skladani2)


# Ukládání rastrových geodat do NetCDF souborů ----------------------------

# tyto soubory jsou oblíbené mezi klimatology, kteří využívají jejich vlastnosti udržovat časové řady gridovaných veličin
# lze ale ukládat i další atributy (informace o uložené veličině, jejích jednotkách apod.)
# pro správné fungování writeCDF() potřebujeme mít nainstalovaný balíček ncdf4
writeCDF(skladani2,
         "geodata/mesice_a_rok.nc",
         varname = "tavg",
         longname = "average monthly and annual air temperature (°C)",
         unit = "°C")

# pro načítání těchto souborů postačí poměrně univerzální funkce rast()
zpetne_nacteni <- rast("geodata/mesice_a_rok.nc")

# zdá se, že jsme přišli o svoje názvy
zpetne_nacteni

# jak je na tom GeoTIFF?
writeRaster(skladani2,
            "geodata/mesice_a_rok.tif")

zpetne_nacteni2 <- rast("geodata/mesice_a_rok.tif")

zpetne_nacteni2

# připomeňme si, že zmíněné agregační funkce jako app() aplikují funkce na jednotlivé buňky přes vrstvy
# neslučujme tyto funkce s funkcí terra::aggregate(), která umožnuje snižovat rozlišení rastru podle parametru fact


# Digitální model reliéfu Česka a jeho kreslení ---------------------------

# pomocí funkce RCzechia::vyskopis() stáhneme jeden z nabízených digitálních modelů reliéfu (dem) Česka nabízených v R
dem <- vyskopis(format = "actual")

# kreslíme ve smyslu ggplot2
ggplot() + 
  geom_spatraster(data = extend(dem, 50)) + # funkcí extend() ještě raději přidáváme prázdné buňky okolo buněk s hodnotami (mapa nebude tak blízko mapového rámu)
  scale_fill_hypso_tint_c(palette = "wiki-schwarzwald-cont") + # tidyterra obsahuje mnohé palety vhodné pro kreslení výškopisu
  labs(fill = "m n. m.") + 
  ggspatial::annotation_scale()


# Základy kreslení pomocí funkcí balíčku tmap -----------------------------

# načteme balíček
library(tmap)

# kreslíme (podobně jako u ggplot vrstvíme operátorem +)
tm_shape(extend(dem, 50)) + # funkce tm_shape() nemá nic společného s shapefily!
  tm_graticules() + # přidáváme síť poledníků a rovnoběžek
  tm_raster() + # aplikujeme kreslení rastru
  tm_shape(republika()) + # přidáváme hranice Česka (stahujeme funkcí RCzechia::republika())
  tm_borders(col = "darkblue") + # hranice, ačkoliv polygon, lze tímto kreslit jenom jako čáru
  tm_scalebar() # přidáváme grafické měřítko

# funkce tmap_save() má podobný význam jako funkce ggsave() - slouží k ukládání vytvořených map
# když není specifikován objekt, ze kterého se má ukládat, funkce využívá poslední vykreslenou mapu
tmap_save(filename = "figures/pokus_s_tmap.tiff",
          dpi = 300,
          width = 29.7,
          height = 21,
          units = "cm")

# jelikož tmap verze >=4.0 je velmi nový koncept, chtělo by to prostudovat viněty na stránkách https://r-tmap.github.io/tmap/articles/; případně je připravována celá kniha: https://tmap.geocompx.org/

# zapomněli jsme také zmínit, že existuje i interaktivní vykreslování pomocí funkcí balíčku tmap (podobně jako tomu je u mapview) - stačí napřed přepnout na tmap_mode("view")
