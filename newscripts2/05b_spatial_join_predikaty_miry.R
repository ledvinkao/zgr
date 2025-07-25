
# Úloha s demonstrací prostorového joinu, výpočtu plochy atd. -------------

# nejprve balíčky (funkce balíčku units budeme volat pomocí dvojitých dvojteček)
xfun::pkg_attach2("tidyverse",
                  "sf",
                  "arcgislayers")

# načteme metadata vodoměrných stanic
# zdroj: https://opendata.chmi.cz/
stanice <- read_rds("metadata/wgmeta2024.rds")

# polygony působnosti poboček ČHMÚ
# zdroj: https://chmi.maps.arcgis.com/home/index.html
pobocky <- arc_read("https://services1.arcgis.com/ZszVN9lBVA5x4VmX/arcgis/rest/services/rozvodnice5G_hranice_pobocek/FeatureServer/0") |> 
  as_tibble() |> 
  st_sf()

# zajímá nás jen klíčový sloupec
pobocky <- pobocky |> 
  select(pobocka)

# za využití prostorového joinu přidáme k vrstvě stanic atributy z vrstvy s polygony poboček
stanice <- stanice |> 
  st_join(pobocky) |> 
  filter(!is.na(pobocka)) # zde se omezujeme jen na řádky, které reprezentují nějakou z poboček

# počítáme svoje plochy polygonů
pobocky <- pobocky |> 
  mutate(a = st_area(st_transform(geometry, 3035)) |> # pro výpočet vybíráme plochojevný crs
           units::set_units(m2) |> 
           units::set_units(km2) |> 
           round(units::set_units(2, km2))) # když budeme chtít zaokrouhlovat vektor s jednotkami, musí být i argument s počty desetinných míst s jednotkami

# prohlédneme výsledek
pobocky

# vypočítáme počty stanic pro každou pobočku
stanice2 <- stanice |> 
  st_drop_geometry() |> # teď už zde geometrii nepotřebujeme
  count(pobocka)

# pro jednoduchost si tvoříme i objekt s pobočkami bez geometrie
pobocky2 <- pobocky |> 
  st_drop_geometry()

# tabulky spojujeme na základě klíčového sloupce pobocka
pobocky2 <- pobocky2 |> 
  left_join(stanice2,
            join_by(pobocka))

# počítáme podíl počtu stanic na km2
pobocky2 <- pobocky2 |> 
  mutate(podil = n / units::drop_units(a)) # raději zahazujeme jednotky

# teď již připojujeme k polygonům, abychom mohli vykreslit mapu
pobocky <- pobocky |> 
  left_join(pobocky2 |> 
              select(pobocka, podil),
            join_by(pobocka))

# a kreslíme jednoduchou mapu (kartogram)
ggplot() + 
  geom_sf(data = pobocky,
          aes(fill = podil)) + 
  scale_fill_distiller(palette = "Blues",
                       direction = 1) + 
  labs(fill = "# stanic\nna km2")

# avšak není zohledněno období fungování stanic!
