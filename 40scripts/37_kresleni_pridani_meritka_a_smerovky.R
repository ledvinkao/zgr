
# Kreslení map v R - přidání měřítka a směrovky ---------------------------

# směrovka není ani tak důležitá, máme-li k dispozici nástroje pro kreslení souřadnicové sítě
# grafické měříto by naopak mělo být součástí každé mapy

# demonstrujme tedy přidání těchto mapových prvků pomocí funkcí balíčku tmap
# navážeme přitom na skript 36, kde již máme započatou práci s facetami

# načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "RCzechia",
                  "arcgislayers",
                  "tmap")

toky <- arc_read("https://agrigis.cz/server/rest/services/ISVSVoda/osy_vodnich_linii/FeatureServer/0") |> 
  as_tibble() |> 
  st_sf()

toky_vyb <- toky |> 
  filter(str_detect(naz_tok, "^Teplá Vltava|^Studená Vltava|^Berounka|^Mandava"))

# zkusíme přidat i hranice Česka
h <- republika()

# a kreslíme
# graf si můžeme napřed uložit do nového objektu
plot <- tm_shape(h) + 
  tm_graticules() +
  tm_borders(col = "purple",
             lwd = 3) + 
  tm_shape(toky_vyb,
           is.main = T,
           crs = 4326) + 
  tm_lines(col = "darkblue") + 
  tm_facets("naz_tok",
            ncol = 2) + 
  tm_compass(position = c("right",
                          "top"),
             show.labels = F) + # aby se neukazovalo písmeno N pro sever:-)
  tm_scalebar(position = c("LEFT", # na velikosti písmen záleží
                           "BOTTOM"))

# výsledek můžeme uložit pomocí funkce tmap_save(), kde si ještě můžeme hrát s výškou, šířkou apod.
tmap_save(plot,
          "results/vybrane_reky.pdf")
