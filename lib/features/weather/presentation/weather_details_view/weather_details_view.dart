import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import '../../../../core/app/_app.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/shared/widgets/_widgets.dart';
import '../../data/dtos/city_location_model.dart';
import '../widgets/city_item_card.dart';
import '../widgets/forecast_item_card.dart';
import 'weather_details_viewmodel.dart';

class WeatherDetailsView extends StatelessWidget {
  final CityLocationModel city;
  const WeatherDetailsView({
    super.key,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => locator<WeatherDetailsViewModel>(),
      onViewModelReady: (viewModel) => viewModel.init(city),
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Text(
              viewModel.city.name,
              style: AppTextStyles.semiBold24,
            ),
          ),
          body: RefreshIndicator(
            onRefresh: viewModel.fetchForecast,
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Weather',
                        style: AppTextStyles.medium14,
                      ),
                      Spacing.vertSmall(),
                      CityItemCard(city: viewModel.city),
                      Spacing.vertRegular(),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: viewModel.onAirQualityTap,
                          icon: const Icon(Icons.air),
                          label: const Text('Air quality'),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Builder(builder: (context) {
                  if (viewModel.isBusy && viewModel.forecast.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: AppLoader(color: AppColors.biddaPry800),
                    );
                  }
                  if (viewModel.forecast.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No forecast available',
                            style: AppTextStyles.regular14,
                          ),
                          Spacing.vertRegular(),
                          AppButton(
                            label: 'Refresh',
                            isCollapsed: true,
                            onPressed: viewModel.fetchForecast,
                          ),
                        ],
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '5-day forecast',
                          style: AppTextStyles.medium14,
                        ),
                        Spacing.vertSmall(),
                        for (final day in viewModel.forecastByDay.entries) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 8),
                            child: Text(
                              DateFormat.MMMEd().format(day.key),
                              style: AppTextStyles.semiBold16,
                            ),
                          ),
                          for (final weather in day.value) ...[
                            ForecastItemCard(weather: weather),
                            Spacing.vertSmall(),
                          ],
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
