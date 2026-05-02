import 'package:flutter/material.dart';

void showPointsGainedSnack(BuildContext context, int points) {
  if (points <= 0) return;
  final isAr = Localizations.localeOf(context).languageCode == 'ar';
  final msg = isAr
      ? '+$points نقطة مكتسبة! 🎉'
      : '+$points points earned! 🎉';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
          const SizedBox(width: 10),
          Text(msg, style: const TextStyle(color: Colors.white, fontSize: 15)),
        ],
      ),
      backgroundColor: Colors.green.shade700,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(12),
    ),
  );
}
