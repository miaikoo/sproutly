import 'dart:math';

import '../../models/behaviour_log.dart';
import '../../models/enums.dart';

/// How strong the praise should be after an activity (RF-09).
enum ReinforcementLevel {
  /// The child is struggling — praise the effort, not the result.
  gentle,
  standard,

  /// The child is on a roll — short, high-energy celebration.
  celebratory,
}

/// Picks the reinforcement level from how the child has actually been doing,
/// so praise tracks performance instead of being the same every time.
///
/// [recentLogs] must be newest-first, which is how `watchLogsForChild` returns
/// them. Only the last [window] entries matter — older history says little
/// about how this session is going.
ReinforcementLevel levelFor({
  required List<BehaviourLog> recentLogs,
  required Mood currentMood,
  int window = 5,
}) {
  const hardMoods = {Mood.upset, Mood.meltdown, Mood.anxious};

  // A rough moment right now outweighs any streak.
  if (hardMoods.contains(currentMood)) return ReinforcementLevel.gentle;

  final recent = recentLogs.take(window).toList();
  if (recent.isEmpty) return ReinforcementLevel.standard;

  final struggles =
      recent.where((l) => !l.completed || hardMoods.contains(l.mood)).length;
  if (struggles >= 2) return ReinforcementLevel.gentle;

  final streak = recent.take(3).toList();
  final onARoll = streak.length == 3 &&
      streak.every((l) => l.completed && !hardMoods.contains(l.mood));

  return onARoll ? ReinforcementLevel.celebratory : ReinforcementLevel.standard;
}

const _phrases = {
  ReinforcementLevel.gentle: [
    'Tidak apa-apa, kamu sudah berusaha. Terima kasih ya.',
    'Kamu sudah mencoba, itu hebat. Kita lanjut perlahan.',
    'Pelan-pelan saja. Ibu bangga kamu mau mencoba.',
  ],
  ReinforcementLevel.standard: [
    'Kerja bagus! Kamu hebat!',
    'Mantap, kamu berhasil!',
    'Bagus sekali, teruskan!',
  ],
  ReinforcementLevel.celebratory: [
    'Wah, keren sekali! Kamu berhasil lagi!',
    'Hebat! Sudah tiga kali berhasil berturut-turut!',
    'Luar biasa! Kamu semakin mandiri!',
  ],
};

/// Spoken praise for [level]. Pass [random] to make the choice deterministic.
String phraseFor(ReinforcementLevel level, {Random? random}) {
  final options = _phrases[level]!;
  return options[(random ?? Random()).nextInt(options.length)];
}

/// Short on-screen label that pairs with the spoken praise.
String badgeFor(ReinforcementLevel level) {
  switch (level) {
    case ReinforcementLevel.gentle:
      return 'Sudah berusaha';
    case ReinforcementLevel.standard:
      return 'Selesai!';
    case ReinforcementLevel.celebratory:
      return 'Luar biasa!';
  }
}
