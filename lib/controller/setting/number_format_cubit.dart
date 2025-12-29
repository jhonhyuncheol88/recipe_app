import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../util/number_format_style.dart';

class NumberFormatCubit extends Cubit<NumberFormatStyle> {
  static const String _prefsKey = 'number_format_style';

  NumberFormatCubit() : super(NumberFormatStyle.defaultStyle) {
    _loadSavedFormat();
  }

  Future<void> _loadSavedFormat() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null) {
      final found = NumberFormatStyle.fromKey(saved);
      if (found != null) {
        emit(found);
      }
    }
  }

  Future<void> setFormatStyle(NumberFormatStyle style) async {
    emit(style);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, style.key);
  }
}

