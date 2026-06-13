import '../../domain/entities/branch.dart';
import '../../domain/repositories/i_branch_repository.dart';

class BranchRepositoryImpl implements IBranchRepository {
  @override
  Future<List<Branch>> getBranches() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Branch(
        name: "Abdoun Branch",
        location: "Amman, Jordan",
        imagePath: "https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=400",
        busynessLevel: "Busy",
        hasQuietZone: false,
      ),
      Branch(
        name: "Dabouq Sanctuary",
        location: "Amman, Jordan",
        imagePath: "https://images.unsplash.com/photo-1600093463592-8e36ae95ef56?q=80&w=400",
        busynessLevel: "Quiet",
        hasQuietZone: true,
      ),
      Branch(
        name: "Weibdeh Branch",
        location: "Amman, Jordan",
        imagePath: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=400",
        busynessLevel: "Moderate",
        hasQuietZone: true,
      ),
    ];
  }
}
