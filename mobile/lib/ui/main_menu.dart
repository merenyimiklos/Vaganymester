import 'package:flutter/material.dart';
import '../data/session_store.dart';
import 'menu_art.dart';
import '../l10n/game_l10n.dart';

const _panel = Color(0xFF152E41);

class MainMenu extends StatefulWidget {
  const MainMenu({super.key, required this.store, required this.onStart,
    required this.onTutorial});
  final SessionStore store;
  final VoidCallback onStart;
  final VoidCallback onTutorial;
  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final TextEditingController _name = TextEditingController();
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = widget.store.playerName != null;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(children: [
            const Positioned.fill(
              child: CustomPaint(painter: MenuScenePainter()),
            ),
            Positioned(
              left: 16, top: 14,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 7, 15, 7),
                decoration: BoxDecoration(
                  color: _panel,
                  border: Border.all(color: const Color(0xFFF7FDFF), width: 2),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [BoxShadow(
                    color: Color(0x66324D62), blurRadius: 12,
                    offset: Offset(0, 4))],
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFFFFD052),
                    child: Icon(Icons.train_rounded,
                        color: Color(0xFF164A75), size: 29),
                  ),
                  SizedBox(width: 8),
                  Text('VÁGÁNYMESTER', style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w900,
                    color: Colors.white, letterSpacing: .4)),
                ]),
              ),
            ),
            Positioned(
              left: 19, top: 91,
              child: SizedBox(
                width: constraints.maxWidth * .43,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _tag(GameL10n.tr('🚆  ÚJ VASÚTI KALAND')),
                    const SizedBox(height: 9),
                    Text(GameL10n.tr('Légy te a\nforgalom mestere!'),
                      style: TextStyle(color: Color(0xFF173E65),
                        fontSize: 27, height: 1.07,
                        fontWeight: FontWeight.w900,
                        shadows: [Shadow(color: Colors.white,
                            blurRadius: 12)])),
                    const SizedBox(height: 9),
                    _tag(GameL10n.tr('⭐ Pontgyűjtés   ❤️ 3 élet   🏆 Ranglista')),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 76, right: 17, bottom: 13,
              width: constraints.maxWidth < 850 ? 278 : 340,
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xF4F4FCFF),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [BoxShadow(
                        color: Color(0x66364B59), blurRadius: 17,
                        offset: Offset(0, 6))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(GameL10n.tr(loggedIn ? 'Üdv a központban!' : 'VENDÉG BELÉPÉS'),
                          style: const TextStyle(
                            color: Color(0xFF154A76), fontSize: 19,
                            fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                          child: Text(loggedIn ? widget.store.playerName! :
                          GameL10n.tr('Adj meg egy nevet, és kezdődhet a szolgálat!'),
                          style: const TextStyle(
                            color: Color(0xFF477B96), fontSize: 12))),
                        const SizedBox(height: 12),
                        if (!loggedIn) ...[
                          TextField(
                            controller: _name,
                            maxLength: 20,
                            textInputAction: TextInputAction.done,
                            onSubmitted: _login,
                            style: const TextStyle(color: Color(0xFF154A76)),
                            decoration: InputDecoration(
                              labelText: GameL10n.tr('Játékos neve'),
                              labelStyle: TextStyle(color: Color(0xFF52788F)),
                              border: OutlineInputBorder(),
                              counterText: '',
                              prefixIcon: Icon(Icons.person_rounded,
                                  color: Color(0xFF177FB5)),
                            ),
                          ),
                          _mainButton(GameL10n.tr('BELÉPÉS'), Icons.login_rounded,
                              () => _login(_name.text)),
                        ] else ...[
                          _mainButton(GameL10n.tr('JÁTÉK INDÍTÁSA'),
                              Icons.play_arrow_rounded, widget.onStart),
                          const SizedBox(height: 8),
                          _secondaryButton(GameL10n.tr('RANGLISTA'),
                              Icons.emoji_events_rounded,
                              () => showLeaderboard(context, widget.store)),
                          const SizedBox(height: 7),
                          _secondaryButton(GameL10n.tr('BEÁLLÍTÁSOK'),
                              Icons.settings_rounded,
                              () => showSettings(context, widget.store)),
                          const SizedBox(height: 7),
                          _secondaryButton(
                            switch (widget.store.language) {
                              'en' => 'TRAINING ACADEMY',
                              'de' => 'TRAININGSAKADEMIE',
                              _ => 'OKTATÓ AKADÉMIA',
                            },
                            Icons.school_rounded, widget.onTutorial),
                          TextButton(
                            onPressed: widget.store.signOut,
                            child: Text(GameL10n.tr('Vendégváltás'),
                              style: TextStyle(color: Color(0xFF356987))),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _tag(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xEAF4FCFF),
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [BoxShadow(
          color: Color(0x33295E87), blurRadius: 5)],
    ),
    child: Text(label, style: const TextStyle(
      color: Color(0xFF15517F), fontSize: 11,
      fontWeight: FontWeight.w800,
    )),
  );

  Widget _mainButton(String text, IconData icon, VoidCallback action) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7EF55D), Color(0xFF29C850)]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(
          color: Color(0x6638B65A), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: action,
          borderRadius: BorderRadius.circular(18),
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF155B32), size: 29),
              const SizedBox(width: 5),
              Text(text, style: const TextStyle(
                color: Color(0xFF155B32), fontSize: 16,
                fontWeight: FontWeight.w900)),
            ]),
        ),
      ),
    );
  }

  Widget _secondaryButton(String text, IconData icon,
      VoidCallback action) {
    return OutlinedButton.icon(
      onPressed: action,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(42),
        backgroundColor: const Color(0xFFD8F1FF),
        foregroundColor: const Color(0xFF16537F),
        side: const BorderSide(color: Color(0xFF87BCE4), width: 2),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
      ),
      icon: Icon(icon),
      label: Text(text, style:
          const TextStyle(fontWeight: FontWeight.w900)),
    );
  }

  void _login(String text) {
    if (text.trim().isNotEmpty) {
      widget.store.enter(text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(GameL10n.tr('Adj meg egy játékosnevet!'))),
      );
    }
  }
}

Future<void> showSettings(BuildContext context, SessionStore store) async {
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(GameL10n.tr('BEÁLLÍTÁSOK')),
      content: SizedBox(
        width: 420,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) => ListView(
            shrinkWrap: true,
            children: [
              SwitchListTile(
                title: Text(GameL10n.tr('Automatikus irányítás')),
                subtitle: Text(GameL10n.tr('Automatikus jelző- és váltókezelés')),
                value: store.autoDispatch,
                onChanged: store.setAuto,
              ),
              SwitchListTile(
                title: Text(GameL10n.tr('Kockázatos játékmód')),
                subtitle: Text(GameL10n.tr(
                  'Veszélyes indításkor ütközés és életvesztés is lehet')),
                value: store.riskMode,
                onChanged: store.setRisk,
              ),
              SwitchListTile(
                title: Text(GameL10n.tr('Kezelési tippek')),
                value: store.showHints,
                onChanged: store.setHints,
              ),
              const Divider(),
              Text(GameL10n.tr('Alapértelmezett sebesség')),
              DropdownButton<int>(
                value: store.speed,
                items: const [1, 10, 30, 60]
                    .map((s) => DropdownMenuItem(
                        value: s, child: Text('$s×')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) store.setSpeed(value);
                },
              ),
              const SizedBox(height: 9),
              Text(GameL10n.tr('Nyelv'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                isExpanded: true,
                value: store.language,
                items: const [
                  DropdownMenuItem(value: 'hu', child: Text('🇭🇺 Magyar')),
                  DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
                  DropdownMenuItem(value: 'de', child: Text('🇩🇪 Deutsch')),
                ],
                onChanged: (value) {
                  if (value != null) store.setLanguage(value);
                },
              ),
              Text(GameL10n.tr('Az eredmények kizárólag ezen az eszközön maradnak.'),
                style: const TextStyle(fontSize: 12, color: Color(0xFFB3CEDB))),

            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
          child: Text(GameL10n.tr('KÉSZ'))),
      ],
    ),
  );
}

Future<void> showLeaderboard(BuildContext context, SessionStore store) async {
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.emoji_events, color: Color(0xFFFFCC68)),
          const SizedBox(width: 10),
          Text(GameL10n.tr('HELYI RANGLISTA')),
        ],
      ),
      content: SizedBox(
        width: 440,
        height: 280,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) => store.leaderboard.isEmpty
              ? Center(child: Text(GameL10n.tr(
                  'Még nincs eredmény. Teljesíts egy szolgálatot!')))
              : ListView.builder(
                  itemCount: store.leaderboard.length,
                  itemBuilder: (context, index) {
                    final entry = store.leaderboard[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text((index + 1).toString())),
                      title: Text(entry.name),
                      subtitle: Text(entry.when.toLocal().toString().split(' ').first),
                      trailing: Text(entry.points.toString() + ' pont',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  },
                ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
            child: Text(GameL10n.tr('BEZÁRÁS'))),
      ],
    ),
  );
}
