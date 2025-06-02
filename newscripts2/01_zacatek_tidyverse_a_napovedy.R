
# Načítání více R balíčků najednou ----------------------------------------

# klasicky načítáme balíčky po jednom funkcí library() - příp. uvnitř námi napsaných funkcí využíváme require()
library(tidyverse)

# pokud vím dopředu o více balíčcích, které budu potřebovat pro práci potřebovat, mohu je najednou načíst takto
xfun::pkg_attach("tidyverse", # když nechci načítat celý balíček xfun, využiji konstrukt s dvěma dvojtečkami (ten se hodí i pro specificakci balíčku, jehož funkci potřebujeme)
                 "sf", # pro vektorová geodata
                 "terra", # pro rastrová geodata
                 "tidyterra", # kdybychom náhodou potřebovali kreslit rastry ve smyslu ggplot2
                 install = T) # pokud není balíček nainstalovaný, nastavíme argument install = T (tedy nejprve instalujeme, pak načítáme)

# protože argument install = T je velmi častou volbou, existuje i varianta funkce xfun::pkg_attach2()
# tato funkce má nastavený argument install = T automaticky
xfun::pkg_attach("tidyverse",
                 "sf", 
                 "terra", 
                 "tidyterra")


# Budeme hodně využívat tidyverse slovesa ---------------------------------

# čtení nápověd je většinou lepší, než spoléhat se na AI
# povšimněme si především tzv. badges, které udávají, v jaké fázi vývoje funkce či její argumenty jsou
?mutate

# u této funkce, která je mj. základem funkcionálního programování ve smyslu tidyverse, si můžeme povšimnout i rady, jak v dnešním R definovat anonymní funkce
?map


# K dotazu o AI -----------------------------------------------------------

# když víme, co hledáme (např. nějaké sousloví), funkce sos::findFn() prohledá nápovědy na CRAN a vrátí přehled balíčků, které mohou kýženou funkci obsahovat (výskyty v tabulce mají dokonce ranky)
library(sos)

# složené závorky jsou právě pro hledání slov vedle sebe
findFn("{pycnophylactic interpolation}")

# toto už je jen pro aplikaci funkce bez nutnosti načítání celého balíčku sos
sos::findFn("{pycnophylactic interpolation}")

# alternativně lze importovat vybrané funkce balíčků podobně, jako v Pythonu
# k tomu slouží balíček import
import::from(sos, findFn)

# pak lze využít funkci findFn bez nutnosti upřesňovat balíček dvěma dvojtečkami
