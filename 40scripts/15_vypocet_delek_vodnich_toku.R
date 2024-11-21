
# Výpočet délek vodních toků ----------------------------------------------

# délka vodního toku je pro hydrology a vodohospodáře velmi důležitý parametr
# před výpočtem délky vodního toku (nebo jiného liniového prvku) je důležité mít vektorovou vrstvu v crs, které na určitém území zkresluje délky co nejméně
# na území Česka je pro tyto účely vhodné využití crs s kódem EPSG:5514 (viz https://epsg.io/5514)

# nejprve načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "RCzechia", # balíček sf je načítán automaticky
                  "arcgislayers")

# proveďme výpočet jen pro toky uvnitř Jihočeského kraje
jihocesky <- kraje() |> 
  filter(NAZ_CZNUTS3 == "Jihočeský kraj") |>
  st_transform(5514) # rovnou transformujeme crs

# načteme vodní toky
toky <- arc_read("https://agrigis.cz/server/rest/services/ISVSVoda/osy_vodnich_linii/FeatureServer/0") |> 
  as_tibble() |> 
  st_sf()

# toky ořízneme polygonem kraje
# abychom nebyli zmateni množstvím atributů, vybereme jen ty podstatné
toky_jihocesky <- toky |> 
  st_intersection(jihocesky) |> 
  select(idvt,
         naz_tok)

# vypočítáme délky a hned si je přidáme do tabulky jako nový sloupec
# délku vyjádříme v kilometrech
# ale rovnou zaokrouhlíme tak, abychom mohli určovat i délku v metrech
toky_jihocesky <- toky_jihocesky |> 
  mutate(delka = st_length(geometry) |> 
           units::set_units(km) |> 
           round(3))

# samozřejmě je potřeba si uvědomit, že délky odpovídají oříznutým liniím!