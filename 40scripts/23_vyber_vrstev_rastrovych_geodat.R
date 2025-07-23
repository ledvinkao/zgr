
# Výběr vrstev rastrových geodat ------------------------------------------

# existuje hned několik možností, jak vybrat vrstvy (pásma) rastrových geodat
# ukažme, jak to lze provést nativně s geodaty typu SpatRaster, a také, jak pomocí funkce select() z balíčku tidyterra

# nejpre načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "terra",
                  "tidyterra")

# načteme soubor
landsat <- rast(system.file("tif/L7_ETMs.tif",
                            package = "stars"))

# protože se rastrová geodata s více vrstvami chovají podobně jako seznam, lze pro výběr vrstev využívat dvojité hranaté závorky
landsat[[c(1, 3)]]

# lze ovšem používat také funkci select() z balíčku tidyterra
landsat |> 
  select(1, 3)

# samozřejmě se lze odkazovat na názvy vrstev (třeba i s využíváním regulárních výrazů)
landsat[[str_detect(names(landsat), "_1$|_3$")]]

landsat |> 
  select(matches("_1$|_3$"))

# pozor! s takto malým množstvím vrstev skoro nelze pozorovat rozdíl v délce operace, ale nativní způsob se závorkami je mnohem rychlejší
# rychlost zpracování se velice projevuje u velkých dat (s velkým množstvím vrstev)
tictoc::tic(); landsat[[str_detect(names(landsat), "_1$|_3$")]]; tictoc::toc()

tictoc::tic(); landsat |> 
  select(matches("_1$|_3$")); tictoc::toc()

# protože s vícevrstvým rastrem můžeme často zacházet jako se seznamem, lze pro výběr jedné specifické vrstvy použít i operátor $ následovaný názvem vrstvy
