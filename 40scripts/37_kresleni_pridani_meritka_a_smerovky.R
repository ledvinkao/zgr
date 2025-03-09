
# Kreslení map v R - přidání měřítka a směrovky ---------------------------

# směrovka není ani tak důležitá, máme-li k dispozici nástroje pro kreslení souřadnicové sítě
# grafické měříto by naopak mělo být součástí každé mapy

# demonstrujme tedy přidání těchto mapových prvků pomocí funcí balíčku tmap
# navážeme přitom na skript 36, kde již máme započatou práci s facetami

# načteme potřebné funkce
xfun::pkg_attach2("tidyverse",
                  "RCzechia",
                  "arcgislayers",
                  "tmap")

toky <- arc_read("https://agrigis.cz/server/rest/services/ISVSVoda/osy_vodnich_linii/FeatureServer/0") |> 
  as_tibble() |> 
  st_sf()

# vybrané toky rovnou transformujeme
toky_vyb <- toky |> 
  filter(str_detect(naz_tok, "^Teplá Vltava|^Studená Vltava|^Berounka|^Mandava")) |> 
  st_transform(4326)

# zkusíme přidat i hranice Česka
h <- republika()

tm_shape(h) + 
  tm_graticules() +
  tm_borders(col = "purple",
             lwd = 3) + 
  tm_shape(toky_vyb,
           is.main = T) + 
  tm_lines(col = "darkblue") + 
  tm_facets("naz_tok",
            ncol = 2) + 
  tm_compass(position = c("right",
                          "top")) + 
  tm_scalebar(position = c("LEFT",
                           "BOTTOM")) +
  tm_layout(compass.show.labels = F)
