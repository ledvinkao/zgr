
# Vektorová geodata ze souborů a nová vektorová geodata -------------------

# nejprve k RDS souborům, totiž také k souboru, ve kterém máme uloženou bodovou vrstvu vodoměrných stanic vytvořenou z metadat ČHMÚ (viz https://opendata.chmi.cz/)
# RDS soubor je tzv. serializovaný objekt (zřejme výhradně R)
# pokud je objekt s vektorovými geodaty rozumně velký, lze jej ukládat i do RDS souboru (např. funkcemi saveRDS() nebo write_rds())
# naopak pro načítání RDS souborů zde máme funkce readRDS() - základní base-R funkce - nebo read_rds() - přichází s tidyverse
# důvodem, proč koexistují zdánlivě dvě takové funkce, je snaha tvůrců tidyverse mít funkce vektorizované (pro účely funkcionálního programování)

xfun::pkg_attach2("tidyverse",
                  "RCzechia", # s tímto přichází i sf, takže není nutné jej zde specifikovat
                  "sfheaders", # pomáhá tvořit nové sfg a sfc či dokonce sf
                  "arcgislayers", # pro stahování geodat z internetových služeb
                  "mapview", # pro kreslení dynamických map
                  "ggspatial") # do ggplot map přidává anotace s grafickým měřítkem a směrovkou

?readRDS

?read_rds

# podobně koexistují i následující funkce připomínající Excel funkci KDYŽ
?ifelse

?if_else

# k dotazu, jak sledovat aktuální změny u funkcí, které dnes mohou fungovat jinak než dříve
# odpověď: u tidyverse funkcí hodně pomáhá sledovat aktuální dokumentaci a třeba nás upozorní i badge jako lifecycle|superseded, lifecycle|deprecated nebo lifecycle|experimental
# viz např.:
?mutate_at # superseded; namísto toho používat pomocníky pick() nebo across()

?map # jedna z funkcí balíčku purrr (funkcionální programování), kde experimentálně funguje paralelizace pomocí funkce in_parallel() vyžadující nastavení mirai::daemons() a mirai::require_daemons()

# načtěme tedy soubor s metadaty vodoměrných stanic
wgmeta <- read_rds("metadata/wgmeta2024.rds") # alternativně lze využít namísto vypisování cesty k souboru funkci readClipboard(), kde je podmínkou mít cestu ve schránce

# zde máme již hotovou bodovou vrstvu, takže prohlížíme a zjišťujeme rozdíly od obyčejné tabulky typu tibble
wgmeta |> 
  colnames() # ať víme, které sloupce si případně vybrat funkcí select()

wgmeta |> 
  select(obj_id,
         dbc,
         station_name,
         stream_name)

# funkce select() to ale umí i efektivněji, pokud jsou chtěné sloupce všechny za sebou
wgmeta |> 
  select(obj_id:stream_name)

# zkoumejme dále, zde máme tříd mnohem více a od toho se odvíjí metody, které můžeme aplikovat
wgmeta |> 
  class()

# postupně můžeme označovat a do konzole pouštět následující řetízek, kde se vlastně vracíme k tomu samému objektu (ale nic nepřepisujeme)
wgmeta |> 
  as.data.frame() |> 
  st_sf() |> 
  as_tibble() |> 
  st_sf()


# Příklad zcela nové vektorové vrstvy -------------------------------------

# dejme tomu, že budeme chtít vytvořit bod reprezentující astronomický střed Evropy
# pro tyto účely existují funkce typu st_point()
?st_point

bod <- st_point(c(15, 50))

# zatím jde jen o geometrii (sfg) bez crs
bod |> 
  class()

# lze ale převádět na třídu sfc (sloupec s geometrií), kde je již možné přidávat i údaj o crs
bod <- bod |> 
  st_sfc() |> # alternativně šlo přidat crs i zde pomocí argumentu crs
  st_set_crs(4326) # pokud je o autoritu EPSG, stačí číselný kód, jinak uvádíme řetězce typu "AUTORITA:KÓD"

# mohu převést na sf collection a přejmenovat sloupec s geometrií
bod <- bod |> 
  st_sf() |> 
  st_set_geometry("geom") # obecně funkce vyhovující zápisu s pipy obsahují v názvu set_

bod |> 
  class()

# ještě převedu na tibble
bod <- bod |> 
  as_tibble() |> 
  st_sf()

bod |> 
  class()

# teď máme sf collection, kde jsou atributy coby tibble
# takže lze již přidávat další sloupce, např. funkcí mutate()
bod <- bod |> 
  mutate(nazev = "Kouřim",
         popis = "astronomický střed Česka")

# takto vypadají dotazy na crs, což lze využít i při dědění crs, když crs chceme nastavovat u jiného objektu
st_crs(bod)

# obecně se crs zadávají tzv. WKT řetězci, zkratkovitě pak řetězcem AUTORITA:KÓD
# rozhodně je zapotřebí zapomenout na tzv pro4stringy, které jsou již zastaralé!

# vykresleme výsledek dynamicky, kde pak lze měnit mapové podklady
# využijme k tomu např. základní funkci balíčku mapview
mapview(bod)

# vidíme, že jsme udělali chybu v atributu, takže napravujeme
bod <- bod |> 
  mutate(popis = "astronomický střed Evropy")

# zkusíme crs převést na jiný, např. na Křovákovo zobrazení s EPSG kódem 5514
bod_trans <- bod |> 
  st_transform(5514)

# opět kreslíme, ale s využitím pipu
bod_trans |> 
  mapview()

# geometrie sf collection je tzv. přilepená a nelze ji standardně odstraňovat
# proto ji odstraňujeme funkcí st_drop_geometry()
atributy <- bod |> 
  st_drop_geometry()

# vytvořme ještě jeden stejný bod, jen pod jiným názvem
bod2 <- st_point(c(15, 50)) |> 
  st_sfc() |> 
  st_sf() |> # toto je nutné, abychom pak mohli manipulovat z názvem geometrického sloupce
  st_set_crs(4326) |> # tohle může jít před st_sf() nebo rovnou jako argument crs do st_sfc()
  st_set_geometry("geom")

# je rozdíl, když připojíme atributy zprava nebo zleva?
bod2a <- bind_cols(bod2,
                  atributy)

bod2b <- bind_cols(atributy, 
                   bod2) |> 
  st_sf() # protože vzniká tabulka s geometrií, je možné aplikovat st_sf(), abychom dospěli k sf collection

bod2a # zde bychom mohli ještě převést na tibble

bod2b

# funkci st_sf() lze vynechávat, pokud jde jen o zisk sfc, tedy sloupce s geometrií
# nelze ale pak sloupci s geometrií přiřazovat název; když zkusíme st_set_geometry(), setkáme se s chybovou hláškou
bod3 <- st_point(c(15, 50)) |> 
  st_sfc() |> 
  st_set_crs(4326)

bod3

# existují i jiné způsoby zbavování se sloupce s geometrií
bod2b |> 
  as_tibble() |> 
  select(-geom)

bod2b |> 
  as_tibble() |> 
  mutate(geom = NULL) # zřejmě pro ty, kteří jsou v procesu tvorby nových proměnných a nechtějí se už zdržovat s funkcí select()

bod2b |> 
  as_tibble() |> 
  select(!geom) # znaménko minus lze zaměnit s vykřičníkem ve smyslu negace

# nad geometrií vektorových geodat rozlišujeme predikáty, míry a transformace
# typickým predikátem je funkce st_intersects(), která je nastavena jako původní i v jiných funkcích
?st_join

# u typů geometrie rozlišujeme hlavně velkou sedmičku; existuje funkce, kterou můžeme mezi typy "přepínat"
?st_cast


# Načtení shapefilu -------------------------------------------------------

# pro načítání geodat ze souborů, podporovaných knihovou GDAL, slouží funkce read_sf()
?read_sf # existuje také funkce st_read() s jinými přednastaveními

# načteme soubor s nádržemi (zde se předpokládá nejprve stažení ZIP souboru ze stránek DIBAVOD vÚV T.G.M. a také jeho rozbalení)
nadrze <- read_sf("geodata/dib_A05_Vodni_nadrze/A05_Vodni_nadrze.shp", # musíme se odkázat na shp
                  options = "ENCODING=windows-1250") # pomáhá nastavit správné kódování znaků

# protějškem funkce read_sf() je funkce write_sf()
# nejprve zapíšeme data se správným kódováním do dvou moderních typů souborů
# obecně by mělo jít ukládat do souborů, které podporuje knihovna GDAL
nadrze |> 
  write_sf("results/nadrze_se_spravnym_kodovanim.gpkg")

nadrze |> 
  write_sf("results/nadrze_se_spravnym_kodovanim.geojson")

# zkusme opět načíst např. z geojson
nadrze_z_json <- read_sf("results/nadrze_se_spravnym_kodovanim.geojson")

nadrze_z_json

# ještě vyzkoušejme geopackage
nadrze_z_gpkg <- read_sf("results/nadrze_se_spravnym_kodovanim.gpkg")

# zapišme také do shapefilu s lepším kódováním
# zde jsme si raději vytvořili ještě další podsložku
nadrze_z_gpkg |> 
  write_sf("results/nadrze_s_kodovanim/nadrze_se_spravnym_kodovanim.shp",
           layer_options = "ENCODING=UTF-8")

# funkcí st_layers() lze zkoumat obsah geopackage, ale i složky apod.
st_layers("results/nadrze_se_spravnym_kodovanim.gpkg")


# Tvorba bodové vrstvy ze sloupců se souřadnicemi -------------------------

# nejprve připravme podklad
wgmeta_tab <- wgmeta |> 
  bind_cols(st_coordinates(wgmeta)) |> # st_coordinates() tvoří matici souřadnic z geometrie
  st_drop_geometry() # zbyde jen tabulka, kde máme připojené souřadnice

# takto tvoříme novou bodovou vrstvu za využití souřadnic ve sloupcích tabulky
wgmeta_sf <- wgmeta_tab |> 
  st_as_sf(coords = c("X", "Y"), # na souřadnice se můžeme odkazovat i indexy sloupců s nimi
           crs = 32633,
           remove = F) # tímto si můžeme souřadnice v atributech nechat

# tohle může pomoci, pokud máme sloupce se souřadnicemi moc daleko a nevidíme na ně
wgmeta_sf |> 
  relocate(X:Y,
           .before = dbc)


# Načtení shapefilu ukrytého v ZIP souboru na internetu rovnou ------------

# nejprve musíme mít odkaz
url <- "http://www.dibavod.cz/data/download/dib_A05_Vodni_nadrze.zip"

# takto se můžeme podívat na obsah souboru
st_layers(str_glue("/vsizip/vsicurl/{url}")) # str_glue() lepí řetězce tak, že obsah složených závorek může být objekt s dalším řetězcem, ale i číslem apod.

# a načteme jen kýženou vrstvu, další atributy necháme na pokoji
nadrze_zip <- read_sf(str_glue("/vsizip/vsicurl/{url}"),
                      options = "ENCODING=WINDOWS-1250",
                      layer = "A05_Vodni_nadrze")

# přesvědčíme se, že je vše v pořádku
nadrze_zip

# transformujme pro následující demonstraci využití funkcionílnáho programování
nadrze_zip2 <- nadrze_zip |> 
  st_transform(32633)


# Uložení více vrstev do geopackage ---------------------------------------

# v rámci funkcionálního programování pracujeme se seznamy nebo s vektory (nebo jejich kombinacemi)
# vytvořme seznam s oběma připravenými sf collections
sez <- list(nadrze_zip,
            nadrze_zip2)

# walk2() akceptuje dva argumenty, přes jejichž prvky se probíhá
# obecně se funkce walk() používají pro vedlejší efekty, jako je ukládání do souborů
walk2(sez,
      c("nadrze_krovak", # zde tvoříme ještě vektor názvů vrstev
        "nadrze_utm"),
      \(x, y) write_sf(x, # tady začíná tzv. anonymní funkce (místo \ lze psát postaru slovo function)
                       "results/nadrze_s_transformacemi.gpkg", # zde je možné odkazovat se jen na jeden soubor
                       layer = y))

# prohlédneme výsledek
st_layers("results/nadrze_s_transformacemi.gpkg")

# co dělat, když potřebujeme průběh přes více objektů?
?pmap

?pwalk

# v těchto funkcích se ale seznamy a vektory ještě uzavírají do seznamu


# Tvorba polygonu z matice ------------------------------------------------

# zde využijeme funkci sfc_polygon() z balíčku sfheaders (viz také bonusový R skript 07)
mat <- matrix(c(16.35, 49.3,
                18.85, 49.3,
                18.85, 50.2,
                16.35, 50.2,
                16.35, 49.3),
              ncol = 2,
              byrow = T)

obdelnik <- sfc_polygon(mat)

# ještě přidáme crs
obdelnik <- obdelnik |> 
  st_set_crs(4326)

obdelnik

# situaci nakreslíme
hranice <- republika(res = "low") # funkce pochází z balíčku RCzechia

ggplot() + 
  geom_sf(data = hranice,
          fill = NA) + 
  geom_sf(data = obdelnik,
          fill = NA,
          col = "red",
          lwd = 2)

# přidáme vodoměrné stanice
ggplot() + 
  geom_sf(data = hranice,
          fill = NA) + 
  geom_sf(data = obdelnik,
          fill = NA,
          col = "red",
          lwd = 2) + 
  geom_sf(data = wgmeta,
          size = 0.4) + 
  theme_bw() # využíváme přednastavenou theme


# Demonstrace predikátů - zjednodušený postup -----------------------------

# při kreslení není nutné mít jednotný crs, ale při analýzách již ano
wgmeta_trans <- wgmeta |> 
  st_transform(st_crs(hranice))

# omezíme výběr stanic na vnitřek obdélníka
vnitrek <- wgmeta_trans[obdelnik,]

# a nyní opak; musíme si pomoci nastavením jiného predikátu
vnejsek <- wgmeta_trans[obdelnik, op = st_disjoint]

# nakreslíme
ggplot() + 
  geom_sf(data = hranice,
          fill = NA) + 
  geom_sf(data = obdelnik,
          fill = NA,
          col = "red",
          lwd = 2) + 
  geom_sf(data = vnitrek,
          size = 0.4) + 
  theme_bw()

ggplot() + 
  geom_sf(data = hranice,
          fill = NA) + 
  geom_sf(data = obdelnik,
          fill = NA,
          col = "red",
          lwd = 2) + 
  geom_sf(data = vnejsek,
          size = 0.4) + 
  theme_bw()


# Zisk vektorových geodat z internetu -------------------------------------

# zdrojový odkaz na osový model vodních toků jsme našli na https://voda.gov.cz/ 
toky <- arc_read("https://agrigis.cz/server/rest/services/ISVSVoda/osy_vodnich_linii/FeatureServer/0") |> 
  as_tibble() |> 
  st_sf()

# vytvoříme objekt pro uložení do souboru
# pro více nastavení (např. pomocí anonymních funkcí viz také bonusový R skript 38)
p1 <- ggplot() + 
  geom_sf(data = toky |> 
            filter(str_detect(naz_tok, "Labe")), # zde využíváme regulární výraz
          col = "darkblue") + 
  coord_sf(crs = 32633) + 
  annotation_scale() + # vychází z balíčku ggspatial
  annotation_north_arrow(location = c("tr"),
                         style = north_arrow_fancy_orienteering(),
                         which_north = "true")

ggsave("figs/obrazek_Labe.png",
       p1,
       dpi = 300,
       width = 21,
       height = 14.8,
       units = "cm",
       scale = 1.2)

# velkou silou ggplot grafů, a to i map, je možnost tvorby tzv. facet
# jaký je rozdíl mezi facet_wrap() a facet_grid()?
?facet_wrap

?facet_grid
