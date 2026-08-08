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
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: isFavorite ? tokens.primary : tokens.fgTertiary,
          size: 22,
        ),
      ),
    );
  }
}
