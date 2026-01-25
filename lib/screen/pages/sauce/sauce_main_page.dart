import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../controller/sauce/sauce_cubit.dart';
import '../../../controller/sauce/sauce_state.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/number_formatter.dart';
import '../../../service/sauce_cost_service.dart';
import '../../../util/unit_converter.dart' as uc;
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../router/router_helper.dart';
import '../../../model/index.dart';
import '../../widget/index.dart';

class SauceMainPage extends StatefulWidget {
  const SauceMainPage({super.key});

  @override
  State<SauceMainPage> createState() => _SauceMainPageState();
}

class _SauceMainPageState extends State<SauceMainPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<SauceCubit>().loadSauces();
  }

  Widget _buildSearchSection() {
    final currentLocale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: AppStrings.getSearchIngredientHint(currentLocale),
          hintStyle:
              TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
          prefixIcon: Icon(Icons.search,
              color: colorScheme.onSurface.withValues(alpha: 0.5)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: colorScheme.onSurface.withValues(alpha: 0.5)),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: colorScheme.surface,
        ),
      ),
    );
  }

  Widget _buildSauceCard(Sauce sauce) {
    final currentLocale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      onTap: () => context.push('/sauce/edit', extra: sauce),
      isClickable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sauce.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                NumberFormatter.formatCurrency(
                  sauce.totalCost,
                  currentLocale,
                  context.watch<NumberFormatCubit>().state,
                ),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                '${NumberFormatter.formatNumber(sauce.totalWeight.toInt(), context.watch<NumberFormatCubit>().state)}g',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
          FutureBuilder<SauceAggregation>(
            future: context.read<SauceCostService>().aggregateSauce(sauce.id),
            builder: (context, snapshot) {
              final agg = snapshot.data;
              if (agg == null || agg.totalBaseAmount <= 0) {
                return const SizedBox.shrink();
              }
              final unitCost = agg.totalCost / agg.totalBaseAmount;
              final unitId = agg.unitType == uc.UnitType.weight
                  ? 'g'
                  : agg.unitType == uc.UnitType.volume
                      ? 'ml'
                      : '개';
              return Column(
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '${NumberFormatter.formatCurrency(unitCost, currentLocale, context.watch<NumberFormatCubit>().state)}/$unitId',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddSauceDialog() {
    final currentLocale = context.read<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(AppStrings.getEnterSauceName(currentLocale),
            style: TextStyle(color: colorScheme.onSurface)),
        content: AppInputField(
          label: AppStrings.getEnterSauceName(currentLocale),
          hint: AppStrings.getSauceNameExample(currentLocale),
          controller: nameController,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.getCancel(currentLocale)),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                context.read<SauceCubit>().addSauce(name: name);
                Navigator.of(context).pop();
              }
            },
            child: Text(AppStrings.getCreate(currentLocale)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    return BlocListener<SauceCubit, SauceState>(
      listener: (context, state) {
        if (state is SauceAdded) {
          RouterHelper.goToSauceIngredientSelect(context, state.sauce.id);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            AppStrings.getSauceManagement(currentLocale),
            style:
                AppTextStyles.headline4.copyWith(color: colorScheme.onSurface),
          ),
          backgroundColor: colorScheme.surface,
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'sauce_add_button',
          onPressed: _showAddSauceDialog,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          icon: const Icon(Icons.add),
          label: Text(AppStrings.getAddSauceButton(currentLocale)),
        ),
        body: Column(
          children: [
            _buildSearchSection(),
            Expanded(
              child: BlocBuilder<SauceCubit, SauceState>(
                builder: (context, state) {
                  if (state is SauceLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is SauceEmpty) {
                    return Center(
                      child: Text(
                        AppStrings.getNoSauces(currentLocale),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  }
                  if (state is SauceError) {
                    return Center(
                        child: Text(state.message,
                            style: TextStyle(color: colorScheme.error)));
                  }
                  if (state is SauceLoaded || state is SauceDeleted) {
                    final allSauces = state is SauceLoaded
                        ? state.sauces
                        : (state as SauceDeleted).sauces;

                    final filteredSauces = _searchQuery.isEmpty
                        ? allSauces
                        : allSauces
                            .where(
                              (sauce) => sauce.name
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()),
                            )
                            .toList();

                    if (filteredSauces.isEmpty) {
                      if (_searchQuery.isNotEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '검색 결과가 없습니다',
                                style: AppTextStyles.headline4.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '다른 검색어를 입력해보세요',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Center(
                          child: Text(
                            AppStrings.getNoSauces(currentLocale),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        );
                      }
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredSauces.length,
                      itemBuilder: (context, index) {
                        final sauce = filteredSauces[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildSauceCard(sauce),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
