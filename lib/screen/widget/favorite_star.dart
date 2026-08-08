import 'package:flutter/material.dart';

import '../../theme/tokens/tokens.dart';

/// 즐겨찾기 별 아이콘 — 재료/레시피/소스 카드 공용.
///
/// 카드 본문 탭(상세/편집 이동)과 분리된 별도 탭 영역으로 사용한다.
class FavoriteStar extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const FavoriteStar({super.key, required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final bgColor = isFavorite ? tokens.primarySoft : tokens.bgMuted;
    final borderColor = isFavorite ? tokens.primary : tokens.borderSubtle;
    final iconColor = isFavorite ? tokens.primary : tokens.fgTertiary;

    // 별을 감싸는 사각 탭 구역. 자체 Material 로 잉크를 그려 카드 배경과 분리되고,
    // 카드 본문 탭과는 별개로 이 영역만 탭하면 즐겨찾기가 토글된다.
    return Material(
      color: bgColor,
      borderRadius: AppRadius.brR10,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brR10,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: AppRadius.brR10,
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Icon(
            isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
            color: iconColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}
