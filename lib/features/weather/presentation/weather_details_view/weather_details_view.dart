import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/shared/widgets/_widgets.dart';
import '../../domain/entities/city_location_model.dart';
import '../home_view/home_view.dart';
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
      // onViewModelReady: (viewModel) => viewModel.getCurrentWeather(),
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Text(
              city.name,
              style: AppTextStyles.semiBold24,
            ),
          ),
          body: SafeArea(
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
                      CityItemCard(city: city),
                    ],
                  ),
                ),
                const Divider(),
                Builder(builder: (context) {
                  if (viewModel.isBusy) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: AppLoader(color: AppColors.biddaPry800),
                    );
                  }
                  if ([].isEmpty) {
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
                            onPressed: () {},
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
                          itemCount: 5, //viewModel.cities.length,
                          separatorBuilder: (_, __) => Spacing.vertRegular(),
                          itemBuilder: (context, index) {
                            // final city = viewModel.cities[index];
                            return CityItemCard(city: city);
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
