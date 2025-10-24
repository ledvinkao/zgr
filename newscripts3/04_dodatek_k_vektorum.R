
# Buffer a další užitečné funkce balíčku sf -------------------------------

# nejprve balíčky, o kterých tušíme, že je budeme potřebovat
xfun::pkg_attach2("tidyverse",
                  "RCzechia", # rovnou si s sebou bere i balíček sf
                  "sfheaders")

# dovysvětlení, co vlastně funkce st_area() počítá
# zajímavé je, že lze počítat i plochy a délky na sféře (příp. již i na elipsoidech), takže není nutné před výpočty ploch transformovat crs do plochojevné projekce
# viz nápovědu funkce st_area(), kde je využita Google knihovna S2 (někdy také oančovanou jako S2Geometry)
?st_area

# výpočty vzdáleností na sféře se pak umožňují výpočty délek ortodrom (angl. great circles)

# poznamenejme, že využívání knihovny S2Geometry lze vypínat a zapínat funkcí sf::sf_use_s2(), což může někdy pomoci při práci s údajně nevalidními geometriemi

# po spuštění nápovědy k funkci st_buffer() vidíme, že existují i jiné funkce
?st_buffer

# demonstrujme třeba tvorbu vepsaného kruhu tak, že se vrátíme k našemu obdélníku
mat <- matrix(c(16.35, 49.3,
                18.85, 49.3,
                18.85, 50.2,
                16.35, 50.2,
                16.35, 49.3),
              ncol = 2,
              byrow = T)

# funkce sfc_polygon() z balíčku sfheaders tvoří simple feature column, což je v pojetí tidyverse tzv. list-column, jak se ukazuje u objektu v globálním prostředí
# existují ale i funkce sfg_polygon() a sf_polygon()
# crs ale musíme nastavit až následně
obdelnik <- sfc_polygon(mat) |> 
  st_set_crs(4326) |> 
  st_transform(32633) # funkce st_inscribed_circle() má radši rovinné souřadnice

# tvoříme vepsaný kruh funkcí st_inscribed_circle()
kruh <- obdelnik |> 
  st_inscribed_circle()

# kreslíme situaci
# pro názornost ještě zobrazíme hranice Česka
hranice <- republika(res = "low") |> 
  st_transform(32633) # aby crs byly stejné

ggplot() + 
  geom_sf(data = hranice,
          fill = NA,
          col = "darkblue") + 
  geom_sf(data = obdelnik,
          fill = NA,
          col = "red",
          linewidth = 1.5) + 
  geom_sf(data = kruh,
          fill = "grey20")

# nyní k samotnému bufferu
# demonstrujme na polygonu území Česka
hranice_buf <- hranice |> # crs již máme transformovaný od kreslení
  st_buffer(units::set_units(50, km)) # využíváme funkce balíčku units, abychom se nemuseli zdržovat s převody z metrů

# je tu i možnost zadávání záporných čísel 
hranice_buf2 <- hranice |> 
  st_buffer(units::set_units(-20, km))

# vykresleme situaci s oběma buffery
ggplot() + 
  geom_sf(data = hranice,
          fill = NA) +
  geom_sf(data = hranice_buf,
          fill = NA,
          col = "red") +
  geom_sf(data = hranice_buf2,
          fill = NA,
          col = "blue")


# Poznámka k nastavování a převodu jednotek -------------------------------

# balíček units a jeho funkce lze využít i pro převod jiných jednotek
# takto lze převést aktuální venkovní teplotu vzduchu ze °C na °F
units::set_units(10, "°C") |> # při specifikaci jednotek někdy nemusíme používat uvozovky ani moninné vyjadřování jednotek; zkoušejte
  units::set_units("°F")


# Poznámka k ggplot objektům s uloženými grafy ----------------------------

p1 <- ggplot() + 
  geom_sf(data = hranice,
          fill = NA) +
  geom_sf(data = hranice_buf,
          fill = NA,
          col = "red") +
  geom_sf(data = hranice_buf2,
          fill = NA,
          col = "blue")

# ggplot objekty mají také možnost být podrobeny funkci summary()
summary(p1)

# přitom tříd zde máme hned několik
class(p1)
