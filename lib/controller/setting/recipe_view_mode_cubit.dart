import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view_mode_cubit.dart';

class RecipeViewModeCubit extends Cubit<IngredientViewMode> {
  static const String _prefsKey = 'recipe_view_mode';

  RecipeViewModeCubit() : super(IngredientViewMode.card) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_prefsKey) == 'compact') {
      emit(IngredientViewMode.compact);
    }
  }

  Future<void> toggle() async {
    final next = state == IngredientViewMode.card
        ? IngredientViewMode.compact
        : IngredientViewMode.card;
    emit(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, next.name);
  }
}
