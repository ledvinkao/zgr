
# Kresba RGB kompozitu ----------------------------------------------------

# někdy je vhodné připravit si viditelná pásma a vykrelsit si tzv. RGB kompozit

# nejprve načteme potřebné balíčky
# předpokládáme ale, že máme k dispozici i balíček stars s daty
xfun::pkg_attach("tidyverse",
                 "terra",
                 install = T)

# načteme soubor
landsat <- rast(system.file("tif/L7_ETMs.tif",
                            package = "stars"))

# RGB kombinace není připravena
has.RGB(landsat)

# tak ji připravíme vhodným výběrem pásem (každá mise to může mít jinak!)
RGB(landsat) <- c(3, 1, 2)

has.RGB(landsat)

# takže kreslíme
plot(landsat)
