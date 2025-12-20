import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final AppLocale locale;

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
    this.locale = AppLocale.korea,
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
        if (onChanged != null && value.isNotEmpty) {
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
        _NumberInputFormatter(locale),
      ],
      prefixIcon: const Icon(Icons.scale, color: AppColors.textSecondary),
    );
  }

  // 숫자 포맷팅 (천 단위 구분자, 정수만)
  String _formatNumber(double number) {
    final asInt = number.round();
    return NumberFormatter.formatNumber(asInt, locale);
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
  final AppLocale locale;

  _NumberInputFormatter(this.locale);

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
    final formatted = NumberFormatter.formatNumber(number.round(), locale);

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
    // controller가 있으면 그대로 사용, 없으면 빈 문자열로 생성
    final effectiveController =
        controller ??
        TextEditingController(
          text: initialValue != null
              ? initialValue!.toStringAsFixed(2)
              : '',
        );

    return AppInputField(
      label: label,
      hint: hint,
      controller: effectiveController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      enabled: enabled,
      validator: validator,
      onChanged: (value) {
        if (onChanged != null && value.isNotEmpty) {
          // 원시 문자열에서 숫자와 소수점만 추출하여 파싱
          final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
          final number = double.tryParse(cleanValue);
          if (number != null) {
            onChanged!(number);
          }
        }
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
        _CurrencyInputFormatter(locale),
      ],
      prefixIcon: Icon(Icons.attach_money, color: AppColors.textSecondary),
    );
  }
}

/// 통화 입력 포맷터 (소수점 2자리 제한, 천 단위 구분자 포함)
class _CurrencyInputFormatter extends TextInputFormatter {
  final AppLocale locale;

  _CurrencyInputFormatter(this.locale);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 숫자와 소수점만 추출 (콤마 제거)
    // 소수점이 입력된 경우를 명시적으로 확인
    String text = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');
    
    // 소수점이 새로 입력된 경우를 감지
    bool isDotInput = newValue.text.contains('.') && !oldValue.text.contains('.');

    if (text.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // 여러 개의 소수점 방지
    final dotCount = '.'.allMatches(text).length;
    if (dotCount > 1) {
      return oldValue;
    }

    // 소수점이 있는 경우 소수점 2자리까지만 허용
    String integerPart = '';
    String decimalPart = '';
    bool hasDecimalPoint = text.contains('.');
    
    if (hasDecimalPoint) {
      final parts = text.split('.');
      integerPart = parts[0];
      if (parts.length == 2) {
        // 소수점 2자리 초과 시 잘라내기
        decimalPart = parts[1].length > 2 
            ? parts[1].substring(0, 2) 
            : parts[1];
      }
      text = '$integerPart.$decimalPart';
    } else {
      integerPart = text;
    }

    // 숫자로 파싱 가능한지 확인 (소수점만 있는 경우도 허용)
    // 소수점만 있거나 끝에 소수점이 있는 경우는 허용
    if (text != '.' && text != '' && !text.endsWith('.')) {
      final number = double.tryParse(text);
      if (number == null) {
        // 숫자가 아닌 경우 이전 값 유지
        return oldValue;
      }
    }

    // 천 단위 구분자 추가
    String formattedText;
    if (hasDecimalPoint) {
      // 소수점이 있는 경우: 정수 부분에만 천 단위 구분자 추가
      if (integerPart.isEmpty) {
        formattedText = '.$decimalPart';
      } else {
        final integerNumber = int.tryParse(integerPart);
        if (integerNumber != null) {
          formattedText = '${NumberFormatter.formatNumber(integerNumber, locale)}.$decimalPart';
        } else {
          formattedText = text;
        }
      }
    } else {
      // 소수점이 없는 경우: 전체에 천 단위 구분자 추가
      if (integerPart.isEmpty) {
        formattedText = '';
      } else {
        final integerNumber = int.tryParse(integerPart);
        if (integerNumber != null) {
          formattedText = NumberFormatter.formatNumber(integerNumber, locale);
        } else {
          formattedText = text;
        }
      }
    }

    // 커서 위치 계산
    int cursorPosition;
    
    // 소수점이 입력된 경우: 소수점 뒤로 커서 이동
    if (isDotInput || (hasDecimalPoint && !oldValue.text.contains('.'))) {
      // 소수점이 새로 입력된 경우: 소수점 바로 뒤로 커서 이동
      int dotIndex = formattedText.indexOf('.');
      cursorPosition = dotIndex != -1 ? dotIndex + 1 : formattedText.length;
    } else if (hasDecimalPoint) {
      // 이미 소수점이 있는 경우: 소수점 뒤의 숫자 개수 기준으로 계산
      String beforeCursor = newValue.text.substring(0, newValue.selection.baseOffset.clamp(0, newValue.text.length));
      int digitsBeforeCursor = beforeCursor.replaceAll(RegExp(r'[^\d.]'), '').length;
      
      // 소수점 위치 찾기
      int dotIndex = formattedText.indexOf('.');
      if (dotIndex != -1) {
        // 소수점 앞의 숫자 개수
        int integerDigits = formattedText.substring(0, dotIndex).replaceAll(RegExp(r'[^\d]'), '').length;
        
        if (digitsBeforeCursor <= integerDigits) {
          // 정수 부분에 커서가 있는 경우: 천 단위 구분자 고려하여 계산
          cursorPosition = _findPositionInFormattedInteger(
            formattedText.substring(0, dotIndex),
            digitsBeforeCursor,
          );
        } else {
          // 소수 부분에 커서가 있는 경우
          int decimalDigits = digitsBeforeCursor - integerDigits - 1; // -1은 소수점
          cursorPosition = dotIndex + 1 + decimalDigits.clamp(0, 2);
        }
      } else {
        cursorPosition = formattedText.length;
      }
    } else {
      // 소수점이 없는 경우: 천 단위 구분자 추가 시 커서를 맨 뒤로
      cursorPosition = formattedText.length;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition.clamp(0, formattedText.length)),
    );
  }

  /// 포맷팅된 정수 부분에서 숫자 개수 기준 위치 찾기
  int _findPositionInFormattedInteger(String formattedInteger, int digitCount) {
    int count = 0;
    for (int i = 0; i < formattedInteger.length; i++) {
      if (RegExp(r'\d').hasMatch(formattedInteger[i])) {
        count++;
        if (count >= digitCount) {
          return i + 1;
        }
      }
    }
    return formattedInteger.length;
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
