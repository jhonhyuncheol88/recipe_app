import '../app_locale.dart';

/// Sauce 관련 문자열
mixin AppStringsSauce {
  /// 소스(Sauce) 관련
  static String getSauceManagement(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스 관리';
      case AppLocale.vietnam:
        return 'Quản lý nước sốt';
      default:
        return 'Sauce Management';
    }
  }

  static String getNoSauces(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '등록된 소스가 없습니다';
      case AppLocale.vietnam:
        return 'Không tìm thấy nước sốt';
      default:
        return 'No sauces found';
    }
  }

  static String getEnterSauceName(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스 이름 입력';
      case AppLocale.vietnam:
        return 'Nhập tên nước sốt';
      default:
        return 'Enter sauce name';
    }
  }

  static String getSauceNameExample(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '예: 데미글라스 소스';
      case AppLocale.vietnam:
        return 'e.g., Demi-glace sauce';
      default:
        return 'e.g., Demi-glace sauce';
    }
  }

  static String getCreate(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '생성';
      case AppLocale.vietnam:
        return 'Tạo';
      default:
        return 'Create';
    }
  }

  static String getSauceComposition(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '구성 재료';
      case AppLocale.vietnam:
        return 'Thành phần';
      default:
        return 'Composition';
    }
  }

  static String getAddIngredientToSauce(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스에 재료 추가';
      case AppLocale.vietnam:
        return 'Thêm nguyên liệu vào nước sốt';
      default:
        return 'Add ingredient to sauce';
    }
  }

  static String getNoSauceIngredients(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '구성 재료가 없습니다.';
      case AppLocale.vietnam:
        return 'Không có nguyên liệu thành phần.';
      default:
        return 'No composition ingredients.';
    }
  }

  static String getTotalWeight(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '총중량';
      case AppLocale.vietnam:
        return 'Tổng trọng lượng';
      default:
        return 'Total Weight';
    }
  }

  static String getAdd(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '추가';
      case AppLocale.vietnam:
        return 'Thêm';
      default:
        return 'Add';
    }
  }

  static String getSauces(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스';
      case AppLocale.vietnam:
        return 'Nước sốt';
      default:
        return 'Sauces';
    }
  }
}
