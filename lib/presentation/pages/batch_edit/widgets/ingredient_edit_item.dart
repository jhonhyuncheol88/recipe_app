import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/ingredient.dart';
import '../../../../../model/tag.dart';
import '../../../../../model/unit.dart';
import '../../../../../util/app_strings.dart';
import '../../../../../util/app_locale.dart';
import '../../../../../util/date_formatter.dart';
import '../../../../../controller/setting/locale_cubit.dart';
import '../../../../../screen/widget/app_input_field.dart';
import '../../../../../theme/app_text_styles.dart';

class IngredientEditItem extends StatefulWidget {
  final Ingredient ingredient;
  final Ingredient? editedIngredient;
  final bool isMarkedForDeletion;
  final Function(
    String? name,
    double? price,
    double? amount,
    String? unitId,
    DateTime? expiryDate,
    List<String>? tagIds,
  ) onChanged;
  final VoidCallback onToggleDelete;

  const IngredientEditItem({
    Key? key,
    required this.ingredient,
    this.editedIngredient,
    required this.isMarkedForDeletion,
    required this.onChanged,
    required this.onToggleDelete,
  }) : super(key: key);

  @override
  State<IngredientEditItem> createState() => _IngredientEditItemState();
}

class _IngredientEditItemState extends State<IngredientEditItem> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    final displayIngredient = widget.editedIngredient ?? widget.ingredient;
    _nameController = TextEditingController(text: displayIngredient.name);
    _priceController = TextEditingController(
      text: displayIngredient.purchasePrice.toString(),
    );
    _amountController = TextEditingController(
      text: displayIngredient.purchaseAmount.toString(),
    );
  }

  @override
  void didUpdateWidget(IngredientEditItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final displayIngredient = widget.editedIngredient ?? widget.ingredient;
    if (oldWidget.editedIngredient != widget.editedIngredient) {
      _nameController.text = displayIngredient.name;
      _priceController.text = displayIngredient.purchasePrice.toString();
      _amountController.text = displayIngredient.purchaseAmount.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayIngredient = widget.editedIngredient ?? widget.ingredient;
    final currentLocale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    final availableTags = DefaultTags.ingredientTagsFor(currentLocale);
    final availableUnits = [
      Unit(id: 'g', name: 'g', type: 'weight', conversionFactor: 1.0),
      Unit(id: 'kg', name: 'kg', type: 'weight', conversionFactor: 1000.0),
      Unit(id: 'ml', name: 'ml', type: 'volume', conversionFactor: 1.0),
      Unit(id: 'L', name: 'L', type: 'volume', conversionFactor: 1000.0),
      Unit(id: '개', name: '개', type: 'count', conversionFactor: 1.0),
      Unit(id: '마리', name: '마리', type: 'count', conversionFactor: 1.0),
      Unit(id: '장', name: '장', type: 'count', conversionFactor: 1.0),
      Unit(id: '인분', name: '인분', type: 'count', conversionFactor: 1.0),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayIngredient.name.isNotEmpty
                      ? displayIngredient.name
                      : '재료',
                  style: AppTextStyles.headline4.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: widget.onToggleDelete,
                  icon: Icon(
                    widget.isMarkedForDeletion
                        ? Icons.undo
                        : Icons.remove_circle_outline,
                  ),
                  color: widget.isMarkedForDeletion
                      ? colorScheme.primary
                      : colorScheme.error,
                  tooltip: widget.isMarkedForDeletion
                      ? '복원'
                      : AppStrings.getRemoveIngredient(currentLocale),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildIngredientForm(currentLocale, displayIngredient, availableTags, availableUnits, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientForm(
    AppLocale currentLocale,
    Ingredient displayIngredient,
    List<Tag> availableTags,
    List<Unit> availableUnits,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        // 재료명
        AppInputField(
          controller: _nameController,
          label: AppStrings.getIngredientName(currentLocale),
          hint: AppStrings.getEnterIngredientNameHint(currentLocale),
          onChanged: (value) => widget.onChanged(value, null, null, null, null, null),
        ),
        const SizedBox(height: 20),

        // 가격
        CurrencyInputField(
          controller: _priceController,
          label: AppStrings.getPurchasePrice(currentLocale),
          hint: AppStrings.getEnterPriceHint(currentLocale),
          locale: currentLocale,
          onChanged: (value) {
            widget.onChanged(null, value, null, null, null, null);
          },
        ),
        const SizedBox(height: 20),

        // 단위와 수량을 한 줄에
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.getUnit(currentLocale),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: displayIngredient.purchaseUnitId.isNotEmpty
                            ? displayIngredient.purchaseUnitId
                            : null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: availableUnits.map((unit) {
                          return DropdownMenuItem(
                            value: unit.id,
                            child: Text(unit.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            widget.onChanged(null, null, null, value, null, null);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: NumberInputField(
                    controller: _amountController,
                    label: AppStrings.getPurchaseAmount(currentLocale),
                    hint: AppStrings.getEnterAmountHint(currentLocale),
                    locale: currentLocale,
                    onChanged: (value) {
                      widget.onChanged(null, null, value, null, null, null);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 유통기한
        Builder(
          builder: (context) {
            final colorScheme = Theme.of(context).colorScheme;
            return InkWell(
              onTap: () => _selectExpiryDate(context, currentLocale),
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
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        displayIngredient.expiryDate != null
                            ? DateFormatter.formatDate(
                                displayIngredient.expiryDate!,
                                currentLocale,
                              )
                            : AppStrings.getSelectExpiryDate(currentLocale),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: displayIngredient.expiryDate != null
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    if (displayIngredient.expiryDate != null)
                      IconButton(
                        onPressed: () {
                          // 유통기한을 명시적으로 null로 설정
                          widget.onChanged(null, null, null, null, null, null);
                        },
                        icon: const Icon(Icons.clear, size: 20),
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),

        // 태그 선택
        Builder(
          builder: (context) {
            final colorScheme = Theme.of(context).colorScheme;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.getTags(currentLocale)} (하나만 선택)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableTags.map((tag) {
                    final isSelected = displayIngredient.tagIds.contains(tag.id);
                    return FilterChip(
                      label: Text(tag.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          // 하나만 선택 가능
                          widget.onChanged(null, null, null, null, null, [tag.id]);
                        } else {
                          widget.onChanged(null, null, null, null, null, []);
                        }
                      },
                      backgroundColor: colorScheme.surface,
                      selectedColor: Color(
                        int.parse(tag.color.replaceAll('#', '0xFF')),
                      ),
                      labelStyle: AppTextStyles.bodySmall.copyWith(
                        color: isSelected
                            ? Colors.white
                            : colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _selectExpiryDate(BuildContext context, AppLocale locale) async {
    final displayIngredient = widget.editedIngredient ?? widget.ingredient;
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: displayIngredient.expiryDate ??
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
      widget.onChanged(null, null, null, null, selectedDate, null);
    }
  }
}
