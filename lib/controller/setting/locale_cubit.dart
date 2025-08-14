import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../util/app_locale.dart';

class LocaleCubit extends Cubit<AppLocale> {
  static const String _prefsKey = 'app_locale_code'; // e.g., "ko_KR"

  LocaleCubit() : super(AppLocale.defaultLocale) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null) {
      final found = AppLocale.fromLocaleCode(saved);
      if (found != null) {
        emit(found);
      }
    }
  }

  Future<void> setLocale(AppLocale locale) async {
    emit(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.localeString);
  }
}
