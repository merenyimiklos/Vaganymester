# VÁGÁNYMESTER – Interaktív oktatás, események, 3 nyelv

## 0.6.0

### Magyarország 1. pálya: valódi tanulópálya

A tanulópálya automatikusan, kézi forgalomirányítással indul.
A játéktér kézre álló, sárga fénnyel kiemelt valódi kezelőszervein
kell végrehajtani a műveleteket. Nem lehet egy „Következő” gombbal
átugrani az oktatást. A magyarázat az állomáskezelő megnyitása után is
látható; a váltóhoz vagy jelzőhöz automatikusan odagörget az UI.

1. **Kezdés** a tutorial buborékban.
2. **Állomás** az alsó navigációban, Fenyvesliget vezérlője megnyílik.
3. **Keleti váltó: 2. vágány** Fenyvesligeten.
4. **Keleti kijárati jelző: SZABAD**.
5. **Kőröspatak** kiválasztása az állomásfüleken.
6. **Nyugati váltó: 2. vágány** Kőröspatakon.
7. **Nyugati bejárati jelző: SZABAD**.
8. **Térkép** gombbal vissza az állomásirányításból.
9. **S 2412** vonatkártya megérintése.
10. **Indítás**, a vonat biztonságosan közlekedik.
11. **Megérkezés** kivárása.
12. **Automata forgalom** bekapcsolása és a többi menet teljesítése.

### Pályánkénti ismertető és új szabályok

Minden még nem látott szint első indítása külön, a választott nyelvre
fordított ismertetőt kap. Elmagyarázza az adott új játékmechanikát:
csúcsforgalom, köd, vágányzár, elsőbbség, tehervonatok, éjszaka,
fesztivál, hegyi vonalak, finálé.

A csúcsforgalom, rendezvény és a finálé pályákon pályára tévedő
gyalogos **nem grafikus, kitalált eseménye** történhet.
Az érintett vonali szakaszon a játékmotor azonnal megállítja a
vonatokat és az új indításokat. A játékosnak a kiemelt piros
**BIZTOSÍTOM A PÁLYÁT** gombot kell megnyomnia. A vészhelyzeti
visszaszámláló valós másodpercekben fut, hogy a gyorsítás ne tegye
teljesíthetetlenné a kihívást. Jó beavatkozásért +80 pont jár.
Válasz nélkül egy élet fogy, de nincs ábrázolt sérülés.

Ez kizárólag szórakoztató játékmodell, nem valós vasúti
biztosítóberendezési vagy vészhelyzeti eljárás.

### Nyelvek

**Magyar, English, Deutsch** kiválasztása a Beállításokban.
A választás újraindítás után is megmarad. A fő kezelőfelület
szövegei, az ország- és pályacímek, az új szintismertetők és a
tanulópálya instrukciói háromnyelvűek; minden hiányzó fordítás
magyarul jelenik meg (nincs üres gomb).

A pályák történetei és az összes szimulációs naplóüzenet további
finomhangolást igényelnek a teljes kiadás előtt.

### Tesztek

- tutorial helyes gombnyomás-sorrendje és első vonatindítás
- esemény és szakaszmegállítás, feloldás, időtúllépés
- a nyelvi váltás alapfeliratai, 60 egyedi pályacím
- korábbi szimulációs és kampánytesztek
