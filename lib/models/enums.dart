enum UserRole {
  parent,
  therapist,
  teacher,
}

enum Severity {
  mild,
  moderate,
  severe,
}

enum Mood {
  happy,
  calm,
  neutral,
  anxious,
  upset,
  meltdown,
}

enum PromptType {
  visual,
  voice,
  text,
}

enum TransitionDifficulty {
  low,
  medium,
  high,
}

enum ActivityCategory {
  morningRoutine,
  selfCare,
  meal,
  study,
  therapy,
  play,
  exercise,
  bedtime,
  emotion,
  waiting,
  other,
}

/// The kind of visual support board. Persisted on `Schedule.type`; existing
/// documents without the field are read back as [schedule].
enum BoardType {
  schedule,
  firstThen,
  waiting,
  emotion,
}