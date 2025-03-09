
# Kategorický rastr -------------------------------------------------------

# v předchozím skriptu 29 jsme viděli, že s orientací svahu bude ještě zapotřebí něco udělat
# zopakujme rychle, co bylo provedeno ve skriptu 29 (bez kreslení) a pokračujme

# načteme balíčky
xfun::pkg_attach2("tidyverse",
                  "terra",
                  "geodata")

# pokud je dem již v adresáři stažený, jen se načte a nic se nestahuje
dem <- elevation_30s(country = "CZE",
                     path = "geodata",
                     mask = F)

# vypočíátme orientaci ve stupních
orientace <- terrain(dem,
                     v = "aspect",
                     filename = "geodata/CZ_asp.tif",
                     overwrite = T)

# zjistěme si, čemu se rovná minimum a čemu maximum
orientace |> 
  values() |> 
  range(na.rm = T)

# pojďme hodnoty rastru převést na kategorie
kat <- orientace |> 
  values() |> 
  cut(breaks = c(0,
                 seq(from = 45,
                     to = 315,
                     by = 90),
                 360),
      include.lowest = T, # nula bude patřit do prvního intervalu (interval bude zleva uzavřený)
      labels = c("s1", # první sever
                 "v", # východ
                 "j", # jih
                 "z", # západ
                 "s2")) |> # druhý sever
  fct_collapse(s = c("s1", "s2"), # slučujeme dva severy
               v = "v",
               j = "j",
               z = "z")

# funkce rast() může být využita pro dědění geometrie (z rastru orientace odstraňuje hodnoty)
orientace_kat <- rast(orientace)

# nyní nastavujeme hodnoty kategorií
values(orientace_kat) <- kat

# balíček terra má vlastní palety, jedna z nich je i pro orientaci svahu
plot(orientace_kat,
     col = map.pal("aspect",
                   n = 4))

# poznamenejme, že namísto kombinace funkcí values() a cut() je možné použít i funkci terra::classify() (není možno nastavovat labely) nebo terra::subst() (je možno nastavovat labely)

# balíček tidyterra nabízí další vhodné palety barev pro kreslení ve smyslu ggplot
library(tidyterra)

ggplot() + 
  geom_spatraster(data = orientace_kat) + 
  scale_fill_grass_d(palette = "aspect") + 
  labs(fill = "orientace svahu\n(kategorie)")

ggplot() + 
  geom_spatraster(data = orientace) +
  scale_fill_grass_c(palette = "aspectcolr") + 
  labs(fill = "orientace svahu\n(úhly)")
