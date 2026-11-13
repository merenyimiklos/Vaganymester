/// Deterministic, offline tutorial rewards. The shop does not sell random loot
/// or handle real money: every chest has the two known hint items.
class AcademyProgress {
  AcademyProgress({
    Set<int>? cleared,
    this.skipped = false,
    this.points = 0,
    this.finalRewardClaimed = false,
  }) : cleared = Set.of(cleared ?? {});

  static const lessonCount = 10;
  static const lessonReward = 80;
  static const graduationReward = 220;
  static const chestPrice = 160;

  final Set<int> cleared;
  bool skipped;
  int points;
  bool finalRewardClaimed;

  int get completedCount => cleared.length;
  bool get graduated => completedCount == lessonCount;
  bool get campaignUnlocked => graduated || skipped;
  int get nextLesson {
    for (var i = 0; i < lessonCount; i++) {
      if (!cleared.contains(i)) return i;
    }
    return lessonCount;
  }
  bool canPlay(int index) => index >= 0 && index < lessonCount &&
      (index == 0 || cleared.contains(index - 1));

  /// Returns actual points earned; replaying never gives more.
  int complete(int index) {
    if (!canPlay(index) || !cleared.add(index)) return 0;
    var reward = lessonReward;
    if (graduated && !finalRewardClaimed) {
      finalRewardClaimed = true;
      reward += graduationReward;
    }
    points = (points + reward).clamp(0, 999999).toInt();
    return reward;
  }

  void skip() { skipped = true; }
  bool spend(int cost) {
    if (cost <= 0 || points < cost) return false;
    points -= cost;
    return true;
  }

  Map<String, Object> toJson() => {
    'cleared': cleared.toList()..sort(),
    'skipped': skipped,
    'points': points,
    'finalRewardClaimed': finalRewardClaimed,
  };

  factory AcademyProgress.fromJson(Map<String, dynamic> json) {
    final recorded = json['cleared'];
    final levels = recorded is List
        ? recorded.whereType<int>().where((n) => n >= 0 && n < lessonCount)
            .toSet()
        : <int>{};
    final total = json['points'];
    return AcademyProgress(
      cleared: levels,
      skipped: json['skipped'] == true,
      points: total is int ? total.clamp(0, 999999).toInt() : 0,
      finalRewardClaimed: json['finalRewardClaimed'] == true,
    );
  }
}
