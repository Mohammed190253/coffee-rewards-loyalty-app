import 'package:equatable/equatable.dart';
import '../../../domain/entities/menu_item.dart';

abstract class RecommendationState extends Equatable {
  const RecommendationState();

  @override
  List<Object> get props => [];
}

class RecommendationInitial extends RecommendationState {}

class RecommendationLoading extends RecommendationState {}

class RecommendationLoaded extends RecommendationState {
  final List<MenuItem> items;

  const RecommendationLoaded(this.items);

  @override
  List<Object> get props => [items];
}

class RecommendationError extends RecommendationState {
  final String message;

  const RecommendationError(this.message);

  @override
  List<Object> get props => [message];
}
