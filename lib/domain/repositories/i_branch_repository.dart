import '../entities/branch.dart';

abstract class IBranchRepository {
  Future<List<Branch>> getBranches();
}
