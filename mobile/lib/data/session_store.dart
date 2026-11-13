import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/level_catalog.dart';
import '../game/campaign_progress.dart';
import '../game/help_inventory.dart';
import '../l10n/game_l10n.dart';

class ScoreEntry {
  const ScoreEntry(this.name, this.points, this.when);
  final String name;
  final int points;
  final DateTime when;
  Map<String, dynamic> toJson() => {
    'name': name,
    'points': points,
    'when': when.toIso8601String(),
  };
  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
    json['name'] as String,
    json['points'] as int,
    DateTime.parse(json['when'] as String),
  );
}

/// Helyi vendégprofil és ranglista; nincs online auth vagy szerver.
class SessionStore extends ChangeNotifier {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  String? playerName;
  bool autoDispatch = false;
  bool riskMode = false;
  bool showHints = true;
  int speed = 30;
  String language = 'hu';
  Set<String> introducedLevels = {};
  List<ScoreEntry> leaderboard = [];
  CampaignProgress campaign = CampaignProgress();
  HelpInventory helpInventory = HelpInventory();

  String get _campaignKey => 'campaign_progress:' + (playerName ?? 'guest');
  String get _helpKey => 'help_inventory:' + (playerName ?? 'guest');

  Future<void> load() async {
    playerName = await _prefs.getString('profile_name');
    autoDispatch = await _prefs.getBool('setting_auto') ?? false;
    riskMode = await _prefs.getBool('setting_risk') ?? false;
    showHints = await _prefs.getBool('setting_hints') ?? true;
    speed = await _prefs.getInt('setting_speed') ?? 30;
    final savedLanguage = await _prefs.getString('setting_language');
    language = GameL10n.supported.contains(savedLanguage)
        ? savedLanguage! : 'hu';
    GameL10n.language = language;
    introducedLevels = (await _prefs.getStringList(
        'introduced_levels:' + (playerName ?? 'guest')) ?? []).toSet();
    await _loadCampaign();
    await _loadHelps();
    final entries = await _prefs.getStringList('scores') ?? [];
    leaderboard = [];
    for (final raw in entries) {
      try {
        leaderboard.add(ScoreEntry.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        ));
      } on FormatException {
        // Hibás helyi rekord átugrása.
      } on TypeError {
        // Hibás helyi rekord átugrása.
      }
    }
    leaderboard.sort((a, b) => b.points.compareTo(a.points));
    notifyListeners();
  }

  Future<void> _loadCampaign() async {
    campaign = CampaignProgress();
    final savedCampaign = await _prefs.getString(_campaignKey);
    if (savedCampaign == null) return;
    try {
      campaign = CampaignProgress.fromJson(
        jsonDecode(savedCampaign) as Map<String, dynamic>,
      );
    } on FormatException {
      campaign = CampaignProgress();
    } on TypeError {
      campaign = CampaignProgress();
    }
  }

  Future<void> _loadHelps() async {
    helpInventory = HelpInventory();
    final raw = await _prefs.getString(_helpKey);
    if (raw == null) return;
    try {
      helpInventory = HelpInventory.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on FormatException {
      helpInventory = HelpInventory();
    } on TypeError {
      helpInventory = HelpInventory();
    }
  }

  Future<void> _saveHelps() async {
    await _prefs.setString(_helpKey, jsonEncode(helpInventory.toJson()));
    notifyListeners();
  }

  /// Opening an earned, offline chest gives two guaranteed help items.
  Future<List<HelpType>> openHelpChest() async {
    final contents = helpInventory.openChest();
    if (contents.isNotEmpty) await _saveHelps();
    return contents;
  }

  /// Charge only after an actionable advisory hint was found.
  Future<bool> spendHelp(HelpType type) async {
    if (!helpInventory.consume(type)) return false;
    await _saveHelps();
    return true;
  }

  Future<void> enter(String name) async {
    final safe = name.trim();
    if (safe.isEmpty) return;
    playerName = safe.substring(0, safe.length > 20 ? 20 : safe.length);
    await _prefs.setString('profile_name', playerName!);
    await _loadCampaign();
    await _loadHelps();
    introducedLevels = (await _prefs.getStringList(
        'introduced_levels:' + (playerName ?? 'guest')) ?? []).toSet();
    notifyListeners();
  }

  Future<void> signOut() async {
    playerName = null;
    await _prefs.remove('profile_name');
    campaign = CampaignProgress();
    helpInventory = HelpInventory();
    introducedLevels = {};
    notifyListeners();
  }

  Future<void> setAuto(bool value) async {
    autoDispatch = value;
    await _prefs.setBool('setting_auto', value);
    notifyListeners();
  }
  Future<void> setRisk(bool value) async {
    riskMode = value;
    await _prefs.setBool('setting_risk', value);
    notifyListeners();
  }
  Future<void> setHints(bool value) async {
    showHints = value;
    await _prefs.setBool('setting_hints', value);
    notifyListeners();
  }
  Future<void> setLanguage(String value) async {
    if (!GameL10n.supported.contains(value)) return;
    language = value;
    GameL10n.language = value;
    await _prefs.setString('setting_language', value);
    notifyListeners();
  }

  Future<void> markIntroduced(GameLevel level) async {
    if (!introducedLevels.add(level.id)) return;
    await _prefs.setStringList(
      'introduced_levels:' + (playerName ?? 'guest'),
      introducedLevels.toList()..sort(),
    );
    notifyListeners();
  }

  Future<void> setSpeed(int value) async {
    if (![1, 10, 30, 60].contains(value)) return;
    speed = value;
    await _prefs.setInt('setting_speed', value);
    notifyListeners();
  }

  Future<void> finishLevel(GameLevel level, int stars, int points) async {
    if (!campaign.isUnlocked(level)) return;
    final firstClear = campaign.starsFor(level) == 0 && stars > 0;
    campaign.award(level, stars);
    if (firstClear && helpInventory.earnChest(level.id)) {
      await _saveHelps();
    }
    await _prefs.setString(_campaignKey,
        jsonEncode(campaign.toJson()));
    await recordScore(points);
    notifyListeners();
  }

  Future<void> recordScore(int points) async {
    if (points <= 0 || playerName == null) return;
    leaderboard = [
      ...leaderboard,
      ScoreEntry(playerName!, points, DateTime.now()),
    ]..sort((a, b) => b.points.compareTo(a.points));
    leaderboard = leaderboard.take(20).toList();
    await _prefs.setStringList('scores',
        leaderboard.map((e) => jsonEncode(e.toJson())).toList());
    notifyListeners();
  }
}
