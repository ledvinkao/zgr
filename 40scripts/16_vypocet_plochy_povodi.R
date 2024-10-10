
# Výpočet plochy povodí ---------------------------------------------------

# obdobně je i plocha povodí vodního toku velmi důležitým parametrem v hydrologii
# řekněme, že chceme zjistit, kolik km2 zaujímají na území Česka jednotlivá úmoří

# nejprve načteme potřebné balíčky
xfun::pkg_attach("tidyverse",
                 "sf",
                 "arcgislayers",
                 install = T)

# polygonovou vrstvu s úmořími lze nahradit polygony povodí 1. řádu
# tuto polygonovou vrstvu lze najít na webu s otevřenými geodaty ĆHMÚ (viz https://open-data-chmi.hub.arcgis.com/)
umori <- arc_read("https://services1.arcgis.com/ZszVN9lBVA5x4VmX/arcgis/rest/services/rozvodnice5G_1_radu/FeatureServer/2") |> 
  as_tibble() |> 
  st_sf()

# někdy se stane, že vektorová vrstva není validní
# může to být způsobeno tím, že současný GIS pracuje s otevřenou knihovnou s2 od fy Google, která upřednostňuje práci na sféře spíše než v rovině
# dalším důvodem může být fakt, že starší GIS systémy, ve kterých byly některé vrstvy tvořeny, nepodporovaly geometrii typu MULTIPOLYGON
# a je to i případ této polygonové vrstvy, jak se můžeme přesvědčit funkcí st_is_valid()
st_is_valid(umori)

# validitu geometrie můžeme získat funkcí st_make_valid()
umori <- umori |> 
  st_make_valid()

umori |> 
  st_is_valid()

# nyní už lze počítat plochy, ale před výpočtem je nutné transformovat geometrii na plochojevný crs
# v Evropě se používíá pro výpočty ploch crs s EPSG:3035 (viz https://epsg.io/3035)
umori <- umori |> 
  st_transform(3035) |> 
  mutate(plocha = st_area(geometry) |> 
           units::set_units(km2) |> 
           round(2))

# vytáhneme si sloupce, které nás zajímají, a zahodíme geometrii
umori_dulezite <- umori |> 
  select(naz_pov,
         plocha) |> 
  st_drop_geometry()

# povšimněme si také, jak výhodné je mít tabulky třídy tibble
# po aplikaci funkce units::set_units() zde máme informaci o jednotkách pod názvem sloupce
