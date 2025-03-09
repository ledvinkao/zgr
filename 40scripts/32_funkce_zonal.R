
# Funkce zonal() ----------------------------------------------------------

# ve skriptu 31 jsme ale nepočítali s problémem neplochojevnosti crs
# pojďme si ukázat, jak lze tomuto problému čelit např. v případě kategorického rastru

# nejprve načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "RCzechia", # balíček sf je načten automaticky
                  "terra",
                  "geodata")

dem <- elevation_30s(country = "CZE",
                     path = "geodata",
                     mask = F)

# sklon necháme vypočítat ve stupních
sklon <- terrain(dem,
                 v = "slope",
                 filename = "geodata/CZE_slp.tif",
                 overwrite = T)

# demonstrujme klasifikaci za pomoci matice se třemi sloupci
sklon_kat <- classify(sklon,
                      rcl = matrix(c(0, 5, 1,
                                     5, 10, 2,
                                     10, 15, 3,
                                     15, Inf, 4), # také hodnota Inf (nekonečno) je brána jako hodnota
                                   ncol = 3,
                                   byrow = T),
                      include.lowest = T)

# pro výpočet plochy buněk slouží funkce cellSize()
# k rastrové vrstvě s kategoriemi sklonu lze tedy přidat další vrstvu s hodnotami plochy buněk
sklon_kat <- c(sklon_kat,
               area = cellSize(sklon_kat)) # nové vrstvy lze rovnou pojmenovávat

# vidíme, že plochy se liší, protože nemáme rastr v plochojevném crs
sklon_kat

# ještě potřebujeme vrstvu s polygony, tak opět vezmeme kraje
kraje <- kraje()

# spojíme do jedné rastrové sady
# při rasterizaci polygonů vybíráme jako rastr opět objekt sklon_kat, abychom měli stejnou geometrii
# z vektoru si pro definici pole bybereme např. název kraje
sklon_kat <- c(sklon_kat,
               rasterize(kraje,
                         sklon_kat,
                         field = "NAZ_CZNUTS3"))

# nyní je čas na aplikaci funkce zonal()
vysledek <- zonal(sklon_kat[[2]], # chceme sčítat plochy
                  sklon_kat[[c(3, 1)]],
                  fun = "sum") |> 
  as_tibble() # původně jsou výsledky vraceny jako data frame, ale my chceme hezčí výstup ve třídě tibble

# pojďme ještě určit procenta každé kategorie sklonu v jednotlivých krajích
vysledek <- vysledek |> 
  pivot_longer(cols = -1,
               names_to = "sklon_kat",
               values_to = "plocha") |> 
  mutate(plocha = units::set_units(plocha,
                                    "m2"),
         plocha = units::set_units(plocha,
                                   "km2"))

vysledek <- vysledek |> 
  group_by(NAZ_CZNUTS3) |> 
  mutate(procenta = (plocha / sum(plocha)),
         procenta = units::set_units(procenta, "%") |> 
           round(2))

# výpočet podílů tímto způsobem je správnější, neboť uvažuje rozdílné plochy buněk rastru