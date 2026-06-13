import 'package:equatable/equatable.dart';

class DashboardState extends Equatable {
  final int selectedIndex;
  final bool isScholarMode;

  const DashboardState({
    required this.selectedIndex,
    required this.isScholarMode,
  });

  @override
  List<Object?> get props => [selectedIndex, isScholarMode];
}
