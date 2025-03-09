
# Hnízdění vektorových geodat ---------------------------------------------

# při analýzách vektorových geodat se někdy vyplatí tzv. hnízdění atributových tabulek
# při práci s vektorovými daty se tato vlastnost přirozeně nabízí, a to zvláště tehdy, je-li atributová tabulka třídy tibble

# demonstrujme tuto vlastnost na našich metadatech vodoměrných stanic, kde chybí informace o administrativním kraji
# informaci o příslušnosti ke kraji získáme prostorovým dotazem

# načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "RCzechia", # balíček sf je načítán automaticky
                  "arcgislayers")

# načteme kraje
kraje <- kraje() |> 
  as_tibble() |> 
  st_sf()

# načteme metadata stanic a rovnou propojujeme s kraji
meta <- read_rds("metadata/wgmeta2023.rds") |> 
  st_transform(4326) |> 
  st_join(kraje) |> 
  filter(!is.na(NAZ_CZNUTS3)) # zbavujeme se řádků, kde kraj i tak nakonec není

# nyní můžeme hnízdit dle kraje a počítat např. medián plochy povodí nad stanicí v každém kraji
meta <- meta |> 
  group_by(NAZ_CZNUTS3) |> # dobré prostudovat vinětu
  nest(data = -c(KOD_KRAJ:NAZ_CZNUTS3)) # znaménko minus je negace

# vzniká list-column, který obsahuje vše, co jsme chtěli zahnízdit
# pomocí funkcionálnío programování získáváme nový sloupec s mediánovou plochou
meta <- meta |> 
  mutate(medarea = map_dbl(data,
                           \(x) st_drop_geometry(x) |> 
                             pull(plo_sta) |> 
                             median(x, 
                                    na.rm = T) |> # kyby se náhodou vyskytla chybějící hodnota
                             round(2)
  )
  )
