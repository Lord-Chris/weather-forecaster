import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../../core/app/_app.dart';
import '../../../../core/shared/constants/_constants.dart';
import '../../../../core/shared/widgets/_widgets.dart';
import 'add_city_viewmodel.dart';

class AddCityView extends StatelessWidget {
  const AddCityView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => locator<AddCityViewModel>(),
      builder: (context, viewModel, _) {
        final scheme = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Add city', style: AppTextStyles.semiBold18),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                AppTextField(
                  hint: 'Search for a city',
                  onChanged: viewModel.onQueryChanged,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  prefix: const Icon(Icons.search),
                ),
                Spacing.vertRegular(),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (viewModel.isBusy && viewModel.results.isEmpty) {
                        return const AppLoader(color: AppColors.biddaPry800);
                      }
                      if (viewModel.errorMessage != null) {
                        return Center(
                          child: Text(
                            viewModel.errorMessage!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.regular14,
                          ),
                        );
                      }
                      if (viewModel.hasNoResults) {
                        return const Center(
                          child: Text(
                            'No matching cities',
                            style: AppTextStyles.regular14,
                          ),
                        );
                      }
                      if (viewModel.results.isEmpty) {
                        return Center(
                          child: Text(
                            'Type at least 2 letters to search',
                            style: AppTextStyles.regular14.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: viewModel.results.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final location = viewModel.results[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.location_on_outlined),
                            title: Text(
                              location.displayName,
                              style: AppTextStyles.medium16,
                            ),
                            subtitle: Text(
                              '${location.lat.toStringAsFixed(2)}, ${location.lon.toStringAsFixed(2)}',
                              style: AppTextStyles.regular12,
                            ),
                            trailing: const Icon(Icons.add_circle_outline),
                            onTap: () => viewModel.onResultTap(location),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
