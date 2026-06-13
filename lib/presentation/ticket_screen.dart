import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/app_colors.dart';
import '../../domain/entities/event_circle.dart';
import 'cubit/event/event_cubit.dart';
import 'cubit/event/event_state.dart';
import 'cubit/user/user_cubit.dart';
import 'cubit/user/user_state.dart';

class TicketScreen extends StatefulWidget {
  final EventCircle event;

  const TicketScreen({super.key, required this.event});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  bool _isScanning = false;
  bool _isTicketCheckedIn = false;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  void _simulateWorkerScan(BuildContext context, String eventTitle) {
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
    });
    
    // Repeat animation up and down during the scan simulation
    _laserController.repeat(reverse: true);

    // Stop scan and confirm attendance after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _laserController.stop();
        setState(() {
          _isScanning = false;
          _isTicketCheckedIn = true;
        });

        // Trigger Cubit attendance confirmation
        context.read<EventCubit>().confirmScan(eventTitle);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.astrolabeGold,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.primaryTeal),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Worker scan validated! Attendance recorded for $eventTitle.",
                    style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryTeal,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "DIGITAL PASS",
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 3),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, userState) {
          String userName = "GUEST";
          String userId = "000000";
          if (userState is UserLoaded) {
            userName = userState.user.name;
            // Parse numeric ID from "USER_84920394_ASTRO" or similar
            userId = userState.user.qrCodeData
                .replaceAll("USER_", "")
                .replaceAll("_ASTRO", "");
          }

          // Strict String payload: "ASTRO_CHECKIN_[EventTitle]_u[UserID]"
          final qrPayload = "ASTRO_CHECKIN_${widget.event.title}_u$userId";

          return BlocBuilder<EventCubit, EventState>(
            builder: (context, eventState) {
              // Find the live updated event from cubit to show live scanned counts
              EventCircle liveEvent = widget.event;
              if (eventState is EventLoaded) {
                final found = eventState.events.firstWhere((e) => e.title == widget.event.title, orElse: () => widget.event);
                liveEvent = found;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                child: Column(
                  children: [
                    // Main Ticket Design Container
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top Section: Header
                          Padding(
                            padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
                            child: Column(
                              children: [
                                Text(
                                  liveEvent.title.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.astrolabeGold,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  liveEvent.topic,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryTeal,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),

                          // QR code wrapper with live scanning animation
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: Colors.grey[100]!),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 8,
                                    )
                                  ],
                                ),
                                child: QrImageView(
                                  data: qrPayload,
                                  version: QrVersions.auto,
                                  size: 190.0,
                                  foregroundColor: AppColors.primaryTeal,
                                ),
                              ),
                              
                              // Glowing laser animation overlay
                              if (_isScanning)
                                AnimatedBuilder(
                                  animation: _laserController,
                                  builder: (context, child) {
                                    return Positioned(
                                      top: 15 + (_laserController.value * 190),
                                      left: 15,
                                      right: 15,
                                      child: Container(
                                        height: 3,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.red.withOpacity(0.8),
                                              blurRadius: 10,
                                              spreadRadius: 2.5,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          // Ticket Details
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Column(
                              children: [
                                const Divider(height: 1),
                                const SizedBox(height: 20),
                                _ticketInfoRow("VOYAGER PASSENGER", userName),
                                const SizedBox(height: 12),
                                _ticketInfoRow("VOYAGER ID", userId),
                                const SizedBox(height: 12),
                                _ticketInfoRow("DATE & TIME", "${liveEvent.date} @ ${liveEvent.time}"),
                                const SizedBox(height: 12),
                                _ticketInfoRow("LOCATION", liveEvent.location),
                                const SizedBox(height: 12),
                                _ticketInfoRow(
                                  "TICKET STATUS", 
                                  _isTicketCheckedIn ? "CONFIRMED & CHECKED IN" : "RESERVED (PENDING SCAN)",
                                  customColor: _isTicketCheckedIn ? Colors.green[700] : AppColors.astrolabeGold,
                                ),
                                const SizedBox(height: 25),
                              ],
                            ),
                          ),
                          
                          // Decorative Dotted Ticket Cutout
                          Row(
                            children: List.generate(
                              20,
                              (index) => Expanded(
                                child: Container(
                                  color: index.isEven ? Colors.transparent : Colors.grey[200],
                                  height: 2,
                                ),
                              ),
                            ),
                          ),

                          // Bottom instructions section
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundBeige.withOpacity(0.5),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outline, size: 14, color: AppColors.textGrey),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Present this celestial QR pass to the barista or branch coordinator upon arrival.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.textGrey, fontSize: 11, height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Staff check-in controller & real-time analytics panel
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.astrolabeGold.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.analytics_outlined, color: AppColors.astrolabeGold, size: 18),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Staff Scanning Simulator",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          
                          // Real-time confirmed attendee metric gauge
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "CONFIRMED CHECK-INS",
                                      style: TextStyle(color: AppColors.textGrey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${liveEvent.confirmedAttendeeCount} / ${liveEvent.joinedCount} checked in",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _isTicketCheckedIn ? Colors.green.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _isTicketCheckedIn ? Colors.green[400]! : Colors.amber[400]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    _isTicketCheckedIn ? "SCANNED" : "PENDING",
                                    style: TextStyle(
                                      color: _isTicketCheckedIn ? Colors.green[300] : Colors.amber[300],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          
                          // Trigger scanner button
                          ElevatedButton.icon(
                            onPressed: _isTicketCheckedIn || _isScanning 
                                ? null 
                                : () => _simulateWorkerScan(context, liveEvent.title),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.astrolabeGold,
                              foregroundColor: AppColors.primaryTeal,
                              disabledBackgroundColor: Colors.white.withOpacity(0.12),
                              disabledForegroundColor: Colors.white.withOpacity(0.3),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            icon: _isScanning 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryTeal,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    _isTicketCheckedIn ? Icons.verified_user : Icons.camera_alt_outlined, 
                                    size: 18,
                                  ),
                            label: Text(
                              _isScanning 
                                  ? "Scanning Ticket Code..." 
                                  : _isTicketCheckedIn 
                                      ? "Ticket Verification Complete" 
                                      : "Simulate Worker Check-In Scan",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _ticketInfoRow(String label, String value, {Color? customColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label, 
          style: const TextStyle(color: AppColors.textGrey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        Text(
          value, 
          style: TextStyle(
            color: customColor ?? AppColors.primaryTeal, 
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}