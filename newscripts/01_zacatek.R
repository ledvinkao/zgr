
# Práce s datumem a časem ve smyslu lubridate -----------------------------

# načítání více balíčků najednou bez nutnosti nastavovat install = T
# je nutné mít nainstalovaní balíček xfun
xfun::pkg_attach2("tidyverse", # načte se všech 9 jádrových balíčků, včetně lubridate, který byl přidaný poměrně nedávno (je určen právě pro práci s datumy a časy)
                  "sf", # klíčový balíček pro práci s vektorovými geodaty
                  "terra") # balíček vybrán jen pro ukázku, abychom viděli že se funkce tidyr::extract() a terra::extract() maskují (aneb záleží na pořadí načítání balíčků)

# proč nefunguje jediný kód v prezentaci - chybí určit, jak textový řetězec souvisí s datumem
# navíc pozor na kopírování různých typů uvozověk z textů odjinud
cas <- seq(from = ymd("2025-03-13"), 
           to = ymd("2025-03-14"), 
           by = "day")

# jaké publikace se vztahují k balíčku sf?
citation("sf")

# balíček sos odpoví na otázku, zdali neexistují již nějaké funkce, které bychom potřebovali pro náš úkol 
# nechceme přece utrácet svůj čas psaním něčeho, co již existuje
library(sos)

# funkce findFn() je základní funkcí balíčku sos
findFn("{pycnophylactic interpolation}") # složenými závorkami uvnitř uvozovek se zaměřujeme na přesné výskyty slov vedle sebe

# funkci findFn() lze údajně nahradit třemi otazníky, tedy ???

tidyr::extract() # řešení konfliktů v názvech funkcí - používáme konstrukt s dvěma dvojtečkami
