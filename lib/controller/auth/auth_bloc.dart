import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import '../../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

final _log = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

/// 계정 탈퇴 시 reauth 가 필요한 경우 [AuthFailure.error] 로 전달되는 sentinel.
const String authReauthRequiredSentinel = 'REAUTH_REQUIRED';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authStateSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignInWithGoogleRequested>(_onSignInWithGoogle);
    on<SignInWithAppleRequested>(_onSignInWithApple);
    on<SignOutRequested>(_onSignOutRequested);
    on<DeleteAccountRequested>(_onDeleteAccount);

    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        // ignore: invalid_use_of_visible_for_testing_member
        emit(Authenticated(user));
      } else {
        // ignore: invalid_use_of_visible_for_testing_member
        emit(Unauthenticated());
      }
    });
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    // authStateChanges 스트림이 자동 처리.
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithGoogle();
      // 성공 시 authStateChanges → Authenticated 자동 emit.
    } on AuthCancelledException {
      emit(Unauthenticated());
    } catch (e, st) {
      _log.e('[signInWithGoogle]', error: e, stackTrace: st);
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignInWithApple(
    SignInWithAppleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithApple();
    } on AuthCancelledException {
      emit(Unauthenticated());
    } catch (e, st) {
      _log.e('[signInWithApple]', error: e, stackTrace: st);
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.signOut();
      // authStateChanges 가 Unauthenticated 자동 emit.
    } catch (e, st) {
      _log.e('[signOut]', error: e, stackTrace: st);
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.deleteAccount();
      // authStateChanges 가 Unauthenticated 자동 emit.
    } on FirebaseAuthException catch (e) {
      _log.w('[deleteAccount] FirebaseAuthException ${e.code}: ${e.message}');
      if (e.code == 'requires-recent-login') {
        emit(AuthFailure(authReauthRequiredSentinel));
      } else {
        emit(AuthFailure(e.message ?? e.code));
      }
    } catch (e, st) {
      _log.e('[deleteAccount]', error: e, stackTrace: st);
      emit(AuthFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
