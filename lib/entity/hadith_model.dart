class HadithItem {
  final int id;
  final String category;
  final String arabic;
  final String turkish;
  final String source;
  final String? topic;

  const HadithItem({
    required this.id,
    required this.category,
    required this.arabic,
    required this.turkish,
    required this.source,
    this.topic,
  });
}
