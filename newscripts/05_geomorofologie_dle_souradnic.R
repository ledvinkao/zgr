
# Geomorfologické jednotky dle souřadnic ----------------------------------

# načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "RCzechia")

# demonstrujeme funkcionální programován v R
# vytvoříme vektor geomorfologické hierarchie
vek <- c("system", 
         "subsystem", 
         "provincie", 
         "subprovincie", 
         "oblast", 
         "celek", 
         "podcelek", 
         "okrsek")

# na základě tohoto vektoru lze psát anonymní funkci, která podle souřadnic jakéhokoliv bodu na území Česka najde příslušnost ke geomorfologickým jednotkám
# do funkce můžeme zadat defaultní souřadnice a pak je nahrazovat
prislusnost <- \(lon = 14.4632861,
                 lat = 50.0695103) {
  tab <- tibble(uroven = vek)
  p <- st_point(c(lon, lat)) |> 
    st_sfc(crs = 4326) |> 
    st_sf() |> 
    st_set_geometry("geom")
  tab <- tab |> 
    mutate(data = map_chr(uroven,
                          \(x) st_intersection(p,
                                               geomorfo(x)) |> 
                            st_drop_geometry() |> 
                            select(any_of(x)) |> 
                            pull()))
  return(tab)
}

# příklad bez zadání jiných souřadnic
prislusnost()
