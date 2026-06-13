import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardState(selectedIndex: 0, isScholarMode: false));

  void changeTab(int index) {
    emit(DashboardState(
        selectedIndex: index,
        isScholarMode: state.isScholarMode
    ));
  }

  void toggleScholarMode(bool active) {
    emit(DashboardState(
        selectedIndex: state.selectedIndex,
        isScholarMode: active
    ));
  }
}
