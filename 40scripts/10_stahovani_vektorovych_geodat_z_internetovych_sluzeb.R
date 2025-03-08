
# Stahování vektorových geodat z internetu --------------------------------

# poslední dobou se množí případy, kdy jsou různá vektorová geodata sdílena prostřednictvím různých serverů
# často se setkáme s tzv. ArcGIS REST API službami, což je důsledek toho, že mnohé instituce využívají komerční licence firmy ESRI a nemají vlastní servery pro tento účel
# často se tedy setkáme s vektorovými geodaty nabízenými přes tzv. FeatureServery nebo MapServery
# existuje více balíčků, jejichž funkce umožňují získat z internetu vektorová geodata, ale v současnosti se osvědčil balíček arcgislayers

# načtení balíčků
xfun::pkg_attach2("tidyverse",
                  "sf",
                  "arcgislayers")

# jedním z mnohých webů, které nabízí otevřená vodohospodářská geodata prostřednictvím takových služeb je portál https://voda.gov.cz/
# zde můžeme např. nalézt odkaz na vektorovou vrstvu s osovým modelem vodních toků na území Česka a bezprostředního okolí
# k načtení potřebujeme znát odkaz, který lze u detailů vrstvy najít
# nesmíme zapomenout také dodat číslo vrstvy (tím musí odkaz končit)
# když nebudeme specifikovat crs, vrstva se načte s crs, který služba nabízí standardně (v Česku EPSG:5514)

toky <- arc_read("https://agrigis.cz/server/rest/services/ISVSVoda/osy_vodnich_linii/FeatureServer/0") |> 
  as_tibble() |> # zbytek je prováděn z důvodu získání třídy tibble pro simple feature collection
  st_sf()
