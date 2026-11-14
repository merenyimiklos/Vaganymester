# VÁGÁNYMESTER — WPF forgalmi szolgálattevő szimulátor

## 🖥️ Windows telepítő – letöltés

**A Windows WPF-szimulátor teljes telepítője** egyetlen .exe fájl,
nincs szükség Visual Studióra vagy külön .NET-re.

[**VÁGÁNYMESTER Windows telepítő letöltése**](https://github.com/merenyimiklos/Vaganymester/releases/download/wpf-preview/Vaganymester-Windows-Setup.exe)

A telepítő Windows 10/11 x64 rendszerre készült, egyedi
ikont és sötét telepítőgrafikát tartalmaz. A program még
tesztverzió, digitális aláírás hiányában a Windows
SmartScreen figyelmeztetést jeleníthet meg.

---


Saját, tanulásra és játékra készült, egyállomásos **C# / WPF** szimulátor.

## Megnyitás Windows alatt

**Előfeltétel:** Windows 10/11, Visual Studio 2022 **17.13 vagy újabb** (WPF/.NET Desktop development komponenssel), vagy Visual Studio 2026, illetve .NET 8 SDK. A `.slnx` megoldásformátumhoz Visual Studio 2022 17.13+ vagy a .NET 9+ CLI ajánlott.

1. Csomagold ki a ZIP-et.
2. Dupla kattintással nyisd meg a `Vaganymester.slnx` fájlt Visual Studióban.
3. Válaszd a **Vaganymester** projektet indítási projektként.
   Alternatívaként dupla kattintással indíthatod az `INDITAS_WINDOWS.bat` fájlt (telepített .NET 8 SDK esetén).
4. Nyomd meg az **F5**-öt vagy az **Indítás** gombot.

Ha Visual Studio helyett parancssorból akarod futtatni, Windows alatt, megfelelő .NET SDK-val:

A kicsomagolt mappából futtasd:

```powershell
dotnet run --project .\Vaganymester\Vaganymester.csproj
```

**Fontos:** a WPF Windows-specifikus, Linuxon és macOS-en nem fut.

## Játékmenet

- A menetrendben szereplő vonatok maguktól érkeznek **nyugatról és keletről**.
- A bejárati és kijárati jelzők alaphelyzetben vörösek. A **Jelző / váltó** fülön kiválasztva nyithatók vagy zárhatók.
- Két váltó határozza meg, hogy a vonat az **1. vagy 2. vágányra** kerüljön, és melyik ágon hagyhatja el az állomást.
- A biztonságos vágányút-ellenőrzés megakadályozza a foglalt pályára vezető vágányút beállítását, és lezárja az igénybe vett váltót.
- A jelzők a vonat elhaladásakor automatikusan vörösre állnak vissza.
- A **Vonatok** fülön a kiválasztott mozdonyvezetőnek indulási, megállási, vészfékezési vagy veszélyes jelzőmeghaladási utasítást adhatsz.
- A **Személyzet** fülön külön mozdonyvezetők és rádióállapotuk látszik. Különböző fékezési reakciójuk van.
- A menetrend és az időbélyeges eseménynapló valós időben frissül.
- Új, rendkívüli személy-, IC- vagy tehervonatot is indíthatsz.
- A szimuláció sebessége **1–5×** között állítható. Szüneteltetés, +1 mp léptetés és újraindítás elérhető.

## Első sikeres menet — nyugatról keletre

1. A `W1` (nyugati) váltót hagyd az **1. vágányon**.
2. Állítsd az **N-BE** jelzőt **SZABAD** állásba, még mielőtt az első személyvonat odaérne.
3. A vonat belép az 1. vágányra, és a kijárati jelző előtt várakozik.
4. A `W2` (keleti) váltót is állítsd **1. vágány** állásba.
5. Ha a keleti vonalszakasz szabad, állítsd a **V1-K** kijárati jelzőt **SZABAD** állásba.
6. A vonat elhagyja az állomást; a teljesítés megjelenik a menetrendben.

Ugyanez keletről nyugatra: `W2` + `K-BE` bejárat, `W1` + `V1-N`/`V2-N` kijárat.

## Ütközéses próba

Az ütközések **szándékosan előidézhetők** az oktatási modellben. Például az 1. vágányra engedett egyik vonattal szemben a másik vonatot is ugyanoda engedheted, ha kikapcsolod a biztonságos vágányút-ellenőrzést, vagy a **Vörös meghaladása** utasítást adod ki. A vonatok fizikai helyzetét ellenőrzi a program, és átfedésnél balesetet naplóz, vörösre állít minden jelzőt, megállítja a forgalmat. Újraindítással kezdhető új szolgálat.

## Vezérlés

| Billentyű | Funkció |
|---|---|
| Space | Indítás / szünet |
| F2 | Rendkívüli személyvonat nyugatról |
| F3 | Rendkívüli személyvonat keletről |
| F5 | +1 mp léptetés |
| F9 | Újraindítás |

## Forráskód felépítése

- `Vaganymester.slnx` — Visual Studio megoldásfájl
- `Vaganymester/Vaganymester.csproj` — .NET 8 / WPF projekt
- `MainWindow.xaml` — kezelőpult és vágányrajz
- `MainWindow.xaml.cs` — gombok, billentyűk, WPF-időzítő
- `Models/` — vonat, mozdonyvezető, jelző, váltó, menetrend, események
- `Simulation/DispatchEngine.cs` — vágányút-ellenőrzés, vonatmozgás, fékezés, ütközések, menetrend

**Korlátok:** fiktív kétvágányos állomás, egyszerűsített kitérőgeometria és fékmodell, egyetlen vonalirány állomásonként; nincs teljes vasúti blokkbiztosítás, vágányútoldás, fékgörbe vagy szabályzati megfelelőség. A program kizárólag játék és oktatási célra készült, valódi vasúti forgalom irányítására nem használható.

### Új funkció: vonat belső nézete

- A pályarajzon egy vonatra kattintva külön WPF-ablak nyílik. A VONATOK fülön az **Utastér / ülésrajz** gombbal vagy a listán dupla kattintással is megnyitható.
- Személyvonaton 3, InterCityn 4 személykocsi látszik. Kocsinként A–D ülések, kétoldali üléspárok és középső folyosó található.
- A foglalt helyek mellett szimulált magyar utasnevek, jegytípusok, valamint a foglalt/szabad helyek száma és az összesített kihasználtság látszik.
- Egy ülésre kattintva szerkeszthető a rajta lévő utas vagy felszabadítható a hely. Az adatok a vonat objektumában maradnak, az ablak bezárása nem törli őket.
- A tehervonatnak nincs utastér; ezt a külön ablak jelzi.
- Az utasnevek automatikusan generált tesztadatok, nem valós utasok.


## Javítás: belépő vonatok várólistája és sötét kezelőfelület

- A menetrendi és rendkívüli vonatok a nyílt vonalon várnak, ha a bejárati szakasz foglalt.
- A biztonsági ellenőrzés megakadályozza, hogy ellenkező irányból érkező szerelvény jelenjen meg egy kihaladó vonat előtt.
- Azonos irányban is megmarad a követési térköz. A várakozási sor automatikusan újrapróbálkozik.
- A kijelző mutatja a várakozó vonatok számát és irányát, a menetrendben látható a várakozás oka.
- A kézzel indított rendkívüli vonatok is sorba állnak; legfeljebb 16 kérés várhat.
- Kikapcsolt biztosítással továbbra is vizsgálható a szembeforgalmi ütközés, de átfedő spawn nem engedélyezett.
- A főablak és a vonat részletező ablaka egységes, nagy kontrasztú sötét hátteret kapott.
- A fülek, gombok, listák, táblázatfejlécek és kombinált listák olvashatósága javult.

GitHub Actions munkafolyamat végzi a WPF-projekt Windowsos fordításellenőrzését a PR-eken.


## Újdonságok: Hálózati központ és automatikus forgalomirányítás

A program indulásakor a **Hálózati térkép** nyílik meg. Az eredeti állomási pult továbbra is
a **Kőröspatak** csomópont részletes kezelőfelülete. A két nézet ugyanazt a
DispatchEngine példányt használja, tehát a vonatok és a jelzőállapotok közösek.

Az első hálózati verzió **5 névvel ellátott állomást** jelenít meg:
Nyugati pályaudvar, Fenyvesliget, Kőröspatak, Tiszaváros, Keleti pályaudvar.
Kőröspatak a ténylegesen szimulált, kétvágányos állomás; a további négy
állomás egyelőre **sematikus hálózati csomópont**. A nyugati és keleti
vonalhoz kapcsolódó engedélyek a központi szimulációra valóban hatnak.
Ez még nem teljes, több különálló biztosítóberendezéssel rendelkező hálózat.

### Tíz új funkció

1. **Ötállomásos hálózati térkép** – kattintható pályaudvarok, csatlakozó vonalak.
2. **Élő vonatkövetés** – közeledő és a központi állomáson közlekedő szerelvények mozgó jelölői, vonatszám és státusz.
3. **Kézi belépési engedély** – a nyugati/keleti vonalról érkező forgalom külön tiltása vagy engedése.
4. **Kézi kihaladási engedély** – külön engedély az állomást nyugat vagy kelet felé elhagyó vonatoknak.
5. **Automata forgalmi szolgálattevő** – a jelzők és váltók automatikus állítása a szabad vágányok és vonatok alapján.
6. **InterCity-prioritás** – választható IC-elsőbbség a belépésre váró vonatok között.
7. **Vágányzár / pályamunka** – az 1. vagy 2. állomási vágány kizárása az új biztonságos vágányutakból.
8. **Késésfigyelés** – 15 másodpercnél nagyobb belépési késések számlálója, várakozási okok.
9. **Központi vészleállítás és feloldás** – minden aktív vonat megállítása és minden jelző vörösre állítása.
10. **Forgalmi napló CSV-exportja** – pontos szimulációs idővel, Excelben megnyitható magyar CSV-ként.

### Megjelenés

- Az állomási térképen modern, ablakos, színes szerelvényprofilok.
- Az utastérben lekerekített székek, ülésoldali díszcsík, szabad/foglalt színek,
  középső folyosó, kihasználtsági sáv és hosszanti vonatprofil.
- A hálózati központ sötétkék diszpécseri stílusa a korábban javított sötét témára épül.

### Játék / kezelés

- **Hálózati térkép**: az állomási pult fejlécében lévő gomb, illetve induláskor automatikusan nyílik.
- **Állomási kezelőpult**: visszavált a részletes jelző- és váltóállításhoz.
- **Állomás kiválasztása**: kattintás az öt csomópont egyikére.
- **Belépés / kihaladás**: a nyugati vagy keleti csatlakozó vonal lezárható; tiltott belépő menetrendi vonat várólistán marad.
- **Automata**: az "Automata jelző- és váltókezelés" kapcsoló a hálózati és az állomási nézetből is elérhető.
- **Vágányzár**: a beállítás az új vágányút-engedélyezést korlátozza. A már a vágányon haladó vonatot nem mozgatja át.
- **Vészleállítás**: automatikus mód kikapcsol, minden jelző vörös; a forgalom feloldása után a jelzők újra állítandók.
- **Napló exportálása**: mentés helyét és fájlnevét a felhasználó választja ki.

### További fejlesztési irány

A következő iterációban a négy csatlakozó állomás saját peronkapacitást,
helyi jelzőket és váltókat, vonatfordulókat, menetrendi késéseket és szakaszfoglaltságot
kaphat. Ehhez célszerű a mai egyállomásos szimulációs motort szakaszokra bontani,
és a vonatokat átadni az állomások között: csak ekkor lesz a hálózati nézet
teljes értékű, önállóan működő többállomásos biztosítóberendezési szimuláció.
