import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/shared/widgets/_widgets.dart';
import '../../domain/entities/city_location_model.dart';
import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
        viewModelBuilder: () => HomeViewModel(),
        onViewModelReady: (viewModel) => viewModel.getCurrentWeather(),
        builder: (context, viewModel, _) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Weather Forecaster',
                      style: AppTextStyles.semiBold24,
                    ),
                    const SizedBox(height: 24),
                    if (viewModel.allCities.isNotEmpty)
                      AppTextField(
                        onChanged: viewModel.onSearchQueryChanged,
                        hint: 'Search city',
                      ),
                    Builder(
                      builder: (context) {
                        if (viewModel.isBusy) {
                          return const Expanded(
                            child: AppLoader(color: AppColors.biddaPry800),
                          );
                        }

                        if (viewModel.cities.isEmpty) {
                          return const Expanded(
                            child: Center(child: Text('No cities found')),
                          );
                        }

                        return Expanded(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: viewModel.cities.length,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            separatorBuilder: (_, __) => Spacing.vertRegular(),
                            itemBuilder: (context, index) {
                              final city = viewModel.cities[index];
                              return CityItemCard(
                                city: city,
                                onTap: viewModel.onCardTap,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

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
              child: Row(
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
