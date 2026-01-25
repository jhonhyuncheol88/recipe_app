import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          context.read<RecipeCubit>().loadAiRecipes();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<LocaleCubit, AppLocale>(
      builder: (context, currentLocale) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            title: Text(
              AppStrings.getAiRecipeGeneration(currentLocale),
              style: AppTextStyles.headline3.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            backgroundColor: colorScheme.surface,
            elevation: 0,
            iconTheme: IconThemeData(color: colorScheme.onSurface),
            bottom: TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor:
                  colorScheme.onSurface.withValues(alpha: 0.6),
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              dividerColor: Colors.transparent,
              labelStyle: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.normal,
              ),
              tabs: [
                Tab(
                  icon: const Icon(Icons.auto_awesome, size: 20),
                  text: AppStrings.getAiRecipeGenerationTab(currentLocale),
                ),
                Tab(
                  icon: const Icon(Icons.auto_awesome_outlined, size: 20),
                  text: AppStrings.getAiRecipeManagement(currentLocale),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              AiMainPage(
                onTabChanged: (int index) {
                  _tabController.animateTo(index);
                },
              ),
              const AiRecipePage(),
            ],
          ),
        );
      },
    );
  }
}
