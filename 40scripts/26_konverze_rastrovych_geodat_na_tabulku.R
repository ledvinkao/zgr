
# Konverze rastrových geodat na tabulku -----------------------------------

# někdy se může hodit (např. kvůli lepší manipulaci) rastrová geodata převést do tabulky
# autor balíčku terra na to samozřejmě pamatuje také

# načteme potřebné balíčky
xfun::pkg_attach("tidyverse",
                 "terra",
                 install = T)

# načteme rastrová geodata (ideálně s více vrstvami)
landsat <- rast(system.file("tif/L7_ETMs.tif",
                            package = "stars"))

# aplikujme funkci as.data.frame()
# někdy se může hodit dostat do tabulky i souřadnice x a y, tak nastavíme argument xy na pravdu
# starý formát data frame si ještě můžeme převést na třídu tibble
tab <- as.data.frame(landsat,
                     xy = T) |> 
  as_tibble()

# vytiskneme aspoň část tabulky do konzole
tab

# nálsedně lze s tabulkou provádět další operace jako např. hledání řádku s chybějící hodnotou v jakémkoliv pásmu
tab |> 
  filter(if_any(L7_ETMs_1:L7_ETMs_6, is.na))
