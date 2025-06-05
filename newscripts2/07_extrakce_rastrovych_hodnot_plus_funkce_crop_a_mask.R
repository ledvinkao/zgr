
# Extrahování rastrových hodnot do tabulky vektorové vrstvy ---------------

# nejprve načteme balíčky, o kterých předpokládáme, že je budeme potřebovat
xfun::pkg_attach2("tidyverse",
                  "terra", # důležitá je zde hlavně funkce extract()
                  "sf",
                  "arrow") # když budeme chtít demonstrovat extrakci na bodové vektorové vrstvě stanic kvality ovzduší

# vezměme metadata kvality ovzduší a převeďme tabulku na sf collection
ovzdusi <- open_dataset("metadata/airquality_metadata_pq") |> 
  collect() |> 
  st_as_sf(coords = c("ZEMEPISNA_DELKA",
                      "ZEMEPISNA_SIRKA"),
           crs = 4326)

# načteme rastry teploty vzduchu, které máme již uložené v souboru staeném ve složce geodata
# namísto dopředného lomítka lze použít i dvě zpětná lomítka, když se chceme odkazovat na cestu k souboru
tavg <- rast("geodata\\climate\\wc2.1_country\\CZE_wc2.1_30s_tavg.tif")

# předpokládáme, že budeme brzy aplikovat pivoting tabulek
# pro tento účel se omezíme pouze na sloupec, podle kterého poznáme, o kterou stanici se ve kterém řádku jedná
ovzdusi <- ovzdusi |> 
  select(ID_REGISTRACE)

# pokud chceme extrahovat hodnoty v místech bodů, nemusíme specifikovat argument fun
# pokud nechceme dostat jen pouhou matici s indexy řádků, je vhodné využít funkcionalitu připojování k vektorové vrstvě pomocí argumentu bind
ovzdusi <- extract(tavg,
                   ovzdusi,
                   bind = T) |> 
  st_as_sf() |> # protože výsledkem je vektorová vrstva třídy SpatVector (nativní pro balíček terra), převádíme na třídu sf collection, se kterou umíme pracovat lépe
  as_tibble() |> 
  st_sf()

# nyní nastává pivoting tabulky
ovzdusi <- ovzdusi |> 
  st_drop_geometry() |> # napřed se zbavíme geometrie
  pivot_longer(cols = -ID_REGISTRACE, # znaménko - nebo ! znamená negaci (vybíráme pro natažení všechny sloupce, které nejsou ID_REGISTRACE)
               names_to = "mesic", # nastavujeme jména nového sloupce složeného z původních jmen natahovaných sloupců
               values_to = "val_num") |> # nastavujeme jméno sloupce pro hodnoty
  mutate(mesic = str_replace(mesic, # ještě si upravíme prvky sloupce mesic; str_replace() nahrazuje řetězce (i pomocí regulárních výrazů)
                             "CZE_wc2.1_30s_tavg_",
                             "") |> 
           str_pad(width = 2, # přidáváme vodicí nuly (tím zajistíme správné řazení pro následující kreslení grafů)
                   pad = "0"))

# prohlédneme výsledek
ovzdusi

# zkusme vykreslit boxplot
ggplot(ovzdusi) + 
  geom_boxplot(aes(x = mesic,
                   y = val_num),
               outlier.size = 0.4) + # aby tečky s odlehlými hodnotami byly menší
  labs(x = "měsíc",
       y = "teplota vzduchu [°C]")

# pro demonstraci exrakce do polygonů si vezmeme na pomoc polygony obcí Česka
obce <- RCzechia::obce_polygony()

obce <- obce |> 
  as_tibble() |> 
  st_sf()

# záměrně bereme jen první dva sloupce, abychom mohli obce identifikovat
obce <- obce |> 
  select(KOD_OBEC:NAZ_OBEC)

# tady už nastavujeme i funkci argumentem fun, protože v polygonech máme více buněk a musíme si říct, co takovými hodnotami
obce <- extract(tavg,
                obce,
                fun = \(x) round(mean(x), 1), # často je aplikován průměr; zde řešeno navíc anonymní funkcí, abychom měli výsledek rovnou i zaokrouhlený na jedno desetinné místo
                bind = T) |> 
  st_as_sf() |> 
  as_tibble() |> 
  st_sf()

# opět provedeme pivoting a úpravu sloupců
obce2 <- obce |> 
  st_drop_geometry() |> # nezapomeneme na odstranění geometrie
  pivot_longer(cols = -c(KOD_OBEC, NAZ_OBEC),
               names_to = "mesic",
               values_to = "val_num") |> 
  mutate(mesic = str_replace(mesic,
                             "CZE_wc2.1_30s_tavg_",
                             "") |> 
           str_pad(width = 2,
                   pad = "0"))

# kreslíme boxploty s průměrnou teplotou vzduchu, tentokrát pro obce
ggplot(obce2) +
  geom_boxplot(aes(x = mesic,
                   y = val_num),
               outlier.size = 0.4,
               col = "darkblue") + 
  labs(x = "měsíc",
       y = "teplota vzduchu [°C]")

# když jsme poznali funkci tmap_save(), ukažme si i funkci ggsave()
ggsave("figures/mesicni_teploty_vzduchu_pro_polygony_obci.pdf",
       width = 29.7,
       height = 21,
       units = "cm")


# Extrakce nadmořské výšky a stavba lineárního modelu ---------------------

# řekněme, že jsme se rozhodli zjistit konstrukcí lineárního modelu, jaký je vztah mezi průměrnou roční teplotou vzduchu a nadmořskou výškou
# stáhneme dem Česka
dem <- RCzechia::vyskopis("actual")

# extrahujeme pro obce průměrnou nadmořskou výšku (využíváme polygony obcí, tak nastavujme arguent fun)
obce <- extract(dem,
                obce,
                fun = \(x) round(mean(x), 1),
                bind = T) |> 
  st_as_sf() |> 
  as_tibble() |> 
  st_sf()

# pokud by hrozilo, že rozdíly plochách reprezentovaných buňkami rastru byly zásadně odlišné, měli bychom zřejmě zapojit do hry vážené statistiky
# pro zjištění plochy buněk rastru je výtečná funkce terra::cellSize()
?cellSize

# nyní bychom v objektu obce měli mít navíc i sloupec Band_1, který reprezentuje průměrnou nadmořskou výšku
names(obce)

# pivoting není potřebný, protože máme jen jeden sloupec pro nadmořskou výšku
obce3 <- obce |> 
  st_drop_geometry() |> 
  select(KOD_OBEC, NAZ_OBEC,
         dem = Band_1) # ve funkci select() lze rovnou volit i nové názvy sloupců

# abychom měli teplotní data srovnatelná s daty o nadmořské výšce, agregujme měsíční hodnoty teploty do ročních hodnot
obce2b <- obce2 |> 
  group_by(KOD_OBEC) |> # agregujeme po obcích; alternativně lze využít argument .by v následující funkci summarize()
  summarize(val_num = mean(val_num) |> # pipe lze využít i uvnitř jiné funkce
              round(1))

# propojme si tabulky s nadmořskou výškou a teplotou
obce3 <- obce3 |> 
  left_join(obce2b,
            join_by(KOD_OBEC))

# postavme lineární model (závislá proměnná teplota, nezávislá proměnná nadmořská výška)
model <- lm(val_num ~ dem,
            data = obce3)

# prohlédneme detailní vlastnosti modelu
summary(model)

# výstupy funkce summary() nejsou přívětivé, pokud jde o zpracování ve smyslu tidyverse
# velké množství výsledných modelů lze pak uklízet do tabulky funkcí tidy() z balíčku broom, což je dále vhodné pro strojové učení
model |> 
  broom::tidy()


# Je rozdíl mezi funkcí terra:extract() a terra::zonal() ------------------

?zonal

# pro aplikaci funkce zonal() viz např. bonusový skript 32
# pro kategorické rastry viz též bonusový skript 30
# pro práci s úhlovými daty (jako je sklon svahu) v regresních modelech v ekologii viz též knihu https://link.springer.com/book/10.1007/978-3-319-71404-2


# Analýzy terénu funkcemi balíčku terra -----------------------------------

# zásadní je zde funkce terrain(), která podle argumentu v dává různé výsledky ve formě rastru
?terrain

# takto se např. odvozuje rastr sklonu na bázi dem
# sklon je nastaven defaultně
slopes <- terrain(dem)

# prohlédneme, výsledkem je skutečně rastr
slopes

# výsledek lze samozřejmě kreslit
library(tidyterra)

ggplot() + 
  geom_spatraster(data = slopes) + 
  scale_fill_distiller(palette = "Greys",
                       na.value = NA) # někdy je tohle nutné nastavit, protože jinak by se v místech s hodnotami NA (resp. NaN) objevovala šedivá barva


# Význam funkcí terra::crop() a terra::mask() -----------------------------

# pro demonstraci funkcí crop() a mask() vyberme z objektu s obcemi řádek, který obsahuje polygon pro Prahu
praha <- obce |> 
  filter(str_detect(NAZ_OBEC, "Praha")) # nevíme, jak se Praha ve sloupci NAZ_OBEC vyskytuje, tak si raději pomáháme regulárními výrazy (tj. pomocníkem str_detect()) - někdy je jen Praha, jindy Hlavní město Praha apod.

# nejprve aplikujeme crop() a pak mask()
# jelikož často maskujeme stejným polygonem, který používám ve funkci crop(), zavedl autor balíčku terra ve funkci crop() také argument mask, díky čemuž se kód může krátit
dem_praha <- dem |> 
  crop(praha,
       mask = T)

# kreslíme výsledek
ggplot() + 
  geom_spatraster(data = dem_praha) + 
  scale_fill_distiller(palette = "Greys",
                       na.value = NA)

# co se děje, když aplikujeme jen crop()?
# jde jen o omezení na extent, resp. bounding box
dem_praha_cropped <- dem |> 
  crop(praha)

ggplot() + 
  geom_spatraster(data = dem_praha_cropped) + 
  scale_fill_distiller(palette = "Greys",
                       na.value = NA)

# u maskování existuje i argument inverse, jehož hodnotou TRUE vymaskujeme vnitřek polygonu, přičemž vnější hodnoty zůstanou
dem_praha_cropped_masked <- dem_praha_cropped |> 
  mask(praha,
       inverse = T)

ggplot() + 
  geom_spatraster(data = dem_praha_cropped_masked) + 
  scale_fill_distiller(palette = "Greys",
                       na.value = NA)
