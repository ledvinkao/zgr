
# Kreslení statických map pomocí ggplot -----------------------------------

# nejprve načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "sf")

# příklad se Slovenskem od EEA (viz též bonusový skript 03)
st_layers("/vsizip//vsicurl/https://www.eea.europa.eu/data-and-maps/data/eea-reference-grids-2/gis-files/slovakia-shapefile/at_download/file/slovakia_shapefile.zip")

sk <- read_sf("/vsizip//vsicurl/https://www.eea.europa.eu/data-and-maps/data/eea-reference-grids-2/gis-files/slovakia-shapefile/at_download/file/slovakia_shapefile.zip",
              layer = "sk_10km")

# asi nejdůležitější funkce
?geom_sf

# kreslíme (a vrstvíme operátorem +)
ggplot() + 
  geom_sf(data = sk, # na rozdíl od uvedení argumentu data volíme uvádění zde (kvůli přidávání jiných objektů jako argument data)
          fill = NA, # bez výplně
          col = "darkblue") # barva ohraničení polygonů

# jak na centroidy
sk_centroid <- sk |> 
  st_centroid()

# kreslení více vrstev dohromady
ggplot() +
  geom_sf(data = sk,
          fill = NA,
          col = "darkblue") +
  geom_sf(data = sk_centroid,
          size = 0.5) # velikost bodu

# budeme načítat hranice funkcí RCzechia::republika()
library(RCzechia)

# kvůli přidávání měřítka a směrovky
library(ggspatial)

hranice <- republika()

# kreslíme ve WGS 84 s 10km bufferem (ještě lze)
ggplot() + 
  geom_sf(data = hranice,
          fill = NA,
          col = "#0029cc", # korporátní barva ČHMÚ dána hexadecimálně; získáno konverzí z CMYK (100, 80, 0, 20)
          ) +
  geom_sf(data = st_buffer(hranice,
                           units::set_units(10, "km")), # využíváme balíček units
          col = "red",
          fill = NA)

# buffery spíše uplatňujeme v rovinné projekci
# takže transformujeme do WGS 84 UTM Zone 33N
hranice_t <- hranice |> 
  st_transform(32633)

ggplot() + 
  geom_sf(data = hranice_t,
          fill = NA,
          col = "#0029cc",
  ) +
  geom_sf(data = st_buffer(hranice_t,
                           units::set_units(10, "km")),
          col = "red",
          fill = NA) +
  geom_sf(data = st_buffer(hranice_t,
                           units::set_units(-10, "km")), # teprve zde lze nastavovat i záporné hodnoty
          col = "purple",
          fill = NA) +
  annotation_scale() + # přidání grafického měřítka
  annotation_north_arrow(pad_x = unit(10, "cm"), # přidání směrovky a nastavení její pozice (další možností je parametr location, kde lze uplatňovat zkratky jako 'bl' nebo 'tr'; viz bonusový skript 38)
                         pad_y = unit(5, "cm")) + 
  theme_bw() # nastavení jiné šablony

# funkce pro ukládání ggplot obrázků (třeba i do PDF)
?ggsave


# Krátce k list-columns a funkcionálnímu programování ---------------------

# pozor na tuto funkci, má tendenci řadit
# namísto toho raději používat nesting pomocí tidyr::nest() (viz např. bonusový skript 38)
?group_split

# zajímavá je funkce pluck() (pro výběr elementů seznamu)
?pluck


# Ukázka slučování rozvodnic nad vodoměrnými stanicemi --------------------

# byla demonstrována síla funkce st_union() a práce s funkcemi balíčku multidplyr
# viz bonusový skript 40
