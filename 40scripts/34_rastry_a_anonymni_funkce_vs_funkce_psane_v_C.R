
# Rastry a anonymní R funkce vs. funkce psané v C++ -----------------------

# když aplikujeme funkci na rastr, je třeba rozlišovat mezi funkcí psanou v C++ a R funkcí
# anonymní funkce předpokládájí aplikace R funkce a také uvažují jinou strategii s rastry (mají např. tendenci vše zpracovávat v RAM)
# R funkce jsou zpravidla pomalejší, jak můžeme demonstrovat měřením času

# načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "RCzechia", # balíček sf je načten automaticky
                  "terra",
                  "geodata")

# porovnáme různé strategie na výpočtu střední nadmořské výšky v krajích
dem <- elevation_30s(country = "CZE",
                     path = "geodata",
                     mask = F)

kraje <- kraje() |> 
  as_tibble() |> 
  st_sf()

# aplikujme anonymní funkci
tictoc::tic(); kraje_a <- extract(dem,
                                  kraje,
                                  fun = \(x) mean(x) |> 
                                    round(1),
                                  bind = T) |> 
  st_as_sf() |> 
  as_tibble() |> 
  st_sf(); tictoc::toc()

# nyní srovnejme s funkcí implementovanou v C++
tictoc::tic(); kraje_b <- extract(dem,
                                  kraje,
                                  fun = mean,
                                  bind = T) |> 
  st_as_sf() |> 
  as_tibble() |> 
  st_sf() |> 
  mutate(CZE_elv = round(CZE_elv, 1)); tictoc::toc()

# rozdíly se zamozřejmě zvětšují se zvetšujícím se množstvím dat a někdy už vůbec nelze aplikovat postup s anonymní funkcí kvůli limtům RAM
