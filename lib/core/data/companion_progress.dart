import 'reinforcement_policy.dart';

/// Points (and matching exp) earned for finishing an activity praised at
/// [level]. Effort still pays out on a gentle day — finishing is the win,
/// not the mood; a struggling child shouldn't earn less than a calm one.
const rewardByLevel = {
  ReinforcementLevel.gentle: 8,
  ReinforcementLevel.standard: 10,
  ReinforcementLevel.celebratory: 15,
};

/// Exp needed per companion level. Flat curve — good enough until there's
/// real data on how fast children actually accrue exp.
const expPerLevel = 100;

/// Companion level from lifetime exp. Starts at 1, never caps.
int levelForExp(int exp) => exp ~/ expPerLevel + 1;

/// Exp already banked toward the current level, for a progress bar.
int expIntoLevel(int exp) => exp % expPerLevel;
