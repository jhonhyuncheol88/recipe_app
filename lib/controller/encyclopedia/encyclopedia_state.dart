import 'package:equatable/equatable.dart';
import '../../model/encyclopedia_recipe.dart';

/// 백과사전 상태 기본 클래스
abstract class EncyclopediaState extends Equatable {
  const EncyclopediaState();

  @override
  List<Object?> get props => [];
}

/// 초기 상태
class EncyclopediaInitial extends EncyclopediaState {
  const EncyclopediaInitial();
}

/// 로딩 상태
class EncyclopediaLoading extends EncyclopediaState {
  const EncyclopediaLoading();
}

/// 레시피 목록 로드 성공
class EncyclopediaLoaded extends EncyclopediaState {
  final List<EncyclopediaRecipe> recipes;

  const EncyclopediaLoaded({required this.recipes});

  @override
  List<Object?> get props => [recipes];
}

/// 검색 결과
class EncyclopediaSearchResult extends EncyclopediaState {
  final List<EncyclopediaRecipe> recipes;
  final String query;

  const EncyclopediaSearchResult({
    required this.recipes,
    required this.query,
  });

  @override
  List<Object?> get props => [recipes, query];
}

/// 에러 상태
class EncyclopediaError extends EncyclopediaState {
  final String message;

  const EncyclopediaError(this.message);

  @override
  List<Object?> get props => [message];
}

/// 빈 상태 (레시피가 없을 때)
class EncyclopediaEmpty extends EncyclopediaState {
  const EncyclopediaEmpty();
}

