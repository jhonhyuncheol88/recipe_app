import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../controller/sauce/sauce_cubit.dart';
import '../../../controller/sauce/sauce_state.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/number_formatter.dart';
import '../../../service/sauce_cost_service.dart';
import '../../../util/unit_converter.dart' as uc;
import '../../../controller/setting/locale_cubit.dart';

class SauceMainPage extends StatefulWidget {
  const SauceMainPage({super.key});

  @override
  State<SauceMainPage> createState() => _SauceMainPageState();
}

class _SauceMainPageState extends State<SauceMainPage> {
  @override
  void initState() {
    super.initState();
    context.read<SauceCubit>().loadSauces();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.getSauceManagement(currentLocale)),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: BlocBuilder<SauceCubit, SauceState>(
        builder: (context, state) {
          if (state is SauceLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SauceEmpty) {
            return Center(
              child: Text(
                AppStrings.getNoSauces(currentLocale),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }
          if (state is SauceError) {
            return Center(child: Text(state.message));
          }
          if (state is SauceLoaded) {
            final sauces = state.sauces;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sauces.length,
              itemBuilder: (context, index) {
                final sauce = sauces[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(sauce.name, style: AppTextStyles.bodyMedium),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppStrings.getTotalWeight(currentLocale)}: ${NumberFormatter.formatNumber(sauce.totalWeight.toInt(), currentLocale)} | ${AppStrings.getTotalCost(currentLocale)}: ${NumberFormatter.formatCurrency(sauce.totalCost, currentLocale)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FutureBuilder<SauceAggregation>(
                          future: context
                              .read<SauceCostService>()
                              .aggregateSauce(sauce.id),
                          builder: (context, snapshot) {
                            final agg = snapshot.data;
                            if (agg == null || agg.totalBaseAmount <= 0) {
                              return const SizedBox.shrink();
                            }
                            final unitCost =
                                agg.totalCost / agg.totalBaseAmount;
                            final unitId = agg.unitType == uc.UnitType.weight
                                ? 'g'
                                : agg.unitType == uc.UnitType.volume
                                ? 'ml'
                                : '개';
                            return Text(
                              '단위당 가격: ${NumberFormatter.formatPerUnitText(unitCost, unitId, currentLocale)}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/sauce/edit', extra: sauce),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // _createSauce는 현재 FAB에서 사용하지 않으므로 제거되었습니다.
}
