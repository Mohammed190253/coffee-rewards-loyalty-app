import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/i_menu_repository.dart';
import 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  final IMenuRepository _menuRepository;

  MenuCubit(this._menuRepository) : super(MenuInitial());

  Future<void> fetchMenu() async {
    emit(MenuLoading());
    try {
      final items = await _menuRepository.getAstrolabeMenu();
      emit(MenuLoaded(items));
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }
}
