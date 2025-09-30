import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_router.dart';
import '../model/recipe.dart';
import '../model/ingredient.dart';
import '../model/ocr_result.dart';

/// 라우터 헬퍼 클래스
class RouterHelper {
  /// 홈으로 이동
  static void goHome(BuildContext context) {
    context.go(AppRouter.home);
  }

  /// 재료 페이지로 이동
  static void goToIngredients(BuildContext context) {
    context.go(AppRouter.ingredients);
  }

  /// 레시피 페이지로 이동
  static void goToRecipes(BuildContext context) {
    context.go(AppRouter.recipes);
  }

  /// 설정 페이지로 이동
  static void goToSettings(BuildContext context) {
    context.go(AppRouter.settings);
  }

  /// 로그인 페이지로 이동
  static void goToLogin(BuildContext context) {
    context.go(AppRouter.login);
  }

  /// 계정 정보 페이지로 이동
  static void goToAccountInfo(BuildContext context) {
    context.go(AppRouter.accountInfo);
  }

  /// AI 페이지로 이동 (탭바 페이지)
  static void goToAi(BuildContext context) {
    context.go(AppRouter.ai);
  }

  /// AI 레시피 관리 페이지로 이동
  static void goToAiRecipeManagement(BuildContext context) {
    context.go(AppRouter.aiRecipeManagement);
  }

  /// AI 판매 분석 페이지로 이동
  static void goToAiSalesAnalysis(BuildContext context, Recipe recipe) {
    context.push(AppRouter.aiSalesAnalysis, extra: recipe);
  }

  /// 재료 추가 페이지로 이동
  static void goToIngredientAdd(BuildContext context) {
    context.push(AppRouter.ingredientAdd);
  }

  /// 재료 추가 페이지로 이동 (재료 이름 미리 입력)
  static void goToIngredientAddWithName(
    BuildContext context,
    String ingredientName,
  ) {
    context.push(
      AppRouter.ingredientAdd,
      extra: {'preFilledIngredientName': ingredientName},
    );
  }

  /// 재료 대량등록 페이지로 이동
  static void goToIngredientBulkAdd(BuildContext context) {
    context.push(AppRouter.ingredientBulkAdd);
  }

  /// 재료 대량등록 페이지로 이동 (데이터와 함께)
  static void goToIngredientBulkAddWithData(
    BuildContext context,
    List<Map<String, dynamic>> ingredients,
  ) {
    context.push(
      AppRouter.ingredientBulkAdd,
      extra: {
        'prefilledIngredients': ingredients,
        'source': 'ai_recipe_missing_ingredients',
      },
    );
  }

  /// 재료 수정 페이지로 이동
  static void goToIngredientEdit(
    BuildContext context,
    Map<String, dynamic> ingredient,
  ) {
    context.push(AppRouter.ingredientEdit, extra: {'ingredient': ingredient});
  }

  /// 재료 상세 페이지로 이동
  static void goToIngredientDetail(
    BuildContext context,
    Map<String, dynamic> ingredient,
  ) {
    context.push(AppRouter.ingredientDetail, extra: {'ingredient': ingredient});
  }

  /// 레시피 생성 페이지로 이동
  static void goToRecipeCreate(
    BuildContext context, {
    List<Map<String, dynamic>> selectedIngredients = const [],
    bool animateFromIngredients = false,
  }) {
    context.push(
      AppRouter.recipeCreate,
      extra: {
        'selectedIngredients': selectedIngredients,
        'animateFromIngredients': animateFromIngredients,
      },
    );
  }

  /// 레시피 수정 페이지로 이동
  static void goToRecipeEdit(
    BuildContext context,
    Map<String, dynamic> recipe,
  ) {
    context.push(AppRouter.recipeEdit, extra: {'recipe': recipe});
  }

  /// 레시피 상세 페이지로 이동
  static void goToRecipeDetail(
    BuildContext context,
    Map<String, dynamic> recipe,
  ) {
    context.push(AppRouter.recipeDetail, extra: {'recipe': recipe});
  }

  /// 영수증 스캔 페이지로 이동
  static void goToScanReceipt(BuildContext context) {
    context.push(AppRouter.scanReceipt);
  }

  /// OCR 메인 페이지로 이동
  static void goToOcrMain(BuildContext context) {
    context.push(AppRouter.ocr);
  }

  /// OCR 결과 페이지로 이동
  static void goToOcrResult(
    BuildContext context, {
    required List<Ingredient> ingredients,
    required String imagePath,
    OcrResult? ocrResult,
  }) {
    context.push(
      AppRouter.ocrResult,
      extra: {
        'ingredients': ingredients,
        'imagePath': imagePath,
        'ocrResult': ocrResult,
      },
    );
  }

  /// 위젯 예시 페이지로 이동
  static void goToWidgetExamples(BuildContext context) {
    context.push(AppRouter.widgetExamples);
  }

  /// 뒤로 가기
  static void goBack(BuildContext context) {
    context.pop();
  }

  /// 이전 페이지로 이동 (홈이 아닌 경우)
  static void goBackOrHome(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRouter.home);
    }
  }

  /// 현재 경로 확인
  static bool isCurrentPath(BuildContext context, String path) {
    return GoRouterState.of(context).uri.path == path;
  }

  /// 현재 경로 가져오기
  static String getCurrentPath(BuildContext context) {
    return GoRouterState.of(context).uri.path;
  }

  /// 라우터 상태 가져오기
  static GoRouterState getRouterState(BuildContext context) {
    return GoRouterState.of(context);
  }

  /// 라우터 파라미터 가져오기
  static Map<String, String> getPathParameters(BuildContext context) {
    return GoRouterState.of(context).pathParameters;
  }

  /// 라우터 쿼리 파라미터 가져오기 (URI에서 직접 파싱)
  static Map<String, String> getQueryParameters(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    return uri.queryParameters;
  }

  /// 라우터 extra 데이터 가져오기
  static Map<String, dynamic>? getExtraData(BuildContext context) {
    return GoRouterState.of(context).extra as Map<String, dynamic>?;
  }

  /// 온보딩 완료 후 홈으로 이동
  static void completeOnboarding(BuildContext context) {
    context.go(AppRouter.home);
  }

  /// 온보딩 페이지로 이동
  static void goToOnboarding(BuildContext context) {
    context.push(AppRouter.onboarding);
  }
}
