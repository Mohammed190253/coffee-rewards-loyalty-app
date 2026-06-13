import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/i_branch_repository.dart';
import 'branch_state.dart';

class BranchCubit extends Cubit<BranchState> {
  final IBranchRepository _branchRepository;

  BranchCubit(this._branchRepository) : super(BranchInitial());

  Future<void> fetchBranches() async {
    emit(BranchLoading());
    try {
      final branches = await _branchRepository.getBranches();
      emit(BranchLoaded(branches));
    } catch (e) {
      emit(BranchError(e.toString()));
    }
  }
}
