import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:uuid/uuid.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../util/app_strings.dart';
import '../../util/app_locale.dart';
import '../../model/recipe_price_history.dart';
import '../../data/recipe_price_history_repository.dart';

class RecipePriceChartBottomSheet extends StatefulWidget {
  final String recipeId;
  final String recipeName;
  final double currentPrice;
  final AppLocale locale;

  const RecipePriceChartBottomSheet({
    super.key,
    required this.recipeId,
    required this.recipeName,
    required this.currentPrice,
    required this.locale,
  });

  @override
  State<RecipePriceChartBottomSheet> createState() =>
      _RecipePriceChartBottomSheetState();
}

class _RecipePriceChartBottomSheetState
    extends State<RecipePriceChartBottomSheet> {
  final RecipePriceHistoryRepository _repository =
      RecipePriceHistoryRepository();
  final Uuid _uuid = const Uuid();
  String _selectedPeriod = 'daily'; // daily, monthly, yearly
  List<RecipePriceHistory> _allHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPriceHistory();
  }

  Future<void> _loadPriceHistory() async {
    setState(() => _isLoading = true);
    try {
      final history = await _repository.getPriceHistoryByRecipeId(
        widget.recipeId,
      );
      print('가격 히스토리 로드: recipeId=${widget.recipeId}, count=${history.length}');

      // 데이터가 없으면 현재 가격을 히스토리에 추가
      if (history.isEmpty && widget.currentPrice > 0) {
        print('가격 히스토리가 없음 - 현재 가격 추가: ${widget.currentPrice}');
        final initialHistory = RecipePriceHistory(
          id: _uuid.v4(),
          recipeId: widget.recipeId,
          price: widget.currentPrice,
          recordedAt: DateTime.now(),
        );
        await _repository.insertPriceHistory(initialHistory);

        // 다시 로드
        final updatedHistory = await _repository.getPriceHistoryByRecipeId(
          widget.recipeId,
        );
        setState(() {
          _allHistory = updatedHistory;
          _isLoading = false;
        });
      } else {
        setState(() {
          _allHistory = history;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('가격 히스토리 로드 실패: $e');
      print('스택 트레이스: $stackTrace');
      setState(() => _isLoading = false);
    }
  }

  List<FlSpot> _getChartData() {
    if (_allHistory.isEmpty) return [];

    final processedData = _processData();
    return processedData
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();
  }

  List<double> _processData() {
    if (_allHistory.isEmpty) return [];

    switch (_selectedPeriod) {
      case 'daily':
        return _processDaily();
      case 'monthly':
        return _processMonthly();
      case 'yearly':
        return _processYearly();
      default:
        return _processDaily();
    }
  }

  List<double> _processDaily() {
    // 일별: 날짜별로 그룹화하여 최신 가격 표시
    final Map<String, double> dailyPrices = {};
    for (final history in _allHistory) {
      final dateKey =
          '${history.recordedAt.year}-${history.recordedAt.month.toString().padLeft(2, '0')}-${history.recordedAt.day.toString().padLeft(2, '0')}';
      // 같은 날짜의 최신 가격만 유지 (시간순으로 정렬되어 있으므로 마지막 값)
      dailyPrices[dateKey] = history.price;
    }
    // 날짜순으로 정렬
    final sortedKeys = dailyPrices.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    return sortedKeys.map((key) => dailyPrices[key]!).toList();
  }

  List<double> _processMonthly() {
    // 월별: 월별 평균 가격
    final Map<String, List<double>> monthlyPrices = {};
    for (final history in _allHistory) {
      final monthKey =
          '${history.recordedAt.year}-${history.recordedAt.month.toString().padLeft(2, '0')}';
      monthlyPrices.putIfAbsent(monthKey, () => []).add(history.price);
    }
    // 월순으로 정렬
    final sortedKeys = monthlyPrices.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    return sortedKeys
        .map((key) =>
            monthlyPrices[key]!.reduce((a, b) => a + b) /
            monthlyPrices[key]!.length) // 평균
        .toList();
  }

  List<double> _processYearly() {
    // 연도별: 연도별 평균 가격
    final Map<int, List<double>> yearlyPrices = {};
    for (final history in _allHistory) {
      final year = history.recordedAt.year;
      yearlyPrices.putIfAbsent(year, () => []).add(history.price);
    }
    // 연도순으로 정렬
    final sortedKeys = yearlyPrices.keys.toList()..sort();
    return sortedKeys
        .map((year) =>
            yearlyPrices[year]!.reduce((a, b) => a + b) /
            yearlyPrices[year]!.length) // 평균
        .toList();
  }

  List<String> _getXAxisLabels() {
    if (_allHistory.isEmpty) return [];

    switch (_selectedPeriod) {
      case 'daily':
        {
          final Map<String, String> dailyLabels = {};
          for (final history in _allHistory) {
            final dateKey =
                '${history.recordedAt.year}-${history.recordedAt.month.toString().padLeft(2, '0')}-${history.recordedAt.day.toString().padLeft(2, '0')}';
            dailyLabels[dateKey] =
                '${history.recordedAt.month}/${history.recordedAt.day}';
          }
          final sortedKeys = dailyLabels.keys.toList()
            ..sort((a, b) => a.compareTo(b));
          return sortedKeys.map((key) => dailyLabels[key]!).toList();
        }
      case 'monthly':
        {
          final Map<String, String> monthlyLabels = {};
          for (final history in _allHistory) {
            final monthKey =
                '${history.recordedAt.year}-${history.recordedAt.month.toString().padLeft(2, '0')}';
            monthlyLabels[monthKey] =
                '${history.recordedAt.year}/${history.recordedAt.month}';
          }
          final sortedKeys = monthlyLabels.keys.toList()
            ..sort((a, b) => a.compareTo(b));
          return sortedKeys.map((key) => monthlyLabels[key]!).toList();
        }
      case 'yearly':
        {
          final Map<int, String> yearlyLabels = {};
          for (final history in _allHistory) {
            yearlyLabels[history.recordedAt.year] =
                history.recordedAt.year.toString();
          }
          final sortedKeys = yearlyLabels.keys.toList()..sort();
          return sortedKeys.map((year) => yearlyLabels[year]!).toList();
        }
      default:
        return [];
    }
  }

  double _getMaxPrice() {
    if (_allHistory.isEmpty) return 1000;
    final maxPrice =
        _allHistory.map((h) => h.price).reduce((a, b) => a > b ? a : b);
    return maxPrice * 1.1; // 여유 공간을 위해 10% 추가
  }

  double _getMinPrice() {
    if (_allHistory.isEmpty) return 0;
    final minPrice =
        _allHistory.map((h) => h.price).reduce((a, b) => a < b ? a : b);
    return minPrice > 0 ? minPrice * 0.9 : 0; // 여유 공간
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipeName,
                        style: AppTextStyles.headline3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.getPriceChart(widget.locale),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 필터 탭
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildPeriodButton('daily', AppStrings.getDaily(widget.locale)),
                const SizedBox(width: 8),
                _buildPeriodButton(
                    'monthly', AppStrings.getMonthly(widget.locale)),
                const SizedBox(width: 8),
                _buildPeriodButton(
                    'yearly', AppStrings.getYearly(widget.locale)),
              ],
            ),
          ),
          // 차트
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _allHistory.isEmpty
                    ? Center(
                        child: Text(
                          AppStrings.getNoPriceData(widget.locale),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: AppColors.divider,
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, meta) {
                                    final labels = _getXAxisLabels();
                                    if (value.toInt() >= 0 &&
                                        value.toInt() < labels.length) {
                                      return Text(
                                        labels[value.toInt()],
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: AppColors.divider,
                              ),
                            ),
                            minX: 0,
                            maxX: (_getChartData().length > 0
                                ? (_getChartData().length - 1).toDouble()
                                : 0),
                            minY: _getMinPrice(),
                            maxY: _getMaxPrice(),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _getChartData(),
                                isCurved: true,
                                color: AppColors.primary,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 5,
                                      color: AppColors.primary,
                                      strokeWidth: 3,
                                      strokeColor: Colors.grey[800]!,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color:
                                      AppColors.primaryLight.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _selectedPeriod = period);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color:
                    isSelected ? AppColors.buttonText : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}




