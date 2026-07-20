import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kuranvenamaz/core/hadith_data.dart';
import 'package:kuranvenamaz/core/httpcontroller.dart';
import 'package:kuranvenamaz/entity/hadith_model.dart';
import 'package:kuranvenamaz/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HadithListPage extends StatefulWidget {
  const HadithListPage({Key? key}) : super(key: key);

  @override
  State<HadithListPage> createState() => _HadithListPageState();
}

class _HadithListPageState extends State<HadithListPage> {
  final HttpController _httpController = HttpController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _apiCategories = [];
  String _selectedCategoryTitle = 'Tümü';
  String? _selectedCategoryId;

  List<HadithItem> _hadiths = [];
  List<HadithItem> _filteredHadiths = [];
  bool _isLoading = true;
  final Set<int> _favoriteHadithIds = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _fetchCategoriesAndHadiths();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favs = prefs.getStringList('favorite_hadiths');
    if (favs != null && mounted) {
      setState(() {
        _favoriteHadithIds.clear();
        _favoriteHadithIds.addAll(favs.map((e) => int.parse(e)));
      });
    }
  }

  Future<void> _toggleFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteHadithIds.contains(id)) {
        _favoriteHadithIds.remove(id);
      } else {
        _favoriteHadithIds.add(id);
      }
    });
    await prefs.setStringList(
      'favorite_hadiths',
      _favoriteHadithIds.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _fetchCategoriesAndHadiths() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await _httpController.fetchHadithCategories();
      if (categories.isNotEmpty) {
        _apiCategories = categories;
      }
    } catch (_) {}

    await _loadHadithsForCategory(null);
  }

  Future<void> _loadHadithsForCategory(String? categoryId) async {
    setState(() {
      _isLoading = true;
      _selectedCategoryId = categoryId;
    });

    List<HadithItem> loadedList = [];

    if (categoryId != null) {
      final apiHadithList = await _httpController.fetchHadithsByCategory(categoryId, perPage: 15);
      if (apiHadithList.isNotEmpty) {
        for (var item in apiHadithList) {
          final detail = await _httpController.fetchHadithDetail(item['id']);
          if (detail != null) {
            loadedList.add(
              HadithItem(
                id: int.tryParse(detail['id']) ?? item['id'].hashCode,
                category: _selectedCategoryTitle,
                arabic: detail['arabic'],
                turkish: detail['turkish'],
                source: "${detail['source']} (${detail['grade']})",
                topic: detail['explanation'].isNotEmpty ? detail['explanation'] : null,
              ),
            );
          }
        }
      }
    }

    // Fallback or 'Tümü'
    if (loadedList.isEmpty) {
      loadedList = HadithData.allHadiths;
    }

    if (mounted) {
      setState(() {
        _hadiths = loadedList;
        _isLoading = false;
      });
      _applyFilter();
    }
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredHadiths = _hadiths.where((hadith) {
        final isFavFilter = _selectedCategoryTitle == 'Favorilerim';
        if (isFavFilter && !_favoriteHadithIds.contains(hadith.id)) {
          return false;
        }

        final textMatch = query.isEmpty ||
            hadith.turkish.toLowerCase().contains(query) ||
            hadith.source.toLowerCase().contains(query) ||
            (hadith.topic != null && hadith.topic!.toLowerCase().contains(query));

        return textMatch;
      }).toList();
    });
  }

  void _copyToClipboard(HadithItem hadith) {
    final textToCopy =
        "${hadith.arabic}\n\n\"${hadith.turkish}\"\n\nKaynak: ${hadith.source}";
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Hadis-i Şerif panoya kopyalandı."),
        duration: Duration(seconds: 2),
        backgroundColor: AppTheme.primaryEmerald,
      ),
    );
  }

  void _showHadithExplanation(HadithItem hadith) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.auto_stories_rounded, color: AppTheme.goldAccent),
                  SizedBox(width: 10),
                  Text(
                    "Hadis-i Şerif Şerhi ve Açıklaması",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),
              Text(
                hadith.topic ?? "Açıklama mevcut değil.",
                style: const TextStyle(
                  color: AppTheme.textPrimaryDark,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Kapat", style: TextStyle(color: AppTheme.goldAccent)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> categoryList = [
      {'id': 'all', 'title': 'Tümü'},
      {'id': 'fav', 'title': 'Favorilerim'},
    ];

    if (_apiCategories.isNotEmpty) {
      for (var c in _apiCategories.take(12)) {
        categoryList.add({'id': c['id'].toString(), 'title': c['title'].toString()});
      }
    } else {
      for (var c in HadithData.categories.sublist(1)) {
        categoryList.add({'id': 'local', 'title': c});
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hadis-i Şerifler (Diyanet)"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.goldAccent),
            onPressed: _fetchCategoriesAndHadiths,
            tooltip: "Yenile",
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppTheme.textPrimaryDark),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.goldAccent),
                hintText: 'Diyanet Hadislerinde ara (Örn: Niyet, İlim, İman)...',
                hintStyle: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 13),
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
              onChanged: (_) => _applyFilter(),
            ),
          ),

          // Dynamic Horizontal Category Chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: categoryList.length,
              itemBuilder: (context, index) {
                final cat = categoryList[index];
                final isSelected = cat['title'] == _selectedCategoryTitle;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(
                      cat['title'] == 'Favorilerim'
                          ? '❤️ Favoriler (${_favoriteHadithIds.length})'
                          : cat['title']!,
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryTitle = cat['title']!;
                      });
                      if (cat['id'] != 'all' && cat['id'] != 'fav' && cat['id'] != 'local') {
                        _loadHadithsForCategory(cat['id']);
                      } else {
                        _loadHadithsForCategory(null);
                      }
                    },
                    backgroundColor: AppTheme.surfaceDark,
                    selectedColor: AppTheme.primaryEmerald,
                    checkmarkColor: AppTheme.goldAccent,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondaryDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppTheme.goldAccent : Colors.transparent,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Hadith Cards List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppTheme.goldAccent),
                        SizedBox(height: 12),
                        Text(
                          "Diyanet Hadis-i Şerifleri Yükleniyor...",
                          style: TextStyle(color: AppTheme.textSecondaryDark),
                        ),
                      ],
                    ),
                  )
                : _filteredHadiths.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.search_off_rounded, size: 48, color: AppTheme.goldAccent),
                            SizedBox(height: 12),
                            Text(
                              "Kriterlere uygun Hadis bulunamadı.",
                              style: TextStyle(color: AppTheme.textSecondaryDark),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        itemCount: _filteredHadiths.length,
                        itemBuilder: (context, index) {
                          final hadith = _filteredHadiths[index];
                          final isFav = _favoriteHadithIds.contains(hadith.id);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: AppTheme.cardDecoration(
                              color: AppTheme.surfaceDark,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryEmerald.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppTheme.goldAccent.withOpacity(0.4)),
                                      ),
                                      child: const Text(
                                        "Diyanet Hadis Kaynağı",
                                        style: TextStyle(
                                          color: AppTheme.goldLight,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                            color: isFav ? Colors.redAccent : AppTheme.textSecondaryDark,
                                            size: 22,
                                          ),
                                          onPressed: () => _toggleFavorite(hadith.id),
                                          tooltip: isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.copy_rounded,
                                            color: AppTheme.goldAccent,
                                            size: 20,
                                          ),
                                          onPressed: () => _copyToClipboard(hadith),
                                          tooltip: 'Kopyala',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Arabic Text
                                Text(
                                  hadith.arabic,
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(
                                    color: AppTheme.primaryEmerald,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Turkish Translation
                                Text(
                                  "\"${hadith.turkish}\"",
                                  style: const TextStyle(
                                    color: AppTheme.textPrimaryDark,
                                    fontSize: 14,
                                    height: 1.5,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Source Footer
                                Row(
                                  children: [
                                    const Icon(Icons.bookmark_outline_rounded,
                                        size: 14, color: AppTheme.goldAccent),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        hadith.source,
                                        style: const TextStyle(
                                          color: AppTheme.goldLight,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (hadith.topic != null) ...[
                                      InkWell(
                                        onTap: () => _showHadithExplanation(hadith),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Açıklama",
                                                style: TextStyle(
                                                  color: AppTheme.goldAccent,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Icon(Icons.info_outline_rounded,
                                                  size: 14, color: AppTheme.goldAccent),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
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
