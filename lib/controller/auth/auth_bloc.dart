import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authStateSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignOutRequested>(_onSignOutRequested);

    // Firebase 인증 상태 변화 감지
    _authStateSubscription = _authRepository.authStateChanges.listen((
      User? user,
    ) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    // 앱 시작 시 초기 인증 상태 확인
    // authStateChanges 스트림이 자동으로 처리
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(Unauthenticated());
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
