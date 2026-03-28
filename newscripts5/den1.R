# nový R skript založen klávesovou zkratkou CTRL+SHIFT+N
# pro začátek předpokládáme, že pracujeme v R projektu, takže můžeme používat relativní cesty k souborům apod.
# postupně si také v komentářích zakládáme sekce klávesovou zkratkou CTRL+SHIFT+R, které nám pak umožní přeskakovat v osnově po jednotlivých tématech
# dodejme na začátku také, že na GitHubu máme ke kuru repozitář 'zgr' s materiály včetně 40 bonusovýh skriptů, seznamem základních klávesových zkratek užívaných na české klávesnici v IDE RStudio a také elektronickou verzi prezentace s funkčními odkazy
# tento repozitář se vyplatí sledovat i dále, protože bude aktualizován


# Začátek -----------------------------------------------------------------

# vyzkoušeli jsme založení sekce v komentářích
# vysvětlili jsme si, jak se v R komentáře uvozují a jak funguje např. klávesová zkratka CTRL+SHIFT+C pro komentování většího (označeného) množství řádek

# důležité je umět načítat R balíčky
# klasicky je načítáme funkcí library(), pokud chceme všechny jejich funkce mít v RAM

# následující řádek jsme schválně zakomentovali, protože existují efektivnější způsoby načítání R balíčků
# library(tidymodels)

# tidymodels je tzv. metabalíček, které s sebou přináší více balíčků najednou
# tidymodeling je jeden z moderních přístupů ke strojovému učení v R


# Odbočka - odkaz na Python -----------------------------------------------

# bavili jsme se o elektronických knihách a materiálěch na internetu, které se vztahují k tzv. prostorové datové vědě

# zmínili jsme i přístupy prostorové datové vědy pro sociální geografy, které excelentně popisuje M. Fleischmann z Univerzity Karlovy
# M. Fleischman ale preferuje programovací jazyk Python, viz jeho stránky:
# https://martinfleischmann.net/sds/


# Daleko ------------------------------------------------------------------

# sekce Daleko vznikla jen pro demonstraci toho, jak moc užitečné může být vytváření sekcí, když chceme přepnout na sekci, která je hodně daleko od začátku


# Moderní přístupy k načítání balíčků a šetrnější volání funkcí -----------

# pokud použijeme konstrukt balíček::funkce(), znamená to, že se odkazueme konkrétně na unikátní funkci pocházející z nějakého balíčku
# výhody jsou minimálně dvě: 1) nedochází ke konfliktům (popletením) funkcí, které jsou jinak stejně nazvány, 2) nemusíme balíček načítat celý
# nevýhodou je, že musíme pochopit, že balíček, ze kterého takto funkci voláme, musí být nainstalovaný předem

# takto si jednoduše otevřeme texťáček s nastavením R prostředí
# balíček usethis ale musí být nainstalován
usethis::edit_r_environ()

# takto podobně otevřeme texťáček týkající se profilového nastavení
usethis::edit_r_profile()

# vždy po práci s nastavením environmentu (prostředí) a profilu musíme soubor uložit (klasicky zkratkou CTRL+S) a restartovat R sezení (session), aby přenastavení mělo efekt
# zkratkovitě lze R sezení restartovat klávesami CTRL+SHIFT+F10

# využití dvojitých dvojteček lze i kombinovat
# tady nám balíček mapview a jeho funkce mapview() zobrazí dynamickou mapu
# funkce republika() (z balíčku RCzechia) pomáhá rychle zobrazit polygon s územím Česka
# funkce republika() ve skutečnosti stahuje vektorová data z internetu, takže dobré připojení k internetu je nutností
mapview::mapview(RCzechia::republika())

# ale, dokud nerestartujeme R sezení, dočasný soubor, do kterého se polygon uložil dlí někde u nás v souborovém systému
# takže se po opětovném volání funkce republika() nic z internetu nestahuje, ale načítá se to z dočasného souboru

# následuje moderní způsob načítání více balíčků najednou
# hodí se tehdy, pokud na začátku skriptu víme, že budeme potřebovat funkce více balíčků (či metabalíčků) najednou
# balíček xfun musí být nainstalovaný, vše ostatní se řeší automatickou instalací v případě absence
# automatické instalace docílíme právě uvedením čísla 2 za funkcí pkg_attach()
# pkg_attach() totiž nemá instalaci nastavenou na TRUE a s FALSE jen načítá předem nainstalované balíčky (v případě absence balíčku se setkáme s chybou)
xfun::pkg_attach2("tidyverse", # jde o metabalíček, proto hlásí načtení více balíčků najednou
                  "sf", # pro vektorová geodata; linkuje se k externím knihovnám, což nám po načtení říká
                  "terra") # jak pro vektorová data, tak ale hlavně pro rastrová geodata

# balíček xfun je mimochodem plejádou nejrůznějších utilitek se kterými začal čínský programátor Yihui Xie, který se věnuje dynamickému textu a je také autorem tinytexu
# existují určitě i jiné moderní způsoby načítání balíčků, viz např. příspěvek https://joshuamarie.com/posts/06-load-pkg/


# Dodržujme citační etiku -------------------------------------------------

# když už pro nás někdo šikovné R napsal, naučme se ho správně citovat
# existuje pro to funkce citation()
citation()

# když chceme zjistit, jak a co chtějí citovat autoři balíčků, specifikujeme v argumentu package
# nemusí jít jen o balíček jako takový, může jít i o článek či dokonce knihu
citation(package = "sf")


# Nápovědy k funkcím ------------------------------------------------------

# když známe název funkce, lze použít otazníček před tímto názvem
?st_sfc

# rovněž je možné stisknout klávesu F1 zatímo jsme ve skriptu někoho zkušenějšího, kdo zná plejádu takových funkcí, s kurzorem právě na tomto názvu
# existují i jiné možnosti (dva otazníčky, či dokonce tři otazníčky pojící se s funkcí sos::findFn())


# Načítání vektorových geodat ---------------------------------------------

# v balíčku sf pro toto existují balíčky st_read() a read_sf()
# podívejme se do nápovědy
?read_sf

# každá načítá vektorová geodata trochu jinak
# st_read() jako obyčejnou data frame tabulku (s vektorovým sloupcem)
# read_sf() jako moderní tibble tabulku (s vektorovým sloupcem)
# st_read() je aktuálně také upovídanější při načítání vektorových geodat

# vyzkoušejme načtení shapefilu s vodními nádržemi v Česku
# předpokládá se, že jsem napřed stáhli ZIP soubor ze struktury DIBAVOD VÚV TGM (https://www.dibavod.cz/27/struktura-dibavod.html)
# a rozbalili jsme obsah ZIP souboru do předpřipravené složky projektu 'geodata' (proto můžeme použít relativní cestu)
nadrze <- st_read("geodata/a05_vodni_nadrze.shp") # ze všech souborů shapefilu se musíme odkázat na .shp

# prohlédneme
nadrze

# lepší tisk do konzole získáme tak, že budeme mít typ tabulky tibble
nadrze <- read_sf("geodata/a05_vodni_nadrze.shp")

nadrze

# klasicky pak můžeme zkoumat parametry tabulky včetně jejích názvů
colnames(nadrze)

# to dovoluje vybírat dle názvů sloupců funkcí select()
nadrze |> 
  select(OBJECTID, NAZ_NA)

# všimněme si, že se kromě chtěných sloupců stále vybírá i geometrie (je tzv. přilepená, 'sticky')


# Některé speciální funkce pro geometrii ----------------------------------

# často se stává, že jedna funkce (s jedním názvem) plní různé úlohy
# což je i případ funkce st_geometry(), jejíž varianty přidávají geometrii nebo třeba i sloupec s ní přejmenovávají
nadrze |> 
  select(OBJECTID, NAZ_NA) |> 
  st_set_geometry("geom") # funkce st_set_geometry() je variantou funkce st_geometry(), která vyhovuje pipe operátorům

# tímto si již geometrii přejmenujeme natvrdo (máme zde přiřazení)
st_geometry(nadrze) <- "geom"

# v současnosti však patrně pro přejmenování existuje i způsob přejmenování geometrie přes funkci rename()
# což dříve nešlo
nadrze |> 
  select(OBJECTID, NAZ_NA) |> 
  rename(objid = OBJECTID,
         geometry = geom)

# geometrie se zbavujeme funkcí st_drop_geometry()
# děláme to z důvodu, že geometrie může být v případech, kdy ji již nepotřebujeme, dosti otravná (zpomaluje výpočty apod.)
nadrze |> 
  select(OBJECTID, NAZ_NA) |> 
  rename(objid = OBJECTID,
        geometry = geom) |> 
  st_drop_geometry() |> 
  View() # studenti mají rádi se na tabulky dívat funkcí View(), která je volána i při poklepání na objekt v Globláním prostředí


# Nastavení správného kódování znaků při načítání shapefilu ---------------

# fakt, že specifikujeme příponu načítaného souboru, také aktivuje daný driver knihovny GDAL
# každý driver má svá doplňující nastavení pro načítání i ukládání (viz https://gdal.org/en/stable/drivers/vector/index.html)
# to nám pomůže nastavit i správné kódování pro českou diakritiku v atributové tabulce
nadrze <- read_sf("geodata/a05_vodni_nadrze.shp",
                  options = "encoding=windows-1250") # nezáleží na velikosti písmen

# vidíme, že teď je vše v pořádku
nadrze


# Přímé načtení vektorových geodat ze ZIP souboru či internetu ------------

# GDAL umožňuje tzv. řetízky, které dopomohou načíst geodata bez rozbalení nebo dokonce bez stažení souboru z internetu
# takto např. můžeme i díky řetězení odkazu prohlížet obsah ZIP souboru
st_layers("/vsizip/geodata/dib_a05_vodni_nadrze.zip")

# jsou zde i jakési doplňky, které však jsou jen v databázové tabulce a nejsou prostorovými daty
# vlastnosti GDAL však mohou být nápomocny i zde, např. právě při nastavení kódování znaků
doplnky <- read_sf("/vsizip/geodata/dib_a05_vodni_nadrze.zip",
                   layer = "a05_doplnujici_charakteristiky",
                   options = "encoding=windows-1250")

# přesvědčíme se o pravdě
doplnky

# nejen prohlížení metadat vrstev, ale i načítání je možné rovnou z internetu
# podmínkou však je, že známe přímý odkaz, jehož hledání může někdy působit bolesti hlavy:-)
st_layers("/vsizip/vsicurl/https://www.dibavod.cz/data/download/dib_A05_Vodni_nadrze.zip")

# z dokumentace knihovny GDAL jsme se také přesvědčili, že i RAR soubory jsou podporovány


# Ukládání vektorových geodat do souborů ----------------------------------

# v moderním světě již do shapefilu neukládáme, i když to je možné

# R nabízí i možnosti tzv. serializovat objekt z RAM a uložit jej do RDS souboru
# k tomu existuje základní funkce saveRDS()
?saveRDS

# nebo tidyverse funkce write_rds()
?write_rds

# při ukládání je lepší specifikovat i složku R projektu, ve které chceme uchovávat geodata
write_rds(nadrze,
          "geodata/nadrze_se_spravnym_kodovanim.rds",
          compress = "gz") # můžeme určit i kompresi

# znovu načteme funkcí read_rds() nebo readRDS()
nadrze_z_rds <- read_rds("geodata/nadrze_se_spravnym_kodovanim.rds")

# ukažme, jak takový znovunačtený soubor vypadá
# jsou zde uchovány správné třídy sloupců, což nepochybně výhoda
nadrze_z_rds

# nevýhodou je, že jsou RDS soubory jen málo rozšířeny mimo R komunitu
# takovým kolegům jsme nuceni předávat jiné typy souborů, ze kterých jsou schopni vektorová geodata dostat
# v takovém případě používáme funkce st_write() nebo write_sf()

# takto uložíme např. do shapefilu
# ukazuje se chyba týkající se délek názvů sloupců
# i to je důvod, proč do shapefilu příště již neukládat
write_sf(nadrze,
         "geodata/nadrze_se_spravnym_kodovanim.shp",
         layer_options = "encoding=utf-8") # tohle přiměje driver uložit i CPG soubor, což je malý texťáček s uvedením kódování znaků v atributech

# uložme geopackage
write_sf(nadrze,
         "geodata/nadrze_se_spravnym_kodovanim.gpkg")

# geopackage může obsahovat klidně více (vektorových) vrstev najednou, což si vzápětí ukážeme
st_layers("geodata/nadrze_se_spravnym_kodovanim.gpkg")

# ukažme ještě uložení do geojson souboru
write_sf(nadrze,
         "geodata/nadrze_se_spravnym_kodovanim.geojson")


# Další funkce pracující s geometrií - transformace -----------------------

# načtěme pro demonstraci balíček tmap, což je jedena z nelepších prerekvizit pro tvorbu a ukazování si tematických map 
library(tmap)

# balíček tmap obsahuje i vrstvu pro kreslení světa
svet <- World |> 
  as_tibble() |> # vrstva World je typu data frame, tak ji převedeme na tibble
  st_sf() # a hned pak zase na simple feature collection

# geometrii můžeme zobrazit v jiném souřadnicovém systému
# když kreslíme ve smyslu tmap, je to podobné jako u ggplot2, vždy ale specifikujeme novou vrstvu funkcí tm_shape()
tm_shape(svet,
         crs = "ESRI:54024") + # takto lze specifikovat souřadnicový systém (tmap si potrpí na velká písmena při uvádění autority před dvojtečnou)
  tm_graticules() + # kreslí souřadnicovou síť (poledníky a rovnoběžky)
  tm_borders() # pro kreslení polygonů existují funkce tm_borders() - kterslí hranice, a tm_polygons() - kreslí polygony, tedy i s možnostmi výplní

# získali jsme tak jednoduchý nákres světa v tzv. Bonneho zobrazení

# když chceme natrvalo změnit souřadnicový systém u vektorových geodat, aplikujeme funkci st_transform()
nadrze_transformed <- nadrze |> 
  st_transform("epsg:32633") # tady je již jedno, zda písmo je velké či malé (transformovali jsme do WGS 84 UTM Zone 33N; kódů pro Česko je jen pár, což si lze snadno zapamatovat)

# uložíme opět do geopackage
write_sf(nadrze_transformed,
         "geodata/nadrze_se_spravnym_kodovanim.gpkg")

# teď jsme si původní layer v geopackage přepsali
st_layers("geodata/nadrze_se_spravnym_kodovanim.gpkg")

# to lze ale napravit specifikací argumentu layer, abychom ukládali do různých vrstev
write_sf(nadrze_transformed |> 
           st_transform(5514),
         "geodata/nadrze_se_spravnym_kodovanim.gpkg",
         layer = "nadrze_krovak")

# podívejme se, skutečně je vrstev v geopackage souboru již více
st_layers("geodata/nadrze_se_spravnym_kodovanim.gpkg")

# jak je vidět, lze v jednom geopackage souboru uchovávat více vrstev najednou
# co ale tehdy, pokud máme za úkol uložit stovky až tisíce takových vrstev do jedné geopackage?
# určitě to nechceme dělat ručně
# v takových případech můžeme využít tzv. mapping ukládací funkce, což již vyžaduje znalosti základů funkcionálního programování


# Potenciál funkcionálního programování při ukládání ----------------------

# základem funkcionálního programování ve smyslu tidyverse je funkce map() pocházející z balíčku purrr
?map

# pro tzv. vedlejší efekty, ke kterým náleží i exportování něčeho z prostředí R (ukládání souborů, do jisté míry i kreslení), využíváme její obdobu walk()

# vytvořme nejprve seznam s vektorovými vrstvami (mapping funkce provádíme přes prvky seznamu nebo vektoru)
nadrze_seznam <- list(nutm = nadrze_transformed, # seznam může mít prvky pojmenované
                      nkrovak = nadrze_transformed |> 
                        st_transform(5514))

# o názvech prvků seznamu se snadno přesvědčíme
nadrze_seznam |> 
  names()

# když chceme mapovat funkci přes více seznamů nebo vektorů, využijeme obdobné funkce map2(), walk2() nebo dokonce pmap() pwalk() 
# walk2() umožnuje dva seznamy, vektory, nebo jejich kombinace
walk2(nadrze_seznam,
      names(nadrze_seznam),
      \(x, y) write_sf(x, # vytváříme zde tzv. anonymní funkci využívající funkci write_sf(); x a y jsou zástupné proměnné
                       "geodata/nadrze_ukazka_funkcionalniho_programovani.gpkg",
                       layer = y)) # důležité je, že měníme název vrstvy v závislosti na tom, co je ukládáno

# nahlédneme do výsledného souboru
st_layers("geodata/nadrze_ukazka_funkcionalniho_programovani.gpkg")


# Získávání vektorových geodat R funkcemi ---------------------------------

# již víme, že existuje funkce pro získání polygonu území Česka
# funkci republika() najdeme v balíčku RCzechia
hranice <- RCzechia::republika()

# tento balíček však obsahuje mnoho dalších funkcí pro zisk vektorových (ale i rastrových) geodat

# načtěme balíček geodata a ukažme si některé jeho funkce
library(geodata)

# balíček geodata se pojí s balíčkem terra, takže:
# 1) v balíčku terra již takové funkce nenajdeme (což byl případ staršího balíčku raster)
# 2) většinou se setkáme s vektorovými geodaty ve třídě SpatVector, což je nativní třída balíčku terra pro vektorová geodata

# SpatVector lze ale snadno konvertovat na simple feature collection

# často potřebujeme pro stahování geodat pojících se s nějakou zemí právě kódy těchto zemí
# existuje funkce, která nám tyto kódy pomáhá hledat
# zkusme Polsko
country_codes("Poland")

# potřebujeme hlavně třímístné kódy

# při této znalosti můžeme funkcí gadm() stáhnout polygon území Polska
polsko <- gadm(country = "POL",
               level = 0, # 0 znamená, že nechceme vnitřní členění
               path = "geodata") # nastavujeme cestu pro stažení, odkud se pak geodata načítají bez nutnosti dalšího stažení (např. při dalším R sezení)

# jak vypadá hlavička třídy SpatVector?
polsko

# dokáže mapview kreslit SpatVector?
mapview::mapview(polsko)

# a co tmap?
tm_shape(polsko) +
  tm_graticules() +
  tm_borders()

# takto si SpatVector převedeme na simple feature collection
polsko_sf <- polsko |> 
  st_as_sf() # musíme použít funkci st_as_sf() z balíčku sf()

# nefunguje, není k dispozici geometrie
polsko |> 
  st_sf()

# funkcí ttm() z balíčku tmap přepínáme mód kreslení (ze statických map na dynamické a zpět)
ttm()

# přitom si můžeme všimnout, že zde máme méně podkladových map než nabízí mapview
tm_shape(polsko) +
  tm_borders()

# přepněme zpět na statické mapy
ttm()

tm_shape(polsko) +
  tm_borders()

# funkcí tmap::tm_polygons() zaručíme možnosti kreslení ohraničení i výplní
tm_shape(polsko) +
  tm_polygons(col = "purple",
              fill = "green",
              lwd = 3) # týká se tloušťky hranice


# Funkcionální programování jako pomocník při stahování geodat ------------

# odpovídali jsme si na otázku, jak je možné funkcí gadm() získat polygony více zemí
# sama funkce gadm() tuto možnost nenabízí
# ani funkce country_codes() pro to není uspůsobena
?country_codes

# co ale funkce country_codes() umí, je hledat řádky spjate se zeměmi pomocí tzv. regulárních výrazů
# toho můžeme využít třeba, když nevíme, zda je Česko uváděno jako 'Czechia' nebo 'Czech Republic'

# vytvoříme vektor hledaných výrazů
# a ten podrobíme mapování
c("Czech", "Slovakia", "Germany") |> 
  map_chr(\(x) country_codes(x) |> # map_chr() zde má smysl, protože výsledkem každé iterace je textový řetězec
            pull(ISO3)) # funkce pull() vytahuje sloupec do vektoru (tady bude vždy jednoprvkový, pokud jde o individuální iteraci)

# na základě právě uvedeného lze vytvořit nový vektor 'kody' a ted využít dále
kody <- c("Czech", "Slovakia", "Germany") |> 
  map_chr(\(x) country_codes(x) |> 
            pull(ISO3))

# toto je případ mapované funkce gadm() bez nutnosti nastavení anonymní funkce
staty <- map(kody,
             gadm) # všimněme si, že není nutné používat závorky za mapovanou funkcí

# stažené vrstvy jsou ale nyní v nějaké složce systému, kterou musíme pracně hledat zkoumáním dokumentace funkcí
# možná bude přece jen lepší nastavit anonymní funkci pro ukládání do námi zvolené složky projektu
staty <- map(kody,
             \(x) gadm(x,
                       path = "geodata")) # ještě bychom mohli nastavit úroveň administrativního členění

# výsledkem tohoto mapování funkce je seznam
# takže se můžeme k jeho jednotlivým prvkům dostat třeba dvojitými hranatými závorkami
staty[[1]]

# další otázka se týkala kreslení všech vrstev najednou
# velmi pěknou možností jsou tzv. facety, které fungují i u balíčku tmap
# připravme si pro facety vhodný podklad
# převedeme na celistvou simple feature collection, což zajistí funkce list_rbind(), která spojuje prvky seznamu, když to dává logický smysl
staty_sf <- staty |> 
  map(st_as_sf) |> 
  map(as_tibble) |> 
  list_rbind()

# máme tibble s ukrytou geometrií
# tak tedy můžeme aplikovat st_sf() pro stavbu kolekce
staty_sf <- staty_sf |> 
  st_sf()

# takhle sice lze kreslit v jedné mapě
tm_shape(staty_sf) + 
  tm_borders()

# ale pro kreslení v individuálních oknech lze využít facety
tm_shape(staty_sf) + 
  tm_borders() + 
  tm_facets(by = "COUNTRY", # alternativně bylo možné použít tm_facets_wrap()
            free.coords = T, # dovolíme různá měřítka na osách ve facetách
            nrow = 3) # chceme kreslit do jednoho sloupce tři řádky


# Tvorba vlastních vektorových geodat -------------------------------------

# často si potřebujeme vytvořit vlastní vektorová geodata s tím, že máme v tabulce k dispozici nějaké údaje, které nám pomohou (např. souřadnice)

# jako příklad může sloužit stavba bodové vektorové vrstvy z geografických souřadnic uvedených v metadatech vodoměrných stanic ČHMÚ

# nejprve odkaz na JSOn soubor
url <- "https://opendata.chmi.cz/hydrology/historical/metadata/meta1.json"

# pak konverze JSON souboru na seznam obsahující matici (tabulku s daty) a její hlavičku
# musíme mít nainstalovaný balíček jsonlite
stanice <- jsonlite::fromJSON(url)

# jedná se o tzv. hierarchická data, kde jsou prvky seznamů, které potřebujeme pěkně hluboko
# k těmto prvkům se potřebujeme nějak dostat
# pomohou např. dolárky

# tohle je kýžená matice
stanice$data$data$values

# tohle je kýžený (jednoprvkový) vektor s hlavičkami
stanice$data$data$header

# toto je doporučený (rychlý) postup stavby tabulky pomocí tidyverse funkcí
stanice <- stanice$data$data$values |> 
  as.data.frame() |> 
  as_tibble() |> 
  set_names(stanice$data$data$header |> 
              str_split_1(",")) |> # pozor! na konci této funkce není písmeno 'l', ale číslice 1
  janitor::clean_names() # balíček janitor musí být nainstalovaný, jeho funkce clean_names() nastavuje vhodnější názvy sloupců z těch původních

# ještě zbývá nastavit správné třídy u některých sloupců
# evidentně mají některé sloupce být numerické, ne textové
# děláme to hlavně kvůli souřadnicím, které musí vstupovat jako numerické do následujících funkcí
stanice2 <- stanice |> 
  mutate(across(c(geogr1:geogr2, dryh:spa4h, dryq:plo_sta), # across() potřebuje zaprvé vybrat sloupce (akceptuje i tidy selection) a zadruhé znát funkci, která na vybrané sloupce má být aplikována
                as.numeric)) # pokud funkci nepotřebujeme zadat další argumenty, je uváděna bez závorek (podobně jako u funkce map())

# nakonec stavíme simple feature collection
stanice2 <- stanice2 |> 
  st_as_sf(coords = c("geogr2", "geogr1"), # nejprve délka, potom šířka (v tabulce je to podle čísel prohozené)
           crs = 4326, # kde specifikujeme kódem souřadnicový systém (crs); funkcím balíčku sf stačí klidně jen číselný kód, když jde o standardní EPSG autoritu
           remove = F) # remove = F znamená, že souřadnice z atributové tabulky nezmizí (ale defaultně je nastaveno remove = T)

# sloupců je hodně, tak pro demonstraci vybereme jen identifikátory, abychom ukázali, že geometrie je přilepená
# toto ne asi nejjednodušší příklad geometrie, kde máme zakódovány jen dvojice souřadnic pro body
stanice2 |> 
  select(obj_id)

# ukázali jsme si, že geometrii odstranit lze i za pomoci select(), když nejprve sf collection převedeme např. na tibble
stanice2 |> 
  as_tibble() |> 
  select(obj_id)

# geometrii odtranit nelze za pomoci select(), když tuto funkci aplikujeme na sf collection
stanice2 |> 
  select(obj_id, -geometry)

# ale lze použít st_drop_geometry()
# čímž se ze sf colletion stává opět tabulka (mizí hlavička a další vlastnosti spjaté s geometrií)
stanice2 |> 
  select(obj_id) |> 
  st_drop_geometry()

# pojďme kreslit
# v balíčku tmap neexistuje funkce tm_points()
# ale můžeme využít tm_dots() nebo jiné obdobné funkce, jako je tm_bubbles(), tm_symbols() apod.
stanice2 |> 
  tm_shape() + 
  tm_dots()

# přejděme na dynamické kreslení
ttm()

stanice2 |> 
  tm_shape() + 
  tm_dots(size = 0.4,
          fill = "darkblue")


# Význam predikátů při výběrech -------------------------------------------

# řekli jsme si, že výběry bodů budeme demonstrovat na polygonu Olomouckého kraje
olomoucky <- RCzechia::kraje()

# nevíme přesně, jak se ve vrstvě Olomoucký kraj jmenuje tak to zkusíme s reguálrními výrazy
olomoucky <- olomoucky |> 
  filter(str_detect(NAZ_CZNUTS3, "^Olomoucký"))

olomoucky <- olomoucky |> 
  as_tibble() |> 
  st_sf()

# hranaté závorky můžeme použít jako zkratku namísto funkce st_filter(), která je mimochodem příbuzná funkci st_join()
# defaultně je nastavený predikát st_intersects()
# jednoduše v závorkách omezujeme na řádky, které prostorově spadají do polygonu Olomouckého kraje
stanice2_olomoucky <- stanice2[olomoucky, ]

# kreslíme situaci
tm_shape(stanice2_olomoucky) + 
  tm_dots(size = 0.4,
          fill = "darkolivegreen")

# když chceme aplikovat jiný predikát, musíme ho nastavit argumentem op
stanice2_neolomoucky <- stanice2[olomoucky,
                                 op = st_disjoint]

# tady se tedy vykreslí vše, co není v Olomouckém kraji
tm_shape(stanice2_neolomoucky) + 
  tm_dots(size = 0.4,
          fill = "darkolivegreen")

# predikátů je mnohem více, stačí se podívat na dokumentaci některého z nich
# nápověda je koncipována hromadně
?st_disjoint


# Vizuální editace vektorových geodat -------------------------------------

# umožňují funkce balíčku mapedit
library(mapedit)

# demonstrovali jsme si přidání polygonu v kartě Viewer
stanice3_olomoucky <- stanice2_olomoucky |> 
  editFeatures()

# výsledek jsme prohlíželi z důvodu zvědavosti, co se vlastně ve vrstvě stalo
# měli jsme bodovou vrstvu, ale přidali jsme do ní polygon
stanice3_olomoucky

# na tento polygon jsme se takto zaměřili blíže
# a vykreslili jsme jej
stanice3_olomoucky |> 
  filter(!is.na(layerId)) |> 
  tm_shape() + 
  tm_polygons()


# Tvorba polygonu manuálním zadáním souřadnic -----------------------------

# při tvorbě nových vektorových geodat tímto způsobem hodně pomáhá balíček sfheaders
library(sfheaders)

# demonstrujme tvorbu geometrického sloupce z matice souřadnic
obdelnik <- sfc_polygon(obj = matrix(c(15, 50,
                                       16, 50,
                                       16, 51,
                                       15, 51,
                                       15, 50),
                                     ncol = 2,
                                     byrow = T))

# nastavíme souřadnicový systém
obdelnik <- obdelnik |> 
  st_set_crs(4326)

# podívejme se, co vzniklo
obdelnik

# vykresleme
tm_shape(obdelnik) + 
  tm_polygons()

# zde vidíme další aplikaci funkce st_set_geometry()
# vytvoříme jednoduchou tabulku (atributy) a pak k ní přidáme geometrický sloupec (musí být třída sfc)
tab <- tibble(nazev = "vymyšlený obdélník") |> 
  st_set_geometry(obdelnik)

tab

# detaily souřadnicových systémů lze mimochodem zkoumat funkcí st_crs()
# ta snadradně zobrazuje tzv. WKT (well-known text) string
st_crs(tab)
