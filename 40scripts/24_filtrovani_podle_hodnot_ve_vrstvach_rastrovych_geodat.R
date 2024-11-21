
# Filtrování podle hodnot ve vrstvách rastrových geodat -------------------

# pokud existují výběry vrstev u rastrových geodat, musí existovat i filtrování
# autor balíčku terra pro představu uváí, že každou vrstvu si lze představit jako individuální sloupec tabulky
# proto lze použít funkci filter() podobně jako u tabulek

# nejprve načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "terra",
                  "tidyterra")

# načteme soubor s rastrovými geodaty
landsat <- rast(system.file("tif/L7_ETMs.tif",
                            package = "stars"))

# podíváme se na statistiky jednotlivých pásem
summary(landsat)

# zkusme např. filtrovat na hodnoty 6. pásma, které jsou větší než 60
landsatf <- landsat |> 
  filter(L7_ETMs_6 > 60)

# vykresleme výsledek
plot(landsatf)
