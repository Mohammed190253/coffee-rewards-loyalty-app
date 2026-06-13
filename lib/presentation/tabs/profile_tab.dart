import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/app_colors.dart';
import '../../domain/entities/stamp_model.dart';
import '../cubit/dashboard/dashboard_cubit.dart';
import '../cubit/dashboard/dashboard_state.dart';
import '../cubit/user/user_cubit.dart';
import '../cubit/user/user_state.dart';
import '../account_settings_screen.dart';
import '../order_history_screen.dart';
import '../sanctuary_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Read the current scholar mode state to adapt colors seamlessly
    final isScholar = context.watch<DashboardCubit>().state.isScholarMode;

    // Define color palettes for old-world parchment vs scholar mode
    final Color pageBg = isScholar ? AppColors.scholarBackground : const Color(0xFFF9F6F0);
    final Color cardBg = isScholar ? AppColors.scholarCard : const Color(0xFFFAF2E6);
    final Color inkColor = isScholar ? AppColors.astrolabeGold : const Color(0xFF1D3D3A);
    final Color textColor = isScholar ? Colors.white : AppColors.primaryTeal;
    final Color subTextColor = isScholar ? Colors.white54 : AppColors.textGrey;
    final Color goldTint = AppColors.astrolabeGold;

    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.astrolabeGold));
        } else if (state is UserError) {
          return Center(child: Text(state.message, style: TextStyle(color: textColor)));
        } else if (state is UserLoaded) {
          final user = state.user;
          final unlockedCount = user.earnedStamps.where((s) => s.isUnlocked).length;
          final totalStamps = user.earnedStamps.length;

          return Container(
            color: pageBg,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 25, right: 25, top: 25, bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. PASSPORT BOOK HEADER
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: inkColor.withOpacity(0.3), width: 1.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "ASTROLABE TRAVEL DOCUMENT",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: goldTint,
                            letterSpacing: 4,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "UNITED VOYAGERS COFFEE GUILD",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: subTextColor,
                            letterSpacing: 2,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 2. VOYAGER PERSONAL DETAIL PAGE (PASSPORT PROFILE CARD)
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: inkColor.withOpacity(0.2), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Passport Photo Placeholder / Avatar framed with double-borders
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: inkColor.withOpacity(0.4), width: 2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    width: 84,
                                    height: 94,
                                    decoration: BoxDecoration(
                                      color: inkColor.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(Icons.portrait_rounded, size: 68, color: inkColor.withOpacity(0.5)),
                                  ),
                                ),
                                // Security stamp overlay look
                                Container(
                                  transform: Matrix4.translationValues(8, 8, 0)..rotateZ(0.2),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: inkColor.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Text(
                                    "PASSED",
                                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                                )
                              ],
                            ),
                            
                            const SizedBox(width: 20),
                            
                            // Passport personal metadata
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name.toUpperCase(),
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  _buildPassportLine("STATUS", user.tierName, inkColor, textColor),
                                  _buildPassportLine("DOC NO", "AST-84920394", inkColor, textColor),
                                  _buildPassportLine("GUILD", "AMMAN BRANCH", inkColor, textColor),
                                  _buildPassportLine("WALLET", "${user.walletBalance.toStringAsFixed(2)} JOD", inkColor, goldTint),
                                ],
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 25),
                        Divider(color: inkColor.withOpacity(0.15), thickness: 1),
                        const SizedBox(height: 15),

                        // Scan QR trigger (with exclusive Sanctuary escape hatch trigger instruction)
                        Center(
                          child: GestureDetector(
                            onLongPress: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => const SanctuaryScreen(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(opacity: animation, child: child);
                                  },
                                  transitionDuration: const Duration(milliseconds: 1500),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: inkColor.withOpacity(0.15)),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
                                    ],
                                  ),
                                  child: QrImageView(
                                    data: user.qrCodeData,
                                    version: QrVersions.auto,
                                    size: 130.0,
                                    foregroundColor: AppColors.primaryTeal,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "SCAN AT REGISTER",
                                  style: TextStyle(color: textColor, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "(Long-press photo to open hidden Sanctuary portal)",
                                  style: TextStyle(color: subTextColor, fontSize: 9, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 3. STATS & STARS BAR
                  Row(
                    children: [
                      _buildPassportStatCard("PASSPORT STARS", "${user.currentStars}", Icons.star, cardBg, inkColor, textColor, goldTint),
                      const SizedBox(width: 15),
                      _buildPassportStatCard("UNLOCKED MILESTONES", "$unlockedCount / $totalStamps", Icons.verified, cardBg, inkColor, textColor, goldTint),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // 4. MILESTONE PROGRESS INDICATOR
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: inkColor.withOpacity(0.2), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Voyage Progression",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
                            ),
                            Text(
                              "$unlockedCount / $totalStamps Stamps",
                              style: TextStyle(color: goldTint, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: totalStamps > 0 ? unlockedCount / totalStamps : 0.0,
                            backgroundColor: goldTint.withOpacity(0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(goldTint),
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          unlockedCount == totalStamps
                              ? "Excellent! You have cleared all voyage milestones for Level 5 Voyager status!"
                              : "Collect ${totalStamps - unlockedCount} more ink stamps to unlock Level 5 Voyager status!",
                          style: TextStyle(color: subTextColor, fontSize: 12, height: 1.3),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 5. THE VOYAGE STAMPS INK GRID
                  Text(
                    "PASSPORT VISA STAMPS",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: user.earnedStamps.length,
                    itemBuilder: (context, index) {
                      return _buildInkStampCard(user.earnedStamps[index], cardBg, inkColor, textColor, subTextColor, goldTint);
                    },
                  ),

                  const SizedBox(height: 30),

                  // 6. STANDARD ITEMS FRAMED ELEGANTLY
                  Text(
                    "PASSPORT UTILITIES",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2, color: textColor),
                  ),
                  const SizedBox(height: 12),
                  _buildPassportUtility(
                    context,
                    Icons.person_outline,
                    'Voyager Details',
                    'Manage personal identity credentials',
                    cardBg,
                    inkColor,
                    textColor,
                    subTextColor,
                    goldTint,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
                      );
                    },
                  ),
                  _buildPassportUtility(
                    context,
                    Icons.history,
                    'Travel Ledgers',
                    'View chronological transaction histories',
                    cardBg,
                    inkColor,
                    textColor,
                    subTextColor,
                    goldTint,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPassportLine(String label, String value, Color inkColor, Color valColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              color: inkColor.withOpacity(0.4),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassportStatCard(
    String title,
    String value,
    IconData icon,
    Color cardBg,
    Color inkColor,
    Color textColor,
    Color goldColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: inkColor.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: goldColor, size: 20),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(color: inkColor.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInkStampCard(
    StampModel stamp,
    Color cardBg,
    Color inkColor,
    Color textColor,
    Color subTextColor,
    Color goldColor,
  ) {
    final Color sealColor = stamp.isUnlocked ? goldColor : Colors.grey.withOpacity(0.35);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: stamp.isUnlocked ? goldColor.withOpacity(0.4) : inkColor.withOpacity(0.15),
          width: stamp.isUnlocked ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Elegant physical-looking ink stamp circular body
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: sealColor,
                width: stamp.isUnlocked ? 2 : 1.5,
                style: stamp.isUnlocked ? BorderStyle.solid : BorderStyle.none, // Dotted if locked
              ),
            ),
            child: stamp.isUnlocked
                ? Icon(stamp.iconData, color: sealColor, size: 26)
                : Icon(Icons.lock_outline, color: sealColor, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            stamp.title.replaceAll(" Stamp", "").replaceAll(" Focus Ring", ""),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: stamp.isUnlocked ? textColor : textColor.withOpacity(0.4),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          if (stamp.isUnlocked) ...[
            Text(
              stamp.branchName?.toUpperCase() ?? "AMMAN",
              style: TextStyle(color: goldColor, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 2),
            Text(
              stamp.dateEarned ?? "",
              style: TextStyle(color: subTextColor, fontSize: 8),
            ),
          ] else ...[
            Text(
              "LOCKED",
              style: TextStyle(color: subTextColor, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 2),
            Text(
              stamp.id == 'ibn_battuta'
                  ? "25m focus required"
                  : stamp.id == 'al_khwarizmi'
                      ? "45m focus required"
                      : stamp.id == 'celestial_navigator'
                          ? "60m focus required"
                          : "90m focus required",
              textAlign: TextAlign.center,
              style: TextStyle(color: subTextColor.withOpacity(0.6), fontSize: 7, fontStyle: FontStyle.italic),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildPassportUtility(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color cardBg,
    Color inkColor,
    Color textColor,
    Color subTextColor,
    Color goldColor, {
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: inkColor.withOpacity(0.15), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: goldColor.withOpacity(0.08), shape: BoxShape.circle),
          child: Icon(icon, color: goldColor, size: 20),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: subTextColor)),
        trailing: Icon(Icons.arrow_forward_ios, size: 12, color: goldColor),
      ),
    );
  }
}