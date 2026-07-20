import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kuranvenamaz/theme/app_theme.dart';

class AyetDuaHadisTheme extends StatelessWidget {
  final String title;
  final String description;
  final String? arabicText;
  final String? kaynakca;

  const AyetDuaHadisTheme({
    Key? key,
    required this.title,
    required this.description,
    this.arabicText,
    this.kaynakca,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: const EdgeInsets.all(16.0),
      decoration: AppTheme.cardDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        showBorder: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.goldAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.format_quote_rounded,
                      color: AppTheme.goldAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.goldAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: AppTheme.textSecondaryDark, size: 18),
                tooltip: 'Kopyala',
                onPressed: () {
                  final textToCopy = "$title\n\n${arabicText != null ? "$arabicText\n\n" : ""}$description\n\nKaynak: ${kaynakca ?? ''}";
                  Clipboard.setData(ClipboardData(text: textToCopy));
                  Get.snackbar(
                    'Kopyalandı',
                    '$title panoya kopyalandı.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppTheme.primaryEmerald,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
            ],
          ),
          if (arabicText != null && arabicText!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.goldAccent.withOpacity(0.15)),
              ),
              child: Text(
                arabicText!,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: AppTheme.goldLight,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: AppTheme.textPrimaryDark,
              fontSize: 14.5,
              height: 1.5,
            ),
          ),
          if (kaynakca != null && kaynakca!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "— $kaynakca",
                style: const TextStyle(
                  color: AppTheme.goldAccent,
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
