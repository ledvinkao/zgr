
# Tvorba bodové vrstvy z tabulky se souřadnicemi --------------------------

# nejprve potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "sf",
                  "arrow") # arrow pomáhá s otevíráním Apache Parquet souborů

# pro demonstraci využijeme právě Apache Parquet soubor, který máme ve složce s metadaty (máme již od stažení z GitHub)
# otevřením datasetu se jen odkážeme na data v souboru
# u konzole vpravo nahoře si můžeme všimnout zeléného kolečka s ležatou osmičkou, což značí, že je otevřen tzv. aktivní binding (viz také typ objektu v Globálním prostředí)
ovzdusi <- open_dataset("metadata/airquality_metadata_pq")

# práce s Apache Parquet je pak podobná jako s databází
ovzdusi |> 
  head(10) |> # vybíráme pouze prvních 10 řádků 
  collect() # funkcí collect() sebereme data do paměti

# lze aplikovat i jiná tidyverse slovesa
ovzdusi |> 
  filter(VLASTNIK_ZKRATKA != "ČHMÚ") |> 
  select(ID_REGISTRACE:VLASTNIK_ZKRATKA) |> 
  collect()

# my si však dovolíme sebrat do paměti celou tabulku, neboť není tak velká
ovzdusi <- ovzdusi |> 
  collect()

# omezíme se jen na nejdůležitější sloupce
ovzdusi2 <- ovzdusi |> 
  select(ID_REGISTRACE,
         ZEMEPISNA_DELKA,
         ZEMEPISNA_SIRKA)

# nejprve demonstrujeme funkci st_as_sf() bez nastavení argumentu remove
ovzdusi2 <- ovzdusi2 |> 
  st_as_sf(coords = c("ZEMEPISNA_DELKA", "ZEMEPISNA_SIRKA"),
           crs = 4326)

# pak nastavíme argument remive = F
ovzdusi3 <- ovzdusi |> 
  select(ID_REGISTRACE,
         ZEMEPISNA_DELKA,
         ZEMEPISNA_SIRKA) |> 
  st_as_sf(coords = c(2, 3), # sloupce se souřadnicemi lze vybírat i indexy jejich pořadí
           crs = 4326,
           remove = F)

# prohlédneme rozdíly
ovzdusi2

# zde souřadnice tvoří jak geometrický sloupec, tak také zůstaly mezi atributy
# to se může hodit dále, např. do nějakých modelů
ovzdusi3

# kreslíme velmi jednoduchou mapu vzniklých bodů
ggplot() + 
  geom_sf(data = ovzdusi3, 
          size = 0.5)

# balíček ggspatial dopomáhá k přidání grafického měřítka (ale i jiných prvků)
library(ggspatial)

# kreslíme již komplexněji
ggplot() + 
  geom_sf(data = ovzdusi3, 
          size = 0.5,
          aes(col = ID_REGISTRACE)) + # tímto dospějeme k různým intenzitám barev koleček podle ID
  scale_colour_distiller(palette = "Reds", # hrajeme si s měřítkem barev - nastavujeme červenou paletu a směr zintenzivnění
                         direction = 1) +
  labs(title = "Kvalita ovzdzduší", # popisujeme 
       subtitle = "teď nevím",
       col = "ID") + # tímto získáme lepší nadpis na škálou barev
  coord_sf(crs = "ESRI:54024") + # tímto transformujeme souřadnicový systém (zde Bonneho zobrazení)
  annotation_scale(location = "br") # přidávám měřítko; zkratka "br" znamená "bottom right"
