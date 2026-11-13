# VÁGÁNYMESTER – országok és kampány (0.4.0)

A játék új kampányrendszere 6 országból, összesen 60 pályából áll.
Egy országban mindig 10 különböző helyzet van, saját névvel, célokkal,
vonattípusokkal, forgalmi paraméterekkel és különböző nehézséggel.

## Országok

| Ország | Vasúti világ | Játékbeli jellemző |
| --- | --- | --- |
| 🇭🇺 Magyarország | Alföld, Balaton, Budapest | klasszikus regionális és IC, köd, fesztivál |
| 🇦🇹 Ausztria | Alpok, Railjet, Brenner | lassabb hegyi pálya, téli forgalom |
| 🇨🇭 Svájc | Gotthard, Bernina, S-Bahn | hegyvidéki vonalak, szűkebb időcél |
| 🇩🇪 Németország | ICE, Ruhr-vidék, S-Bahn | sűrű elővárosi vonatok és gyors ICE |
| 🇮🇹 Olaszország | kikötők, Frecciarossa, partvidék | gyorsvonat és mediterrán helyszínek |
| 🇯🇵 Japán | Sinkanszen, Tokió, hanami | nagy sebesség és sűrű forgalom |

*Játékban megjelenített, leegyszerűsített, kitalált vasúti helyzetek: a
vonali geometria, sebesség és biztosítóberendezés nem hiteles valós
nemzeti vasúti adat.*

## Pályánkénti 10 különleges küldetéstípus

1. Alapszolgálat, jelző- és váltókezelés
2. Csúcsforgalom, sok vonat, rövid indulási időközök
3. Köd, valós játéksebesség-csökkentéssel
4. Vágányzár, ténylegesen lezárt állomási peron
5. Expressz elsőbbség, több IC és nagyobb sebesség
6. Teherforgalom, lassabb szerelvények
7. Éjszakai szolgálat, külön világítás és lassítás
8. Rendezvényforgalom, több vonat
9. Hegyvidéki szakasz, sebességkorlátozás
10. Országos finálé, több vonat, magasabb cél

Minden szinthez külön név és leírás tartozik az adott országról.
Az országok más állomásokat, szerelvényjelölést és vonali alaptempót
használnak, és a világ színei, domborzata is eltér.

## Nehézség és értékelés

A pályák **1–5 csillagos nehézséggel** jelennek meg:
1–2: ★☆☆☆☆, 3–4: ★★☆☆☆, 5–6: ★★★☆☆,
7–8: ★★★★☆, 9–10: ★★★★★.

Az eredmény értékelése ettől független, **1–3 jutalomcsillag**:

- ★★★ – hibátlanul, az adott időcélon belül
- ★★ – legfeljebb egy elveszített élettel, az időcél 165%-án belül
- ★ – minden más túlélve teljesített pálya

A szint akkor teljesül, ha az adott számú állomásközi menet sikeres.
A szimuláció leáll, a csillagos értékelés megjelenik, és a következő
szint feloldódik. A pályát újra lehet játszani, a legjobb eredmény marad.

Az induláskor csak **Magyarország 1. pályája** nyitott. Az előző pálya
legalább egy csillagos teljesítése kell a következőhöz.
Az ország 10. pályája megnyitja a következő ország első pályáját.

Az eredmények **vendégjátékosnévenként és eszközönként** mentődnek
SharedPreferences-ben, nem kapcsolódnak online fiókhoz.
A meglévő helyi pont-ranglista is megmarad.

## Forráskód

- \`lib/game/level_catalog.dart\`: 6 ország, 60 pálya, célok, játékmódok
- \`lib/game/campaign_progress.dart\`: lépésenkénti feloldás és csillagok
- \`lib/game/simulation.dart\`: szintfüggő vonatok, nehézség, idő és cél
- \`lib/data/session_store.dart\`: profilhoz tartozó offline mentés
- \`lib/ui/campaign_screen.dart\`: országok és szintek választóképernyője
- \`lib/ui/dispatch_screen.dart\`: teljesítés és következő szint
- \`lib/game/playful_world.dart\`: országonként eltérő színek és tájrészletek
- \`test/campaign_test.dart\`: 9 kampány- és szimulációs teszt

## Még tervezett

Helyszínenként összetettebb váltók és csomóponti topológiák,
sebesség- és időkorlátozó táblák, egyedi országos vonatspritelok,
objektív menetrendi késéspontozás, pályánkénti történet és előzetes animációk.
