import 'level_catalog.dart';

/// Kizárólag teljesített, csillagot kapott pályák oldják fel
/// a következő szintet. A hat ország egyetlen lineáris kampány.
class CampaignProgress {
  CampaignProgress([Map<String, int>? initial])
      : _stars = Map<String, int>.of(initial ?? {});

  final Map<String, int> _stars;

  int starsFor(GameLevel level) => _stars[level.id] ?? 0;
  int get completedCount => LevelCatalog.all
      .where((level) => starsFor(level) > 0).length;
  int get totalStars => LevelCatalog.all.fold<int>(
      0, (sum, level) => sum + starsFor(level));

  int get unlockedCount => completedCount == LevelCatalog.all.length
      ? LevelCatalog.all.length : completedCount + 1;

  bool isUnlocked(GameLevel level) {
    final index = LevelCatalog.all.indexWhere((e) => e.id == level.id);
    if (index == -1) return false;
    if (index == 0) return true;
    return starsFor(LevelCatalog.all[index - 1]) >= 1;
  }

  bool isCountryUnlocked(RailwayCountry country) {
    final levels = LevelCatalog.inCountry(country.code);
    return levels.isNotEmpty && isUnlocked(levels.first);
  }

  bool award(GameLevel level, int stars) {
    if (!isUnlocked(level) || stars < 1 || stars > 3) return false;
    final previous = starsFor(level);
    if (stars <= previous) return false;
    _stars[level.id] = stars;
    return true;
  }

  Map<String, int> toJson() => {
    for (final level in LevelCatalog.all)
      if (starsFor(level) > 0) level.id: starsFor(level),
  };

  factory CampaignProgress.fromJson(Map<String, dynamic> data) {
    final accepted = <String, int>{};
    // Nem oldhatók fel tetszőleges későbbi pályák az importált adatokból:
    // csak a legelejétől folytonosan teljesített eredményeket fogadjuk el.
    for (final level in LevelCatalog.all) {
      final raw = data[level.id];
      if (raw is! int || raw < 1 || raw > 3) break;
      accepted[level.id] = raw;
    }
    return CampaignProgress(accepted);
  }
}
