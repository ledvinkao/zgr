
# Funkce extract() --------------------------------------------------------

# v balíčku terra existuje velmi důležitá funkce extract()
# tuto funkci lze využít k extrakci hodnot rastru pro body, které se v místě buňky rastru nacházejí
# funkci lze použít i pro extrakci hodnot podél linie, ale hlavně ji lze zaměstnat agregováním hodnot rastru uvnitř polygonu

# nejprve načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "RCzechia", # balíček sf je načten automaticky
                  "terra",
                  "geodata")

# demonstrujme význam této funkce na sklonitosti svahu v Česku a okolí
dem <- elevation_30s(country = "CZE",
                     path = "geodata",
                     mask = F)

sklon <- terrain(dem,
                 v = "slope",
                 filename = "geodata/CZE_slp.tif",
                 overwrite = T)

values(sklon) |> 
  range(na.rm = T)

# potřebujeme ještě nějaké polygony přes které budeme agregovat
# vezmeme si např. administrativní kraje Česka
# tato vektorová vrstva je dokonce ve stejném crs, takže není nutné transformovat
# ale nové verze balíčku terra už vlastně transformace téměř nepotřebují, protože vektorová geodata jsou bez předchozí transformace crs automaticky transformována do crs rastru
kraje <- kraje()

# funkce crs() pochází sice z balíčku terra, ale od nějaké doby ji lze použít i na objekt třídy sf
crs(kraje) == crs(sklon)

# aplikujme funkci extract() a vypočítejme např. mediánový sklon v každém kraji
# povšimněme si, že funkce má i argument "bind", kterým dáváme najevo, že výsledné hodnoty chceme připojit do tabulky vektorové vrstvy
# jinak by výsledkem byla jen matice
# v tomto případě vlastně ani nepotřebujeme ID polygonu
kraje <- extract(sklon, # zde je zvykem, že na prvním míste je vždy rastr
                 kraje,
                 fun = median, # lze ale nastavovat jakoukoliv anonymní funkci
                 bind = T) |> # výsledkem je nativní vektorový objekt balíčku terra (SpatVector)
  st_as_sf() |> # ten lze převést na simple feature kolekci
  as_tibble() |> # a dále u něj měnit třídu na tibble
  st_sf()
  
# nastavení argumentu exact = T sice dá přesné podíly buněk podle hranice polygonu, ale výpočet pak trvá mnohem déle
