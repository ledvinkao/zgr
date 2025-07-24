
# Tvorba tematické mapy pro web kurzu -------------------------------------

# mapy v R lze tvořit i za využití jiných balíčků kromě tmap
# v oblibě je např. přístup ggplot2 v kombinaci s dalšími (pro přidání měřítka, směrovky apod.)
# ukažme si, jak na to tímto způsobem a vytvořme mapu, která by mohla být na webu kurzu:-)

# načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "RCzechia",
                  "czso", # pro načítání dat Českého statistického úřadu
                  "ggspatial") # pro přidání grafického měřítka a směrovky

# předpokládá se dobré připojení k internetu, protože podkladová data jsou zde stahována

# zisk vrstvy s okresy
# ještě převádíme na přehlednější formát tibble
okresy <- okresy() |> 
  as_tibble() |> 
  st_sf()

# zisk tabulky ze sčítání lidu
# nejprve prozkoumáme datový katalog
kat <- czso_get_catalogue()

# protože nevíme, jak se tabulka přesně jmenuje, zkusíme si výběr aspoň zúžit
colnames(kat)

kat |> 
  mutate(dataset = str_to_lower(description)) |> 
  filter(str_detect(description, "sčítání")) |> 
  select(dataset_id, title)

# zkusíme to s datasetem, který má id 170240-17
tab <- czso_get_table("170240-17")

# omezíme se na roky 2001 a 2011
# raději zakládáme nový objekt
# omezíme se jen na sloupce, které nás zajímají (pro spojení s geografickou vrstvou)
tab2 <- tab |> 
  filter(rok %in% c(2001, 2011)) |> 
  select(okres, rok, hodnota)

# můžeme provést agregaci podle skupin (ve skutečnosti totiž máme čísla za obce, ne za okresy)
# ještě raději řadíme, ať funguje, co chceme udělat dále
tab2 <- tab2 |> 
  arrange(okres, rok) |> 
  group_by(okres, rok) |> 
  summarize(hodn = sum(hodnota))

# před spojením s geografickou vrstvou bude vhodnější si data zahnízdit
tab2 <- tab2 |> 
  nest()

# provedeme propojení na základě číselného kódu okresu
okresy <- okresy |> 
  left_join(tab2,
            join_by(KOD_OKRES == okres))

# pro výpočet hustoty zalidnění potřebujeme znát plochy okresů
# k tomu využijeme plochojevné zobrazení, které se využívá napříč EU pro statistické výpočty
# jednotky převedeme na km2 a jednotek se raději pro další výpočty zbavíme (někdy jednotky vadí)
okresy <- okresy |> 
  mutate(a = st_area(st_transform(geometry, 3035)) |> 
           units::set_units("km2") |> 
           units::drop_units())

# pomocí funkcionálního programování si vytáhneme procenta změn (rok 2001 = 100 %)
# pomůžeme si anonymní funkcí
okresy <- okresy |> 
  mutate(zmena = data |> 
           map2_dbl(a, \(x, y)
                    (slice(x, 2) |> pull(hodn) / y) / (slice(x, 1) |> pull(hodn) / y) * 100)
  )

# a kreslíme mapu
# složitější labeling volíme kvůli češtině (chceme se zbavit desetinných teček apod.)
# můžeme si také povšimnout, že při labelingu lze využít anonymní funkce, které naopak využívají hodnot v argumentu breaks
ggplot(okresy) +
  geom_sf(aes(fill = zmena)) +
  scale_fill_distiller(palette = "BuPu",
                       direction = 1) +
  scale_x_continuous(breaks = 12:19,
                     labels = \(x) str_c(x, "°")) +
  scale_y_continuous(breaks = 49:51,
                     labels = \(x) str_c(x, "°")) +
  labs(title = "Index změny hustoty zalidnění v okresech Česka mezi lety 2001 a 2011",
       subtitle = "2001 = 100 %, min. = 95,3 %, max. = 145,7 %",
       fill = "změna [%]",
       caption = "zdroj: ČSÚ") +
  annotation_north_arrow(location = "tr",
                         style = north_arrow_fancy_orienteering(text_size = 0), # děláme kvůli zmizení písmene N
                         which_north = "true") +
  annotation_scale(location = "bl")

# pro ukládání do souboru si přiřadíme graf nějakému objektu
p <- ggplot(okresy) +
  geom_sf(aes(fill = zmena)) +
  scale_fill_distiller(palette = "BuPu",
                       direction = 1) +
  scale_x_continuous(breaks = 12:19,
                     labels = \(x) str_c(x, "°")) +
  scale_y_continuous(breaks = 49:51,
                     labels = \(x) str_c(x, "°")) +
  labs(title = "Index změny hustoty zalidnění v okresech Česka mezi lety 2001 a 2011",
       subtitle = "2001 = 100 %, min. = 95,3 %, max. = 145,7 %",
       fill = "změna [%]",
       caption = "zdroj: ČSÚ") +
  annotation_north_arrow(location = "tr",
                         style = north_arrow_fancy_orienteering(text_size = 0),
                         which_north = "true") +
  annotation_scale(location = "bl")

# a protože pracujeme v R projektu, můžeme se při ukládání souboru odkazovat relativně
# předpokládáme, že máme složku v projektu s názvem figs
# nastavíme velikost stránky A5 na šířku
ggsave("figs/mapa_kurzu.png",
       p,
       width = 21,
       height = 14.85,
       units = "cm")
