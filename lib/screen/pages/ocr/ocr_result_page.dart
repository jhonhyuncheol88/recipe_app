import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../controller/ocr/ocr_cubit.dart';
import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../theme/app_colors.dart';
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
import '../../../service/ocr_gemini_service.dart'; // Added import for OcrGeminiService

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
  bool _showPreview = false;

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
    // setState를 build 중에 호출하지 않도록 addPostFrameCallback 사용
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
              'originalData': ingredient, // 원본 Gemini 데이터 보존
            });

            // 컨트롤러 생성
            _nameControllers.add(TextEditingController(text: name));
            _priceControllers.add(
              TextEditingController(
                text: suggestedPrice > 0
                    ? NumberFormatter.formatPrice(suggestedPrice, currentLocale)
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

  // 기존의 _formatPriceForLocale 메서드 제거 (NumberFormatter 사용)

  @override
  void dispose() {
    // 모든 컨트롤러 정리
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

  void _updateIngredient(int index, Object field, Object? value) {
    setState(() {
      _editableIngredients[index] = {
        ..._editableIngredients[index],
        field.toString(): value,
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

  // 재료 삭제
  void _removeIngredient(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('재료 삭제'),
        content: Text(
          '${index + 1}번째 재료 "${_editableIngredients[index]['name']}"를 삭제하시겠습니까?',
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
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  // 재료 삭제 확인
  void _confirmRemoveIngredient(int index) {
    setState(() {
      // 컨트롤러 정리
      _nameControllers[index].dispose();
      _priceControllers[index].dispose();
      _amountControllers[index].dispose();

      // 컨트롤러 목록에서 제거
      _nameControllers.removeAt(index);
      _priceControllers.removeAt(index);
      _amountControllers.removeAt(index);

      // 편집 가능한 재료 목록에서 제거
      _editableIngredients.removeAt(index);
    });

    // 삭제 완료 메시지
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('재료가 삭제되었습니다.'),
        backgroundColor: AppColors.success,
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
    final currentLocale = context.read<LocaleCubit>().state;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${index + 1}번째 재료의 $fieldName을(를) 확인해주세요'),
        backgroundColor: AppColors.error,
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
          print('재료 추가 실패: ${ingredientData['name']} - $e');
        }
      }

      if (mounted) {
        if (successCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$successCount개 재료가 성공적으로 추가되었습니다.'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(); // OCR 결과 페이지 닫기
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('재료 저장에 실패했습니다.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('재료 저장 중 오류가 발생했습니다: $e'),
            backgroundColor: AppColors.error,
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
    final selectedDate = await showDatePicker(
      context: context,
      initialDate:
          (_editableIngredients[index]['expiryDate'] as DateTime?) ??
          now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.buttonText,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      _updateIngredient(index, 'expiryDate', selectedDate);
    }
  }

  // 포맷팅된 가격 파싱
  double? _parseFormattedPrice(String value) {
    final numbers = value.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(numbers);
  }

  // 포맷팅된 수량 파싱
  double? _parseFormattedAmount(String value) {
    final numbers = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(numbers);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.getParsedIngredients(locale),
          style: AppTextStyles.headline4.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          // 저장 버튼 제거 (파싱하지 않으므로 저장할 재료가 없음)
        ],
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
          // 이미지 미리보기
          _buildImagePreview(context, locale),

          const SizedBox(height: 24),

          // Gemini 분석 결과 (자동 표시)
          _buildGeminiResult(context, locale),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, AppLocale locale) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                AppStrings.getReceiptImage(locale),
                style: AppTextStyles.cardTitle.copyWith(
                  color: AppColors.textPrimary,
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

  // 더 이상 필요하지 않은 재료 관련 메서드들 제거
  // _buildIngredientsList, _buildIngredientCard, _buildSaveButton,
  // _updateIngredientName, _updateIngredientPrice, _updateIngredientAmount,
  // _updateIngredientUnit, _removeIngredient, _saveIngredients 등 제거

  // Gemini 분석 결과
  Widget _buildGeminiResult(BuildContext context, AppLocale locale) {
    return BlocBuilder<OcrCubit, OcrState>(
      builder: (context, state) {
        // OCR 처리 중일 때 로딩 표시
        if (state is OcrProcessing) {
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.image, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '영수증 이미지 분석 중',
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColors.textPrimary,
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
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '영수증 이미지를 분석하고 있습니다...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        // Gemini 분석 중일 때 로딩 표시
        if (state is OcrGeminiAnalyzing) {
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'AI 재료 분석 중',
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColors.textPrimary,
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
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI가 재료명을 분석하고 있습니다...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        // Gemini 분석 완료일 때 결과 표시
        if (state is OcrGeminiCompleted) {
          final geminiResult = state.geminiResult;
          final ingredients = geminiResult['ingredients'] as List? ?? [];

          // 디버깅: Gemini 결과 확인
          print('🔍 Gemini 분석 결과: ${ingredients.length}개 재료 추출');
          for (int i = 0; i < ingredients.length; i++) {
            final ingredient = ingredients[i];
            print(
              '📦 재료 ${i + 1}: ${ingredient['name']} (카테고리: ${ingredient['category']}, 신뢰도: ${(ingredient['confidence'] * 100).toInt()}%)',
            );
          }

          // 편집 가능한 재료 목록이 비어있을 때만 초기화
          if (_editableIngredients.isEmpty && ingredients.isNotEmpty) {
            _initializeEditableIngredients(
              ingredients.map((item) => item as Map<String, dynamic>).toList(),
            );
          }

          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI 재료 분석 결과',
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 분석 요약
                _buildAnalysisSummary(geminiResult),

                const SizedBox(height: 16),

                // 편집 가능한 재료 목록
                if (_editableIngredients.isNotEmpty) ...[
                  Text(
                    '추출된 재료 (${_editableIngredients.length}개)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._editableIngredients.asMap().entries.map(
                    (entry) =>
                        _buildEditableIngredientCard(entry.value, entry.key),
                  ),
                ],

                const SizedBox(height: 16),

                // 저장 버튼
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: _isLoading ? '저장 중...' : '모든 재료 저장',
                    type: AppButtonType.primary,
                    onPressed: _editableIngredients.isNotEmpty && !_isLoading
                        ? _saveIngredients
                        : null,
                  ),
                ),

                const SizedBox(height: 16),

                // 원본 OCR 텍스트와 비교
                _buildOcrComparison(context, locale, geminiResult),
              ],
            ),
          );
        }

        // OCR 결과 생성 완료되었지만 Gemini 분석이 아직 시작되지 않은 경우
        if (state is OcrResultGenerated) {
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'OCR 분석 완료',
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColors.textPrimary,
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
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI 재료 분석을 시작합니다...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        // 다른 상태일 때
        return const SizedBox.shrink();
      },
    );
  }

  // 분석 요약
  Widget _buildAnalysisSummary(Map<String, dynamic> geminiResult) {
    final analysisSummary =
        geminiResult['analysis_summary'] as Map<String, dynamic>? ?? {};
    final highCount = analysisSummary['high_confidence_count'] ?? 0;
    final mediumCount = analysisSummary['medium_confidence_count'] ?? 0;
    final lowCount = analysisSummary['low_confidence_count'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '분석 품질',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildQualityIndicator('높음', highCount, AppColors.success),
              const SizedBox(width: 16),
              _buildQualityIndicator('보통', mediumCount, AppColors.warning),
              const SizedBox(width: 16),
              _buildQualityIndicator('낮음', lowCount, AppColors.error),
            ],
          ),
        ],
      ),
    );
  }

  // 품질 지표
  Widget _buildQualityIndicator(String label, int count, Color color) {
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
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // 재료 항목
  Widget _buildIngredientItem(Map<String, dynamic> ingredient) {
    final name = ingredient['name'] as String? ?? '';
    final category = ingredient['category'] as String? ?? '기타';
    final confidence = ingredient['confidence'] as double? ?? 0.0;
    final quality = ingredient['extraction_quality'] as String? ?? 'unknown';
    final brand = ingredient['brand'] as String?;
    final packageInfo = ingredient['package_info'] as String?;
    final additionalInfo = ingredient['additional_info'] as String?;
    final suggestedAmount = ingredient['suggested_amount'] as double? ?? 0.0;
    final suggestedUnit = ingredient['suggested_unit'] as String? ?? 'g';
    final originalOcrText = ingredient['original_ocr_text'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 재료명과 품질 아이콘
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              _buildQualityIcon(quality),
            ],
          ),

          const SizedBox(height: 8),

          // 카테고리와 신뢰도
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '신뢰도: ${(confidence * 100).toInt()}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          // 상세 정보
          if (brand != null ||
              packageInfo != null ||
              additionalInfo != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.divider.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (brand != null && brand.isNotEmpty) ...[
                    _buildInfoRow('브랜드/품질', brand, Icons.branding_watermark),
                    const SizedBox(height: 8),
                  ],
                  if (packageInfo != null && packageInfo.isNotEmpty) ...[
                    _buildInfoRow('패키지 정보', packageInfo, Icons.inventory_2),
                    const SizedBox(height: 8),
                  ],
                  if (additionalInfo != null && additionalInfo.isNotEmpty) ...[
                    _buildInfoRow('추가 정보', additionalInfo, Icons.info_outline),
                    const SizedBox(height: 8),
                  ],
                  if (suggestedAmount > 0) ...[
                    _buildInfoRow(
                      '추천 수량',
                      '$suggestedAmount $suggestedUnit',
                      Icons.scale,
                    ),
                  ],
                ],
              ),
            ),
          ],

          // 원본 OCR 텍스트
          if (originalOcrText.isNotEmpty && originalOcrText != name) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.divider.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.source, color: AppColors.textSecondary, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '원본: $originalOcrText',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 정보 행
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  // 품질 아이콘
  Widget _buildQualityIcon(String quality) {
    IconData iconData;
    Color color;

    switch (quality) {
      case 'excellent':
        iconData = Icons.star;
        color = AppColors.success;
        break;
      case 'good':
        iconData = Icons.star_half;
        color = AppColors.warning;
        break;
      case 'fair':
        iconData = Icons.star_border;
        color = AppColors.error;
        break;
      default:
        iconData = Icons.help_outline;
        color = AppColors.textSecondary;
    }

    return Icon(iconData, color: color, size: 20);
  }

  // OCR 비교 섹션
  Widget _buildOcrComparison(
    BuildContext context,
    AppLocale locale,
    Map<String, dynamic> geminiResult,
  ) {
    final totalExtracted = geminiResult['total_extracted'] ?? 0;
    final totalConverted = geminiResult['total_converted'] ?? 0;
    final ocrTextLength = geminiResult['ocr_text_length'] ?? 0;
    final processingTimestamp = geminiResult['processing_timestamp'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                '분석 통계',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
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
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  '변환된 재료',
                  '$totalConverted개',
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'OCR 텍스트',
                  '${ocrTextLength}자',
                  AppColors.warning,
                ),
              ),
            ],
          ),
          if (processingTimestamp.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 6),
                Text(
                  '분석 시간: ${_formatTimestamp(processingTimestamp)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 통계 항목
  Widget _buildStatItem(String label, String value, Color color) {
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
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // 타임스탬프 포맷
  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return '알 수 없음';
    }
  }

  // 편집 가능한 재료 카드
  Widget _buildEditableIngredientCard(
    Map<String, dynamic> ingredient,
    int index,
  ) {
    final currentLocale = context.read<LocaleCubit>().state;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    color: AppColors.textPrimary,
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
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ingredient['category'] ?? '기타',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 삭제 버튼
                    IconButton(
                      onPressed: () => _removeIngredient(index),
                      icon: const Icon(Icons.delete_outline),
                      color: AppColors.error,
                      tooltip: '재료 삭제',
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.error.withOpacity(0.1),
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

  // 편집 가능한 재료 입력 폼
  Widget _buildEditableIngredientForm(
    AppLocale currentLocale,
    Map<String, dynamic> ingredient,
    int index,
  ) {
    return Column(
      children: [
        // 재료명
        AppInputField(
          controller: _nameControllers[index],
          label: '재료명',
          hint: '재료명을 입력하세요',
          onChanged: (value) => _updateIngredient(index, 'name', value),
        ),
        const SizedBox(height: 16),

        // 가격과 수량을 한 줄에
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
                  final price = NumberFormatter.parsePrice(value.toString());
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
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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

        // 단위 선택
        DropdownButtonFormField<String>(
          value: ingredient['purchaseUnitId'].isNotEmpty
              ? ingredient['purchaseUnitId']
              : null,
          decoration: InputDecoration(
            labelText: '단위',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

        // 유통기한
        InkWell(
          onTap: () => _selectExpiryDate(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.textSecondary,
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
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (ingredient['expiryDate'] != null)
                  IconButton(
                    onPressed: () {
                      _updateIngredient(index, 'expiryDate', null);
                    },
                    icon: const Icon(Icons.clear, size: 20),
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 태그 선택
        Text(
          '태그 (하나만 선택)',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = ingredient['tagIds'].contains(tag.id);
            return FilterChip(
              label: Text(tag.name),
              selected: isSelected,
              onSelected: (selected) => _toggleTag(index, tag.id),
              backgroundColor: AppColors.surface,
              selectedColor: Color(
                int.parse(tag.color.replaceAll('#', '0xFF')),
              ),
              labelStyle: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
