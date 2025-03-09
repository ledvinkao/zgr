
# Kreslení map v R - tmap a facety ----------------------------------------

# jak známo, i v ggplot pojetí bychom si mohli nakreslit mapu (pomocí funkce geom_sf()) s využitím facet
# ggplot strategie ale nedovoluje uvolnění měřítek na osách při použití funkce, takže je vhodné sáhnout po jiném nástroji

# pro tento příklad najdeme ve vektorové vrstvě s toky čtyři řeky: Teplou Vltavu, Studenou Vltavu, Berounku a Mandavu
# každá řeka ostane svůj vlastní panel obrázku

# načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "sf",
                  "arcgislayers",
                  "tmap")

# vybereme kýžené toky
toky <- arc_read("https://agrigis.cz/server/rest/services/ISVSVoda/osy_vodnich_linii/FeatureServer/0") |> 
  as_tibble() |> 
  st_sf()

# využíváme možnosti vložit regulární výraz do funkce str_detect()
toky_vyb <- toky |> 
  filter(str_detect(naz_tok, "^Teplá Vltava|^Studená Vltava|^Berounka|^Mandava"))

# vykreslíme
tm_shape(toky_vyb |> 
           st_transform(4326)) + # raději transformujeme, ať souřadnicová síť nevypadá divně
  tm_graticules() + # takto přidáme souřadnicovou síť
  tm_lines(col = "darkblue") +
  tm_facets("naz_tok",
            ncol = 2,
            free.coords = T) # velmi důležité, nastaveno defaultně jako TRUE, ale je to tu z důvodu možnosti přepínat na FALSE

# kdyby byl dostatek místa, tak se jistě vykreslí souřadnice u všech os