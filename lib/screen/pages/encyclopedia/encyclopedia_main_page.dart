import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../controller/encyclopedia/encyclopedia_cubit.dart';
import '../../../controller/encyclopedia/encyclopedia_state.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../model/encyclopedia_recipe.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../service/admob_forward.dart';
import '../../../service/gemini_service.dart';

/// 백과사전 메인 페이지
class EncyclopediaMainPage extends StatefulWidget {
  const EncyclopediaMainPage({super.key});

  @override
  State<EncyclopediaMainPage> createState() => _EncyclopediaMainPageState();
}

class _EncyclopediaMainPageState extends State<EncyclopediaMainPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _displayCount = 10; // 처음에 표시할 레시피 개수
  bool _isTranslated = false; // 번역 상태 추적
  Map<String, String> _translatedNames = {}; // 번역된 이름 저장 (원본 이름 → 번역된 이름)
  bool _isTranslating = false; // 번역 진행 중 상태
  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    // 페이지를 열 때마다 랜덤으로 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EncyclopediaCubit>().loadRecipes();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query != _searchQuery) {
      setState(() {
        _searchQuery = query;
        _displayCount = 10; // 검색 시 표시 개수 초기화
        _isTranslated = false; // 검색 시 번역 상태 초기화
        _translatedNames.clear();
      });
      context.read<EncyclopediaCubit>().searchRecipes(query);
    }
  }

  /// 더보기 버튼 클릭 핸들러
  Future<void> _handleLoadMore(AppLocale currentLocale) async {
    // 광고 시청
    final adWatched = await AdMobForwardService.instance.showInterstitialAd();
    
    if (adWatched && mounted) {
      setState(() {
        _displayCount += 10; // 10개 더 표시
      });
      
      // 번역 상태가 활성화되어 있고, 새로 표시된 레시피가 있다면 번역
      if (_isTranslated && _translatedNames.isNotEmpty) {
        _translateDisplayedRecipes(currentLocale);
      }
    }
  }

  /// 번역하기/원본 보기 토글 핸들러
  Future<void> _handleTranslateToggle(AppLocale currentLocale) async {
    if (_isTranslated) {
      // 원본 보기
      setState(() {
        _isTranslated = false;
      });
    } else {
      // 번역하기
      await _translateDisplayedRecipes(currentLocale);
    }
  }

  /// 현재 표시된 레시피들 번역
  Future<void> _translateDisplayedRecipes(AppLocale currentLocale) async {
    if (_isTranslating) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      // 현재 표시된 레시피들 가져오기
      final recipes = context.read<EncyclopediaCubit>().state;
      List<EncyclopediaRecipe> displayedRecipes = [];
      
      if (recipes is EncyclopediaLoaded) {
        displayedRecipes = recipes.recipes.take(_displayCount).toList();
      } else if (recipes is EncyclopediaSearchResult) {
        displayedRecipes = recipes.recipes.take(_displayCount).toList();
      }

      if (displayedRecipes.isEmpty) {
        setState(() {
          _isTranslating = false;
        });
        return;
      }

      // 번역이 필요한 레시피 이름들만 추출 (아직 번역되지 않은 것들)
      final namesToTranslate = <String>[];
      final recipeMap = <String, EncyclopediaRecipe>{};
      
      for (final recipe in displayedRecipes) {
        if (!_translatedNames.containsKey(recipe.menuName)) {
          namesToTranslate.add(recipe.menuName);
          recipeMap[recipe.menuName] = recipe;
        }
      }

      // 번역이 필요한 이름들이 있을 때만 번역 수행
      if (namesToTranslate.isNotEmpty) {
        final translations = await _geminiService.translateRecipeNames(
          namesToTranslate,
          targetLocale: currentLocale,
        );

        if (mounted) {
          setState(() {
            _translatedNames.addAll(translations);
            _isTranslated = true;
            _isTranslating = false;
          });
        }
      } else {
        // 이미 번역된 경우 상태만 업데이트
        if (mounted) {
          setState(() {
            _isTranslated = true;
            _isTranslating = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTranslating = false;
        });
        
        // 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '번역 중 오류가 발생했습니다: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.getEncyclopedia(currentLocale),
          style: AppTextStyles.headline4.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          // 한국어가 아닐 때만 번역 버튼 표시
          if (currentLocale != AppLocale.korea)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: _isTranslating
                    ? null
                    : () => _handleTranslateToggle(currentLocale),
                icon: _isTranslating
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accent,
                        ),
                      )
                    : Icon(
                        _isTranslated ? Icons.visibility : Icons.translate,
                        color: _isTranslating
                            ? AppColors.textSecondary
                            : AppColors.accent,
                      ),
                label: Text(
                  _isTranslating
                      ? AppStrings.getTranslating(currentLocale)
                      : (_isTranslated
                          ? AppStrings.getShowOriginal(currentLocale)
                          : AppStrings.getTranslate(currentLocale)),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _isTranslating
                        ? AppColors.textSecondary
                        : AppColors.accent,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(currentLocale),
          Expanded(
            child: BlocBuilder<EncyclopediaCubit, EncyclopediaState>(
              builder: (context, state) {
                if (state is EncyclopediaLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accent,
                    ),
                  );
                }

                if (state is EncyclopediaError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<EncyclopediaCubit>().loadRecipes();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.buttonText,
                          ),
                          child: Text(AppStrings.getRetry(currentLocale)),
                        ),
                      ],
                    ),
                  );
                }

                if (state is EncyclopediaEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.getNoRecipes(currentLocale),
                          style: AppTextStyles.headline4.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                List<EncyclopediaRecipe> recipes = [];
                if (state is EncyclopediaLoaded) {
                  recipes = state.recipes;
                } else if (state is EncyclopediaSearchResult) {
                  recipes = state.recipes;
                }

                if (recipes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.getNoRecipes(currentLocale),
                          style: AppTextStyles.headline4.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return _buildRecipeList(recipes, currentLocale);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocale currentLocale) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppStrings.getSearchRecipeHint(currentLocale),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.accent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: AppTextStyles.bodyMedium,
      ),
    );
  }

  /// 레시피 리스트 생성
  Widget _buildRecipeList(
    List<EncyclopediaRecipe> recipes,
    AppLocale currentLocale,
  ) {
    // 표시할 레시피 개수 제한
    final displayedRecipes = recipes.take(_displayCount).toList();
    final hasMore = recipes.length > _displayCount;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: displayedRecipes.length,
            itemBuilder: (context, index) {
              return _buildRecipeCard(displayedRecipes[index], currentLocale);
            },
          ),
        ),
        // 더보기 버튼 (더 표시할 레시피가 있을 때만)
        if (hasMore)
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => _handleLoadMore(currentLocale),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.buttonText,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.getLoadMore(currentLocale),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.buttonText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_downward,
                    color: AppColors.buttonText,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecipeCard(EncyclopediaRecipe recipe, AppLocale currentLocale) {
    // 번역된 이름이 있으면 사용, 없으면 원본 이름 사용
    final displayName = _isTranslated &&
            _translatedNames.containsKey(recipe.menuName)
        ? _translatedNames[recipe.menuName]!
        : recipe.menuName;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // 번역 정보를 상세 페이지로 전달 (메인 페이지의 번역 상태 전달)
          final translationData = _isTranslated
              ? {
                  'translatedRecipeName': _translatedNames[recipe.menuName],
                  'isTranslated': true,
                }
              : {
                  'isTranslated': false,
                };

          context.push(
            '/encyclopedia/recipe/${recipe.number}',
            extra: {
              'recipe': recipe,
              'translationData': translationData,
            },
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: AppTextStyles.headline4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${AppStrings.getIngredientsList(currentLocale)}: ${recipe.ingredients.length}개 | ${AppStrings.getSaucesList(currentLocale)}: ${recipe.sauces.length}개',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
