import 'package:flutter/material.dart';

import '../../../../core/extensions/num_extension.dart';
import '../../../../core/extensions/string_extension.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/shared/widgets/_widgets.dart';
import '../../data/dtos/forecast_model.dart';

class ForecastItemCard extends StatelessWidget {
  final ListElement weather;

  const ForecastItemCard({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final condition = weather.weather.firstOrNull;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            WeatherIcon(icon: condition?.icon, size: 48),
            Spacing.horizSmall(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    condition?.description.capitalizeString() ?? '',
                    style: AppTextStyles.medium16,
                  ),
                  Text(
                    '${weather.parsedDate}  ${weather.parsedTime}',
                    style: AppTextStyles.regular12.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  weather.main.tempMax.asCelsius,
                  style: AppTextStyles.semiBold18,
                ),
                Text(
                  weather.main.tempMin.asCelsius,
                  style: AppTextStyles.regular14.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
