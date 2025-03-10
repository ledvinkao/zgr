
# Matematické operace s geometrií vektorových geodat ----------------------

# geometrický sloupec vektorových geodat je ve své podstatě třídy seznam
# lze s ním tedy provádět i matematické operace, jako je přičítání nebo násobení
# tato vlastnost se může hodit např. při systematickém posouvání bodů o několik metrů jakýmkoliv směrem

# demonstrujme s využitím metadat Úseku kvality ovzduší ČHMÚ

# načteme potřebné balíčky
xfun::pkg_attach2("tidyverse",
                  "arrow",
                  "sf",
                  "tmap")

# s Apache Parquet soubory lze zacházet podobně jako s databázemi
aqmeta <- open_dataset("metadata/airquality_metadata_pq")

# řekněme, že se budeme chtít omezit jen na veličinu O3
o3 <- aqmeta |> 
  filter(VELICINA_ZKRATKA == "O3") |> 
  collect()

aqmeta |> 
  filter(VELICINA_ZKRATKA == "O3") |> 
  select(AKTIVNI_OD, AKTIVNI_DO) |> 
  head(5) |> 
  collect()
