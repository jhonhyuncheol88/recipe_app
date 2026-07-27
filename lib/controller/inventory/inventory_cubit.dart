import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/index.dart';
import '../../model/index.dart';
import '../../util/inventory_step.dart';

/// AI 미리보기에서 반영할 1건. ingredientId null = 새 재료 생성.
class InventoryAiApplyItem {
  final String? ingredientId;
  final String name;
  final double qty;
  final String unitName;

  const InventoryAiApplyItem({
    this.ingredientId,
    required this.name,
    required this.qty,
    required this.unitName,
  });
}

class InventoryState extends Equatable {
  final bool isLoading;

  /// 선택된 세그먼트. null = 미분류 세그먼트.
  final StorageLocation? selectedLocation;
  final List<Ingredient> ingredients;
  final Map<String, InventoryItem> items; // ingredientId → 잔량
  final Map<String, Unit> unitsById;
  final double todayPurchaseTotal;
  final int todayTxCount;
  final String? error;

  const InventoryState({
    this.isLoading = false,
    this.selectedLocation = StorageLocation.shelf,
    this.ingredients = const [],
    this.items = const {},
    this.unitsById = const {},
    this.todayPurchaseTotal = 0,
    this.todayTxCount = 0,
    this.error,
  });

  /// 현재 세그먼트에 속한 재료 (이름순)
  List<Ingredient> get filteredIngredients {
    final list = ingredients
        .where((i) => i.storageLocation == selectedLocation)
        .toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  /// 미분류 재료 수 (세그먼트 배지용)
  int get unsortedCount =>
      ingredients.where((i) => i.storageLocation == null).length;

  InventoryState copyWith({
    bool? isLoading,
    StorageLocation? Function()? selectedLocation,
    List<Ingredient>? ingredients,
    Map<String, InventoryItem>? items,
    Map<String, Unit>? unitsById,
    double? todayPurchaseTotal,
    int? todayTxCount,
    String? Function()? error,
  }) {
    return InventoryState(
      isLoading: isLoading ?? this.isLoading,
      selectedLocation: selectedLocation != null
          ? selectedLocation()
          : this.selectedLocation,
      ingredients: ingredients ?? this.ingredients,
      items: items ?? this.items,
      unitsById: unitsById ?? this.unitsById,
      todayPurchaseTotal: todayPurchaseTotal ?? this.todayPurchaseTotal,
      todayTxCount: todayTxCount ?? this.todayTxCount,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        selectedLocation,
        ingredients,
        items,
        unitsById,
        todayPurchaseTotal,
        todayTxCount,
        error,
      ];
}

class InventoryCubit extends Cubit<InventoryState> {
  final InventoryRepository _inventoryRepository;
  final IngredientRepository _ingredientRepository;
  final UnitRepository _unitRepository;
  final Uuid _uuid = const Uuid();

  InventoryCubit({
    required InventoryRepository inventoryRepository,
    required IngredientRepository ingredientRepository,
    required UnitRepository unitRepository,
  })  : _inventoryRepository = inventoryRepository,
        _ingredientRepository = ingredientRepository,
        _unitRepository = unitRepository,
        super(const InventoryState());

  /// 전체 로드: 재료 + 잔량 + 단위 + 오늘 요약
  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: () => null));
    try {
      final ingredients = await _ingredientRepository.getAllIngredients();
      final items = await _inventoryRepository.getAllItems();
      final units = await _unitRepository.getAllUnits();
      final summary = await _inventoryRepository.getTodaySummary();

      emit(state.copyWith(
        isLoading: false,
        ingredients: ingredients,
        items: items,
        unitsById: {for (final u in units) u.id: u},
        todayPurchaseTotal: summary.totalPurchase,
        todayTxCount: summary.txCount,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: () => e.toString()));
    }
  }

  void selectLocation(StorageLocation? location) {
    emit(state.copyWith(selectedLocation: () => location));
  }

  /// 재료의 구매 단위 기준 스텝 (단위 미조회 시 1)
  double stepFor(String ingredientId) {
    final ingredient =
        state.ingredients.where((i) => i.id == ingredientId).firstOrNull;
    if (ingredient == null) return 1;
    final unit = state.unitsById[ingredient.purchaseUnitId];
    if (unit == null) return 1;
    return inventoryStepForUnit(unit.name);
  }

  Future<void> increment(String ingredientId) => _change(
      ingredientId, stepFor(ingredientId), InventoryTxType.adjust);

  Future<void> decrement(String ingredientId) => _change(
      ingredientId, -stepFor(ingredientId), InventoryTxType.consume);

  Future<void> _change(
      String ingredientId, double delta, InventoryTxType type) async {
    try {
      final item = await _inventoryRepository.changeQuantity(
        ingredientId: ingredientId,
        delta: delta,
        type: type,
      );
      await _refreshAfterChange(ingredientId, item);
    } catch (e) {
      emit(state.copyWith(error: () => e.toString()));
    }
  }

  /// 직접 입력으로 잔량 설정 (adjust)
  Future<void> setQuantity(String ingredientId, double qty) async {
    try {
      final item = await _inventoryRepository.setQuantity(
        ingredientId: ingredientId,
        newQty: qty,
        type: InventoryTxType.adjust,
      );
      await _refreshAfterChange(ingredientId, item);
    } catch (e) {
      emit(state.copyWith(error: () => e.toString()));
    }
  }

  /// 구매 기록: 잔량 증가 + 금액 기록
  Future<void> recordPurchase({
    required String ingredientId,
    required double qty,
    required double price,
  }) async {
    try {
      final item = await _inventoryRepository.recordPurchase(
        ingredientId: ingredientId,
        qty: qty,
        price: price,
      );
      await _refreshAfterChange(ingredientId, item);
    } catch (e) {
      emit(state.copyWith(error: () => e.toString()));
    }
  }

  /// 미분류 재료의 보관 위치 지정 + 재고 행 lazy 생성 (잔량 0 유지)
  Future<void> classifyIngredient(
      String ingredientId, StorageLocation location) async {
    try {
      final ingredient =
          state.ingredients.where((i) => i.id == ingredientId).firstOrNull;
      if (ingredient == null) return;

      final updated = ingredient.copyWith(storageLocation: location);
      await _ingredientRepository.updateIngredient(updated);

      // 재고 행 없으면 잔량 0 으로 생성 (트랜잭션 delta 0)
      if (!state.items.containsKey(ingredientId)) {
        await _inventoryRepository.setQuantity(
          ingredientId: ingredientId,
          newQty: 0,
          type: InventoryTxType.adjust,
        );
      }
      await load();
    } catch (e) {
      emit(state.copyWith(error: () => e.toString()));
    }
  }

  /// AI 미리보기에서 체크된 항목 일괄 반영.
  /// - 기존 재료: 잔량을 추측값으로 설정 (ai_adjust)
  /// - 새 재료: 재료 마스터 생성 (구매가 0, 위치 shelf) 후 잔량 설정
  Future<void> applyAiAdjustments(List<InventoryAiApplyItem> items) async {
    try {
      for (final item in items) {
        String ingredientId;
        if (item.ingredientId != null) {
          ingredientId = item.ingredientId!;
        } else {
          // 단위 이름 매칭 (대소문자 무시), 실패 시 첫 단위
          final units = await _unitRepository.getAllUnits();
          final matched = units
              .where((u) =>
                  u.name.toLowerCase() == item.unitName.toLowerCase())
              .firstOrNull;
          final unitId =
              matched?.id ?? (units.isNotEmpty ? units.first.id : '');

          final newIngredient = Ingredient(
            id: _uuid.v4(),
            name: item.name,
            purchasePrice: 0,
            purchaseAmount: item.qty > 0 ? item.qty : 1,
            purchaseUnitId: unitId,
            createdAt: DateTime.now(),
            tagIds: const [],
            storageLocation: StorageLocation.shelf,
          );
          await _ingredientRepository.insertIngredient(newIngredient);
          ingredientId = newIngredient.id;
        }

        await _inventoryRepository.setQuantity(
          ingredientId: ingredientId,
          newQty: item.qty,
          type: InventoryTxType.aiAdjust,
        );
      }
      await load();
    } catch (e) {
      // 부분 실패 시에도 DB 에 이미 쓰인 반영분을 상태에 노출.
      // load() 는 error 를 클리어하므로 반드시 load 이후에 error emit.
      await load();
      emit(state.copyWith(error: () => e.toString()));
    }
  }

  Future<void> _refreshAfterChange(
      String ingredientId, InventoryItem item) async {
    final summary = await _inventoryRepository.getTodaySummary();
    emit(state.copyWith(
      items: {...state.items, ingredientId: item},
      todayPurchaseTotal: summary.totalPurchase,
      todayTxCount: summary.txCount,
      error: () => null, // 변경 성공 시 이전 에러 클리어
    ));
  }
}
