import 'package:flutter/material.dart';
import 'package:kuranvenamaz/entity/namazvakitleri.dart';
import 'package:kuranvenamaz/theme/app_theme.dart';

Widget NamazVakitleriKucuk(NamazVakitleri namazVakit, {bool isNextVakit = false}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
    decoration: BoxDecoration(
      color: isNextVakit ? AppTheme.goldAccent.withOpacity(0.2) : AppTheme.surfaceDark,
      border: Border.all(
        color: isNextVakit ? AppTheme.goldAccent : AppTheme.goldAccent.withOpacity(0.2),
        width: isNextVakit ? 1.5 : 1,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: isNextVakit
          ? [
              BoxShadow(
                color: AppTheme.goldAccent.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _getVakitIcon(namazVakit.vakitIsmi),
          size: 18,
          color: isNextVakit ? AppTheme.goldAccent : AppTheme.textSecondaryDark,
        ),
        const SizedBox(height: 4),
        Text(
          namazVakit.vakitIsmi,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isNextVakit ? FontWeight.bold : FontWeight.normal,
            color: isNextVakit ? AppTheme.goldAccent : AppTheme.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          namazVakit.namazSaati,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isNextVakit ? Colors.white : AppTheme.textPrimaryDark,
          ),
        ),
      ],
    ),
  );
}

IconData _getVakitIcon(String vakitIsmi) {
  switch (vakitIsmi.toLowerCase()) {
    case 'imsak':
      return Icons.nights_stay_outlined;
    case 'güneş':
    case 'gunes':
      return Icons.wb_twilight;
    case 'öğle':
    case 'ogle':
      return Icons.wb_sunny_outlined;
    case 'ikindi':
      return Icons.wb_sunny;
    case 'akşam':
    case 'aksam':
      return Icons.wb_twilight_rounded;
    case 'yatsı':
    case 'yatsi':
      return Icons.bedtime_outlined;
    default:
      return Icons.access_time;
  }
}