
# Ořezávání linií polygony ------------------------------------------------

# ačkoliv v jiných GIS softwarech známe tuto činnost pod názvem "clipping", v R (lépe řečeno v balíčku sf) tuto aktivitu nahrazuje funkce st_intersection()
# ta kromě geometrie řeší také atributy
# pozor! neplést si tuto funkci s funkcí st_intersects(), která dělá něco jiného

# načteme balíčky
xfun::pkg_attach2("tidyverse",
                  "RCzechia", # balíček sf je načítán automaticky
                  "arcgislayers")

# řekněme, že budeme chtít oříznout vrstvu vodních toků obrysem Jihočeského kraje

# načteme vrstvu s kraji a vybereme jen Jihočeský kraj
kraje <- kraje()

jihocesky <- kraje |> 
  filter(NAZ_CZNUTS3 == "Jihočeský kraj")

# načteme vodní toky
toky <- arc_read("https://agrigis.cz/server/rest/services/ISVSVoda/osy_vodnich_linii/FeatureServer/0") |> 
  as_tibble() |> 
  st_sf()

toky_jihocesky <- toky |>  
  st_intersection(st_transform(jihocesky, st_crs(toky))) # potřebujeme mít stejné crs (dědíme funkcí st_crs())

ggplot() + 
  geom_sf(data = jihocesky,
          col = "red",
          fill = NA,
          linewidth = 1.5) +
  geom_sf(data = toky_jihocesky,
          col = "darkblue")
