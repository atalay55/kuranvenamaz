class Surah {
  final int number;
  final String name;
  final String turkishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType; // Meccan or Medinan

  const Surah({
    required this.number,
    required this.name,
    required this.turkishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });
}

class AyahDetail {
  final int numberInSurah;
  final String arabicText;
  final String turkishTranslation;

  const AyahDetail({
    required this.numberInSurah,
    required this.arabicText,
    required this.turkishTranslation,
  });
}
