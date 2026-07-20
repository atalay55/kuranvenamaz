import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/core/quran_service.dart';
import 'package:kuranvenamaz/entity/quran_model.dart';
import 'package:kuranvenamaz/pages/quran/surah_detail_page.dart';
import 'package:kuranvenamaz/theme/app_theme.dart';

class SurahListPage extends StatefulWidget {
  const SurahListPage({Key? key}) : super(key: key);

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  late TextEditingController searchController;
  List<Surah> filteredSurahs = QuranService.allSurahs;
  Map<String, dynamic>? lastReadBookmark;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    _loadBookmark();
  }

  Future<void> _loadBookmark() async {
    final bookmark = await QuranService.getLastReadSurah();
    if (mounted) {
      setState(() {
        lastReadBookmark = bookmark;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterSurahs(String query) {
    final input = query.toLowerCase().trim();
    setState(() {
      if (input.isEmpty) {
        filteredSurahs = QuranService.allSurahs;
      } else {
        filteredSurahs = QuranService.allSurahs.where((surah) {
          final nameMatch = surah.turkishName.toLowerCase().contains(input);
          final englishMatch = surah.englishNameTranslation.toLowerCase().contains(input);
          final numberMatch = surah.number.toString() == input;
          return nameMatch || englishMatch || numberMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kur'an-ı Kerim Sûreleri"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar & Bookmark Header
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  style: const TextStyle(color: AppTheme.textPrimaryDark),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.goldAccent),
                    hintText: 'Sûre ara (Örn: Yâsîn, Fâtiha, 36)...',
                    hintStyle: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 14),
                    filled: true,
                    fillColor: AppTheme.surfaceDark,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppTheme.goldAccent.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppTheme.goldAccent.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.goldAccent),
                    ),
                  ),
                  onChanged: _filterSurahs,
                ),
                if (lastReadBookmark != null) ...[
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      final int num = lastReadBookmark!['number'];
                      final surah = QuranService.allSurahs.firstWhere((s) => s.number == num);
                      Get.to(() => SurahDetailPage(surah: surah))?.then((_) => _loadBookmark());
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: AppTheme.headerGradientDecoration(borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          const Icon(Icons.bookmark_rounded, color: AppTheme.goldAccent, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Son Kaldığınız Sûre",
                                  style: TextStyle(color: AppTheme.goldLight, fontSize: 11, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "${lastReadBookmark!['number']}. ${lastReadBookmark!['name']} Sûresi",
                                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.goldAccent, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Surah List
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: filteredSurahs.length,
              itemBuilder: (context, index) {
                final surah = filteredSurahs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: AppTheme.cardDecoration(color: AppTheme.surfaceDark),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryEmerald,
                        border: Border.all(color: AppTheme.goldAccent),
                      ),
                      child: Center(
                        child: Text(
                          "${surah.number}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          surah.turkishName,
                          style: const TextStyle(
                            color: AppTheme.textPrimaryDark,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          surah.name,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: AppTheme.primaryEmerald,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              surah.revelationType,
                              style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 11),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${surah.numberOfAyahs} Âyet",
                            style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "•  ${surah.englishNameTranslation}",
                            style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 11, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Get.to(() => SurahDetailPage(surah: surah))?.then((_) => _loadBookmark());
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
