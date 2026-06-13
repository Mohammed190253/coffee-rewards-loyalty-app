import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/app_colors.dart';
import '../cubit/menu/recommendation_cubit.dart';
import '../cubit/menu/recommendation_state.dart';
import '../cubit/user/user_cubit.dart';
import '../cubit/user/user_state.dart';
import '../loyalty_rewards_screen.dart';
import '../order_history_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  final int visitCount = 14;

  String _resolveDisplayName(UserState state) {
    if (state is UserLoaded) {
      final name = state.user.name.trim();
      if (name.isNotEmpty) return name;
    }
    return 'Guest Voyager';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, userState) {
        final displayName = _resolveDisplayName(userState);
        final isHydrating = userState is UserInitial || userState is UserLoading;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back,',
                style: TextStyle(color: AppColors.textGrey, fontSize: 16),
              ),
              if (isHydrating)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.astrolabeGold,
                    ),
                  ),
                )
              else
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryTeal,
                    letterSpacing: -0.5,
                  ),
                ),

              const SizedBox(height: 30),
              _buildDailyWisdom(context),
              const SizedBox(height: 30),
              _buildPremiumPointsCard(context),
              const SizedBox(height: 25),
              _buildPurchaseHistoryButton(context),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recommended for You',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: AppColors.primaryTeal.withValues(alpha: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildRecommendations(),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyWisdom(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.astrolabeGold.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wb_sunny_outlined,
                  color: AppColors.astrolabeGold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'DAILY WISDOM',
                style: TextStyle(
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: AppColors.astrolabeGold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '"Traveling—it leaves you speechless, then turns you into a storyteller."',
            style: TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: AppColors.primaryTeal,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '- Ibn Battuta',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumPointsCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoyaltyRewardsScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryTeal, Color(0xFF132A28)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Icons.star,
                size: 120,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STARS EARNED',
                  style: TextStyle(
                    color: AppColors.astrolabeGold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '1,240',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseHistoryButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.astrolabeGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.astrolabeGold,
                size: 24,
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Purchases',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryTeal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Visits: $visitCount times',
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    return BlocBuilder<RecommendationCubit, RecommendationState>(
      builder: (context, state) {
        if (state is RecommendationLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.astrolabeGold),
          );
        } else if (state is RecommendationError) {
          return Center(child: Text(state.message));
        } else if (state is RecommendationLoaded) {
          return SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.items.length,
              clipBehavior: Clip.none,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.star_rounded,
                          color: AppColors.astrolabeGold,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                          fontSize: 15,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${item.smallPrice.toStringAsFixed(2)} JOD',
                        style: const TextStyle(
                          color: AppColors.astrolabeGold,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
