import '../data/sauce_repository.dart';
import '../data/ingredient_repository.dart';

class SauceExpiryService {
  final SauceRepository sauceRepository;
  final IngredientRepository ingredientRepository;

  SauceExpiryService({
    required this.sauceRepository,
    required this.ingredientRepository,
  });

  /// 소스 만료일 = 구성 재료 중 가장 빠른 만료일 (null은 제외)
  Future<DateTime?> getSauceExpiryDate(String sauceId) async {
    final parts = await sauceRepository.getIngredientsForSauce(sauceId);
    if (parts.isEmpty) return null;

    DateTime? earliest;
    for (final p in parts) {
      final ingredient = await ingredientRepository.getIngredientById(
        p.ingredientId,
      );
      final expiry = ingredient?.expiryDate;
      if (expiry == null) continue;
      if (earliest == null || expiry.isBefore(earliest)) {
        earliest = expiry;
      }
    }
    return earliest;
  }
}
