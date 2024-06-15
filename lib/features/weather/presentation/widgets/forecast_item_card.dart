import 'package:flutter/material.dart';

import '../../../../core/extensions/string_extension.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../domain/entities/forecast_model.dart';

class ForecastItemCard extends StatelessWidget {
  final ListElement weather;

  const ForecastItemCard({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        weather.weather.firstOrNull?.description
                                .capitalizeString() ??
                            '',
                        style: AppTextStyles.medium16,
                      ),
                    ),
                    Spacing.horizRegular(),
                    Text(
                      weather.parsedDate.toString(),
                      style: AppTextStyles.regular14,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Spacer(),
                    Spacing.horizRegular(),
                    Text(
                      weather.parsedTime,
                      style: AppTextStyles.regular12,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Min Temp: ${weather.main.tempMin}',
                    style: AppTextStyles.regular12,
                  ),
                ),
                Spacing.horizRegular(),
                Expanded(
                  child: Text(
                    'Max Temp: ${weather.main.tempMax}',
                    style: AppTextStyles.regular12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
