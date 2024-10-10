
# Načtení vektorových geodat přímo ze ZIP archivu (internet) --------------

# leckdy ZIP soubor není ani nutné stahovat a vektorová geodata si lze vzít rovnou z archivu umístěného na internetu

# nejprve načteme potřebné balíčky
xfun::pkg_attach("tidyverse",
                 "sf",
                 install = T)

# k tomu, abychom byli v takovém načítání úspěšní, potřebujeme znát internetovou adresu souboru (končící na ".zip")
# tuto adresu vložíme do naší "načítací" funkce, kde ale navíc použijeme tzv. řetězení prefixů
nadrze <- read_sf("/vsizip//vsicurl/https://www.dibavod.cz/data/download/dib_A05_Vodni_nadrze.zip",
                  option = "ENCODING=windows-1250")

# podrobnosti k těmto postupům lze nalézt na stránkách knihovny GDAL, která je při tomto načítání vektorových geodat využívána
# viz https://gdal.org/en/latest/user/virtual_file_systems.html
# povšimněme si např. dvojitých lomítek za částí /vsizip