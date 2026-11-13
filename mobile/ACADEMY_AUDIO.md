# VÁGÁNYMESTER 0.7.0 – Akadémia, hangok és jutalmak

## Játékmenet

A vendégprofil után az első játékindítás a 10 tanulópályás
VÁGÁNYMESTER Akadémiára irányít. Az akadémia kihagyható külön
megerősítéssel; ilyenkor a normál országpályák azonnal elérhetők,
de nem jár oktatópont. A tanulópályák főmenüből később elérhetők.

Minden lecke a valódi RailwaySimulation és RailwayGame motort
vezérli. A kezelőszerv kiemelést kap, és csak helyes művelet lépteti.

1. Váltók, jelzők, indulás és első vonat megérkezése
2. Sebességváltás, szünet és folytatás
3. Állomások és több peron
4. Vonali vágányzár és feloldás
5. InterCity elsőbbsége és vonat kiválasztása
6. Tehervonatok és sebesség
7. Éjszakai műszak
8. Váratlan pályaveszély, biztosítás
9. Segítségkészlet, ajándék próbaláda
10. Automatikus irányítás és sikeres menet

Minden első teljesítés +80 oktatópont, végzéskor +220 bónusz.
Ismétléskor nincs új jutalom. 160 pont egy offline láda ára;
minden láda két garantált segítséget ad, véletlen tartalom nélkül.
Az oktatás pénzneme külön van a ranglista pontszámától.

## Hanganyagok

A mobile/tool/generate_audio.py tisztán a Python szabványos
moduljaival, eredeti szintézissel készít négy WAV fájlt:
menu_theme.wav, train_wheels.wav, train_horn.wav, success.wav.
A GitHub Actions ezt az Android APK előtt automatikusan futtatja;
helyi Flutter buildnél is futtatni kell. Nincs külső zenei minta.

Beállítások: HU/EN/DE, menüzene, vonathang, rezgés, hangerő,
sebesség és játékvezérlés. Saját nagy, időzített bezárható alert.

A mentés és a pontbolt offline. Nem tartalmaz valódi pénzes
vásárlást, szerveroldali gazdaságot vagy valódi vasúti vezérlést.
