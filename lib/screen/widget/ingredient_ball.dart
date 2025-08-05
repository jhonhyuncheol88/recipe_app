import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import '../../model/ingredient.dart';
import 'dart:ui';
import 'dart:math';

/// 재료 볼 위젯
/// 재료를 원형 컨테이너로 표현하며 물리적 애니메이션을 지원합니다.
class IngredientBall extends StatefulWidget {
  final Ingredient ingredient;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isAnimating;
  final double? initialVelocity;
  final Offset? initialPosition;

  const IngredientBall({
    super.key,
    required this.ingredient,
    this.onTap,
    this.onLongPress,
    this.isAnimating = false,
    this.initialVelocity,
    this.initialPosition,
  });

  @override
  State<IngredientBall> createState() => _IngredientBallState();
}

class _IngredientBallState extends State<IngredientBall>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _bounceController;
  late AnimationController _shakeController;

  Offset _position = Offset.zero;
  Offset _velocity = Offset.zero;
  bool _isSettled = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializePosition();
  }

  void _initializeControllers() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  void _initializePosition() {
    if (widget.initialPosition != null) {
      _position = widget.initialPosition!;
    } else {
      // 기본 위치: 화면 상단에서 시작
      _position = Offset(0, -100);
    }

    if (widget.initialVelocity != null) {
      _velocity = Offset(0, widget.initialVelocity!);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bounceController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void startFallAnimation() {
    _animationController.forward();
  }

  void startBounceAnimation() {
    _bounceController.forward();
  }

  void startShakeAnimation() {
    _shakeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _animationController,
        _bounceController,
        _shakeController,
      ]),
      builder: (context, child) {
        return Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: _buildBallContainer(),
          ),
        );
      },
    );
  }

  Widget _buildBallContainer() {
    return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: _getIngredientColors(),
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.ingredient.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '₩${widget.ingredient.purchasePrice.toInt()}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(seconds: 2),
          color: Colors.white.withOpacity(0.3),
        );
  }

  List<Color> _getIngredientColors() {
    // 모든 재료 볼에 통일된 색상 적용
    return [
      const Color(0xFF4A90E2), // 파란색
      const Color(0xFF7ED321), // 초록색
    ];
  }

  void updatePhysics(double deltaTime) {
    if (_isSettled) return;

    const gravity = 500.0;
    const groundLevel = 600.0; // 바닥 위치
    const bounceFactor = 0.7;
    const friction = 0.98;

    // 중력 적용
    _velocity = Offset(
      _velocity.dx * friction,
      _velocity.dy + gravity * deltaTime,
    );
    _position += _velocity * deltaTime;

    // 바닥 충돌 감지
    if (_position.dy >= groundLevel) {
      _position = Offset(_position.dx, groundLevel);
      _velocity = Offset(_velocity.dx, -_velocity.dy * bounceFactor);

      // 속도가 충분히 작으면 정착
      if (_velocity.dy.abs() < 10) {
        _isSettled = true;
        _velocity = Offset.zero;
      }
    }

    setState(() {});
  }
}

/// 재료 볼 물리 컴포넌트 (Flame 게임 엔진용)
class IngredientBallComponent extends PositionComponent
    with HasGameRef, DragCallbacks, CollisionCallbacks {
  final Ingredient ingredient;
  Vector2 velocity = Vector2.zero();
  bool isSettled = false;
  bool isDragging = false;
  Vector2? dragStartPosition;

  static const double gravity = 400.0; // 중력 감소
  static const double bounceFactor = 0.8; // 바운스 증가
  static const double friction = 0.99; // 마찰력 감소
  Function(Ingredient)? onPositionSaved; // 위치 저장 콜백

  IngredientBallComponent({
    required this.ingredient,
    required Vector2 position,
    Vector2? initialVelocity,
    this.onPositionSaved,
  }) : super(position: position, size: Vector2(80, 80)) {
    if (initialVelocity != null) {
      velocity = initialVelocity;
    }
    // 저장된 위치가 있으면 정착 상태로 시작
    if (ingredient.isAnimationSettled) {
      isSettled = true;
    }
    // 충돌 감지 활성화
    add(CircleHitbox());
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // 이미지 로딩은 나중에 구현할 예정
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2;

    // 그림자 효과 먼저 그리기
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, radius, shadowPaint);

    // 기본 그라데이션 사용 (이미지 로딩이 실패하거나 없을 때)
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          const Color(0xFF4A90E2), // 파란색
          const Color(0xFF7ED321), // 초록색
        ],
        stops: [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);

    // 원형 마스크 적용 (이미지를 원형으로 자르기)
    final clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(clipPath);

    // 재료명과 가격 텍스트 그리기 (반투명 배경과 함께)
    final textBackgroundRect = Rect.fromLTWH(
      center.dx - 40,
      center.dy + 15,
      80,
      30,
    );

    final textBackgroundPaint = Paint()..color = Colors.black.withOpacity(0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(textBackgroundRect, const Radius.circular(15)),
      textBackgroundPaint,
    );

    // 재료명 텍스트
    final textPainter = TextPainter(
      text: TextSpan(
        text: ingredient.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2 - 5,
      ),
    );

    // 가격 텍스트
    final pricePainter = TextPainter(
      text: TextSpan(
        text: '₩${ingredient.purchasePrice.toInt()}',
        style: const TextStyle(color: Colors.white, fontSize: 8),
      ),
      textDirection: TextDirection.ltr,
    );
    pricePainter.layout();
    pricePainter.paint(
      canvas,
      Offset(
        (size.x - pricePainter.width) / 2,
        (size.y - pricePainter.height) / 2 + 8,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isSettled || isDragging) return;

    // 중력 적용
    velocity.y += gravity * dt;
    position += velocity * dt;

    // 화면 경계 체크
    _checkBoundaries();

    // 바닥 충돌 감지
    final groundLevel = gameRef.size.y - height;
    if (position.y >= groundLevel) {
      position.y = groundLevel;
      velocity.y = -velocity.y * bounceFactor;

      // 속도가 충분히 작으면 정착
      if (velocity.y.abs() < 5 && velocity.x.abs() < 5) {
        if (!isSettled) {
          isSettled = true;
          velocity = Vector2.zero();
          // 위치 저장
          _savePosition();
        }
      }
    }

    // 다른 볼들과의 충돌 감지
    _checkCollisionWithOtherBalls();

    // 마찰력 적용 (공기 저항)
    velocity *= friction;
  }

  void _checkBoundaries() {
    // 좌우 경계 체크
    if (position.x <= 0) {
      position.x = 0;
      velocity.x = -velocity.x * 0.8; // 벽에 부딪힐 때 속도 감소
    } else if (position.x >= gameRef.size.x - width) {
      position.x = gameRef.size.x - width;
      velocity.x = -velocity.x * 0.8;
    }

    // 상단 경계 체크
    if (position.y <= 0) {
      position.y = 0;
      velocity.y = -velocity.y * 0.8;
    }
  }

  void _checkCollisionWithOtherBalls() {
    final otherBalls =
        parent?.children
            .whereType<IngredientBallComponent>()
            .where((ball) => ball != this)
            .toList() ??
        [];

    for (final otherBall in otherBalls) {
      if (_isColliding(otherBall)) {
        _resolveCollision(otherBall);
        break; // 한 번에 하나의 충돌만 처리
      }
    }
  }

  bool _isColliding(IngredientBallComponent other) {
    final distance = position.distanceTo(other.position);
    final minDistance = (size.x + other.size.x) / 2;
    return distance < minDistance;
  }

  void _resolveCollision(IngredientBallComponent other) {
    // 충돌 방향 계산
    final collisionVector = (other.position - position).normalized();
    final overlap =
        (size.x + other.size.x) / 2 - position.distanceTo(other.position);

    // 겹침 해결 (서로 밀어내기)
    position -= collisionVector * overlap * 0.5;
    other.position += collisionVector * overlap * 0.5;

    // 탄성 충돌 물리 계산
    final relativeVelocity = velocity - other.velocity;
    final velocityAlongNormal = relativeVelocity.dot(collisionVector);

    if (velocityAlongNormal < 0) {
      // 질량이 같다고 가정 (모든 볼이 같은 크기)
      final restitution = 0.5; // 탄성 계수 감소
      final impulse = -(1 + restitution) * velocityAlongNormal;

      // 속도 변경 (최대 속도 제한)
      final newVelocity1 = velocity - collisionVector * impulse;
      final newVelocity2 = other.velocity + collisionVector * impulse;

      // 최대 속도 제한 (너무 빠르게 튕겨나가지 않도록)
      velocity = _clampVelocity(newVelocity1, 200);
      other.velocity = _clampVelocity(newVelocity2, 200);

      // 충돌 후 정착 상태 해제 (움직이게 만들기)
      if (isSettled && velocity.length > 5) {
        isSettled = false;
      }
      if (other.isSettled && other.velocity.length > 5) {
        other.isSettled = false;
      }
    }
  }

  Vector2 _clampVelocity(Vector2 velocity, double maxSpeed) {
    if (velocity.length > maxSpeed) {
      return velocity.normalized() * maxSpeed;
    }
    return velocity;
  }

  void _savePosition() {
    if (onPositionSaved != null) {
      final updatedIngredient = ingredient.copyWith(
        animationX: position.x,
        animationY: position.y,
        isAnimationSettled: true,
      );
      onPositionSaved!(updatedIngredient);
    }
  }

  void applyShake(Vector2 shakeForce) {
    if (!isSettled) return;
    velocity += shakeForce;
    isSettled = false;
  }

  // 드래그 시작
  @override
  bool onDragStart(DragStartEvent event) {
    isDragging = true;
    dragStartPosition = position.clone();
    velocity = Vector2.zero(); // 드래그 중에는 속도 초기화
    isSettled = false;
    return true;
  }

  // 드래그 중
  @override
  bool onDragUpdate(DragUpdateEvent event) {
    if (isDragging) {
      position += event.localDelta;
      // 화면 경계 체크
      position.x = position.x.clamp(0, gameRef.size.x - size.x);
      position.y = position.y.clamp(0, gameRef.size.y - size.y);
    }
    return true;
  }

  // 드래그 종료
  @override
  bool onDragEnd(DragEndEvent event) {
    isDragging = false;
    dragStartPosition = null;
    // 드래그 종료 후 물리 효과 재시작
    if (position.y < gameRef.size.y - size.y) {
      isSettled = false;
      velocity = Vector2.zero();
    }
    return true;
  }
}
