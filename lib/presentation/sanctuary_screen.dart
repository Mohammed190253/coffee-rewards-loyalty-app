import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/app_colors.dart';
import '../domain/entities/stamp_model.dart';
import 'cubit/sanctuary/sanctuary_cubit.dart';
import 'cubit/sanctuary/sanctuary_state.dart';
import 'cubit/user/user_cubit.dart';

class SanctuaryScreen extends StatefulWidget {
  const SanctuaryScreen({super.key});

  @override
  State<SanctuaryScreen> createState() => _SanctuaryScreenState();
}

class _SanctuaryScreenState extends State<SanctuaryScreen> {
  final TextEditingController _noteController = TextEditingController();

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // Beautiful vintage physics ink stamp slam-down bouncing overlay dialog
  void _showStampUnlockedDialog(BuildContext context, StampModel stamp) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Stamp Unlocked",
      barrierColor: Colors.black.withOpacity(0.85), // Deep focus mask overlay
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        // Curve simulating a heavy brass ink stamp being slammed down
        final stampCurve = CurvedAnimation(parent: anim1, curve: Curves.bounceOut);
        final opacityCurve = CurvedAnimation(parent: anim1, curve: Curves.easeInOut);

        return Opacity(
          opacity: opacityCurve.value,
          child: ScaleTransition(
            scale: opacityCurve,
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              contentPadding: EdgeInsets.zero,
              content: _StampVictoryCard(stamp: stamp, animation: stampCurve),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryTeal, // Deep focus background
      resizeToAvoidBottomInset: false, // 1. FIX KEYBOARD OVERFLOW CRUSHING ELEMENTS
      body: SafeArea(
        child: BlocConsumer<SanctuaryCubit, SanctuaryState>(
          listener: (context, state) {
            // Automatic background unlocking is disabled to prevent timer bypass cheats.
            // Rewards must be collected via the dedicated 'COLLECT REWARD' button.
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. ESCAPE HATCH & HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.meeting_room_outlined, color: AppColors.astrolabeGold, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text("THE SANCTUARY", style: TextStyle(color: AppColors.astrolabeGold, letterSpacing: 5, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(width: 48), // Balance for back button
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 2. POMODORO TIMER MODULE WITH ADJUSTABLE CONTROLS
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Decrement Duration Control (-)
                          _buildAdjustmentButton(
                            icon: Icons.remove,
                            isEnabled: !state.isTimerRunning && state.timerSeconds > 0,
                            onTap: () => context.read<SanctuaryCubit>().adjustTimer(-60), // -1 min
                            onLongPress: () => context.read<SanctuaryCubit>().adjustTimer(-300), // -5 mins
                          ),
                          
                          const SizedBox(width: 20),
                          
                          // Central Circular Timer Gauge
                          Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.astrolabeGold.withOpacity(0.3), width: 2),
                              boxShadow: [BoxShadow(color: AppColors.astrolabeGold.withOpacity(0.05), blurRadius: 40)],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _formatTime(state.timerSeconds),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 64,
                                    fontWeight: FontWeight.w200,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                if (state.timerSeconds == 0) ...[
                                  GestureDetector(
                                    onTap: () {
                                      final newlyUnlockedStamp = context.read<UserCubit>().completeFocusSession(
                                        state.focusDurationSeconds ~/ 60, // Convert to minutes
                                        "Abdoun Branch",
                                      );
                                      if (newlyUnlockedStamp != null) {
                                        _showStampUnlockedDialog(context, newlyUnlockedStamp);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("You have already claimed this milestone stamp!"),
                                            backgroundColor: AppColors.primaryTeal,
                                          ),
                                        );
                                      }
                                      // Reset the timer back to custom baseline focus duration
                                      context.read<SanctuaryCubit>().resetTimer();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.astrolabeGold,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.astrolabeGold.withOpacity(0.4),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          )
                                        ],
                                      ),
                                      child: const Text(
                                        "COLLECT REWARD",
                                        style: TextStyle(
                                          color: AppColors.primaryTeal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  if (state.isTimerRunning) ...[
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () => context.read<SanctuaryCubit>().toggleTimer(),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius: BorderRadius.circular(30),
                                              border: Border.all(color: AppColors.astrolabeGold),
                                            ),
                                            child: const Text(
                                              "PAUSE",
                                              style: TextStyle(color: AppColors.astrolabeGold, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            context.read<SanctuaryCubit>().resetTimer();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(30),
                                              border: Border.all(color: Colors.redAccent),
                                            ),
                                            child: const Text(
                                              "CANCEL",
                                              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    GestureDetector(
                                      onTap: () => context.read<SanctuaryCubit>().toggleTimer(),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: AppColors.astrolabeGold.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(color: AppColors.astrolabeGold),
                                        ),
                                        child: const Text(
                                          "START FOCUS",
                                          style: TextStyle(color: AppColors.astrolabeGold, fontWeight: FontWeight.bold, letterSpacing: 1),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 20),
                          
                          // Increment Duration Control (+)
                          _buildAdjustmentButton(
                            icon: Icons.add,
                            isEnabled: !state.isTimerRunning && state.timerSeconds > 0,
                            onTap: () => context.read<SanctuaryCubit>().adjustTimer(60), // +1 min
                            onLongPress: () => context.read<SanctuaryCubit>().adjustTimer(300), // +5 mins
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 3. AMBIENT SOUNDS DECK
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text("Ambient Accompaniment", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildSoundCard(context, "Rain on Glass", Icons.water_drop_outlined, state.activeSoundTrack),
                      _buildSoundCard(context, "Espresso Machine", Icons.coffee_maker_outlined, state.activeSoundTrack),
                      _buildSoundCard(context, "Acoustic Oud", Icons.music_note_outlined, state.activeSoundTrack),
                      _buildSoundCard(context, "Library Whispers", Icons.menu_book_outlined, state.activeSoundTrack),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                // 4. QUICK NOTES LOG
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: const BoxDecoration(
                      color: Color(0xFF132826), // Slightly lighter teal
                      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Quick Thoughts & Quotes", style: TextStyle(color: AppColors.astrolabeGold, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.quickNotes.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("• ", style: TextStyle(color: AppColors.astrolabeGold, fontSize: 18)),
                                    Expanded(child: Text(state.quickNotes[index], style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4))),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        TextField(
                          controller: _noteController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Jot down a fleeting thought...",
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: AppColors.primaryTeal.withOpacity(0.5),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send, color: AppColors.astrolabeGold),
                              onPressed: () {
                                context.read<SanctuaryCubit>().addQuickNote(_noteController.text);
                                _noteController.clear();
                              },
                            ),
                          ),
                          onSubmitted: (val) {
                            context.read<SanctuaryCubit>().addQuickNote(val);
                            _noteController.clear();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAdjustmentButton({
    required IconData icon,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
    required bool isEnabled,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: isEnabled ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !isEnabled,
        child: Tooltip(
          message: icon == Icons.add ? "Tap +1m, Hold +5m" : "Tap -1m, Hold -5m",
          child: GestureDetector(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.astrolabeGold, width: 1.5),
                color: AppColors.primaryTeal.withOpacity(0.4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.astrolabeGold.withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.astrolabeGold, size: 20),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSoundCard(BuildContext context, String title, IconData icon, String? activeTrack) {
    final isActive = activeTrack == title;
    return GestureDetector(
      onTap: () => context.read<SanctuaryCubit>().toggleSoundTrack(title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isActive ? AppColors.astrolabeGold.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppColors.astrolabeGold : Colors.white24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? AppColors.astrolabeGold : Colors.white54, size: 28),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: isActive ? AppColors.astrolabeGold : Colors.white54, fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}

// Stylized passport visa granted ink stamp card
class _StampVictoryCard extends StatelessWidget {
  final StampModel stamp;
  final Animation<double> animation;

  const _StampVictoryCard({required this.stamp, required this.animation});

  @override
  Widget build(BuildContext context) {
    int starsReward = 0;
    int mins = 25;
    if (stamp.id == 'ibn_battuta') {
      starsReward = 150;
      mins = 25;
    } else if (stamp.id == 'al_khwarizmi') {
      starsReward = 250;
      mins = 45;
    } else if (stamp.id == 'celestial_navigator') {
      starsReward = 400;
      mins = 60;
    } else if (stamp.id == 'scholar_laureate') {
      starsReward = 600;
      mins = 90;
    }

    return Container(
      width: 310,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF2E6), // Parchment passport page
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.astrolabeGold, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 30,
            spreadRadius: 3,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. PASSPORT SEAL DECAL
          Text(
            "GUILD VISA APPROVED",
            style: TextStyle(
              color: AppColors.primaryTeal.withOpacity(0.5),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 20),

          // 2. BOUNCING SLAM STAMP ANIMATION
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final scale = 2.8 - (animation.value * 1.8);
              final angle = (1.0 - animation.value) * 0.45;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scale(scale)
                  ..rotateZ(angle),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.astrolabeGold, width: 2.5),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.astrolabeGold.withOpacity(0.4), width: 1.5),
                    ),
                    child: Icon(stamp.iconData, color: AppColors.astrolabeGold, size: 40),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 25),

          // 3. STAMP DETAILS
          Text(
            stamp.title.toUpperCase().replaceAll(" STAMP", "").replaceAll(" FOCUS RING", ""),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primaryTeal,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Certified at Abdoun Branch upon fulfilling a $mins-minute deep focus session.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          
          const SizedBox(height: 20),

          // 4. STAR REWARD DISPLAY
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: AppColors.astrolabeGold, size: 16),
                const SizedBox(width: 6),
                Text(
                  "+$starsReward STARS AWARDED",
                  style: const TextStyle(
                    color: AppColors.astrolabeGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // 5. ASTROLABE SIGNATURE ACTION BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: AstrolabeButton(
              label: "COLLECT TO PASSPORT",
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
