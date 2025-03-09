
# Rastrové vrstvy jako prvky seznamu --------------------------------------

# v balíčku terra nechybí ani funkce pro konverzi SpatRasteru na seznam a naopak
# někdy může být výhodne takto rastrová geodata konvertovat (např. z důvodu aplikace vektorizované funkce uvnitř funkce map() či walk())

# načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "terra")

# načteme rastrová geodata s více vrstvami
landsat <- rast(system.file("tif/L7_ETMs.tif",
                            package = "stars"))

# zkontrolujeme třídu
class(landsat)

# lze aplikovat i jiné funkce pro exploraci dat
str(landsat)

glimpse(landsat)

# aplikujme funkci as.list()
landsatl <- as.list(landsat)

class(landsatl)

str(landsatl)

glimpse(landsatl)

# zkusme nyní jednotlivé vrstvy zapsat do souborů na disk zvlášť
# rovnou pojďme měřit i čas procesu
tictoc::tic(); landsatl |> 
  walk(\(x) writeRaster(x,
                        str_c("results/",
                              names(x),
                              ".tif"),
                        overwrite = T)); tictoc::toc() # overwrite nastavujeme, abychom se zbavili hlášek, že určitý soubor již existuje (prostě jej přepíšeme)

# schvalně, co je rychlejší
nms <- str_c("results/",
             names(landsat),
             ".tif")

tictoc::tic(); landsat |> 
  writeRaster(nms,
              overwrite = T); tictoc::toc()

# je třeba volit specifické strategie v závislosti na úloze a na stroji, na kterém hodláme data zpracovávat
