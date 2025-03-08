
# Vektorové gridy ---------------------------------------------------------

# někdy se vyplatí vytvořit si vlastní pravidelnou síť polygonů pokrývajících nějaké území
# chceme tím např. zkoumat prostorovou variabilitu nějakého jevu
# k tvorbě takových vektorových gridů slouží např. funkce st_make_grid() z balíčku sf

# nejprve načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "RCzechia") # balíček sf se načítá automaticky

# chceme-li si např. území Česka pokrýt pravidelnou sítí čtverců o ploše 100 km2, lze postupovat následovně
ctverce_cesko <- republika() |> 
  st_transform(3035) |> 
  st_make_grid(cellsize = units::set_units(10, "km"))

# nakreslíme situaci
ggplot() + 
  geom_sf(data = ctverce_cesko) +
  geom_sf(data = republika(),
          fill = NA,
          col = "red",
          lwd = 1.5)

# a můžeme se přesvědčit i o ploše každého čtverce
ctverce_cesko <- ctverce_cesko |> 
  st_sf() |> 
  as_tibble() |> 
  st_sf() |> 
  st_set_geometry("geometry") |> 
  mutate(plocha = st_area(geometry) |> 
           units::set_units("km2"))
