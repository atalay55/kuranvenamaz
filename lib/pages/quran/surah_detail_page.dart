import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/core/quran_service.dart';
import 'package:kuranvenamaz/entity/quran_model.dart';
import 'package:kuranvenamaz/theme/app_theme.dart';

class SurahDetailPage extends StatefulWidget {
  final Surah surah;
  const SurahDetailPage({Key? key, required this.surah}) : super(key: key);

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  late Future<List<AyahDetail>> ayahsFuture;
  double arabicFontSize = 24.0;
  double turkishFontSize = 14.5;
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    ayahsFuture = QuranService().fetchSurahAyahs(widget.surah.number);
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    final lastRead = await QuranService.getLastReadSurah();
    if (mounted && lastRead != null && lastRead['number'] == widget.surah.number) {
      setState(() {
        isBookmarked = true;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    await QuranService.saveLastReadSurah(widget.surah.number, widget.surah.turkishName);
    setState(() {
      isBookmarked = true;
    });
    Get.snackbar(
      'Kaldığınız Yer Kaydedildi',
      '${widget.surah.turkishName} Sûresi son okunan olarak işaretlendi.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.primaryEmerald,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _increaseFontSize() {
    setState(() {
      if (arabicFontSize < 36) {
        arabicFontSize += 2;
        turkishFontSize += 1.5;
      }
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (arabicFontSize > 18) {
        arabicFontSize -= 2;
        turkishFontSize -= 1.5;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text("${widget.surah.number}. ${widget.surah.turkishName} Sûresi"),
            Text(
              "${widget.surah.numberOfAyahs} Âyet • ${widget.surah.revelationType}",
              style: const TextStyle(fontSize: 11, color: AppTheme.goldLight),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isBookmarked ? AppTheme.goldAccent : Colors.white60,
            ),
            tooltip: 'Kaldığım Yere Ekle',
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Control Bar: Font Size Zoom & Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppTheme.surfaceDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.text_format_rounded, color: AppTheme.goldAccent, size: 18),
                    SizedBox(width: 6),
                    Text("Yazı Boyutu", style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded, color: AppTheme.goldAccent, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Küçült',
                      onPressed: _decreaseFontSize,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${arabicFontSize.toInt()} pt",
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.goldAccent, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Büyüt',
                      onPressed: _increaseFontSize,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Ayahs List
          Expanded(
            child: FutureBuilder<List<AyahDetail>>(
              future: ayahsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppTheme.goldAccent),
                        SizedBox(height: 14),
                        Text("Sûre Âyetleri Yükleniyor...", style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Hata: ${snapshot.error}", style: const TextStyle(color: Colors.white70)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Âyet verisi bulunamadı. Lütfen internet bağlantınızı kontrol edin.", style: TextStyle(color: Colors.white70)),
                  );
                }

                final ayahs = snapshot.data!;

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  itemCount: ayahs.length + (widget.surah.number != 9 && widget.surah.number != 1 ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show Bismillah Header at index 0 for Surahs except Tawbah (9) & Fatiha (1)
                    if (widget.surah.number != 9 && widget.surah.number != 1 && index == 0) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: AppTheme.headerGradientDecoration(borderRadius: BorderRadius.circular(16)),
                        child: const Column(
                          children: [
                            Text(
                              "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: AppTheme.goldLight,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                height: 1.6,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Rahmân ve Rahîm olan Allah'ın adıyla",
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }

                    final ayahIndex = (widget.surah.number != 9 && widget.surah.number != 1) ? index - 1 : index;
                    final ayah = ayahs[ayahIndex];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: AppTheme.cardDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ayah Header (Number Badge & Actions)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryEmerald.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.goldAccent.withOpacity(0.3)),
                                ),
                                child: Text(
                                  "Âyet ${ayah.numberInSurah}",
                                  style: const TextStyle(
                                    color: AppTheme.goldAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy_rounded, color: AppTheme.textSecondaryDark, size: 18),
                                tooltip: 'Âyeti Kopyala',
                                onPressed: () {
                                  final textToCopy = "${widget.surah.turkishName} Sûresi, ${ayah.numberInSurah}. Âyet:\n\n${ayah.arabicText}\n\nMeali: ${ayah.turkishTranslation}";
                                  Clipboard.setData(ClipboardData(text: textToCopy));
                                  Get.snackbar(
                                    'Kopyalandı Panoya',
                                    '${widget.surah.turkishName} ${ayah.numberInSurah}. Ayet kopyalandı.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: AppTheme.primaryEmerald,
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 2),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Arabic Text
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.goldAccent.withOpacity(0.15)),
                            ),
                            child: Text(
                              ayah.arabicText,
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: AppTheme.goldLight,
                                fontSize: arabicFontSize,
                                fontWeight: FontWeight.w500,
                                height: 1.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Diyanet Turkish Translation
                          Text(
                            ayah.turkishTranslation,
                            style: TextStyle(
                              color: AppTheme.textPrimaryDark,
                              fontSize: turkishFontSize,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
