import 'package:flutter/material.dart';
import 'package:sheryan/core/theme/app_colors.dart';
import 'package:sheryan/core/theme/app_design_constants.dart';
import 'package:sheryan/l10n/app_localizations.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final List<Map<String, Object>> tips = [
      {
        'title': l10n.tipBeforeTitle,
        'points': <String>[
          l10n.tipBeforePoint1,
          l10n.tipBeforePoint2,
          l10n.tipBeforePoint3,
          l10n.tipBeforePoint4,
        ]
      },
      {
        'title': l10n.tipDuringTitle,
        'points': <String>[
          l10n.tipDuringPoint1,
          l10n.tipDuringPoint2,
          l10n.tipDuringPoint3,
        ]
      },
      {
        'title': l10n.tipAfterTitle,
        'points': <String>[
          l10n.tipAfterPoint1,
          l10n.tipAfterPoint2,
          l10n.tipAfterPoint3,
          l10n.tipAfterPoint4,
        ]
      },
      {
        'title': l10n.tipBenefitsTitle,
        'points': <String>[
          l10n.tipBenefitsPoint1,
          l10n.tipBenefitsPoint2,
          l10n.tipBenefitsPoint3,
          l10n.tipBenefitsPoint4,
        ]
      },
      {
        'title': l10n.tipEligibilityTitle,
        'points': <String>[
          l10n.tipEligibilityPoint1,
          l10n.tipEligibilityPoint2,
          l10n.tipEligibilityPoint3,
          l10n.tipEligibilityPoint4,
        ]
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.awarenessTitle),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: AppDesignConstants.edgeInsetsMedium,
          itemCount: tips.length,
          itemBuilder: (context, index) {
            final tip = tips[index];
            final String title = tip['title'] as String;
            final List<String> points = List<String>.from(tip['points'] as List);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: AppDesignConstants.edgeInsetsMedium,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bloodtype, color: AppColors.primaryRed),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(
                      points.length,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 6, left: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("• ", style: TextStyle(color: AppColors.primaryRed, fontSize: 16)),
                            Expanded(
                              child: Text(
                                points[i],
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}