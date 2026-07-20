import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/core/quran_service.dart';
import 'package:kuranvenamaz/entity/quran_model.dart';
import 'package:kuranvenamaz/theme/app_theme.dart';

enum QuranViewMode { combined, arabicOnly, turkishOnly }

class SurahDetailPage extends StatefulWidget {
  final Surah surah;
  const SurahDetailPage({Key? key, required this.surah}) : super(key: key);

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  late Future<List<AyahDetail>> ayahsFuture;
  late PageController _pageController;

  QuranViewMode viewMode = QuranViewMode.combined;
  bool isBookTheme = true; // Warm Book Parchment Theme is DEFAULT
  bool isPageViewMode = true; // Sayfa Sayfa Horizontal Book Flip Mode
  int currentPageIndex = 0;
  static const int ayahsPerPage = 5; // Group 5 continuous Ayahs per book page

  double arabicFontSize = 25.0;
  double turkishFontSize = 15.0;
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    ayahsFuture = QuranService().fetchSurahAyahs(widget.surah.number);
    _checkBookmarkStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkBookmarkStatus() async {
    final lastRead = await QuranService.getLastReadSurah();
    if (mounted &&
        lastRead != null &&
        lastRead['number'] == widget.surah.number) {
      setState(() {
        isBookmarked = true;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    await QuranService.saveLastReadSurah(
        widget.surah.number, widget.surah.turkishName);
    setState(() {
      isBookmarked = !isBookmarked;
    });
    Get.snackbar(
      isBookmarked ? 'Kaldığınız Yer Kaydedildi' : 'Kaldığınız Yer Silindi',
      isBookmarked
          ? '${widget.surah.turkishName} Sûresi son okunan olarak işaretlendi.'
          : '${widget.surah.turkishName} Sûresi son okunan olarak kaldırıldı.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.primaryEmerald,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _increaseFontSize() {
    setState(() {
      if (arabicFontSize < 38) {
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

  // Chunk list of Ayahs into pages of 5 Ayahs each
  List<List<AyahDetail>> _chunkAyahs(List<AyahDetail> ayahs) {
    List<List<AyahDetail>> pages = [];
    for (var i = 0; i < ayahs.length; i += ayahsPerPage) {
      pages.add(
        ayahs.sublist(
          i,
          i + ayahsPerPage > ayahs.length ? ayahs.length : i + ayahsPerPage,
        ),
      );
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Theme Colors (Warm Book Parchment Cream #FAF6EE as default)
    final Color bgColor =
        isBookTheme ? AppTheme.bgBookParchment : AppTheme.bgDark;
    final Color cardBgColor =
        isBookTheme ? AppTheme.surfaceBookParchment : AppTheme.surfaceDark;
    final Color primaryTextColor =
        isBookTheme ? AppTheme.textBookPrimary : AppTheme.textPrimaryDark;
    final Color secondaryTextColor =
        isBookTheme ? AppTheme.textBookSecondary : AppTheme.textSecondaryDark;
    final Color borderColor = isBookTheme
        ? AppTheme.goldBookBorder
        : AppTheme.goldAccent.withOpacity(0.3);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isBookTheme ? AppTheme.surfaceBookParchment : null,
        iconTheme: IconThemeData(
            color: isBookTheme ? AppTheme.textBookPrimary : Colors.white),
        title: Column(
          children: [
            Text(
              "${widget.surah.number}. ${widget.surah.turkishName} Sûresi",
              style: TextStyle(
                  color: isBookTheme ? AppTheme.textBookPrimary : Colors.white),
            ),
            Text(
              "${widget.surah.numberOfAyahs} Âyet • ${widget.surah.revelationType}",
              style: TextStyle(
                  fontSize: 11,
                  color: isBookTheme
                      ? AppTheme.textBookSecondary
                      : AppTheme.goldLight),
            ),
          ],
        ),
        actions: [
          // Layout Switcher (Sayfa Sayfa Kitap vs Dikey Liste)
          IconButton(
            icon: Icon(
              isPageViewMode
                  ? Icons.auto_stories_rounded
                  : Icons.view_day_rounded,
              color:
                  isBookTheme ? AppTheme.goldBookBorder : AppTheme.goldAccent,
            ),
            tooltip: isPageViewMode
                ? 'Dikey Listeye Geç'
                : 'Sayfa Çevirme Moduna Geç',
            onPressed: () {
              setState(() {
                isPageViewMode = !isPageViewMode;
              });
            },
          ),
          // Theme Switcher (Krem Kâğıt vs Gece Modu)
          IconButton(
            icon: Icon(
              isBookTheme ? Icons.menu_book_rounded : Icons.dark_mode_rounded,
              color:
                  isBookTheme ? AppTheme.goldBookBorder : AppTheme.goldAccent,
            ),
            tooltip: isBookTheme ? 'Gece Moduna Geç' : 'Kitap Temasına Geç',
            onPressed: () {
              setState(() {
                isBookTheme = !isBookTheme;
              });
            },
          ),
          // Bookmark Icon
          IconButton(
            icon: Icon(
              isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isBookmarked
                  ? (isBookTheme
                      ? AppTheme.goldBookBorder
                      : AppTheme.goldAccent)
                  : (isBookTheme ? AppTheme.textBookSecondary : Colors.white60),
            ),
            tooltip: 'Kaldığım Yere Ekle',
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Control Toolbar
          _buildTopToolbar(
              cardBgColor, primaryTextColor, secondaryTextColor, borderColor),

          // Main Reading Area: Continuous PageView vs ListView
          Expanded(
            child: FutureBuilder<List<AyahDetail>>(
              future: ayahsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                            color: isBookTheme
                                ? AppTheme.goldBookBorder
                                : AppTheme.goldAccent),
                        const SizedBox(height: 14),
                        Text(
                          "Sûre Âyetleri Yükleniyor...",
                          style: TextStyle(color: secondaryTextColor),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Hata: ${snapshot.error}",
                        style: TextStyle(color: secondaryTextColor)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "Âyet verisi bulunamadı. Lütfen internet bağlantınızı kontrol edin.",
                      style: TextStyle(color: secondaryTextColor),
                    ),
                  );
                }

                final ayahs = snapshot.data!;
                final ayahPages = _chunkAyahs(ayahs);

                return isPageViewMode
                    ? _buildContinuousBookPageView(
                        ayahPages: ayahPages,
                        cardBgColor: cardBgColor,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        borderColor: borderColor,
                      )
                    : _buildVerticalListView(
                        ayahs: ayahs,
                        cardBgColor: cardBgColor,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        borderColor: borderColor,
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 1. CONTINUOUS HORIZONTAL BOOK PAGEVIEW (Multiple Ayahs per Page)
  Widget _buildContinuousBookPageView({
    required List<List<AyahDetail>> ayahPages,
    required Color cardBgColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color borderColor,
  }) {
    final bool hasBismillah =
        (widget.surah.number != 9 && widget.surah.number != 1);
    final int totalPages = ayahPages.length + (hasBismillah ? 1 : 0);

    return Column(
      children: [
        // Horizontal PageView
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            itemCount: totalPages,
            itemBuilder: (context, index) {
              // Page 0: Bismillah Header for Surahs except Tawbah 9 & Fatiha 1
              if (hasBismillah && index == 0) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: _buildBismillahHeader(cardBgColor, borderColor),
                  ),
                );
              }

              final pageIndex = hasBismillah ? index - 1 : index;
              final pageAyahs = ayahPages[pageIndex];

              return Padding(
                padding: const EdgeInsets.all(14.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: isBookTheme
                            ? AppTheme.goldBookBorder.withOpacity(0.15)
                            : Colors.black38,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: pageAyahs.length,
                    itemBuilder: (context, aIdx) {
                      final ayah = pageAyahs[aIdx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: borderColor.withOpacity(0.3),
                              width: 0.8,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ayah Badge Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryEmerald,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: AppTheme.goldBookBorder,
                                        width: 0.8),
                                  ),
                                  child: Text(
                                    "Âyet ${ayah.numberInSurah}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.copy_rounded,
                                      color: secondaryTextColor, size: 18),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  tooltip: 'Âyeti Kopyala',
                                  onPressed: () {
                                    final textToCopy =
                                        "${widget.surah.turkishName} Sûresi, ${ayah.numberInSurah}. Âyet:\n\n${ayah.arabicText}\n\nMeali: ${ayah.turkishTranslation}";
                                    Clipboard.setData(
                                        ClipboardData(text: textToCopy));
                                    Get.snackbar(
                                      'Kopyalandı',
                                      '${widget.surah.turkishName} ${ayah.numberInSurah}. Ayet panoya kopyalandı.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: AppTheme.primaryEmerald,
                                      colorText: Colors.white,
                                      duration: const Duration(seconds: 2),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Arabic Uthmani Text
                            if (viewMode == QuranViewMode.combined ||
                                viewMode == QuranViewMode.arabicOnly) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isBookTheme
                                      ? Colors.white.withOpacity(0.65)
                                      : Colors.black26,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: borderColor.withOpacity(0.4)),
                                ),
                                child: Text(
                                  ayah.arabicText,
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    color: isBookTheme
                                        ? AppTheme.primaryEmerald
                                        : AppTheme.goldLight,
                                    fontSize: arabicFontSize,
                                    fontWeight: FontWeight.bold,
                                    height: 1.8,
                                  ),
                                ),
                              ),
                            ],

                            if (viewMode == QuranViewMode.combined)
                              const SizedBox(height: 10),

                            // Diyanet Turkish Translation
                            if (viewMode == QuranViewMode.combined ||
                                viewMode == QuranViewMode.turkishOnly) ...[
                              Text(
                                ayah.turkishTranslation,
                                style: TextStyle(
                                  color: primaryTextColor,
                                  fontSize: turkishFontSize,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),

        // Bottom Book Page Navigation Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: cardBgColor,
            border: Border(top: BorderSide(color: borderColor, width: 0.8)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: currentPageIndex > 0
                    ? () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 14,
                  color: currentPageIndex > 0
                      ? (isBookTheme
                          ? AppTheme.primaryEmerald
                          : AppTheme.goldAccent)
                      : Colors.grey,
                ),
                label: Text(
                  "Önceki Sayfa",
                  style: TextStyle(
                    fontSize: 12,
                    color: currentPageIndex > 0
                        ? (isBookTheme
                            ? AppTheme.primaryEmerald
                            : AppTheme.goldAccent)
                        : Colors.grey,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color:
                      isBookTheme ? AppTheme.bgBookParchment : Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor.withOpacity(0.5)),
                ),
                child: Text(
                  "Sayfa ${currentPageIndex + 1} / $totalPages",
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: currentPageIndex < totalPages - 1
                    ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                label: Text(
                  "Sonraki Sayfa",
                  style: TextStyle(
                    fontSize: 12,
                    color: currentPageIndex < totalPages - 1
                        ? (isBookTheme
                            ? AppTheme.primaryEmerald
                            : AppTheme.goldAccent)
                        : Colors.grey,
                  ),
                ),
                icon: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: currentPageIndex < totalPages - 1
                      ? (isBookTheme
                          ? AppTheme.primaryEmerald
                          : AppTheme.goldAccent)
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. VERTICAL LIST VIEW (ScrollView)
  Widget _buildVerticalListView({
    required List<AyahDetail> ayahs,
    required Color cardBgColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color borderColor,
  }) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      itemCount: ayahs.length +
          (widget.surah.number != 9 && widget.surah.number != 1 ? 1 : 0),
      itemBuilder: (context, index) {
        if (widget.surah.number != 9 &&
            widget.surah.number != 1 &&
            index == 0) {
          return _buildBismillahHeader(cardBgColor, borderColor);
        }

        final ayahIndex = (widget.surah.number != 9 && widget.surah.number != 1)
            ? index - 1
            : index;
        final ayah = ayahs[ayahIndex];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: isBookTheme
                    ? Colors.black.withOpacity(0.04)
                    : Colors.black26,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryEmerald,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: isBookTheme
                              ? AppTheme.goldBookBorder
                              : AppTheme.goldAccent.withOpacity(0.4)),
                    ),
                    child: Text(
                      "Âyet ${ayah.numberInSurah}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy_rounded,
                        color: secondaryTextColor, size: 18),
                    tooltip: 'Âyeti Kopyala',
                    onPressed: () {
                      final textToCopy =
                          "${widget.surah.turkishName} Sûresi, ${ayah.numberInSurah}. Âyet:\n\n${ayah.arabicText}\n\nMeali: ${ayah.turkishTranslation}";
                      Clipboard.setData(ClipboardData(text: textToCopy));
                      Get.snackbar(
                        'Kopyalandı',
                        '${widget.surah.turkishName} ${ayah.numberInSurah}. Ayet panoya kopyalandı.',
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
              if (viewMode == QuranViewMode.combined ||
                  viewMode == QuranViewMode.arabicOnly) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isBookTheme
                        ? Colors.white.withOpacity(0.65)
                        : Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    ayah.arabicText,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: isBookTheme
                          ? AppTheme.primaryEmerald
                          : AppTheme.goldLight,
                      fontSize: arabicFontSize,
                      fontWeight: FontWeight.bold,
                      height: 1.8,
                    ),
                  ),
                ),
              ],
              if (viewMode == QuranViewMode.combined)
                const SizedBox(height: 12),
              if (viewMode == QuranViewMode.combined ||
                  viewMode == QuranViewMode.turkishOnly) ...[
                Text(
                  ayah.turkishTranslation,
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: turkishFontSize,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Top Toolbar Widget
  Widget _buildTopToolbar(Color cardBgColor, Color primaryTextColor,
      Color secondaryTextColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cardBgColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.8)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildModeChip("Arapça+Meal", QuranViewMode.combined),
              _buildModeChip("Arapça", QuranViewMode.arabicOnly),
              _buildModeChip("Meal", QuranViewMode.turkishOnly),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.format_size_rounded,
                    color: isBookTheme
                        ? AppTheme.goldBookBorder
                        : AppTheme.goldAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text("Metin Boyutu",
                      style:
                          TextStyle(color: secondaryTextColor, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline_rounded,
                      color: isBookTheme
                          ? AppTheme.goldBookBorder
                          : AppTheme.goldAccent,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Küçült',
                    onPressed: _decreaseFontSize,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "${arabicFontSize.toInt()} pt",
                    style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      color: isBookTheme
                          ? AppTheme.goldBookBorder
                          : AppTheme.goldAccent,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Büyüt',
                    onPressed: _increaseFontSize,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip(String label, QuranViewMode mode) {
    final bool isSelected = viewMode == mode;
    final Color activeColor = AppTheme.primaryEmerald;
    final Color activeText = Colors.white;
    final Color inactiveText =
        isBookTheme ? AppTheme.textBookSecondary : AppTheme.textSecondaryDark;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? activeText : inactiveText,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: activeColor,
      backgroundColor:
          isBookTheme ? Colors.black.withOpacity(0.05) : Colors.black26,
      side: BorderSide(
        color: isSelected
            ? (isBookTheme ? AppTheme.goldBookBorder : AppTheme.goldAccent)
            : Colors.transparent,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            viewMode = mode;
          });
        }
      },
    );
  }

  Widget _buildBismillahHeader(Color cardBgColor, Color borderColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isBookTheme ? AppTheme.surfaceBookParchment : AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isBookTheme
                ? AppTheme.goldBookBorder
                : AppTheme.goldAccent.withOpacity(0.4),
            width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isBookTheme
                ? AppTheme.goldBookBorder.withOpacity(0.15)
                : Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: isBookTheme ? AppTheme.primaryEmerald : AppTheme.goldLight,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Rahmân ve Rahîm olan Allah'ın adıyla",
            style: TextStyle(
              color: isBookTheme ? AppTheme.textBookSecondary : Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
