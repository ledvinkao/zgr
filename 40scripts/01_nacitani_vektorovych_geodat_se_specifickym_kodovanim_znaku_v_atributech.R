
# Načtení souboru typu shapefile s jiným kódováním znaků než UTF-8 --------

# často se stává, že narazíme na zastaralá vektorová geodata, která mají v souborech jiné kódování znaků v atributech, než je dnes standardní UTF-8
# někdy se dokonce stává, že načítaný soubor nemá ani definovaný referenční souřadnicový systém (crs)
# v takovém případě má smysl v českém prostředí zkoušet např. crs s EPSG kódem 5514 (velmi pravděpodobné, pokud v souřadnicích vidíme záporná čísla)
# s takovými případy se často setkáváme např. ve spojení s tzv. shapefilem (asi nejrozšířenějším typem souboru s vektorovými geodaty)
# příklady takových dat jsou soubory tzv. Digitální báze vod (DIBAVOD), kterou udržuje Výzkumný ústav vodohospodářský T. G. Masaryka, v.v.i.
# stáhněme např. ZIP soubor s vodními nádržemi z https://dibavod.cz/27/struktura-dibavod.html a vše rozbalme (sekce A - základní jevy povrchových a podzemních vod)

# načtěme potřebné balíčky pro následující načtení souborů, které jsou uvnitř tohoto archivu
# nejdůležitější je SHP soubor a na ten také musíme odkázat driver podpůrné knihovny GDAL
# stejně tak budeme muset nastavit správné kódování
xfun::pkg_attach2("tidyverse",
                  "sf")

nadrze <- read_sf("geodata/dib_a05_vodni_nadrze/a05_vodni_nadrze.shp", # předpokládáme umístění staženého souboru ve složce geodata našeho R projektu
                  options = "ENCODING=WINDOWS-1250")
