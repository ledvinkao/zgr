
# Načtení vektorových geodat přímo ze ZIP archivu (internet) --------------

# leckdy ZIP soubor není ani nutné stahovat a vektorová geodata si lze vzít rovnou z archivu umístěného na internetu

# nejprve načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "sf")

# k tomu, abychom byli v samotném načítání úspěšní, potřebujeme znát internetovou adresu souboru (končící na ".zip")
# tuto adresu vložíme do naší "načítací" funkce, kde ale navíc použijeme tzv. řetězení prefixů

# vhodné je před načítáním geodat podívat se, co je v archivu nebo ve složce k dispozici
# funkcí st_layers() z balíčku sf lze takto složky prohlížet
# demonstrujme na souboru pro Slovesnko, který na stránkách nabízí Evropská agentura pro životní prostředí (EEA)
st_layers("/vsizip//vsicurl/https://www.eea.europa.eu/data-and-maps/data/eea-reference-grids-2/gis-files/slovakia-shapefile/at_download/file/slovakia_shapefile.zip")

# a načteme jednu z vrstev
sk <- read_sf("/vsizip//vsicurl/https://www.eea.europa.eu/data-and-maps/data/eea-reference-grids-2/gis-files/slovakia-shapefile/at_download/file/slovakia_shapefile.zip",
                  layer = "sk_10km")

# podrobnosti k těmto postupům lze nalézt na stránkách knihovny GDAL, která je při tomto načítání vektorových geodat využívána
# viz https://gdal.org/en/latest/user/virtual_file_systems.html
# povšimněme si např. dvojitých lomítek za částí /vsizip (není to nutné, ale je to doporučováno)
