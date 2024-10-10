
# Nalezení pramene a ústí vodního toku ------------------------------------

# stává se, že potřebujeme najít začátek a konec liniového objektu
# zde se osvědčují funkce balíčku lwgeom

# načteme balíčky
# jsou zde nějaké konflikty mezi funkcemi z různých balíčků, ale toho si nevšímáme, dokud nám to nebude vadit
xfun::pkg_attach("tidyverse",
                 "sf",
                 "arcgislayers",
                 "lwgeom",
                 install = T)

# načteme všechny vodní toky na území Česka, které využívají státní podniky Povodí a rezort Ministerstva zemědělství
toky <- arc_read("https://agrigis.cz/server/rest/services/ISVSVoda/osy_vodnich_linii/FeatureServer/0") |> 
  as_tibble() |> 
  st_sf()

# najdeme si např. Teplou Vltavu
tvltava <- toky |> 
  filter(naz_tok == "Teplá Vltava")

# k tomu, abychom mohli aplikovat funkce pro hledání pramene a ústí, je potřeba, aby linie byla typu LINESTRING, ne MULTILINESTRING
# varování je liché, protože jsme dostali pouze jednu liniii (ale asi je aplikováno vždy)
tvltava <- tvltava |> 
  st_cast("LINESTRING")

# nicméně můžeme pokračovat
# zde využijeme toho, že osový model toků je uspořádán tak, že počáteční bod je vždy ústí a konečný bod je vždy pramen
# je to z důvodu, aby bylo možné počítat říční kilometry
usti <- tvltava |> 
  st_startpoint() |> # jedná se jen o geometrii
  st_sf() |> # tak převádíme na simple feature
  st_set_geometry("geom") |> # trochu se přitom porouchal název geometrie, tak jej opravujeme
  as_tibble() |> # chceme lepší třídu - tibble
  st_sf() # z níž potřebujeme opět získat simple feature

# totéž prvedeme pro pramen
pramen <- tvltava |> 
  st_endpoint() |> 
  st_sf() |> 
  st_set_geometry("geom") |> 
  as_tibble() |> 
  st_sf()

# polohu usti i pramene si můžeme vykreslit v dynamické mapě
usti <- usti |> 
  mutate(typ = "usti")

pramen <- pramen |> 
  mutate(typ = "pramen")

dohromady <- bind_rows(usti,
                       pramen)

# dynamické mapy lze kreslit např. následovně
mapview::mapview(dohromady)
