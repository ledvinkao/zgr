
# Zjištění obsahu složky nebo archivu s geodaty ---------------------------

# někdy se potřebujeme před načítáním geodat jen podívat, co je v archivu nebo ve složce k dispozici
# funkcí st_layers() s balíčku sf lze takto složky prohlížet
# využijme např. toho, že jž víme, že z ZIP souboru ze skriptu 03 je více takových vrstev

# načteme potřebný balíček
library(sf)

# a podíváme se, co je pro nás nachystáno v ZIP souboru s nádržemi
st_layers("/vsizip//vsicurl/https://www.dibavod.cz/data/download/dib_A05_Vodni_nadrze.zip")
