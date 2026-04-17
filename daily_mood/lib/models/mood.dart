enum Mood {
  happy('😊', 'Mutlu', 'happy'),
  sad('😢', 'Üzgün', 'sad'),
  angry('😠', 'Öfkeli', 'angry'),
  calm('😌', 'Huzurlu', 'calm'),
  tired('😴', 'Yorgun', 'tired'),
  excited('🤩', 'Heyecanlı', 'excited'),
  anxious('😰', 'Endişeli', 'anxious'),
  neutral('😐', 'Nötr', 'neutral');

  const Mood(this.emoji, this.displayName, this.value);

  final String emoji;
  final String displayName;
  final String value;

  static Mood fromString(String value) {
    return Mood.values.firstWhere(
      (mood) => mood.value == value,
      orElse: () => Mood.neutral,
    );
  }
}
