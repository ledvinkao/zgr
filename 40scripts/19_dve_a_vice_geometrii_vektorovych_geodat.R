
# Dvě a více geometrií vektorových geodat ---------------------------------

# kolekce simple features může mít klidně více geometrií
# to se může hodit, pokud potřebujeme více geometií najednou pro výpočet nějaké charakteristiky
# existují charakteristiky, kde např. potřebujeme crs s co nejmenším zkreslením délek a plochojevný crs

# zjistěme, jak moc se liší tvary jednotlivých administrativních krajů Česka od tvaru kruhového
# pro tyto účely existuje tzv. Graveliův koeficient

# načteme nejprve potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "RCzechia") # balíček sf je načten automaticky

# načteme polygony krajů
kraje <- kraje() |> 
  as_tibble() |> 
  st_sf()

# již víme, že na území Česka lze pro účely výpočtů délek používat crs s EPSG:5514
# pro účely výpočtu ploch využíváme crs s EPSG:3035
# transformujme tedy geometrii, která je nyní v crs s EPSG:4326
kraje <- kraje |> 
  mutate(geom1 = st_transform(geometry,
                              5514),
         geom2 = st_transform(geometry,
                              3035))

# skutečně nyní máme tři geometrické sloupce, jak se lze přesvědčit
kraje

# řekněme, že původní geometrie nás už nezajímá
# takže první geometrický sloupec zahodíme
kraje <- kraje |> 
  st_drop_geometry()

# vypočítejme nyní obvody polygonů
# a také plochy polygonů
# necháme vypočítat v m, resp. m2
# výpočet je proveden, i když jsme po aplikaci funkce st_drop_geometry() ztratili třídu sf
kraje <- kraje |> 
  mutate(obvod = st_perimeter(geom1),
         plocha = st_area(geom2))

# nyní jsme připraveni počítat koeficienty (viz např. Riedl a Zachar, 1984, s. 14)
kraje <- kraje |> 
  mutate(graveli = obvod / 2 / sqrt(pi * plocha))

# jelikož je výsledkem tabulka (ne kolekce simple features), můžeme podle toho odstraňovat i další nepotřebné sloupce
kraje <- kraje |> 
  select(-c(geom1, geom2)) |> 
  mutate(obvod = NULL, # i takto lze odstraňovat sloupce
         plocha = NULL)


# Literatura --------------------------------------------------------------

# Riedl, O. and Zachar, D.: Forest Amelioration, Elsevier, Amsterdam, 623 pp., 1984.
