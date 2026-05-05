import 'package:flutter/material.dart';
import '../../theme/tokens/tokens.dart';

/// 공용 세그먼트 컨트롤 — generic over value type T.
///
/// 사용 예:
/// ```dart
/// SegmentControl<_Tab>(
///   items: [
///     SegmentItem(value: _Tab.recipe, label: '레시피 3'),
///     SegmentItem(value: _Tab.sauce,  label: '소스 2'),
///   ],
///   selected: _currentTab,
///   onChanged: (t) => setState(() => _currentTab = t),
/// )
/// ```
class SegmentControl<T> extends StatelessWidget {
  final List<SegmentItem<T>> items;
  final T selected;
  final ValueChanged<T> onChanged;

  const SegmentControl({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tokens.bgMuted,
        borderRadius: AppRadius.brR12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: items.map((item) {
          return Expanded(
            child: _SegmentItemWidget<T>(
              item: item,
              selected: item.value == selected,
              onTap: () => onChanged(item.value),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// 세그먼트 한 항목 데이터 클래스.
class SegmentItem<T> {
  final T value;
  final String label;

  const SegmentItem({required this.value, required this.label});
}

class _SegmentItemWidget<T> extends StatelessWidget {
  final SegmentItem<T> item;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentItemWidget({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Material(
      color: selected ? tokens.bgBase : Colors.transparent,
      borderRadius: AppRadius.brR8,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brR8,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
          child: Center(
            child: Text(
              item.label,
              style: AppTypography.label1.copyWith(
                color: selected ? tokens.fgStrong : tokens.fgTertiary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
