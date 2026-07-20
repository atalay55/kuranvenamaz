import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class ZikirItem {
  final String title;
  final String arabic;
  final String meaning;

  const ZikirItem({
    required this.title,
    required this.arabic,
    required this.meaning,
  });
}

class Zikirmatik extends StatefulWidget {
  const Zikirmatik({Key? key}) : super(key: key);

  @override
  State<Zikirmatik> createState() => _ZikirmatikState();
}

class _ZikirmatikState extends State<Zikirmatik> {
  RxInt count = RxInt(0);
  RxInt tourCount = RxInt(0);
  int targetLimit = 33;
  bool isVibrationEnabled = true;

  final List<ZikirItem> zikirList = const [
    ZikirItem(
      title: "Sübhânallah",
      arabic: "سُبْحَانَ اللَّهِ",
      meaning: "Allah noksan sıfatlardan münezzehtir.",
    ),
    ZikirItem(
      title: "Elhamdülillâh",
      arabic: "الْحَمْدُ لِلَّهِ",
      meaning: "Hamd Allah'a mahsustur.",
    ),
    ZikirItem(
      title: "Allâhu Ekber",
      arabic: "اللَّهُ أَكْبَرُ",
      meaning: "Allah en büyüktür.",
    ),
    ZikirItem(
      title: "Lâ ilâhe illallâh",
      arabic: "لَا إِلٰهَ إِلَّا اللَّهُ",
      meaning: "Allah'tan başka ilah yoktur.",
    ),
    ZikirItem(
      title: "Estağfirullâh",
      arabic: "أَسْتَغْفِرُ اللَّهَ",
      meaning: "Allah'tan bağışlanma dilerim.",
    ),
  ];

  late ZikirItem selectedZikir = zikirList.first;

  @override
  void initState() {
    super.initState();
    _loadCounterData();
  }

  Future<void> _loadCounterData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      count.value = prefs.getInt("count") ?? 0;
      tourCount.value = prefs.getInt("tourCount") ?? 0;
      isVibrationEnabled = prefs.getBool("vibration") ?? true;
    });
  }

  Future<void> _saveCounterData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("count", count.value);
    await prefs.setInt("tourCount", tourCount.value);
    await prefs.setBool("vibration", isVibrationEnabled);
  }

  void _incrementCounter() {
    setState(() {
      count.value++;
      if (targetLimit > 0 && count.value % targetLimit == 0) {
        tourCount.value++;
        _triggerVibration(isLong: true);
      } else {
        _triggerVibration(isLong: false);
      }
    });
    _saveCounterData();
  }

  void _triggerVibration({bool isLong = false}) async {
    if (!isVibrationEnabled) return;
    try {
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        if (isLong) {
          Vibration.vibrate(duration: 400);
        } else {
          Vibration.vibrate(duration: 40);
        }
      }
    } catch (_) {}
  }

  void _resetCounter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text("Zikri Sıfırla", style: TextStyle(color: AppTheme.goldAccent)),
        content: const Text("Zikir sayacını sıfırlamak istediğinize emin misiniz?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal", style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                count.value = 0;
                tourCount.value = 0;
              });
              _saveCounterData();
              Navigator.pop(context);
            },
            child: const Text("Sıfırla"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Zikirmatik"),
        actions: [
          IconButton(
            icon: Icon(
              isVibrationEnabled ? Icons.vibration_rounded : Icons.phone_android_rounded,
              color: isVibrationEnabled ? AppTheme.goldAccent : Colors.white38,
            ),
            tooltip: 'Titreşim',
            onPressed: () {
              setState(() {
                isVibrationEnabled = !isVibrationEnabled;
              });
              _saveCounterData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded, color: AppTheme.goldAccent),
            tooltip: 'Sıfırla',
            onPressed: _resetCounter,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Zikir Selector Dropdown Card
              _buildZikirSelectorCard(),
              const SizedBox(height: 20),

              // Target Limit Selector (33 / 99 / Sınırsız)
              _buildTargetSelectorRow(),
              const SizedBox(height: 20),

              // Tour & Total Stats Card
              _buildStatsDisplay(),
              const Spacer(),

              // Interactive Tasbeeh Counter Button
              _buildMainCounterButton(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZikirSelectorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppTheme.cardDecoration(color: AppTheme.surfaceDark),
      child: Column(
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton<ZikirItem>(
              value: selectedZikir,
              isExpanded: true,
              dropdownColor: AppTheme.surfaceDark,
              icon: const Icon(Icons.arrow_drop_down_circle_rounded, color: AppTheme.goldAccent),
              items: zikirList.map((item) {
                return DropdownMenuItem<ZikirItem>(
                  value: item,
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      color: AppTheme.goldAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newItem) {
                if (newItem != null) {
                  setState(() {
                    selectedZikir = newItem;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            selectedZikir.arabic,
            style: const TextStyle(
              color: AppTheme.goldLight,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            selectedZikir.meaning,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondaryDark,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSelectorRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [33, 99, 100, 0].map((limit) {
        final isSelected = targetLimit == limit;
        final label = limit == 0 ? "Sınırsız" : "$limit";
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ChoiceChip(
            label: Text(label),
            selected: isSelected,
            selectedColor: AppTheme.goldAccent,
            backgroundColor: AppTheme.surfaceDark,
            labelStyle: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  targetLimit = limit;
                });
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsDisplay() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: AppTheme.cardDecoration(color: AppTheme.surfaceDark),
            child: Column(
              children: [
                const Text("Tur (33'lük)", style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12)),
                const SizedBox(height: 4),
                Obx(() => Text(
                      "${tourCount.value}",
                      style: const TextStyle(color: AppTheme.goldAccent, fontSize: 22, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: AppTheme.cardDecoration(color: AppTheme.surfaceDark),
            child: Column(
              children: [
                const Text("Toplam Zikir", style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12)),
                const SizedBox(height: 4),
                Obx(() => Text(
                      "${count.value}",
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainCounterButton() {
    return GestureDetector(
      onTap: _incrementCounter,
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppTheme.primaryEmerald, AppTheme.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppTheme.goldAccent, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryEmerald.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => Text(
                    "${count.value}",
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  )),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.goldAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "DOKUN",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
