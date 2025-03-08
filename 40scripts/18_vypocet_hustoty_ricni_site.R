
# Výpočet hustoty říční sítě ----------------------------------------------

# jedním z parametrů, který můžeme určit pro každý čtverec ze skriptu 17 je hustota říční sítě
# potřebujeme k tomu jenom nějakou vrstvu vodních toků

# načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "RCzechia", # balíček sf je načítán automaticky
                  "arcgislayers")

# vytvoříme grid čtvercových polygonů
ctverce_cesko <- republika() |> 
  st_transform(3035) |> 
  st_make_grid(cellsize = units::set_units(10, km)) |> 
  st_sf() |> 
  as_tibble() |> 
  st_sf() |> 
  st_set_geometry("geometry")

# načteme vrstvu vodních toků
toky <- arc_read("https://agrigis.cz/server/rest/services/ISVSVoda/osy_vodnich_linii/FeatureServer/0") |> 
  as_tibble() |> 
  st_sf()

# můžeme se omezit jen na čtvrece a jejich části nacházející se uvnitř území Česka
ctverce_cesko <- ctverce_cesko |> 
  st_intersection(republika() |> 
                    st_transform(3035))

# pro jistotu každému řádku v atributové tabulce přidělíme číslo
# a odstraníme zbytečný sloupec s názvem státu
ctverce_cesko <- ctverce_cesko |> 
  mutate(id = row_number()) |> 
  select(-NAZ_STAT)

# nyní potřebujeme řezat vodní toky podle čtvreců
# určitě je dobré transformovat, aby měly obě vrstvy stejný crs
toky_rezy <- toky |> 
  st_intersection(ctverce_cesko |> 
                    st_transform(5514))

# spočítejme sumy délek toků ve všech čtvrecích
toky_rezy_sumy <- toky_rezy |> 
  group_by(id) |> 
  summarize(suma = sum(st_length(geometry) |> 
                         units::set_units("km") |> 
                         round(3)))

# protože jsme čvterce ořízli hranicí Česka, nyní nebudou všechny mít 100 km2
# vypočítejme plochy polygonů
ctverce_cesko <- ctverce_cesko |> 
  mutate(plocha = st_area(geometry) |> 
           units::set_units("km2") |> 
           round(2))

# propojme tabulky na základě klíče id
# nyní se můžeme klidně zbavit jedné geometrie
# rovnou můžeme počítat i hustotu říční sítě
propojeno <- ctverce_cesko |> 
  left_join(toky_rezy_sumy |> 
              st_drop_geometry(),
            join_by(id)) |> 
  mutate(hustota = suma / plocha)

# vykresleme situaci
# při kreslení je někdy potřeba se jednotek zbavit
propojeno <- propojeno |> 
  mutate(hustota = units::drop_units(hustota))

ggplot() + 
  geom_sf(data = propojeno,
          aes(fill = log10(hustota))) + # pro zvýraznění rozdílů
  scale_fill_distiller(palette = "Blues",
                       direction = 1) +
  labs(fill = "river density \n(log10)")
