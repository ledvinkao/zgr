
# Načtení rastrového souboru ----------------------------------------------

# k práci s rastrovými geodaty slouží v současném R hlavně balíček terra
# pro práci s rastrovými geodaty existuje také balíček stars, ale je trochu složitější s ním pracovat
# manipulaci s rastrovými geodaty ve smyslu tidyverse (a také kreslení rastrových podkladů map) umožňuje balíček tidyterra
# s těmito balíčky přichází příkladová data, čehož s výhodou využijeme
# autor balíčku terra dokonce pro zisk geodat vytvořil separátní balíček s názvem geodata
# ukažme, jak lze načíst soubor s rastrovými geodaty pomocí funkce rast() balíčku terra

# nejprve načteme potřebné balíčky
xfun::pkg_attach("tidyverse",
                 "terra")

# podívejme se, jaké tif soubory přichází s balíčkem stars a jaké s balíčkem terra
dir(system.file(package = "stars"),
    pattern = "\\.tif$",
    recursive = T,
    full.names = T)

dir(system.file(package = "terra"),
    pattern = "\\.tif$",
    recursive = T,
    full.names = T)

# načtěme např. soubor L7_ETMs.tif, který je produktem mise Landsat
landsat <- rast(system.file("tif/L7_ETMs.tif",
                            package = "stars"))

# takto se dá kreslit více vrstev najednou
plot(landsat)

# snímek má totiž šest pásem, což lze zjistit už jen z vytisknutí do konzole
landsat

# nebo můžeme využít funkci nlyr()
nlyr(landsat)

# samozřejmě lze aplikovat i jiné dotazovací funkce
nrow(landsat)

ncol(landsat)

crs(landsat) |> 
  cat()

crs(landsat) |> 
  str_view()
