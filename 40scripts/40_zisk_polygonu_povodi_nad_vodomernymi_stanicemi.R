
# Zisk polygonů povodí nad vodoměrnými stanicemi v Česku ------------------

# v hydrologii často potřebujeme pracovat s povodími nad vodoměrnými stanicemi
# důvodem může být porovnání průtokové časové řady s řadami získanými z klimatologických měření (např. ve formě gridu)
# existují sice podrobné vrstvy rozvodnic pro území Česka (např. povodí 4. řádu), ale ty v tomto smyslu hydrologa neuspokojí
# budeme si tedy muset takovou vrstvu odvodit sami
# předpokládá se velmi dobré připojení k internetu, jelikož potřebné geografické vrstvy budeme stahovat

# načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "sf",
                  "arcgislayers")

# získejme všechny nejmenší polygony povodí na podkladě informací na https://open-data-chmi.hub.arcgis.com/datasets/chmi::rozvodnice-povod%C3%AD-4-%C5%99%C3%A1du-roz%C5%A1%C3%AD%C5%99en%C3%A9/about
# na konci si ještě upravujeme textové řetězce, aby správně obsahovaly znaky NA pro chybějící hodnoty (může se hodit i pro jinou práci)
catch <- arc_read("https://services1.arcgis.com/ZszVN9lBVA5x4VmX/arcgis/rest/services/rozvodnice5G_4_radu_plus/FeatureServer/6") |> 
  as_tibble() |> 
  st_sf() |> 
  mutate(across(where(is.character),
                \(x) if_else(x == "", NA, x)))

# zachovejme si tabulku jen s řádky, které obsahují řádky s ID vodoměrných stanic
# využíváme vedlejšího efektu (nezvyklá ID, tj. některé dbcn, jsou konvertovány na hodnoty NA uvnitř funkce filter())
# vybereme jen ty nejdůležitější sloupce před napojením části s geometriemi
stations <- catch |> 
  st_drop_geometry() |> 
  filter(!is.na(as.numeric(dbcn))) |> 
  select(dbcn,
         chp_14_s,
         chp_14_s_u)

# připravíme se na paralelizovaný výpočet prostřednictvím funkce in_parallel() - viz dokumentaci k funkcím balíčku purrr
catch2 <- catch |> 
  left_join(stations,
            join_by(between(chp_14_s, # zde využíváme nové funkce join_by(), která není závislá jen na rovnosti klíčů
                            chp_14_s_u,
                            chp_14_s))) |> 
  filter(!is.na(dbcn.y)) |> 
  nest(rest = -dbcn.y)

# před spuštěním musí být zavoláni tzv. démoni, jejich počet je závislý na počtu logických jader toho kterého stroje
# k tomnu potřebujeme následující funkce balíčku mirai
mirai::daemons(0) # dáváme jen pro případ nutnosti přepnutí na sekvenční zpracování

mirai::daemons(parallelly::availableCores() - 1) # aby byl skript obecný, zjišťujeme nejprve počet dostupných jader a zmenšujeme jej o jedničku, abychom klidně mohli dělat ještě něco jiného

# spustíme proces sjednocování polygonů po řádcích reprezentujících jednotlivé stanice
# měříme též strávený čas
# a nakonec si necháme zahrát fanfáru, která nás zvukově upozorní, že je vše hotové:-)
# podle dokumentace je třeba se ještě ujistit, zda budeme moci proces paralelizovat
mirai::require_daemons() # odteď by funkce map(), walk() apod. měly umožňovat paralelní spouštění funkcí uvnitř in_parallel()

tictoc::tic(); catch3 <- catch2 |> 
  mutate(rest = map(rest,
                    in_parallel(\(x) {
                      xfun::pkg_attach2("tidyverse",
                                        "sf")
                      st_union(x)
                    }))) |> # neznámé objekty v dalších, než je hlavní proces, představujeme za definicí funkce
  unnest(rest) |> 
  st_sf() |> # protože výsledek funkce unnest() je tibble
  st_set_geometry("geoms") |> # přejmenujeme sloupec s geometrií
  rename(id = dbcn.y); tictoc::toc(); beepr::beep(3)

# vypočítáme si plochy nově vzniklých polygonů
catch3 <- catch3 |> 
  mutate(a = st_area(st_transform(geoms,
                                  3035)) |> 
           units::set_units("km2") |> 
           round(2)) |> # v ČHMÚ je zvykem zaokrouhlovat km2 na dvě desetinná místa
  arrange(desc(a)) # pro potřeby kreslení, je dobrým zvykem mít největší povodí vespod (tedy v atributové tabulce v řádcích na začátku)

# zbavíme se povodí s nulovou plochou
catch3 <- catch3 |> 
  filter(a > units::set_units(0,
                              "km2"))

# výsledný objekt uložíme do RDS, abychom s ním mohli v R pracovat dále
write_rds(catch3,
          "results/povodi_nad_738_stanicemi.rds",
          compress = "gz")
