/// Consumable assistance items. This is a local, offline game currency:
/// no purchases, adverts, real money, loot odds or remote entitlements.
enum HelpType { nextStep, freePlatform, signals }

extension HelpTypeDetails on HelpType {
  String get title => switch (this) {
    HelpType.nextStep => 'Merre tovább?',
    HelpType.freePlatform => 'Szabad vágány radar',
    HelpType.signals => 'Jelző- és váltósegéd',
  };

  String get description => switch (this) {
    HelpType.nextStep => 'Megmutatja, mit nyomj meg következőnek.',
    HelpType.freePlatform => 'Megkeresi a következő szabad érkezési peront.',
    HelpType.signals => 'Elmagyarázza az induláshoz szükséges vágányutat.',
  };
}

/// Offline chest reward and inventory, kept separate from rendering and storage.
/// The contents are guaranteed and rotate predictably, not random loot.
class HelpInventory {
  HelpInventory({
    Map<HelpType, int>? quantities,
    this.chests = 1,
    this.opened = 0,
    Set<String>? earnedChestLevels,
  }) : _quantities = {
          for (final type in HelpType.values)
            type: (quantities?[type] ?? 0).clamp(0, 999).toInt(),
        },
        _earnedChestLevels = Set.of(earnedChestLevels ?? {});

  final Map<HelpType, int> _quantities;
  final Set<String> _earnedChestLevels;
  int chests;
  int opened;

  int count(HelpType type) => _quantities[type] ?? 0;
  int get totalItems =>
      HelpType.values.fold(0, (sum, type) => sum + count(type));

  /// Each newly completed campaign level gives exactly one chest.
  /// Replaying or winning more stars cannot farm additional chests.
  bool earnChest(String levelId) {
    if (levelId.isEmpty || !_earnedChestLevels.add(levelId)) return false;
    chests = (chests + 1).clamp(0, 999).toInt();
    return true;
  }

  /// Guaranteed 2 assistance items per chest, all local and free.
  /// A future add-on may call grantItem after an independently verified grant;
  /// no add-on purchase functionality is implemented here.
  List<HelpType> openChest() {
    if (chests < 1) return const [];
    chests--;
    final first = HelpType.values[opened % HelpType.values.length];
    final second = HelpType.values[(opened + 1) % HelpType.values.length];
    opened++;
    grantItem(first);
    grantItem(second);
    return [first, second];
  }

  void grantItem(HelpType type, {int amount = 1}) {
    if (amount <= 0) return;
    _quantities[type] = (count(type) + amount).clamp(0, 999).toInt();
  }

  /// Only consume once the game has a valid actionable hint.
  bool consume(HelpType type) {
    final current = count(type);
    if (current <= 0) return false;
    _quantities[type] = current - 1;
    return true;
  }

  Map<String, Object> toJson() => {
        'schema': 1,
        'chests': chests,
        'opened': opened,
        'items': {for (final type in HelpType.values) type.name: count(type)},
        'earned': _earnedChestLevels.toList()..sort(),
      };

  factory HelpInventory.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final amounts = raw is Map
        ? <HelpType, int>{
            for (final type in HelpType.values)
              type: raw[type.name] is int
                  ? (raw[type.name] as int).clamp(0, 999).toInt()
                  : 0,
          }
        : <HelpType, int>{};
    final recorded = json['earned'];
    return HelpInventory(
      quantities: amounts,
      chests: json['chests'] is int
          ? (json['chests'] as int).clamp(0, 999).toInt() : 1,
      opened: json['opened'] is int
          ? (json['opened'] as int).clamp(0, 99999).toInt() : 0,
      earnedChestLevels: recorded is List
          ? recorded.whereType<String>().toSet() : {},
    );
  }
}
