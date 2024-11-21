
# Práce s bufferem --------------------------------------------------------

# tvorba tzv. bufferu je velmi častou činností, protože jej potřebujeme pro různé účely
# buffer je možné vytvářet pomocí funkce st_buffer(), která je součástí balíčku sf

# načtení balíčků
xfun::pkg_attach2("tidyverse",
                  "RCzechia") # sf je načítán automaticky s tímto balíčkem

# zkusme vytvořit 50km buffer okolo hranice Česka
hranice <- republika() |> 
  st_transform(32633) # při práci s buffery je vhodné převést na rovinnou projekci (se souřadnicemi v metrech)

hran_buf <- hranice |> 
  st_buffer(units::set_units(50, km)) # zde využíváme funkci na nsatavování jednotek z balíčku units (přitom můžeme a nemusíme psát uvozovky před a po zkratkách jednotek)

# nakrelseme situaci
ggplot() + 
  geom_sf(data = hranice,
          col = "purple",
          linewidth = 1.5,
          fill = NA) +
  geom_sf(data = hran_buf,
          col = "orange",
          linewidth = 1.5,
          fill = NA)

# existují i možnosti zadávání záporných čísel
# zde tedy půjde o smrštění polygonu
# tady je už skutečně nutné mít data v rovinné projekci, jinak se vytvoří prázdná geometrie
hran_buf2 <- hranice |> 
  st_buffer(units::set_units(-10, km))

ggplot() + 
  geom_sf(data = hranice,
          col = "purple",
          linewidth = 1.5,
          fill = NA) +
  geom_sf(data = hran_buf,
          col = "orange",
          linewidth = 1.5,
          fill = NA) +
  geom_sf(data = hran_buf2,
          col = "red",
          fill = NA,
          linewidth = 1.5)
