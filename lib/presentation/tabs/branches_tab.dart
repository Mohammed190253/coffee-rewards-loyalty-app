import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/app_colors.dart';
import '../../domain/entities/branch.dart';
import '../cubit/branch/branch_cubit.dart';
import '../cubit/branch/branch_state.dart';

class BranchesTab extends StatelessWidget {
  const BranchesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BranchCubit, BranchState>(
      builder: (context, state) {
        if (state is BranchLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BranchError) {
          return Center(child: Text(state.message));
        } else if (state is BranchLoaded) {
          final branches = state.branches;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Astrolabe Sanctuaries", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryTeal)),
                const Text("Find your next quiet spot or social hub.", style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                const SizedBox(height: 25),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: branches.length,
                  itemBuilder: (context, index) => _buildBranchCard(context, branches[index]),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBranchCard(BuildContext context, Branch branch) {
    Color busynessColor = AppColors.primaryTeal;
    if (branch.busynessLevel == "Quiet") busynessColor = Colors.green;
    if (branch.busynessLevel == "Busy") busynessColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(25)), image: DecorationImage(image: NetworkImage(branch.imagePath), fit: BoxFit.cover)),
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: busynessColor, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Text(branch.busynessLevel, style: TextStyle(color: busynessColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(branch.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryTeal)),
                    if (branch.hasQuietZone)
                      const Icon(Icons.volume_off, color: AppColors.astrolabeGold, size: 20),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.textGrey),
                    const SizedBox(width: 5),
                    Text(branch.location, style: const TextStyle(color: AppColors.textGrey, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryTeal,
                      side: const BorderSide(color: AppColors.primaryTeal),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("Get Directions"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}