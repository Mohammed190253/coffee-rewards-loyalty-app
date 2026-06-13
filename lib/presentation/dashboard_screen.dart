import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../presentation/cubit/dashboard/dashboard_cubit.dart';
import '../presentation/cubit/dashboard/dashboard_state.dart';
import '../presentation/cubit/user/user_cubit.dart';
import '../presentation/cubit/user/user_state.dart';
import '../core/app_colors.dart';
import 'tabs/home_tab.dart';
import 'tabs/menu_tab.dart';
import 'tabs/branches_tab.dart';
import 'tabs/circles_tab.dart';
import 'tabs/profile_tab.dart';
import 'checkout_screen.dart';
import 'account_settings_screen.dart';
import 'loyalty_rewards_screen.dart';
import 'order_history_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _openDrawerRoute(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  String _resolveDrawerName(UserState state) {
    if (state is UserLoaded) {
      final name = state.user.name.trim();
      if (name.isNotEmpty) return name;
    }
    return 'Guest Voyager';
  }

  String _resolveDrawerTier(UserState state) {
    if (state is UserLoaded) {
      return state.user.tierName;
    }
    return 'Voyager';
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return Scaffold(
          key: scaffoldKey,
          backgroundColor: AppColors.getBackground(state.isScholarMode),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.menu,
                color: state.isScholarMode ? Colors.white : AppColors.primaryTeal,
              ),
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
            ),
            title: Text(
              'ASTROLABE',
              style: TextStyle(
                color: state.isScholarMode ? AppColors.astrolabeGold : AppColors.primaryTeal,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          drawer: Drawer(
            backgroundColor: state.isScholarMode ? AppColors.scholarBackground : AppColors.backgroundBeige,
            child: BlocBuilder<UserCubit, UserState>(
              builder: (context, userState) {
                final accountName = _resolveDrawerName(userState);
                final accountTier = _resolveDrawerTier(userState);

                return Column(
                  children: [
                    UserAccountsDrawerHeader(
                      decoration: BoxDecoration(
                        color: state.isScholarMode ? AppColors.scholarCard : AppColors.primaryTeal,
                      ),
                      currentAccountPicture: const CircleAvatar(
                        backgroundColor: AppColors.astrolabeGold,
                        child: Icon(Icons.person, color: Colors.white, size: 35),
                      ),
                      accountName: Text(
                        accountName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      accountEmail: Text(
                        accountTier,
                        style: const TextStyle(
                          color: AppColors.astrolabeGold,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _buildDrawerItem(
                            icon: Icons.history_toggle_off_rounded,
                            title: 'Order History',
                            isScholar: state.isScholarMode,
                            onTap: () => _openDrawerRoute(
                              context,
                              const OrderHistoryScreen(),
                            ),
                          ),
                          _buildDrawerItem(
                            icon: Icons.star_outline_rounded,
                            title: 'Loyalty Rewards',
                            isScholar: state.isScholarMode,
                            onTap: () => _openDrawerRoute(
                              context,
                              const LoyaltyRewardsScreen(),
                            ),
                          ),
                          _buildDrawerItem(
                            icon: Icons.settings_outlined,
                            title: 'Account Settings',
                            isScholar: state.isScholarMode,
                            onTap: () => _openDrawerRoute(
                              context,
                              const AccountSettingsScreen(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: AstrolabeButton(
                        label: 'Close Menu',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          body: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _getTab(state.selectedIndex),
            ),
          ),
          floatingActionButton: state.selectedIndex == 1
              ? FloatingActionButton.extended(
                  backgroundColor: AppColors.astrolabeGold,
                  elevation: 8,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                    );
                  },
                  icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryTeal),
                  label: const Text(
                    'Cart',
                    style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
                  ),
                )
              : null,
          extendBody: true,
          bottomNavigationBar: SafeArea(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryTeal.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppColors.astrolabeGold,
                unselectedItemColor: Colors.white54,
                showSelectedLabels: true,
                showUnselectedLabels: false,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                currentIndex: state.selectedIndex,
                onTap: (index) => context.read<DashboardCubit>().changeTab(index),
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'Menu'),
                  BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), activeIcon: Icon(Icons.location_on), label: 'Branches'),
                  BottomNavigationBarItem(icon: Icon(Icons.group_work_outlined), activeIcon: Icon(Icons.group_work), label: 'Circles'),
                  BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getTab(int index) {
    switch (index) {
      case 0:
        return const HomeTab(key: ValueKey(0));
      case 1:
        return const MenuTab(key: ValueKey(1));
      case 2:
        return const BranchesTab(key: ValueKey(2));
      case 3:
        return const CirclesTab(key: ValueKey(3));
      case 4:
        return const ProfileTab(key: ValueKey(4));
      default:
        return const HomeTab(key: ValueKey(0));
    }
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required bool isScholar,
    required VoidCallback onTap,
  }) {
    final Color itemColor = isScholar ? Colors.white : AppColors.primaryTeal;

    return ListTile(
      leading: Icon(icon, color: AppColors.astrolabeGold),
      title: Text(
        title,
        style: TextStyle(color: itemColor, fontWeight: FontWeight.w500, fontSize: 15),
      ),
      onTap: onTap,
    );
  }
}
