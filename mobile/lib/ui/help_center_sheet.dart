import 'package:flutter/material.dart';

import '../data/session_store.dart';
import '../game/help_inventory.dart';
import '../game/academy_progress.dart';
import '../l10n/game_l10n.dart';

/// The chest shelf and consumable help library. No payments or chance-based
/// loot: every chest guarantees two assistance items.
class HelpCenterSheet extends StatefulWidget {
  const HelpCenterSheet({
    super.key,
    required this.store,
    required this.onUse,
  });

  final SessionStore store;
  final ValueChanged<HelpType> onUse;

  @override
  State<HelpCenterSheet> createState() => _HelpCenterSheetState();
}

class _HelpCenterSheetState extends State<HelpCenterSheet> {
  List<HelpType> _lastRewards = const [];
  String? _purchaseMessage;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final stock = widget.store.helpInventory;
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF0FAFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 26),
            children: [
              Row(children: [
                const CircleAvatar(
                  radius: 23,
                  backgroundColor: Color(0xFFFFD463),
                  child: Icon(Icons.lightbulb_rounded,
                      color: Color(0xFF94650D), size: 29),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(GameL10n.tr('SEGÍTSÉGEK ÉS LÁDÁK'),
                        style: TextStyle(
                          color: Color(0xFF174A6F),
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        )),
                      Text(GameL10n.tr('Ha elakadsz, kérj egy célzott tippet!'),
                        style: TextStyle(
                            color: Color(0xFF487C94), fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Bezárás',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      color: Color(0xFF164C71)),
                ),
              ]),
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFFEEB9), Color(0xFFFFD56E)]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(children: [
                    const Icon(Icons.inventory_2_rounded,
                        size: 36, color: Color(0xFF8F6215)),
                    const SizedBox(width: 9),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ládáid: ' + stock.chests.toString(),
                          style: const TextStyle(
                              color: Color(0xFF694912),
                              fontWeight: FontWeight.w900)),
                        Text(GameL10n.tr('Minden ládában 2 garantált segítség.'),
                          style: TextStyle(
                              color: Color(0xFF805B22), fontSize: 11)),
                      ],
                    )),
                    FilledButton.icon(
                      onPressed: stock.chests > 0 ? _openChest : null,
                      icon: const Icon(Icons.card_giftcard_rounded),
                      label: Text(GameL10n.tr('FELNYITÁS')),
                    ),
                  ]),
                ),
              ),
              if (_purchaseMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Text(_purchaseMessage!,
                    style: const TextStyle(color: Color(0xFF175D77),
                      fontSize: 12, fontWeight: FontWeight.w900)),
                ),
              _shopCard(),
              if (_lastRewards.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Text('🎁 Kaptál: ' +
                      _lastRewards.map((item) => GameL10n.tr(item.title)).join(' + '),
                    style: const TextStyle(
                        color: Color(0xFF21794D),
                        fontWeight: FontWeight.w800,
                        fontSize: 12)),
                ),
              const SizedBox(height: 11),
              Text(GameL10n.tr('FELHASZNÁLHATÓ SEGÍTSÉGEK'),
                style: TextStyle(color: Color(0xFF174A6F),
                    fontWeight: FontWeight.w900, fontSize: 13)),
              const SizedBox(height: 7),
              for (final item in HelpType.values) ...[
                _helpCard(item, stock.count(item)),
                const SizedBox(height: 7),
              ],
              const Text(
                'Minden újonnan teljesített pálya egy új ládát ad. '
                'A segítség csak akkor fogy el, ha van hasznos javaslat. '
                'A későbbi addonok még nincsenek bekapcsolva.',
                style: TextStyle(color: Color(0xFF65869C),
                    fontSize: 11, height: 1.3),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shopCard() {
    final progress = widget.store.academy;
    final cost = AcademyProgress.chestPrice;
    final language = widget.store.language;
    final title = switch (language) {
      'en' => 'ACADEMY POINT SHOP',
      'de' => 'LERNPUNKTE-SHOP',
      _ => 'AKADÉMIA PONTBOLT',
    };
    final buy = switch (language) {
      'en' => 'BUY CHEST',
      'de' => 'KISTE KAUFEN',
      _ => 'LÁDA VÁSÁRLÁSA',
    };
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F5FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF89D1EF), width: 2),
      ),
      child: Row(children: [
        const CircleAvatar(
          backgroundColor: Color(0xFFFFD778),
          child: Icon(Icons.storefront_rounded,
            color: Color(0xFF976313))),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Color(0xFF174A70),
              fontSize: 13, fontWeight: FontWeight.w900)),
            Text('⭐ ' + progress.points.toString() + '  •  🎁 ' +
                cost.toString(),
              style: const TextStyle(color: Color(0xFF396A86),
                fontSize: 12, fontWeight: FontWeight.w800)),
          ]),
        ),
        FilledButton.icon(
          onPressed: progress.points >= cost && widget.store.helpInventory.chests < 999
            ? () async {
                final purchased = await widget.store.buyChestWithPoints();
                if (!mounted) return;
                setState(() {
                  _purchaseMessage = purchased
                    ? switch (language) {
                        'en' => 'Chest purchased! Contains 2 guaranteed hints.',
                        'de' => 'Kiste gekauft! Enthält 2 garantierte Hilfen.',
                        _ => 'Láda megvéve! 2 garantált segítség jár benne.',
                      }
                    : switch (language) {
                        'en' => 'Not enough academy points.',
                        'de' => 'Nicht genug Lernpunkte.',
                        _ => 'Nincs elég akadémiapont.',
                      };
                });
              } : null,
          icon: const Icon(Icons.card_giftcard_rounded, size: 17),
          label: Text(buy, style: const TextStyle(fontSize: 11)),
        ),
      ]),
    );
  }

  Widget _helpCard(HelpType item, int count) {
    final icon = switch (item) {
      HelpType.nextStep => Icons.touch_app_rounded,
      HelpType.freePlatform => Icons.alt_route_rounded,
      HelpType.signals => Icons.traffic_rounded,
    };
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFB8DEEA)),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFD4F3FA),
          child: Icon(icon, color: const Color(0xFF177A9E)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(GameL10n.tr(item.title), style: const TextStyle(
              color: Color(0xFF194C71),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            )),
            Text(GameL10n.tr(item.description), style: const TextStyle(
              color: Color(0xFF50788C), fontSize: 11)),
          ],
        )),
        const SizedBox(width: 6),
        Column(children: [
          Text(count.toString() + ' db',
            style: const TextStyle(color: Color(0xFF184C6F),
                fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          FilledButton(
            onPressed: count > 0 ? () {
              Navigator.pop(context);
              widget.onUse(item);
            } : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(64, 32),
            ),
            child: Text(GameL10n.tr('HASZNÁL'),
                style: TextStyle(fontSize: 10)),
          ),
        ]),
      ]),
    );
  }

  Future<void> _openChest() async {
    final received = await widget.store.openHelpChest();
    if (!mounted) return;
    setState(() => _lastRewards = received);
  }
}
