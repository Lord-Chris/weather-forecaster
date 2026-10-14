import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import '../../../../core/app/_app.dart';
import '../../../../core/extensions/context_extenstion.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/shared/widgets/_widgets.dart';
import '../widgets/city_item_card.dart';
import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
        viewModelBuilder: () => locator<HomeViewModel>(),
        onViewModelReady: (viewModel) => viewModel.init(),
        builder: (context, viewModel, _) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                AppConstants.appName,
                                style: AppTextStyles.semiBold24,
                              ),
                              Text(
                                DateFormat.MMMMEEEEd().format(DateTime.now()),
                                style: AppTextStyles.regular14.copyWith(
                                  color: context.cScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'Add city',
                          onPressed: viewModel.onAddCityTap,
                          icon: const Icon(Icons.add_location_alt_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (viewModel.allCities.isNotEmpty)
                      AppTextField(
                        onChanged: viewModel.onSearchQueryChanged,
                        hint: 'Search city',
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        prefix: const Icon(Icons.search),
                      ),
                    Builder(
                      builder: (context) {
                        if (viewModel.isBusy && viewModel.cities.isEmpty) {
                          return const Expanded(
                            child: AppLoader(color: AppColors.biddaPry800),
                          );
                        }

                        if (viewModel.cities.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'No cities available',
                                  style: AppTextStyles.regular14,
                                ),
                                Spacing.vertRegular(),
                                AppButton(
                                  label: 'Refresh',
                                  isCollapsed: true,
                                  onPressed: viewModel.getCurrentWeather,
                                ),
                              ],
                            ),
                          );
                        }

                        return Expanded(
                          child: RefreshIndicator(
                            onRefresh: viewModel.getCurrentWeather,
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: viewModel.cities.length,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              separatorBuilder: (_, __) =>
                                  Spacing.vertRegular(),
                              itemBuilder: (context, index) {
                                final city = viewModel.cities[index];
                                return CityItemCard(
                                  city: city,
                                  onTap: viewModel.onCardTap,
                                );
                              },
                            ),
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
