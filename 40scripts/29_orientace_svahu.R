
# Orientace svahu ---------------------------------------------------------

# orientace svahu je důležitým faktorem ovlivňujícím celou řadu hydrometeorologických prvků
# při práci s R si můžeme často vystačit s datasety, které nabízí balíček geodata
# tento balíček obsahuje i funkci pro stahování rastru s nadmořskými výškami (angl. digital elevation model, DEM)
# s těmito modely můžeme provádět různé výpočty související s terénem

# nejprve načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "RCzechia", # s tímto se načte automaticky i balíček sf
                  "terra",
                  "tidyterra",
                  "geodata")

# využijeme funkci elevation_30s(), kde ještě specifikujeme, že se chceme zaměřit na území Česka
# zakážeme maskování
dem <- elevation_30s(country = "CZE",
                     path = "geodata",
                     mask = F)

# podíváme se, jak data vypadají
ggplot() + 
  geom_spatraster(data = dem) +
  scale_fill_hypso_c(palette = "wiki-schwarzwald-cont") +
  labs(fill = "m n.m.") + 
  geom_sf(data = republika(),
          fill = NA,
          col = "purple",
          linewidth = 1.5)

# zjistěme si z modelu orientaci svahů ve stupních
# rovnou ukládáme výsledek do souboru, a kreslíme
orientace <- terrain(dem,
                     v = "aspect",
                     filename = "geodata/CZ_asp.tif",
                     overwrite = T)

ggplot() + 
  geom_spatraster(data = orientace) + 
  scale_fill_distiller(palette = "RdYlGn") +
  labs(fill = "orientace \nsvahu [°]")

# ale ještě je s tím třeba něco dělat
