import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import '../../model/ingredient.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'ingredient_ball.dart';

/// 재료 애니메이션 배경 위젯
/// 물리 엔진을 포함한 인터랙티브 배경입니다.
class AnimationBackground extends StatefulWidget {
  final List<Ingredient> ingredients;
  final Function(String)? onIngredientTap;
  final Function(String)? onIngredientLongPress;
  final Function(Ingredient)? onPositionSaved; // 위치 저장 콜백

  const AnimationBackground({
    super.key,
    required this.ingredients,
    this.onIngredientTap,
    this.onIngredientLongPress,
    this.onPositionSaved,
  });

  @override
  State<AnimationBackground> createState() => _AnimationBackgroundState();
}

class _AnimationBackgroundState extends State<AnimationBackground> {
  List<IngredientBallComponent> _ballComponents = [];

  @override
  void initState() {
    super.initState();
    // 센서 관련 코드 제거됨
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: _AnimationGame(
        ingredients: widget.ingredients,
        onIngredientTap: widget.onIngredientTap,
        onIngredientLongPress: widget.onIngredientLongPress,
        onBallComponentsChanged: (components) {
          _ballComponents = components;
        },
        onPositionSaved: widget.onPositionSaved,
      ),
      backgroundBuilder: (context) => const SizedBox.shrink(),
      loadingBuilder: (context) => const SizedBox.shrink(),
    );
  }
}

/// 애니메이션 게임 클래스 (Flame 엔진)
class _AnimationGame extends FlameGame with TapDetector, HasCollisionDetection {
  final List<Ingredient> ingredients;
  final Function(String)? onIngredientTap;
  final Function(String)? onIngredientLongPress;
  final Function(List<IngredientBallComponent>) onBallComponentsChanged;
  final Function(Ingredient)? onPositionSaved;

  _AnimationGame({
    required this.ingredients,
    this.onIngredientTap,
    this.onIngredientLongPress,
    required this.onBallComponentsChanged,
    this.onPositionSaved,
  });

  List<IngredientBallComponent> _ballComponents = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 배경 이미지 추가
    final background = SpriteComponent()
      ..sprite = await Sprite.load('background.png')
      ..size = size;

    add(background);

    // 재료 볼들 생성
    _createIngredientBalls();
  }

  void _createIngredientBalls() {
    _ballComponents.clear();

    for (int i = 0; i < ingredients.length; i++) {
      final ingredient = ingredients[i];
      final random = Random();

      Vector2 position;
      Vector2? initialVelocity;

      // 저장된 위치가 있으면 사용, 없으면 새로운 위치 생성
      if (ingredient.animationX != null &&
          ingredient.animationY != null &&
          ingredient.isAnimationSettled) {
        // 저장된 위치 사용
        position = Vector2(ingredient.animationX!, ingredient.animationY!);
        initialVelocity = Vector2.zero(); // 정착된 상태
      } else {
        // 새로운 위치 생성 (화면 상단에서 시작)
        final startX = random.nextDouble() * (size.x - 80);
        final startY = -100.0 - (i * 30.0);
        position = Vector2(startX, startY);
        initialVelocity = Vector2(
          (random.nextDouble() - 0.5) * 50,
          random.nextDouble() * 150 + 100,
        );
      }

      final ball = IngredientBallComponent(
        ingredient: ingredient,
        position: position,
        initialVelocity: initialVelocity,
        onPositionSaved: onPositionSaved,
      );

      _ballComponents.add(ball);
      add(ball);
    }

    onBallComponentsChanged(_ballComponents);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 화면 밖으로 나간 볼 제거
    _ballComponents.removeWhere((ball) {
      if (ball.position.y > size.y + 100) {
        ball.removeFromParent();
        return true;
      }
      return false;
    });
  }

  @override
  bool onTapDown(TapDownInfo info) {
    // 탭한 위치의 볼 찾기
    for (final ball in _ballComponents) {
      final ballRect = Rect.fromCenter(
        center: Offset(ball.position.x.toDouble(), ball.position.y.toDouble()),
        width: ball.width.toDouble(),
        height: ball.height.toDouble(),
      );

      if (ballRect.contains(
        Offset(info.eventPosition.global.x, info.eventPosition.global.y),
      )) {
        onIngredientTap?.call(ball.ingredient.id);
        break;
      }
    }
    return true;
  }

  @override
  bool onLongTapDown(TapDownInfo info) {
    // 길게 누른 위치의 볼 찾기
    for (final ball in _ballComponents) {
      final ballRect = Rect.fromCenter(
        center: Offset(ball.position.x.toDouble(), ball.position.y.toDouble()),
        width: ball.width.toDouble(),
        height: ball.height.toDouble(),
      );

      if (ballRect.contains(
        Offset(info.eventPosition.global.x, info.eventPosition.global.y),
      )) {
        onIngredientLongPress?.call(ball.ingredient.id);
        break;
      }
    }
    return true;
  }

  // 새로운 재료 추가
  void addIngredient(Ingredient ingredient) {
    final random = Random();
    final startX = random.nextDouble() * size.x;

    final ball = IngredientBallComponent(
      ingredient: ingredient,
      position: Vector2(startX, -100),
      initialVelocity: Vector2(
        (random.nextDouble() - 0.5) * 100,
        random.nextDouble() * 200 + 100,
      ),
    );

    _ballComponents.add(ball);
    add(ball);
    onBallComponentsChanged(_ballComponents);
  }

  // 모든 볼에 흔들기 효과 적용
  void shakeAllBalls() {
    final random = Random();
    for (final ball in _ballComponents) {
      final shakeForce = Vector2(
        (random.nextDouble() - 0.5) * 300,
        (random.nextDouble() - 0.5) * 300,
      );
      ball.applyShake(shakeForce);
    }
  }
}

/// 간단한 배경 위젯 (Flame 없이 사용할 경우)
class SimpleAnimationBackground extends StatefulWidget {
  final List<Ingredient> ingredients;
  final VoidCallback? onIngredientTap;
  final VoidCallback? onIngredientLongPress;

  const SimpleAnimationBackground({
    super.key,
    required this.ingredients,
    this.onIngredientTap,
    this.onIngredientLongPress,
  });

  @override
  State<SimpleAnimationBackground> createState() =>
      _SimpleAnimationBackgroundState();
}

class _SimpleAnimationBackgroundState extends State<SimpleAnimationBackground>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  List<IngredientBall> _balls = [];

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _createBalls();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  void _createBalls() {
    _balls = widget.ingredients.map((ingredient) {
      final random = Random();
      return IngredientBall(
        ingredient: ingredient,
        initialPosition: Offset(
          random.nextDouble() * 300,
          -100 - (random.nextDouble() * 50),
        ),
        initialVelocity: random.nextDouble() * 200 + 100,
        onTap: widget.onIngredientTap,
        onLongPress: widget.onIngredientLongPress,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary, // 베이지색
            AppColors.primaryLight, // 밝은 베이지색
          ],
        ),
      ),
      child: Stack(
        children: [
          // 배경 애니메이션
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return CustomPaint(
                painter: _BackgroundPainter(_backgroundController.value),
                size: Size.infinite,
              );
            },
          ),
          // 재료 볼들
          ..._balls,
        ],
      ),
    );
  }
}

/// 배경 페인터
class _BackgroundPainter extends CustomPainter {
  final double animationValue;

  _BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // 구름 그리기
    for (int i = 0; i < 5; i++) {
      final x =
          (size.width * 0.2 * i + animationValue * size.width) %
          (size.width + 100);
      final y = 50.0 + (i * 30.0);

      canvas.drawCircle(Offset(x, y), 30, paint);
    }

    // 바닥 그리기
    final groundPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 100, size.width, 100),
      groundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
