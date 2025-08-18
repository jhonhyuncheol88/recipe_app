import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/recipe/recipe_cubit.dart';
import 'ai_main_page.dart';
import 'ai_recipe_page.dart';

/// AI 탭바 페이지 - AI 메인 페이지와 AI 레시피 관리 페이지를 탭으로 관리
class AiTabbarPage extends StatefulWidget {
  const AiTabbarPage({super.key});

  @override
  State<AiTabbarPage> createState() => _AiTabbarPageState();
}

class _AiTabbarPageState extends State<AiTabbarPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 1) {
      // 두 번째 탭(AI 레시피 관리)으로 이동했을 때 데이터 로드
      // 약간의 지연 후 데이터 로딩 (탭 애니메이션 완료 후)
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          context.read<RecipeCubit>().loadAiRecipes();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, AppLocale>(
      builder: (context, currentLocale) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              AppStrings.getAiRecipeGeneration(currentLocale),
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.accent,
              indicatorWeight: 3,
              labelStyle: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.normal,
              ),
              tabs: [
                Tab(
                  icon: Icon(Icons.auto_awesome, size: 20),
                  text: AppStrings.getAiRecipeGenerationTab(currentLocale),
                ),
                Tab(
                  icon: Icon(Icons.auto_awesome_outlined, size: 20),
                  text: AppStrings.getAiRecipeManagement(currentLocale),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // 첫 번째 탭: AI 레시피 생성
              AiMainPage(
                onTabChanged: (int index) {
                  _tabController.animateTo(index);
                },
              ),
              // 두 번째 탭: AI 레시피 관리
              const AiRecipePage(),
            ],
          ),
        );
      },
    );
  }
}
