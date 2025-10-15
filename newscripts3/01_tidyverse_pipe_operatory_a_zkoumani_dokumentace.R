
# Klasické načítání metabalíčku tidyverse a pipe operátory ----------------

library(tidyverse) # načítá celkem 9 balíčků, mezi nimi i ggplot2 s funkcemi pro kreslení map

# s tímto přichází i možnost využívání starého pipe operátoru %>%
# ale my se zaměříme na využití nového, nativního pipu |> (pak není nutné mít přídavný balíček)
# pokud zaškrtneme v Global Options... možnost, že jej chceme vkládat zkratkou CTRL + SHIFT + M, bude se vkládat ten
# základní klávesové zkratky najdeme v seznamu po stisknutí ALT + SHIFT + K (viz také dodanou tabulku se základními zkratkami)

# starý pipe nepotřeboval mít za názvy funkcí oblé závorky
trees %>%
  class

# nový pipe to naopak vyžaduje - kód je pak čitelnější, víme, že jde o funkci anebo něco jiného
trees |> 
  class # chyba

trees |> 
  class()


# Nápovědy a dokumentace --------------------------------------------------

# vytvořme objekt stromy, který využijeme dále
stromy <- trees

# když známe přesný název funkce, lze pro zavolání nápovědy použít jednoduchý otazník
?trees

# dvojitý otazník pomůže prohledat dokumentaci balíčků, které máme nainstalovány
??wilcoxon

# když si nevystačíme ani s tím, pomůže balíček sos a jeho funkce findFn()
# při využití konstruktu s dvěma dvojtečkami se předpokládá, že balíček je již nainstalován
# na druhou stranu ale nemusíme balíček načítat celý a nehrozí konflikty v názvech funkcí
sos::findFn("{pycnophylactic interpolation}")


# Moderní způsob instalace a načítání balíčků -----------------------------

# varianta funkce 2 předpokládá argument install = T
xfun::pkg_attach2("tidyverse",
                  "sf",
                  "arcgislayers")

# jinak bychom mohli také psát
xfun::pkg_attach("tidyverse",
                 "sf",
                 "arcgislayers",
                 install = T)


# Objekty typu tibble jako vylepšené tabulky ------------------------------

stromy <- stromy |> 
  as_tibble()

# jaké jsou rozdíly mezi tímto a obyčejným datovým rámcem? - lepší tisk do konzole (odlišení záporných čísel a znaků NA), vidíme hned typy sloupců apod.
stromy

# na závěr úvodu poznámka: protože se doporučuje dlouhý soubor se skriptem strukturovat (klávesová zkratka CTRL + SHIFT + R), není vhodné vkládat na řádku více než 4 znaky # za sebou
