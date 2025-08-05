import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'router/index.dart';
import 'theme/app_theme.dart';
import 'util/app_strings.dart';
import 'util/app_locale.dart';
import 'controller/index.dart';
import 'data/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Repository들
        RepositoryProvider<IngredientRepository>(
          create: (context) => IngredientRepository(),
        ),
        RepositoryProvider<RecipeRepository>(
          create: (context) => RecipeRepository(),
        ),
        RepositoryProvider<TagRepository>(create: (context) => TagRepository()),
        RepositoryProvider<UnitRepository>(
          create: (context) => UnitRepository(),
        ),

        // 재료 관련 BLoC
        BlocProvider<IngredientCubit>(
          create: (context) => IngredientCubit(
            ingredientRepository: context.read<IngredientRepository>(),
            tagRepository: context.read<TagRepository>(),
          ),
        ),

        // 레시피 관련 BLoC
        BlocProvider<RecipeCubit>(
          create: (context) => RecipeCubit(
            recipeRepository: context.read<RecipeRepository>(),
            ingredientRepository: context.read<IngredientRepository>(),
            unitRepository: context.read<UnitRepository>(),
            tagRepository: context.read<TagRepository>(),
          ),
        ),

        // OCR 관련 BLoC
        BlocProvider<OcrCubit>(create: (context) => OcrCubit()),

        // 태그 관련 BLoC
        BlocProvider<TagCubit>(
          create: (context) => TagCubit(
            tagRepository: context.read<TagRepository>(),
            ingredientRepository: context.read<IngredientRepository>(),
            recipeRepository: context.read<RecipeRepository>(),
          ),
        ),

        // 애니메이션 관련 BLoC
        BlocProvider<AnimationCubit>(create: (context) => AnimationCubit()),
      ],
      child: MaterialApp.router(
        title: AppStrings.getAppTitle(AppLocale.korea),
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
