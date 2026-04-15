import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum IngredientViewMode { card, compact }

class ViewModeCubit extends Cubit<IngredientViewMode> {
  static const String _prefsKey = 'ingredient_view_mode';

  ViewModeCubit() : super(IngredientViewMode.card) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_prefsKey);
    if (value == 'compact') {
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
