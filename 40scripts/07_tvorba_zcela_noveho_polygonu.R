
# Tvorba zcela nové vektorové vrstvy --------------------------------------

# dejme tomu, že si pro další práci budeme muset vytvořit polygon (např. obdélník), který definuje náš zájmový region
# toto je velmi častý případ, kdy např. za pomoci takového polygonu stahujeme z nějakého serveru další geodata

# načteme balíčky
xfun::pkg_attach2("tidyverse",
                  "RCzechia", # balíček sf se načítá automaticky
                  "sfheaders") # přestože balíček sf obsahuje pro tyto úlohy podobné funkce také, balíček sfhehaders nabízí více argumentů

# dejme tomu, že zájmovým regionem je sférický obdélník rozkládající se mezi 16,35-18,85° v.z.d. a 49,3-50,2° s.z.š.

# nejprve vytvoříme matici s prvním a posledním řádkem identickým (pro uzavření polygonu)
mat <- matrix(c(16.35, 49.3,
                18.85, 49.3,
                18.85, 50.2,
                16.35, 50.2,
                16.35, 49.3),
              ncol = 2,
              byrow = T)

# vytvoříme polygon, který ale ještě nemá souřadnicový systém
# můžeme se dokonce rozmyslet mezi tvorbou pouhé geometrie (funkce sfg_polygon()) nebo rovnou simple feature s defaultním polem (funkce sf_polygon())
obdelnik <- sfc_polygon(mat)

# přidáme souřadnicový systém a změníme typ objektu na simple feature
# pojmenujeme též sloupec s geometrií
# a abychom byli úplně spokojeni, dodáme objektu ještě třídu tibble
obdelnik <- obdelnik |>
  st_sf() |> 
  st_set_crs(4326) |> 
  st_set_geometry("geom") |> # tímto měníme název geometrického sloupečku (v žádném případě ne funkcí set_names()!)
  as_tibble() |> 
  st_sf() # musíme aplikovat podruhé, jinak bychom měli jenom tabulku

# vykreslíme si situaci
# stáhneme si pomocnou vrstvu pro lepší pochopení polohy
hranice <- republika()

ggplot() +
  geom_sf(data = hranice,
          col = "purple",
          linewidth = 1.5,
          fill = NA) +
  geom_sf(data = obdelnik,
          col = "black",
          fill = "grey30",
          alpha = 0.6,
          linewidth = 1.5)
