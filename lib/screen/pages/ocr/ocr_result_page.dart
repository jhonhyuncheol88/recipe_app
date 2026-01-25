import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../controller/ocr/ocr_cubit.dart';
import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/number_formatter.dart';
import '../../../util/date_formatter.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../model/ingredient.dart';
import '../../../model/ocr_result.dart';
import '../../../model/tag.dart';
import '../../../model/unit.dart';
import '../../widget/app_button.dart' show AppButton, AppButtonType;
import '../../widget/app_card.dart';
import '../../widget/app_input_field.dart';

class OcrResultPage extends StatefulWidget {
  final List<Ingredient> ingredients;
  final File imageFile;
  final OcrResult? ocrResult;
  final Map<String, dynamic>? structuredData;

  const OcrResultPage({
    super.key,
    required this.ingredients,
    required this.imageFile,
    this.ocrResult,
    this.structuredData,
  });

  @override
  State<OcrResultPage> createState() => _OcrResultPageState();
}

class _OcrResultPageState extends State<OcrResultPage> {
  final List<Map<String, dynamic>> _editableIngredients =
      <Map<String, dynamic>>[];
  final List<TextEditingController> _nameControllers =
      <TextEditingController>[];
  final List<TextEditingController> _priceControllers =
      <TextEditingController>[];
  final List<TextEditingController> _amountControllers =
      <TextEditingController>[];
  List<Tag> _availableTags = <Tag>[];
  List<Unit> _availableUnits = <Unit>[];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    _loadTags();
    _loadUnits();
  }

  void _loadTags() {
    final locale = context.read<LocaleCubit>().state;
    setState(() {
      _availableTags = DefaultTags.ingredientTagsFor(locale);
    });
  }

  void _loadUnits() {
    setState(() {
      _availableUnits = [
        Unit(id: 'g', name: 'g', type: 'weight', conversionFactor: 1.0),
        Unit(id: 'kg', name: 'kg', type: 'weight', conversionFactor: 1000.0),
        Unit(id: 'ml', name: 'ml', type: 'volume', conversionFactor: 1.0),
        Unit(id: 'L', name: 'L', type: 'volume', conversionFactor: 1000.0),
        Unit(id: '개', name: '개', type: 'count', conversionFactor: 1.0),
        Unit(id: '마리', name: '마리', type: 'count', conversionFactor: 1.0),
        Unit(id: '장', name: '장', type: 'count', conversionFactor: 1.0),
        Unit(id: '인분', name: '인분', type: 'count', conversionFactor: 1.0),
      ];
    });
  }

  void _initializeEditableIngredients(
    List<Map<String, dynamic>> geminiIngredients,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentLocale = context.read<LocaleCubit>().state;

        setState(() {
          _editableIngredients.clear();
          _nameControllers.clear();
          _priceControllers.clear();
          _amountControllers.clear();

          for (final ingredient in geminiIngredients) {
            final name = ingredient['name'] as String? ?? '';
            final suggestedPrice =
                ingredient['suggested_price'] as double? ?? 0.0;
            final suggestedAmount =
                ingredient['suggested_amount'] as double? ?? 0.0;
            final suggestedUnit =
                ingredient['suggested_unit'] as String? ?? '개';
            final category = ingredient['category'] as String? ?? '기타';

            _editableIngredients.add({
              'name': name,
              'purchasePrice': suggestedPrice,
              'purchaseAmount': suggestedAmount,
              'purchaseUnitId': suggestedUnit,
              'category': category,
              'expiryDate': null,
              'tagIds': <String>[],
              'originalData': ingredient,
            });

            _nameControllers.add(TextEditingController(text: name));
            _priceControllers.add(
              TextEditingController(
                text: suggestedPrice > 0
                    ? NumberFormatter.formatPrice(suggestedPrice, currentLocale,
                        context.watch<NumberFormatCubit>().state)
                    : '',
              ),
            );
            _amountControllers.add(
              TextEditingController(
                text: suggestedAmount > 0 ? suggestedAmount.toString() : '',
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    for (final controller in _priceControllers) {
      controller.dispose();
    }
    for (final controller in _amountControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateIngredient(int index, String field, dynamic value) {
    setState(() {
      _editableIngredients[index] = {
        ..._editableIngredients[index],
        field: value,
      };
    });
  }

  void _toggleTag(int ingredientIndex, String tagId) {
    setState(() {
      final currentTags = List<String>.from(
        (_editableIngredients[ingredientIndex]['tagIds'] as List<dynamic>?) ??
            <dynamic>[],
      );
      if (currentTags.contains(tagId)) {
        currentTags.remove(tagId);
      } else {
        currentTags.clear();
        currentTags.add(tagId);
      }
      _editableIngredients[ingredientIndex]['tagIds'] = currentTags;
    });
  }

  void _removeIngredient(int index) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text('재료 삭제', style: TextStyle(color: colorScheme.onSurface)),
        content: Text(
          '${index + 1}번째 재료 "${_editableIngredients[index]['name']}"를 삭제하시겠습니까?',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmRemoveIngredient(index);
            },
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveIngredient(int index) {
    setState(() {
      _nameControllers[index].dispose();
      _priceControllers[index].dispose();
      _amountControllers[index].dispose();

      _nameControllers.removeAt(index);
      _priceControllers.removeAt(index);
      _amountControllers.removeAt(index);

      _editableIngredients.removeAt(index);
    });

    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('재료가 삭제되었습니다.'),
        backgroundColor: colorScheme.secondary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool _validateIngredients() {
    for (int i = 0; i < _editableIngredients.length; i++) {
      final ingredient = _editableIngredients[i];
      if (ingredient['name'].toString().trim().isEmpty) {
        _showValidationError('재료명', i);
        return false;
      }
      final price = (ingredient['purchasePrice'] as num?)?.toDouble() ?? 0.0;
      if (price <= 0.0) {
        _showValidationError('구매 가격', i);
        return false;
      }
      final amount = (ingredient['purchaseAmount'] as num?)?.toDouble() ?? 0.0;
      if (amount <= 0.0) {
        _showValidationError('구매 수량', i);
        return false;
      }
      if (ingredient['purchaseUnitId'].toString().isEmpty) {
        _showValidationError('단위', i);
        return false;
      }
    }
    return true;
  }

  void _showValidationError(String fieldName, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${index + 1}번째 재료의 $fieldName을(를) 확인해주세요'),
        backgroundColor: colorScheme.error,
      ),
    );
  }

  Future<void> _saveIngredients() async {
    if (!_validateIngredients()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cubit = context.read<IngredientCubit>();
      int successCount = 0;

      for (final ingredientData in _editableIngredients) {
        try {
          final price = NumberFormatter.parsePrice(
            ingredientData['purchasePrice'].toString(),
            context.read<NumberFormatCubit>().state,
          );
          final amount = NumberFormatter.parseAmount(
            ingredientData['purchaseAmount'].toString(),
          );

          if (price != null && amount != null) {
            await cubit.addIngredient(
              name: ingredientData['name'].toString().trim(),
              purchasePrice: price,
              purchaseAmount: amount,
              purchaseUnitId: ingredientData['purchaseUnitId'].toString(),
              expiryDate: ingredientData['expiryDate'] as DateTime?,
              tagIds: List<String>.from(
                ingredientData['tagIds'] as List<dynamic>,
              ),
            );
            successCount++;
          }
        } catch (e) {
          debugPrint('재료 추가 실패: ${ingredientData['name']} - $e');
        }
      }

      if (mounted) {
        final colorScheme = Theme.of(context).colorScheme;
        if (successCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$successCount개 재료가 성공적으로 추가되었습니다.'),
              backgroundColor: colorScheme.primary,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('재료 저장에 실패했습니다.'),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('재료 저장 중 오류가 발생했습니다: $e'),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _selectExpiryDate(int index) async {
    final now = DateTime.now();
    final colorScheme = Theme.of(context).colorScheme;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: (_editableIngredients[index]['expiryDate'] as DateTime?) ??
          now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      _updateIngredient(index, 'expiryDate', selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppStrings.getParsedIngredients(locale),
          style: AppTextStyles.headline4.copyWith(color: colorScheme.onSurface),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: _buildResultView(context, locale),
    );
  }

  Widget _buildResultView(BuildContext context, AppLocale locale) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImagePreview(context, locale),
          const SizedBox(height: 24),
          _buildGeminiResult(context, locale),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                AppStrings.getReceiptImage(locale),
                style: AppTextStyles.cardTitle.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              widget.imageFile,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeminiResult(BuildContext context, AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<OcrCubit, OcrState>(
      builder: (context, state) {
        if (state is OcrProcessing) {
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.image, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '영수증 이미지 분석 중',
                      style: AppTextStyles.cardTitle.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '영수증 이미지를 분석하고 있습니다...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        if (state is OcrGeminiAnalyzing) {
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology,
                        color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'AI 재료 분석 중',
                      style: AppTextStyles.cardTitle.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI가 재료명을 분석하고 있습니다...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        if (state is OcrGeminiCompleted) {
          final geminiResult = state.geminiResult;
          final ingredients = geminiResult['ingredients'] as List? ?? [];

          if (_editableIngredients.isEmpty && ingredients.isNotEmpty) {
            _initializeEditableIngredients(
              ingredients.map((item) => item as Map<String, dynamic>).toList(),
            );
          }

          return Column(
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI 재료 분석 결과',
                          style: AppTextStyles.cardTitle.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildAnalysisSummary(geminiResult),
                    const SizedBox(height: 16),
                    if (_editableIngredients.isNotEmpty) ...[
                      Text(
                        '추출된 재료 (${_editableIngredients.length}개)',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._editableIngredients.asMap().entries.map(
                            (entry) => _buildEditableIngredientCard(
                                entry.value, entry.key),
                          ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        text: _isLoading ? '저장 중...' : '모든 재료 저장',
                        type: AppButtonType.primary,
                        onPressed:
                            _editableIngredients.isNotEmpty && !_isLoading
                                ? _saveIngredients
                                : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildOcrComparison(context, locale, geminiResult),
                  ],
                ),
              ),
            ],
          );
        }

        if (state is OcrResultGenerated) {
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'OCR 분석 완료',
                      style: AppTextStyles.cardTitle.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI 재료 분석을 시작합니다...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAnalysisSummary(Map<String, dynamic> geminiResult) {
    final colorScheme = Theme.of(context).colorScheme;
    final analysisSummary =
        geminiResult['analysis_summary'] as Map<String, dynamic>? ?? {};
    final highCount = analysisSummary['high_confidence_count'] ?? 0;
    final mediumCount = analysisSummary['medium_confidence_count'] ?? 0;
    final lowCount = analysisSummary['low_confidence_count'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '분석 품질',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildQualityIndicator('높음', highCount, Colors.green),
              const SizedBox(width: 16),
              _buildQualityIndicator('보통', mediumCount, Colors.orange),
              const SizedBox(width: 16),
              _buildQualityIndicator('낮음', lowCount, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityIndicator(String label, int count, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $count',
          style: AppTextStyles.bodySmall.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildOcrComparison(
    BuildContext context,
    AppLocale locale,
    Map<String, dynamic> geminiResult,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalExtracted = geminiResult['total_extracted'] ?? 0;
    final totalConverted = geminiResult['total_converted'] ?? 0;
    final ocrTextLength = geminiResult['ocr_text_length'] ?? 0;
    final processingTimestamp = geminiResult['processing_timestamp'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: colorScheme.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                '분석 통계',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '추출된 재료',
                  '$totalExtracted개',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  '변환된 재료',
                  '$totalConverted개',
                  colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'OCR 텍스트',
                  '${ocrTextLength}자',
                  Colors.orange,
                ),
              ),
            ],
          ),
          if (processingTimestamp.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule,
                    color: colorScheme.onSurface.withOpacity(0.4), size: 14),
                const SizedBox(width: 6),
                Text(
                  '분석 시간: ${_formatTimestamp(processingTimestamp)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: colorScheme.onSurface.withOpacity(0.4),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return '알 수 없음';
    }
  }

  Widget _buildEditableIngredientCard(
    Map<String, dynamic> ingredient,
    int index,
  ) {
    final currentLocale = context.read<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${index + 1}번째 재료',
                  style: AppTextStyles.headline4.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ingredient['category'] ?? '기타',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _removeIngredient(index),
                      icon: const Icon(Icons.delete_outline),
                      color: colorScheme.error,
                      tooltip: '재료 삭제',
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.error.withOpacity(0.1),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEditableIngredientForm(currentLocale, ingredient, index),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableIngredientForm(
    AppLocale currentLocale,
    Map<String, dynamic> ingredient,
    int index,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppInputField(
          controller: _nameControllers[index],
          label: '재료명',
          hint: '재료명을 입력하세요',
          onChanged: (value) => _updateIngredient(index, 'name', value),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppInputField(
                controller: _priceControllers[index],
                label: '구매 가격',
                hint: '가격을 입력하세요',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                  ThousandsSeparatorInputFormatter(),
                ],
                onChanged: (value) {
                  final price = NumberFormatter.parsePrice(value.toString(),
                      context.read<NumberFormatCubit>().state);
                  if (price != null) {
                    _updateIngredient(index, 'purchasePrice', price);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppInputField(
                controller: _amountControllers[index],
                label: '구매 수량',
                hint: '수량을 입력하세요',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                onChanged: (value) {
                  final amount = NumberFormatter.parseAmount(value.toString());
                  if (amount != null) {
                    _updateIngredient(index, 'purchaseAmount', amount);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: (ingredient['purchaseUnitId'] as String).isNotEmpty
              ? ingredient['purchaseUnitId']
              : null,
          dropdownColor: colorScheme.surface,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: '단위',
            labelStyle:
                TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: _availableUnits.map((unit) {
            return DropdownMenuItem(value: unit.id, child: Text(unit.name));
          }).toList(),
          onChanged: (value) {
            _updateIngredient(index, 'purchaseUnitId', value ?? '');
          },
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _selectExpiryDate(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: colorScheme.onSurface.withOpacity(0.4),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ingredient['expiryDate'] != null
                        ? DateFormatter.formatDate(
                            ingredient['expiryDate'],
                            currentLocale,
                          )
                        : '유통기한 선택',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: ingredient['expiryDate'] != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ),
                if (ingredient['expiryDate'] != null)
                  IconButton(
                    onPressed: () {
                      _updateIngredient(index, 'expiryDate', null);
                    },
                    icon: const Icon(Icons.clear, size: 20),
                    color: colorScheme.onSurface.withOpacity(0.4),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '태그 (하나만 선택)',
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = (ingredient['tagIds'] as List).contains(tag.id);
            final tagColor =
                Color(int.parse(tag.color.replaceAll('#', '0xFF')));
            return FilterChip(
              label: Text(tag.name),
              selected: isSelected,
              onSelected: (selected) => _toggleTag(index, tag.id),
              backgroundColor: colorScheme.surface,
              selectedColor: tagColor.withOpacity(0.2),
              checkmarkColor: tagColor,
              labelStyle: AppTextStyles.bodySmall.copyWith(
                color: isSelected
                    ? tagColor
                    : colorScheme.onSurface.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? tagColor : colorScheme.outlineVariant,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
