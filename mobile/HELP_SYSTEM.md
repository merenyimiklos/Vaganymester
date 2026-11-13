# Segítségek és ládák – 0.5.0

A játékos induláskor 1 ingyenes ládát kap. Minden új, korábban még
nem teljesített pálya után további 1 láda jár. A pályák újrajátszása
nem ad újabb ládát, de a megszerzett csillagok javíthatók.

A láda tartalma nem véletlenszerű: minden láda **2 garantált segítséget**
ad előre meghatározott, forgó sorrendben. Nincs pénz, fizetés vagy hirdetés.

## Fogyóeszközök

- **Merre tovább?** Megmutatja a következő biztonságos vágányút-lépést.
- **Szabad vágány radar** Megkeresi a fogadó állomás egy szabad vágányát.
- **Jelző- és váltósegéd** A következő szükséges biztosítóberendezési
  művelethez magyarázatot és a cél megnyitását adja.

A segítséget a jobb oldali sárga izzó gombbal lehet használni.
A játékos választhat, melyikből fogyaszt. Ha nem található használható
tanács, az eszköz nem fogy el. A tipp kiemeli a vonatot és az állomási
kezelőpult megfelelő váltóját vagy jelzőjét; ez nem állítja át helyettünk.

A játékosnévhez kötött készlet és a megszerzett ládák helyben
mentődnek. A későbbi addonokhoz a készletműveletek elő vannak
készítve, de **vásárlás, backend és valódi pénz nincs**.

A jobb oldali sebességgombon mindig szerepel a jelenlegi szorzó
(1×, 10×, 30× vagy 60×), rákattintva kiválasztható a másik.

A feladatpanel alaphelyzetben csukva van, a menet-progress látszik;
megérintve nyitható.

## Ikon

A grafikai arculathoz illő, eredeti alkalmazásikon forrása:
\`mobile/assets/launcher_icon.svg\`. A \`tool/generate_launcher_icons.py\`
script Androidhoz minden szükséges mipmap méretet generál és beállítja
az alkalmazás nevét és fekvő tájolását. Ha létezik iOS Runner projekt,
annak ikon méreteit is előállítja. A GitHub Actions a scriptet minden
Android APK build előtt lefuttatja.

Ezzel az Android launcher ikon valóban megváltozik, nem csak
a Flutter UI egy képe.
