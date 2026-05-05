import 'package:flutter/material.dart';

import '../../theme/tokens/tokens.dart';
import '../../util/app_locale.dart';
import '../../util/app_strings.dart';

/// 재료 태그 ID → 이름/색 매핑.
///
/// 앱 전역에서 fresh/frozen/indoor 세 종류만 사용한다.
class IngredientTagPalette {
  IngredientTagPalette._();

  static const String fresh = 'fresh';
  static const String frozen = 'frozen';
  static const String indoor = 'indoor';

  static String? firstKnownTagId(List<String> tagIds) {
    for (final id in tagIds) {
      if (id == fresh || id == frozen || id == indoor) return id;
    }
    return null;
  }

  static String label(String? tagId, AppLocale locale) {
    switch (tagId) {
      case fresh:
        return AppStrings.getIngredientTagFresh(locale);
      case frozen:
        return AppStrings.getIngredientTagFrozen(locale);
      case indoor:
        return AppStrings.getIngredientTagIndoor(locale);
      default:
        return '';
    }
  }

  static ({Color bg, Color fg}) colors(String? tagId, AppColorTokens tokens) {
    switch (tagId) {
      case fresh:
        return (bg: tokens.positiveSoft, fg: tokens.positive);
      case frozen:
        return (bg: tokens.infoSoft, fg: tokens.info);
      case indoor:
        return (bg: tokens.warningSoft, fg: tokens.warning);
      default:
        return (bg: tokens.bgMuted, fg: tokens.fgTertiary);
    }
  }
}

/// 카드 좌측에 배치되는 작은 분류 라벨 박스.
class IngredientCategoryLabel extends StatelessWidget {
  final String? tagId;
  final AppLocale locale;
  final double size;

  const IngredientCategoryLabel({
    super.key,
    required this.tagId,
    required this.locale,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final palette = IngredientTagPalette.colors(tagId, tokens);
    final text = IngredientTagPalette.label(tagId, locale);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: AppRadius.brR12,
      ),
      alignment: Alignment.center,
      child: Text(
        text.isEmpty ? '-' : text,
        style: AppTypography.label2.copyWith(
          color: palette.fg,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// 필터/분류 선택용 알약 모양 칩 (이미지 1·2 의 분류 칩 스타일).
///
/// 선택 시 진한 배경 + 흰 글씨, 비선택 시 옅은 회색 배경 + 회색 글씨.
class IngredientSelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const IngredientSelectableChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final bg = selected ? tokens.fgStrong : tokens.bgMuted;
    final fg = selected ? tokens.fgOnPrimary : tokens.fgSecondary;

    return Material(
      color: bg,
      borderRadius: AppRadius.brPill,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brPill,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
          child: Text(
            label,
            style: AppTypography.label1.copyWith(
              color: fg,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// D-day 뱃지 (유통기한 임박 표시).
///
/// `daysLeft` 가 음수면 만료(빨강), 0~3 위험(주황 강조), 4~7 경고(주황),
/// 그 외엔 표시 안 함.
class IngredientDDayBadge extends StatelessWidget {
  final int daysLeft;
  const IngredientDDayBadge({super.key, required this.daysLeft});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final isExpired = daysLeft < 0;
    final isUrgent = !isExpired && daysLeft <= 7;
    final Color bg;
    final Color fg;
    if (isExpired) {
      bg = tokens.negativeSoft;
      fg = tokens.negative;
    } else if (isUrgent) {
      bg = tokens.warningSoft;
      fg = tokens.warning;
    } else {
      bg = tokens.bgMuted;
      fg = tokens.fgTertiary;
    }
    final text = isExpired ? 'D+${-daysLeft}' : 'D-$daysLeft';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.brR8,
      ),
      child: Text(
        text,
        style: AppTypography.label2.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
