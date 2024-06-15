import 'package:flutter/material.dart';

import '../../../../core/shared/constants/_constants.dart';
import '../../domain/entities/city_location_model.dart';

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
    return InkWell(
      onTap: () => onTap?.call(city),
      child: Card(
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
                          city.name,
                          style: AppTextStyles.medium16,
                        ),
                      ),
                      Spacing.horizRegular(),
                      Text(
                        city.weather?.weather.first.main ?? '',
                        style: AppTextStyles.regular14,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          city.weather?.parsedDate ?? '',
                          style: AppTextStyles.regular12,
                        ),
                      ),
                      Spacing.horizRegular(),
                      Text(
                        city.weather?.parsedTime ?? '',
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
                      'Min Temp: ${city.weather?.main.tempMin}',
                      style: AppTextStyles.regular12,
                    ),
                  ),
                  Spacing.horizRegular(),
                  Expanded(
                    child: Text(
                      'Max Temp: ${city.weather?.main.tempMax}',
                      style: AppTextStyles.regular12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
