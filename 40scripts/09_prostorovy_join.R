
# Prostorový join ---------------------------------------------------------

# někdy potřebujeme připojit atributy z jedné tabulky k druhé právě na základě geometrické příslušnosti
# jako vhodný nástroj se k tomuto úkolu jeví funkce st_join(), která opět standardně uvažuje možnost s st_intersects()
# dejme tomu, že kromě toho, ke které pobočce ČHMÚ patří vodoměrná stanice potřebujeme ještě informaci o příslušnosti ke kraji

# načtení balíčků
xfun::pkg_attach("tidyverse",
                 "RCzechia", # balíček sf se tímto načítá automaticky
                 install = T)

# práce s metadaty
meta <- read_rds("metadata/qdmeta2023.rds") |> 
  st_as_sf(coords = c("UTM_X", "UTM_Y"),
           crs = 32633) |> 
  st_transform(4326)

# načtení vrstvy administrativních krajů
kraje <- kraje()

# kvůli demonstraci se zaměříme jen na podstatné sloupce
# po aplikaci funkce select() geometrie zůstává (jde o tzv. "přilepenou geometrii, angl. sticky geometry")
meta <- meta |> 
  select(ID:BRANCH)

kraje <- kraje |> 
  select(kraj = NAZ_CZNUTS3)

# nyní aplikujeme připojení pomocí st_join()
meta <- meta |> 
  st_join(kraje)

# existuje nějaká stanice, ke které se nepřipojil žádný kraj?
meta |> 
  filter(is.na(kraj))

# jaké jsou počty stanic v jednotlivých regionech?
meta |> 
  count(kraj)

# vidíme, že geometrie je teď na obtíž
# můžeme se jí ale napřed i zbavit
meta |> 
  st_drop_geometry() |> 
  count(kraj)
