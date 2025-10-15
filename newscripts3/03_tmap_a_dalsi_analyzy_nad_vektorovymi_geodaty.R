
# Kreslení pomocí funkcí balíčku tmap a další analýzy ---------------------

# nejprve opět pár balíčků
xfun::pkg_attach2("tidyverse",
                  "RCzechia",
                  "arcgislayers",
                  "tmap",
                  "mapedit")

# a také znovu pár podkladových dat
wgmeta <- read_rds("metadata/wgmeta2024.rds")

hranice <- republika(res = "low")

toky <- arc_read("https://agrigis.cz/server/rest/services/ISVSVoda/osy_vodnich_linii/FeatureServer/0") |> 
  as_tibble() |> 
  st_sf()

# pro účely kreslení vytvoříme objekt
tm <- tm_shape(hranice) + # vždy, když chceme přidat novou vrstvu, musíme to indikovat funkcí tm_shape()
  tm_graticules(n.x = 5) + # přidání souřadnicové sítě; n.x = 5 mění na doporučený počet zobrazených poledníků
  tm_polygons(col = "red", # je rozdíl mezi tm_polygons() a tm_borders()
              fill = "lightblue",
              lwd = 1.5,
              lty = "dotted") + 
  tm_shape(wgmeta,
           is.main = T, # tato vrstva je teď hlavní (zaměříme na ni; hodí se u facet)
           crs = 4326) + 
  tm_dots(size = 0.2) + 
  tm_add_legend(size = 0.2, # ukázka manuálního přidání prvku do legendy
                type = "dots",
                labels = "stanice") + 
  tm_scalebar(position = c("BOTTOM", "LEFT")) + # přidá grafické měřítko
  tm_compass(position = c("top", "right")) # přidá směrovku

# takto objekt tm zobrazíme v panelu Plots
tm

# dále si lze hrát s pozicemi komponent; viz např. argumenty funkce tm_pos_in()
?tm_pos_in

# podobně jako je funkce ggsave(), existuje zde pro ukládání funkce tmap_save()


# Ořezávání toků podle hranic Jihočekého kraje ----------------------------

# demonstrujeme na krajích Česka
kraje <- kraje()

# je dobré se zaměřit jen na vybrané atributy, abychom ve výsledku neměli zbytečné sloupce
colnames(kraje)

jihocesky <- kraje |> 
  filter(NAZ_CZNUTS3 == "Jihočeský kraj")

ggplot() + 
  geom_sf(data = jihocesky,
          fill = NA,
          col = "red",
          linewidth = 1.5) # kromě lwd ggplot akceptuje také linewidth

# kvůli analýze potřebujeme transformovat crs
jihocesky_trans <- jihocesky |> 
  st_transform(5514)

# nejprve se doporučuje omezit se funkcí st_crop(), pak teprve aplikujeme st_intersection()
toky_crop <- toky |> 
  st_crop(jihocesky_trans)

# varování informuje o nenastavení vztahu mezi geometrií a atributy

toky_clip <- toky_crop |> 
  select(naz_tok)

toky_clip <- toky_crop |> 
  st_intersection(jihocesky_trans)

# porovnejme kreslením
ggplot() + 
  geom_sf(data = toky_crop,
          col = "darkblue") +
  geom_sf(data = jihocesky_trans,
          fill = NA,
          col = "red",
          lwd = 1.2)

ggplot() + 
  geom_sf(data = toky_clip,
          col = "darkblue") +
  geom_sf(data = jihocesky_trans,
          fill = NA,
          col = "red",
          lwd = 1.2)


# Statické versus dynamické mapy ------------------------------------------

# už jsme zjistili, že dynamické mapy umí balíček mapview
# ale umí je i tmap, když přepneme mód

tmap_mode("view")

tm_shape(jihocesky_trans) + 
  tm_borders(col = "red",
             lwd = 2)

# vrátíme zpátky na statické mapy
tmap_mode("plot")


# Prostorový join ---------------------------------------------------------

# chceme dostat atribut indikující pobočku do atributů metadat vodoměrných stanic (lze využít prostorový join, pokud máme polygony působnosti poboček)

# stažení polygonů s působností poboček ČHMÚ (odkaz získáme z celosvětového ArcGIS Online - jedná se o vrstvu, která he součástí mapové aplikace; odhadneme číslo vrstvy na konci)
pobocky <- arc_read("https://services1.arcgis.com/ZszVN9lBVA5x4VmX/arcgis/rest/services/rozvodnice5G_hranice_pobocek/FeatureServer/0") |> 
  as_tibble() |> 
  st_sf()

# jak polygony působnosti vypadají?
ggplot() + 
  geom_sf(data = pobocky)

# ať jsou atributy přehlednější
pobocky_sel <- pobocky |> 
  select(pobocka)

pobocky_sel

# aplikujeme funkci st_join
wgmeta_s_pob <- wgmeta |> 
  st_join(pobocky_sel)

# ověříme, zda se atribut skutečně přenesl
colnames(wgmeta_s_pob)

# některým stanicím polygon přiřazen nebyl
wgmeta_s_pob |> 
  select(dbc, pobocka) |> 
  filter(is.na(pobocka))


# Míry a jednotky ---------------------------------------------------------

# prozkoumejme dokumentaci např. k funkci st_area()
?st_area

# dnes lze počítat míry i na sféře a není třeba transformovat crs na plochojevný
pobocky_latlong <- pobocky |> 
  st_transform(4326)

pobocky_latlong <- pobocky_latlong |> 
  mutate(a = st_area(geometry) |> 
           units::set_units(km2)) # potřebujeme mít nainstalovaný balíček units; tímto lze převádět jednotky

pobocky_latlong

# porovnejme
pobocky_projected <- pobocky |> 
  st_transform(3035) |> # toto je EPSG kód plochojevného CRS používaného v Evropě
  mutate(a = st_area(geometry) |> 
           units::set_units(km2))

pobocky_projected


# Sjednocování polygonů ---------------------------------------------------

# zkusíme sjednotit polygony působnosti poboček tak, aby dohromady daly polygon území Česka
cesko_z_pobocek <- pobocky |> 
  st_union() |> 
  st_sfc()

# nastala chyba, zřejmě kvůli nevaliditě geometrií

# funkce st_make_valid() napravuje situaci
# zkontrolujeme kreslením, zda je vše v pořádku i po aplikaci této funkce
ggplot() + 
  geom_sf(data = pobocky |> 
            st_make_valid())

# funkci st_union() lze aplikovat na celou sf kolekci
cesko_z_pobocek <- pobocky |> 
  st_make_valid() |> 
  st_union()

ggplot() + 
  geom_sf(data = cesko_z_pobocek)

# lze ale sjednocovat i jinak
cesko_z_pobocek2 <- pobocky |> 
  st_make_valid() |> 
  summarize(geom = st_union(geometry))

ggplot() + 
  geom_sf(data = cesko_z_pobocek2)

# graficky jsou výsledky podobné, ale po tisku do konzole zjistíme, že objekty nejsou úplně totožné
cesko_z_pobocek

cesko_z_pobocek2


# Sjednocování geometrií po skupinách -------------------------------------

wgmeta_s_pob_multi <- wgmeta_s_pob |> 
  group_by(pobocka) |> 
  summarize(geom = st_union(geometry))

# vytvořila se i skupina pro chybějící hodnoty
# každopádně je výsledkem geometrie typu MULTIPOINT
wgmeta_s_pob_multi

# nakreslíme situaci pro pobočku Brno
ggplot() + 
  geom_sf(data = wgmeta_s_pob_multi |> 
            filter(pobocka == "BR"))

# demonstrujme význam funkce st_cast()
wgmeta_s_pob_multi |> 
  filter(pobocka == "BR") |> 
  st_cast("POINT")


# Manuální editace vektorových vrstev -------------------------------------

# zde bylo demonstrováno, jak lze interaktivne pomocí funkcí balíčku mapedit vektorové vrstvy editovat

# nejprve opět provedeme validaci geometrie
pobocky_valid <- pobocky |> 
  st_make_valid()

# tímto se sputila editace, smazali jsme polygony poboček BR a OS
pobocky_modif <- editFeatures(pobocky_valid)

# po stisknutí tlačítek Save a Done zůstal v objektu pobocky_modif zbytek polygonů
pobocky_modif
