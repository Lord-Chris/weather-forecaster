import 'package:flutter/material.dart';

import '../../../../core/extensions/num_extension.dart';
import '../../../../core/extensions/string_extension.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/shared/widgets/_widgets.dart';
import '../../data/dtos/city_location_model.dart';

class CityItemCard extends StatelessWidget {
  final CityLocationModel city;
  final void Function(CityLocationModel)? onTap;

  const CityItemCard({
    super.key,
    required this.city,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final weather = city.weather;
    final condition = weather?.weather.firstOrNull;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(city),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.primaryContainer.withValues(alpha: 0.55),
                scheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          city.name,
                          style: AppTextStyles.semiBold18,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          condition?.description.capitalizeString() ?? '',
                          style: AppTextStyles.regular14.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacing.horizRegular(),
                  WeatherIcon(icon: condition?.icon),
                  Text(
                    weather?.main.temp.asCelsius ?? '--',
                    style: AppTextStyles.dynamic(
                      32,
                      weight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
              Spacing.vertSmall(),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InfoChip(
                    icon: Icons.south,
                    label: weather?.main.tempMin.asCelsius ?? '-',
                  ),
                  InfoChip(
                    icon: Icons.north,
                    label: weather?.main.tempMax.asCelsius ?? '-',
                  ),
                  if (weather != null) ...[
                    InfoChip(
                      icon: Icons.water_drop_outlined,
                      label: '${weather.main.humidity}%',
                    ),
                    InfoChip(
                      icon: Icons.air,
                      label: '${weather.wind.speed} m/s',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
