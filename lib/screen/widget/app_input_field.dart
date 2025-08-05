import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../util/app_locale.dart';
import '../../util/date_formatter.dart';
import '../../util/number_formatter.dart';

/// 앱에서 사용하는 공통 입력 필드 위젯
class AppInputField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final FocusNode? focusNode;

  const AppInputField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: enabled ? AppColors.textPrimary : AppColors.textLight,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          inputFormatters: inputFormatters,
          autofocus: autofocus,
          focusNode: focusNode,
          style: AppTextStyles.bodyMedium.copyWith(
            color: enabled ? AppColors.textPrimary : AppColors.textLight,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled ? AppColors.surface : AppColors.dividerLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

/// 숫자 입력 필드 위젯 (천 단위 구분자 포함)
class NumberInputField extends StatelessWidget {
  final String label;
  final String? hint;
  final double? initialValue;
  final TextEditingController? controller;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(double)? onChanged;
  final bool allowDecimal;

  const NumberInputField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.allowDecimal = true,
  });

  @override
  Widget build(BuildContext context) {
    // controller가 있으면 그대로 사용, 없으면 포맷팅된 초기값으로 새로 생성
    final effectiveController =
        controller ??
        TextEditingController(
          text: initialValue != null ? _formatNumber(initialValue!) : '',
        );

    // controller가 있고 초기값이 있으면 포맷팅
    if (controller != null && controller!.text.isNotEmpty) {
      final number = double.tryParse(controller!.text);
      if (number != null) {
        controller!.text = _formatNumber(number);
      }
    }

    return AppInputField(
      label: label,
      hint: hint,
      controller: effectiveController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      enabled: enabled,
      validator: validator,
      onChanged: (value) {
        if (onChanged != null && value != null && value.isNotEmpty) {
          // 포맷팅된 값에서 숫자만 추출
          final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
          final number = double.tryParse(cleanValue);
          if (number != null) {
            onChanged!(number);
          }
        }
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d,]')),
        _NumberInputFormatter(),
      ],
      prefixIcon: const Icon(Icons.scale, color: AppColors.textSecondary),
    );
  }

  // 숫자 포맷팅 (천 단위 구분자, 정수만)
  String _formatNumber(double number) {
    return NumberFormat('#,##0', 'en_US').format(number);
  }
}

/// 날짜 입력 필드 위젯 (포맷팅 지원)
class DateInputField extends StatelessWidget {
  final String label;
  final DateTime? initialValue;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(DateTime)? onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final AppLocale locale;

  const DateInputField({
    super.key,
    required this.label,
    this.initialValue,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.locale = AppLocale.korea,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(
      text: initialValue != null
          ? DateFormatter.formatDate(initialValue!, locale)
          : '',
    );

    return AppInputField(
      label: label,
      hint: locale == AppLocale.korea ? 'YYYY년 MM월 DD일' : 'YYYY-MM-DD',
      controller: controller,
      enabled: enabled,
      readOnly: true,
      validator: validator,
      prefixIcon: const Icon(
        Icons.calendar_today,
        color: AppColors.textSecondary,
      ),
      suffixIcon: enabled
          ? IconButton(
              onPressed: () => _selectDate(context, controller),
              icon: const Icon(
                Icons.date_range,
                color: AppColors.textSecondary,
              ),
            )
          : null,
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialValue ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: AppColors.buttonText,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = DateFormatter.formatDate(picked, locale);
      onChanged?.call(picked);
    }
  }
}

/// 숫자 입력 포맷터
class _NumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 숫자만 추출
    final numbers = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (numbers.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final number = double.tryParse(numbers);
    if (number == null) {
      return oldValue;
    }

    // 포맷팅된 값 생성 (천 단위 구분자, 정수만)
    final formatted = NumberFormat('#,##0', 'en_US').format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// 통화 입력 필드 위젯 (포맷팅 지원)
class CurrencyInputField extends StatelessWidget {
  final String label;
  final String? hint;
  final double? initialValue;
  final TextEditingController? controller;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(double)? onChanged;
  final AppLocale locale;

  const CurrencyInputField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.locale = AppLocale.korea,
  });

  @override
  Widget build(BuildContext context) {
    // controller가 있으면 그대로 사용, 없으면 포맷팅된 값으로 새로 생성
    final effectiveController =
        controller ??
        TextEditingController(
          text: initialValue != null
              ? NumberFormatter.formatCurrency(initialValue!, locale)
              : '',
        );

    // controller가 있고 초기값이 있으면 포맷팅
    if (controller != null && controller!.text.isNotEmpty) {
      final numbers = controller!.text.replaceAll(RegExp(r'[^\d]'), '');
      final number = double.tryParse(numbers);
      if (number != null) {
        controller!.text = NumberFormatter.formatCurrency(number, locale);
      }
    }

    return AppInputField(
      label: label,
      hint: hint,
      controller: effectiveController,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      enabled: enabled,
      validator: validator,
      onChanged: (value) {
        if (onChanged != null && value != null && value.isNotEmpty) {
          // 포맷팅된 값에서 숫자만 추출
          final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
          final number = double.tryParse(cleanValue);
          if (number != null) {
            onChanged!(number);
          }
        }
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d,]')),
        _CurrencyInputFormatter(locale),
      ],
      prefixIcon: Icon(Icons.attach_money, color: AppColors.textSecondary),
    );
  }
}

/// 통화 입력 포맷터
class _CurrencyInputFormatter extends TextInputFormatter {
  final AppLocale locale;

  _CurrencyInputFormatter(this.locale);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 숫자만 추출
    final numbers = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (numbers.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final number = double.tryParse(numbers);
    if (number == null) {
      return oldValue;
    }

    // 포맷팅된 값 생성
    final formatted = NumberFormatter.formatCurrency(number, locale);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// 검색 입력 필드 위젯
class SearchInputField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;

  const SearchInputField({
    super.key,
    this.hint = '검색...',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AppInputField(
      label: '',
      hint: hint,
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
      suffixIcon: controller?.text.isNotEmpty == true
          ? IconButton(
              onPressed: () {
                controller?.clear();
                onClear?.call();
              },
              icon: const Icon(Icons.clear, color: AppColors.textSecondary),
            )
          : null,
    );
  }
}
