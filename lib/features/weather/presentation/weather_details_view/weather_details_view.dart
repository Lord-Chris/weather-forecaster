import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/shared/widgets/_widgets.dart';
import '../../domain/entities/city_location_model.dart';
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
      viewModelBuilder: () => WeatherDetailsViewModel(),
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
                            'No forecast found',
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
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: viewModel.forecast.length,
                          separatorBuilder: (_, __) => Spacing.vertRegular(),
                          itemBuilder: (context, index) {
                            final weather = viewModel.forecast[index];
                            return ForecastItemCard(weather: weather);
                          },
                        ),
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
