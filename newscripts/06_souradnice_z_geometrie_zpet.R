
# Jak získat souřadnice z geometrie zpět do sloupců -----------------------

# pokud se nakonec přece jenom rozhodneme někomu předat tabulku se souřadnicemi, je možnost je dostat z geometrie zpět

# nejprve načteme potřebné balíčky
xfun::pkg_attach("tidyverse",
                 "sf",
                 "arrow")

# demonstrujme na metadatech kvality ovzduší
meta <- open_dataset("metadata/airquality_metadata_pq") |> 
  collect() |> 
  st_as_sf(coords = c("ZEMEPISNA_DELKA",
                      "ZEMEPISNA_SIRKA"),
           crs = 4326)

# skutečně jde o sf
meta |> 
  class()

# funkce st_coordinates() vrací matici
meta |> 
  st_coordinates()

# podobně jako funkce base::colbind(), funkce bind_cols() může připojit tuto matici k původním datům
?bind_cols

# zakládáme nový objekt, abychom se případně mohli snadno vrátit
meta2 <- meta |> 
  bind_cols(st_coordinates(meta))

# všimneme si, že nové sloupce se jmenují X a Y
colnames(meta2)

# pokud budeme vědět, že souřadnice, ze kterých skládáme geometrii mají zůstat součástí tabulky, zvolíme při stavění sf argument remove = F
?st_as_sf
