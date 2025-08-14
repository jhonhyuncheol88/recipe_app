import 'package:equatable/equatable.dart';
import '../../model/index.dart';

abstract class SauceState extends Equatable {
  const SauceState();

  @override
  List<Object?> get props => [];
}

class SauceInitial extends SauceState {
  const SauceInitial();
}

class SauceLoading extends SauceState {
  const SauceLoading();
}

class SauceEmpty extends SauceState {
  const SauceEmpty();
}

class SauceLoaded extends SauceState {
  final List<Sauce> sauces;

  const SauceLoaded({required this.sauces});

  @override
  List<Object?> get props => [sauces];
}

class SauceAdded extends SauceState {
  final Sauce sauce;
  final List<Sauce> sauces;

  const SauceAdded({required this.sauce, required this.sauces});

  @override
  List<Object?> get props => [sauce, sauces];
}

class SauceUpdatedState extends SauceState {
  final Sauce sauce;
  final List<Sauce> sauces;

  const SauceUpdatedState({required this.sauce, required this.sauces});

  @override
  List<Object?> get props => [sauce, sauces];
}

class SauceDeleted extends SauceState {
  final String sauceId;
  final List<Sauce> sauces;

  const SauceDeleted({required this.sauceId, required this.sauces});

  @override
  List<Object?> get props => [sauceId, sauces];
}

class SauceError extends SauceState {
  final String message;
  const SauceError(this.message);

  @override
  List<Object?> get props => [message];
}
