# VÁGÁNYMESTER Mobile – vizuális irány 0.3

A mobiljáték élénk, modern, gyerekbarát vasúti szimulációként fejlődik.
A megjelenéshez a kortárs casual/tycoon játékok világos, letisztult,
színes és jól olvasható kezelőfelülete ad inspirációt. A játék grafikai
elemei saját rajzolt vektoros elemek, nem más játékból átvett képek.

## Mit tartalmaz ez az iteráció?

- Vadonatúj, **világos 2D dioráma** hátterű interaktív Flame-térkép.
- Színes hegyek, folyó, fák, állomásépületek, peronok és sínek.
- A vágányok és aktív váltóutak a szimulációs állapothoz igazodnak.
- Új, színes vonatrajzok, ablakok, kerekek, fények.
- Új vendégbelépő képernyő, eredeti rajzolt háttérrel.
- Világos, játékos HUD: pont, élet, szint, feladatok.
- Játékmenethez kötött zöld indítógomb, vonatkártya és kényelmes
  alsó navigáció.
- Kétujjas nagyítás/kicsinyítés és kameramozgatás a Flame-komponensen.
- A WPF-szerű részletes állomásirányítás világos stílusú alsó panelben.

A modern UI szándékosan **nem egyetlen képként van betéve**: az
állomások, vágányok, vonatok, foglaltságok és jelzők továbbra is
interaktív Flame-komponensek, amelyek a valódi játékmotort jelenítik meg.

## Amit még érdemes továbbfejleszteni

Ez az első, működő grafikai átépítés. A látványtervek részletesebb,
3D-ben renderelt vasútállomási épületei és járművei még külön grafikai
asset/animáció-fejlesztést igényelnek. A következő iterációkban tervezett:

1. Külön spritesheet a szerelvényekhez és az épületekhez.
2. Animált jelzőfények, mozgó váltókarok és pályaudvari NPC-k.
3. Külön állomásjelenet és hálózati nézet, eltérő zoomszintekkel.
4. Modern küldetésanimáció, pontugrás, jutalomképernyő.
5. Folyamatos játékmentés, menetrend és WPF funkcióegyezőség.
6. Telefonos érintési, teljesítmény- és vizuális QA.

## Technikai szabály

A játéklogika változatlanul a \`game/simulation.dart\` fájlban él.
A színes világ rajzolása a \`game/playful_world.dart\` fájlban van.
Az UI a \`ui/dispatch_screen.dart\` és \`ui/main_menu.dart\` alatt.
A megjelenítésnek nincs joga szakaszfoglaltságot vagy vágányutat
átírni a szimuláció megkerülésével.

A játék oktatási/szórakoztatási célú, nem valós biztosítóberendezés.
