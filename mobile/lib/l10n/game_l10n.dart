/// Three-language offline interface strings with Hungarian fallback.
/// The selected language is persisted by SessionStore.
class GameL10n {
  GameL10n._();

  static const supported = <String>['hu', 'en', 'de'];
  static String language = 'hu';

  static String tr(String hu, [Map<String, Object> args = const {}]) {
    var result = hu == 'Légy te a\nforgalom mestere!'
        ? (language == 'en' ? 'Become the\nrailway master!'
            : language == 'de' ? 'Werde Meister\nder Zugleitung!'
                : hu)
        : _table[hu]?[language == 'de' ? 1 : 0] ?? hu;
    if (language == 'hu') result = hu;
    for (final entry in args.entries) {
      result = result.replaceAll('{' + entry.key + '}', entry.value.toString());
    }
    return result;
  }

  static final Map<String, List<String>> _table = {
    for (final row in _raw.trim().split('\n'))
      if (row.split('|').length == 3)
        row.split('|')[0]: row.split('|').sublist(1),
  };

  static const _raw = '''
BEÁLLÍTÁSOK|SETTINGS|EINSTELLUNGEN
KÉSZ|DONE|FERTIG
BEZÁRÁS|CLOSE|SCHLIESSEN
JÁTÉK INDÍTÁSA|PLAY|SPIELEN
BELÉPÉS|CONTINUE|WEITER
VENDÉG BELÉPÉS|GUEST PROFILE|GASTPROFIL
Játékos neve|Player name|Spielername
Üdv a központban!|Welcome back!|Willkommen zurück!
Vendégváltás|Change player|Spieler wechseln
Adj meg egy nevet, és kezdődhet a szolgálat!|Enter a name to begin!|Gib einen Namen ein und starte!
Adj meg egy játékosnevet!|Please enter a player name!|Bitte gib einen Spielernamen ein!
🚆  ÚJ VASÚTI KALAND|🚆 NEW RAILWAY ADVENTURE|🚆 NEUES BAHNABENTEUER
⭐ Pontgyűjtés   ❤️ 3 élet   🏆 Ranglista|⭐ Points   ❤️ 3 lives   🏆 Leaderboard|⭐ Punkte   ❤️ 3 Leben   🏆 Bestenliste
RANGLISTA|LEADERBOARD|BESTENLISTE
HELYI RANGLISTA|LOCAL LEADERBOARD|LOKALE BESTENLISTE
Még nincs eredmény. Teljesíts egy szolgálatot!|No results yet. Complete a shift!|Noch keine Ergebnisse. Schließe eine Schicht ab!
Automatikus irányítás|Automatic control|Automatische Steuerung
Automatikus jelző- és váltókezelés|Automatic signal and switch control|Automatische Signal- und Weichensteuerung
Kockázatos játékmód|Risk mode|Risikomodus
Veszélyes indításkor ütközés és életvesztés is lehet|Unsafe departures may cause collisions|Unsichere Abfahrten können Kollisionen verursachen
Kezelési tippek|Gameplay tips|Spieltipps
Alapértelmezett sebesség|Default speed|Standardgeschwindigkeit
Nyelv|Language|Sprache
Magyar|Hungarian|Ungarisch
Angol|English|Englisch
Német|German|Deutsch
Az eredmények kizárólag ezen az eszközön maradnak.|Results stay on this device.|Ergebnisse bleiben auf diesem Gerät.
ORSZÁGOK ÉS PÁLYÁK|COUNTRIES & LEVELS|LÄNDER & LEVEL
Előző ország szükséges|Finish previous country|Vorheriges Land abschließen
Zárolva|Locked|Gesperrt
10 egyedi szint|10 unique levels|10 einzigartige Level
pálya|levels|Level
PÁLYA INDÍTÁSA|START LEVEL|LEVEL STARTEN
VISSZA|BACK|ZURÜCK
Nehézség|Difficulty|Schwierigkeit
Különleges kihívás|Special challenge|Besondere Aufgabe
Vonatok|Trains|Züge
Teljesítendő menetek|Required journeys|Erforderliche Fahrten
3 csillagos időcél|3-star time target|3-Sterne-Zeitlimit
Az első teljesítés feloldja a következő pályát. Az újrajátszással több csillag gyűjthető.|Finishing unlocks the next level. Replay to earn more stars.|Abschluss schaltet das nächste Level frei. Wiederhole für mehr Sterne.
PONT|SCORE|PUNKTE
ÉLET|LIVES|LEBEN
MŰSZAK|SHIFT|SCHICHT
PÁLYA|LEVEL|LEVEL
menet|journeys|Fahrten
MAI FELADATOK|TODAY'S MISSIONS|HEUTIGE AUFGABEN
Sikeres menetek|Completed journeys|Erfolgreiche Fahrten
Gyűjts pontokat|Collect points|Punkte sammeln
Balesetmentes|No accidents|Unfallfrei
Hálózat|Map|Netz
Állomás|Station|Bahnhof
Járatok|Trains|Züge
Ranglista|Leaderboard|Bestenliste
Menü|Menu|Menü
INDÍTÁS|DEPART|ABFAHRT
Vészleállítás|Emergency stop|Not-Halt
Térkép középre|Center map|Karte zentrieren
Állomásvezérlés megnyitása|Open station controls|Bahnhofsteuerung öffnen
ÚTON|IN TRANSIT|UNTERWEGS
INDULÁSRA VÁR|READY TO DEPART|ABFAHRTBEREIT
Két ujjal nagyítható és mozgatható|Pinch to zoom and pan|Mit zwei Fingern zoomen und bewegen
Játéksebesség|Game speed|Spieltempo
Szünet / folytatás|Pause / resume|Pause / fortsetzen
Automatikus / kézi forgalom|Auto / manual dispatch|Automatische / manuelle Steuerung
Nagyítás|Zoom in|Vergrößern
Kicsinyítés|Zoom out|Verkleinern
ÁLLOMÁSI IRÁNYÍTÁS|STATION CONTROL|BAHNHOFSTEUERUNG
SZERELVÉNY ADATAI|TRAIN DETAILS|ZUGDETAILS
Indulás engedélyezése|Authorize departure|Abfahrt freigeben
Vissza az állomáshoz|Back to station|Zurück zum Bahnhof
Mozdonyvezető|Driver|Lokführer
Indulás|Departure|Abfahrt
Következő|Next stop|Nächster Halt
Sebesség|Speed|Tempo
Állapot|Status|Status
Teljesített szakaszok|Completed sections|Abgeschlossene Strecken
Állomáson vár|Waiting at station|Wartet im Bahnhof
KOCKÁZATOS INDÍTÁS|UNSAFE DEPARTURE|RISKANTE ABFAHRT
PÁLYA TELJESÍTVE!|LEVEL COMPLETE!|LEVEL GESCHAFFT!
Új pálya feloldva!|New level unlocked!|Neues Level freigeschaltet!
A kampány végére értél!|Campaign complete!|Kampagne abgeschlossen!
PÁLYAVÁLASZTÓ|LEVEL SELECT|LEVELAUSWAHL
KÖVETKEZŐ PÁLYA|NEXT LEVEL|NÄCHSTES LEVEL
VÉGE A SZOLGÁLATNAK|SHIFT OVER|SCHICHT BEENDET
FŐMENÜ|MAIN MENU|HAUPTMENÜ
ÚJRA|RETRY|ERNEUT
Peronfoglaltság|Platform occupancy|Bahnsteigbelegung
Automata irányítás|Automatic dispatch|Automatische Steuerung
Kézi módban állíts váltókat és jelzőket|Control switches and signals manually|Weichen und Signale manuell schalten
NYUGATI BIZTOSÍTÁS|WEST INTERLOCKING|WESTLICHES STELLWERK
KELETI BIZTOSÍTÁS|EAST INTERLOCKING|ÖSTLICHES STELLWERK
BEJÁRATI JELZŐ|ENTRY SIGNAL|EINFAHRTSIGNAL
KIJÁRATI JELZŐ|EXIT SIGNAL|AUSFAHRTSIGNAL
Váltó állása|Switch track|Weichenstellung
ÁLLOMÁSI VÁGÁNYOK|STATION TRACKS|BAHNHOFSGLEISE
VONALI VÁGÁNYZÁRAK|LINE CLOSURES|STRECKENSPERRUNGEN
SZABAD|CLEAR|FREI
MEGÁLLJ|STOP|HALT
FOGLALT|OCCUPIED|BESETZT
LEZÁRVA|CLOSED|GESPERRT
Feloldás|Reopen|Freigeben
Lezárás|Close|Sperren
SEGÍTSÉGEK ÉS LÁDÁK|HINTS & CHESTS|HILFEN & KISTEN
Ha elakadsz, kérj egy célzott tippet!|Stuck? Ask for a hint!|Nicht weiter? Hol dir einen Hinweis!
FELHASZNÁLHATÓ SEGÍTSÉGEK|AVAILABLE HINTS|VERFÜGBARE HILFEN
FELNYITÁS|OPEN|ÖFFNEN
HASZNÁL|USE|BENUTZEN
Merre tovább?|What next?|Wie weiter?
Szabad vágány radar|Free track radar|Freigleis-Radar
Jelző- és váltósegéd|Signal & switch helper|Signal- & Weichenhilfe
MUTASD|SHOW ME|ZEIGEN
TANULÓPÁLYA|TRAINING LEVEL|TRAININGSLEVEL
KÖVETKEZŐ LÉPÉS|NEXT STEP|NÄCHSTER SCHRITT
KEZDÉS|START|START
ÉRTEM|GOT IT|VERSTANDEN
KÉSŐBB|LATER|SPÄTER
ÚJ SZABÁLY|NEW RULE|NEUE REGEL
Váratlan esemény!|Unexpected event!|Unerwartetes Ereignis!
Gyalogos a síneken!|Pedestrian on the tracks!|Person auf den Gleisen!
BIZTOSÍTOM A PÁLYÁT|SECURE THE TRACK|GLEIS SICHERN
A vonatok megálltak. Biztosítsd a pályát a folytatáshoz.|Trains stopped. Secure the track to resume.|Die Züge halten. Sichere das Gleis zur Weiterfahrt.
Sikeres beavatkozás: +80 pont|Intervention successful: +80 points|Eingriff gelungen: +80 Punkte
Figyelmen kívül hagyott veszély: -1 élet|Unresolved hazard: -1 life|Gefahr nicht behoben: -1 Leben
Oktatás befejezve!|Training complete!|Training abgeschlossen!
Most már önállóan irányíthatsz.|You can now dispatch on your own.|Du kannst den Verkehr nun selbst leiten.
Szintismertető|Level briefing|Level-Einführung
Új kihívás|New challenge|Neue Herausforderung
Fenyvesliget|Pine Grove|Fichtenhain
Kőröspatak|Creek Junction|Bachkreuz
Tiszaváros|Tisza Town|Theißstadt
Ládáid: |Chests: |Kisten: 
Minden ládában 2 garantált segítség.|Each chest contains two guaranteed hints.|Jede Kiste enthält zwei garantierte Hilfen.
Megmutatja, mit nyomj meg következőnek.|Shows the next control to tap.|Zeigt die nächste Taste an.
Megkeresi a következő szabad érkezési peront.|Finds a free arrival platform.|Findet ein freies Einfahrtsgleis.
Elmagyarázza az induláshoz szükséges vágányutat.|Explains the route required for departure.|Erklärt die nötige Fahrstraße.
Minden újonnan teljesített pálya egy új ládát ad. A segítség csak akkor fogy el, ha van hasznos javaslat. A későbbi addonok még nincsenek bekapcsolva.|The first clear of each level earns a chest. Hints are only consumed when advice is available. Add-ons are not enabled yet.|Für jeden erstmals abgeschlossenen Level gibt es eine Kiste. Hilfen werden nur bei gültigem Hinweis verbraucht. Add-ons sind noch nicht aktiviert.
Ládáid|Your chests|Deine Kisten
Kaptál|You received|Du hast erhalten
Segítségek|Hints|Hilfen
Váltó foglalt vagy lezárt vágányra mutat.|Switch points at an occupied or closed track.|Weiche zeigt auf ein besetztes oder gesperrtes Gleis.
Vágányzár alatt nem indulhat új vonat.|No departures during track closure.|Bei Gleissperrung keine Abfahrten.
Játékosnév|Player name|Spielername
Állomások|Stations|Bahnhöfe
ÚJ SZINT|NEW LEVEL|NEUES LEVEL
A vonat nem indítható.|The train cannot depart.|Der Zug kann nicht abfahren.
Új veszélyhelyzet|New hazard|Neue Gefahr
Automata módban a forgalomirányító kezeli az indulásokat.|In auto mode, dispatch is automatic.|Im Automatikmodus erfolgt die Zugleitung automatisch.
Nincs indulásra váró vonat.|No train is ready to depart.|Kein Zug ist abfahrbereit.
A vonat nem indítható.|The train cannot be dispatched.|Der Zug kann nicht abfahren.
Kézi üzem|Manual mode|Manueller Betrieb
Kérlek állítsd a váltót!|Please set the switch!|Bitte stelle die Weiche!
Kövesd a sárgával kiemelt következő lépést!|Follow the next yellow highlighted action!|Folge der nächsten gelb markierten Aktion!
Ez a vonat nem indítható.|This train cannot depart.|Dieser Zug kann nicht abfahren.
A vonat nem indítható.|The train cannot depart.|Dieser Zug kann nicht abfahren.
''';
}
