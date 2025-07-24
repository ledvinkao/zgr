
# Kreslení map v R - módy balíčku tmap ------------------------------------

# v současnoti je pro kreslení map v R asi nepropracovanější balíček tmap
# vlastně ani zpočátku nemuí jít o mapy, jako spíše o vykreslení si schématu napovídajícího, zda jsme s našimi analýzami na správném území
# balíček tmap má jednu skvělou vlastnost, a sice, že si geodata můžeme kreslit do dynamických znázornění (s výhodnými podkladovými mapami)

# vykresleme si např. polygony administrativních krajů Česka

# načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "RCzechia",
                  "tmap")

kraje <- kraje() |> 
  as_tibble() |> 
  st_sf()

# nejprve statické znázornění (podobně jako u ggplot2 řetězíme operátorem +)
tm_shape(kraje) + 
  tm_polygons(col = "purple",
              fill = "magenta",
              fill_alpha = 0.3)

# nyní dynamické znázornění
# musíme přepnout mód balíčku tmap
tmap_mode("view")

tm_shape(kraje) + 
  tm_polygons(col = "purple",
              fill = "magenta",
              fill_alpha = 0.3)

# zpět do kreslení statických map se lze dostat takto
tmap_mode("plot")

# a takto lze kreslit jen hranice
tm_shape(kraje) +
  tm_borders(col = "purple")
