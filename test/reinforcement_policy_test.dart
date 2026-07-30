import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprout_ly_app/core/data/reinforcement_policy.dart';
import 'package:sprout_ly_app/models/behaviour_log.dart';
import 'package:sprout_ly_app/models/enums.dart';

void main() {
  var seq = 0;

  BehaviourLog log({required bool completed, Mood mood = Mood.happy}) {
    seq++;
    return BehaviourLog(
      id: 'log-$seq',
      childId: 'child-1',
      activityId: 'mandi',
      // Newest-first ordering is the caller's job, so timestamps don't matter.
      timestamp: DateTime(2026, 1, 1).subtract(Duration(minutes: seq)),
      mood: mood,
      promptType: PromptType.voice,
      rewardId: null,
      transitionDifficulty: TransitionDifficulty.low,
      completed: completed,
      durationMinutes: 15,
    );
  }

  group('levelFor', () {
    test('a rough mood right now outranks a perfect streak', () {
      final level = levelFor(
        recentLogs: [
          log(completed: true),
          log(completed: true),
          log(completed: true),
        ],
        currentMood: Mood.meltdown,
      );

      expect(level, ReinforcementLevel.gentle);
    });

    test('anxious and upset also count as a rough moment', () {
      for (final mood in [Mood.anxious, Mood.upset]) {
        expect(
          levelFor(recentLogs: const [], currentMood: mood),
          ReinforcementLevel.gentle,
          reason: '$mood should be gentle',
        );
      }
    });

    test('no history yet gives standard praise', () {
      expect(
        levelFor(recentLogs: const [], currentMood: Mood.happy),
        ReinforcementLevel.standard,
      );
    });

    test('two struggles in the window drops to gentle', () {
      final level = levelFor(
        recentLogs: [
          log(completed: false),
          log(completed: true),
          log(completed: true, mood: Mood.upset),
          log(completed: true),
        ],
        currentMood: Mood.happy,
      );

      expect(level, ReinforcementLevel.gentle);
    });

    test('one struggle is not enough to drop to gentle', () {
      final level = levelFor(
        recentLogs: [
          log(completed: true),
          log(completed: true),
          log(completed: false),
          log(completed: true),
        ],
        currentMood: Mood.happy,
      );

      expect(level, ReinforcementLevel.standard);
    });

    test('three clean completions in a row is celebratory', () {
      final level = levelFor(
        recentLogs: [
          log(completed: true, mood: Mood.happy),
          log(completed: true, mood: Mood.calm),
          log(completed: true, mood: Mood.neutral),
        ],
        currentMood: Mood.happy,
      );

      expect(level, ReinforcementLevel.celebratory);
    });

    test('a streak shorter than three stays standard', () {
      final level = levelFor(
        recentLogs: [log(completed: true), log(completed: true)],
        currentMood: Mood.happy,
      );

      expect(level, ReinforcementLevel.standard);
    });

    test('history older than the window is ignored', () {
      // Two failures, but both outside the 3-entry window being looked at.
      final level = levelFor(
        recentLogs: [
          log(completed: true),
          log(completed: true),
          log(completed: true),
          log(completed: false),
          log(completed: false),
        ],
        currentMood: Mood.happy,
        window: 3,
      );

      expect(level, ReinforcementLevel.celebratory);
    });
  });

  group('phraseFor', () {
    test('every level has a phrase and a badge', () {
      for (final level in ReinforcementLevel.values) {
        expect(phraseFor(level, random: Random(1)), isNotEmpty);
        expect(badgeFor(level), isNotEmpty);
      }
    });

    test('gentle praise never claims success', () {
      // Telling a struggling child "kamu berhasil" is the thing to avoid.
      for (var seed = 0; seed < 20; seed++) {
        final phrase = phraseFor(ReinforcementLevel.gentle, random: Random(seed));
        expect(phrase.toLowerCase(), isNot(contains('berhasil')));
      }
    });

    test('a rough mood reported at the end downgrades the praise', () {
      // The runner asks for mood before praising precisely so this holds: a
      // clean streak must not produce confetti for a child who just melted down.
      final history = [
        log(completed: true),
        log(completed: true),
        log(completed: true),
      ];

      expect(
        levelFor(recentLogs: history, currentMood: Mood.happy),
        ReinforcementLevel.celebratory,
      );
      expect(
        levelFor(recentLogs: history, currentMood: Mood.upset),
        ReinforcementLevel.gentle,
      );
    });
  });
}
