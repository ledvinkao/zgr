
# Výpočet hustoty říční sítě ----------------------------------------------

# jedním z parametrů, který můžeme určit pro každý čtverec ze skriptu 17 je hustota říční sítě
# potřebujeme k tomu jenom nějakou vrstvu vodních toků

# načteme potřebné balíčky
xfun::pkg_attach("tidyverse",
                 "RCzechia", # balíček sf je načítán automaticky
                 "arcgislayers",
                 install = T)

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

