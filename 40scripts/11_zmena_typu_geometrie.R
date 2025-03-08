
# Změna typu geometrie ----------------------------------------------------

# někdy je zapotřebí změnit typ geometrie
# některé další funkce (viz další skripty) to dokonce vyžadují
# ve skriptu 10 si můžeme všimnout, že po stažení vektorové vrstvy ze služby máme geometrii typu MULTILINESTRING
# převeďme tento typ na LINESTRING, tedy jednoduché linie

# nejprve načteme nutné balíčky
xfun::pkg_attach2("tidyverse",
                  "sf",
                  "arcgislayers")

# načteme všechny vodní toky na území Česka, které využívají státní podniky Povodí a rezort Ministerstva zemědělství
toky <- arc_read("https://agrigis.cz/server/rest/services/ISVSVoda/osy_vodnich_linii/FeatureServer/0") |> 
  as_tibble() |> 
  st_sf()

# typ geometrie lze měnit funkcí st_cast()
toky_jednoduche <- toky |> 
  st_cast("LINESTRING")

# existuje nějaký vodní tok, který je v modelu (nesprávně) rozdělen na více částí?
toky_jednoduche |> 
  st_drop_geometry() |> # raději se zbavíme geometrie, jinak by byl proces velmi zdlouhavý
  group_by(idvt) |> # grupujeme podle ID vodního toku
  count() |> 
  filter(n > 1)
