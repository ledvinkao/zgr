
# Načtení vektorových geodat přímo ze ZIP archivu (uloženého --------------

# shapefile zabalený v ZIP archivu je dosti častým jevem
# pokud máme stažený ZIP archiv na lokálním disku, není třeba jej rozbalovat, ale lze si načíst soubor s vektorovými geodaty z archivu přímo

# nejprve načteme potřebné balíčky
xfun::pkg_attach("tidyverse",
                 "sf",
                 install = T)

# cestu k ZIP souboru je potřeba doplnit prefixem "/vsizip"
# takto se můžeme např. podívat, jaká data na nás čekají v archivu
st_layers("/vsizip/geodata/dib_A05_Vodni_nadrze.zip")

# následně lze podobný trik s cestou aplikovat i při načítání dat
# povšimněte si, že existuje i funkce st_read()
# v obou funkcích st_read() i read_sf() lze psát i malá písmena ve slově "WINDOWS"
nadrze <- st_read("/vsizip/geodata/dib_A05_Vodni_nadrze.zip",
                  options = "ENCODING=windows-1250")

# objevuje se varování, že v ZIP souboru je více souborů k načtení a že byl vybran ten první
# to nám ale v tuto chíli vůbec nevadí
# jaký je rozdíl v načteném objektu oproti tomu ze skriptu 01?

# výsledek nemá třídu tibble, která je mnohem přehlednější
# existuje funkce st_sf(), která v kombinaci s funkcí as_tibble() pomůže
nadrze <- nadrze |> 
  as_tibble() |> 
  st_sf()

# podmínkou je přítomnost sloupce s geometrií