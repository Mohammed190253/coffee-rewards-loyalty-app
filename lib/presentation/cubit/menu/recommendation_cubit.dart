import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/i_menu_repository.dart';
import 'recommendation_state.dart';

class RecommendationCubit extends Cubit<RecommendationState> {
  final IMenuRepository _menuRepository;

  RecommendationCubit(this._menuRepository) : super(RecommendationInitial());

  Future<void> fetchRecommendations() async {
    emit(RecommendationLoading());
    try {
      final items = await _menuRepository.getRecommendedItems();
      emit(RecommendationLoaded(items));
    } catch (e) {
      emit(RecommendationError(e.toString()));
    }
  }
}
