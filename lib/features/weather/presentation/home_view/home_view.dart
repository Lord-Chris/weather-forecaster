import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/shared/widgets/_widgets.dart';
import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Weather Forecaster',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ViewModelBuilder.reactive(
                viewModelBuilder: () => HomeViewModel(),
                builder: (context, viewModel, _) {
                  if (viewModel.isBusy) {
                    return const AppLoader();
                  }

                  if (viewModel.cities.isEmpty) {
                    return const Expanded(
                      child: Center(
                        child: Text('No cities found'),
                      ),
                    );
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTextField(
                        onChanged: viewModel.onSearchQueryChanged,
                        hint: 'Search city',
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: 5, // viewModel.cities.length,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemBuilder: (context, index) {
                          // final weather = viewModel.cities[index];
                          return const CityItemCard();
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CityItemCard extends StatelessWidget {
  const CityItemCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'weather.cityName',
                    style: AppTextStyles.medium16,
                  ),
                ),
                Spacing.horizRegular(),
                const Text(
                  'weather.temperature',
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
                const Expanded(
                  child: Text(
                    'weather.weather',
                    style: AppTextStyles.regular12,
                  ),
                ),
                Spacing.horizRegular(),
                const Expanded(
                  child: Text(
                    'weather.humidity',
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
