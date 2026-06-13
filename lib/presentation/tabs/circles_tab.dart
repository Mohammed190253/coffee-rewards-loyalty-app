import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/app_colors.dart';
import '../../domain/entities/event_circle.dart';
import '../cubit/event/event_cubit.dart';
import '../cubit/event/event_state.dart';
import '../cubit/user/user_cubit.dart';
import '../cubit/user/user_state.dart';
import '../ticket_screen.dart';

class CirclesTab extends StatelessWidget {
  const CirclesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCubit, EventState>(
      builder: (context, state) {
        if (state is EventLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal));
        } else if (state is EventError) {
          return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
        } else if (state is EventLoaded) {
          final events = state.events;
          return SingleChildScrollView(
            padding: const EdgeInsets.only(left: 25, right: 25, top: 25, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Experience Circles",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
                ),
                const Text(
                  "Connect with Jordan's community of thinkers and artists.",
                  style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                ),
                const SizedBox(height: 25),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: events.length,
                  itemBuilder: (context, index) => _buildEventCard(context, events[index]),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEventCard(BuildContext context, EventCircle event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              image: DecorationImage(image: NetworkImage(event.imagePath), fit: BoxFit.cover),
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
                    Text(
                      event.title.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.astrolabeGold,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: 11,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: event.isFree ? Colors.green[50] : AppColors.primaryTeal.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        event.isFree ? "FREE" : "${event.ticketPrice.toStringAsFixed(2)} JOD",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: event.isFree ? Colors.green[700] : AppColors.primaryTeal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(event.topic, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.primaryTeal)),
                const SizedBox(height: 10),
                
                // Capacity Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Available Seats",
                          style: TextStyle(color: AppColors.textGrey, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "${event.joinedCount} / ${event.maxCapacity} chairs taken",
                          style: TextStyle(
                            color: event.joinedCount >= event.maxCapacity ? Colors.red : AppColors.primaryTeal,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: event.maxCapacity > 0 ? event.joinedCount / event.maxCapacity : 0.0,
                        backgroundColor: Colors.grey[100],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          event.joinedCount >= event.maxCapacity ? Colors.red : AppColors.astrolabeGold,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: AppColors.textGrey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "${event.date} at ${event.time}",
                        style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Conditional Button Builder
                    _buildConditionalActionButton(context, event),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionalActionButton(BuildContext context, EventCircle event) {
    // Case C: User HAS already booked (Paid or Free)
    if (event.isBookedByUser) {
      return OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TicketScreen(event: event),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.astrolabeGold,
          side: const BorderSide(color: AppColors.astrolabeGold, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        icon: const Icon(Icons.qr_code_scanner, size: 16, color: AppColors.astrolabeGold),
        label: const Text(
          "View Digital Ticket",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      );
    }

    // Check if event is already fully booked
    if (event.joinedCount >= event.maxCapacity) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        child: const Text("Sold Out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      );
    }

    // Case B: User has NOT booked yet AND the event is FREE
    if (event.isFree) {
      return ElevatedButton.icon(
        onPressed: () {
          context.read<EventCubit>().bookEvent(event.title);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.primaryTeal,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              content: Text("Seat reserved successfully for ${event.title}!"),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          elevation: 0,
        ),
        icon: const Icon(Icons.bookmark_added_outlined, size: 16, color: Colors.white),
        label: const Text(
          "Reserve Free Seat",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      );
    }

    // Case A: User has NOT booked yet AND the event is PAID
    return ElevatedButton.icon(
      onPressed: () => _showPaymentSheet(context, event),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 0,
      ),
      icon: const Icon(Icons.payment, size: 16, color: Colors.white),
      label: const Text(
        "Pay & Book Chair",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  void _showPaymentSheet(BuildContext context, EventCircle event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isProcessing = false;
            bool isSuccess = false;

            return BlocBuilder<UserCubit, UserState>(
              builder: (context, userState) {
                if (userState is UserLoading) {
                  return Container(
                    height: 350,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal)),
                  );
                } else if (userState is UserLoaded) {
                  final user = userState.user;
                  final canAfford = user.walletBalance >= event.ticketPrice;

                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    padding: EdgeInsets.only(
                      left: 30,
                      right: 30,
                      top: 30,
                      bottom: 30 + MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        if (!isProcessing && !isSuccess) ...[
                          const Text(
                            "Secure Chair Booking",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Confirm ticket purchase for ${event.title}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                          ),
                          const SizedBox(height: 25),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundBeige,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Circle Event:", style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                                    Expanded(
                                      child: Text(
                                        event.title,
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryTeal, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Location Branch:", style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                                    Text(event.location, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryTeal, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                const Divider(height: 1),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Ticket Price:", style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                                    Text(
                                      "${event.ticketPrice.toStringAsFixed(2)} JOD",
                                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryTeal, fontSize: 18),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Astrolabe Wallet Balance:", style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                                    Text(
                                      "${user.walletBalance.toStringAsFixed(2)} JOD",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: canAfford ? AppColors.astrolabeGold : Colors.red,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          if (canAfford)
                            ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  isProcessing = true;
                                });
                                // Simulate payment gateway validation delay
                                await Future.delayed(const Duration(milliseconds: 1500));
                                setState(() {
                                  isProcessing = false;
                                  isSuccess = true;
                                });
                                await Future.delayed(const Duration(milliseconds: 800));
                                
                                if (context.mounted) {
                                  // Trigger states mutations
                                  context.read<UserCubit>().deductWallet(event.ticketPrice);
                                  context.read<EventCubit>().bookEvent(event.title);
                                  Navigator.pop(bottomSheetContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppColors.primaryTeal,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      content: Text("Chair locked successfully! Ticket issued."),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryTeal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                              ),
                              child: const Text("Confirm & Pay JOD", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            )
                          else ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red[100]!),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red, size: 18),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Insufficient wallet balance. Please top up your profile wallet.",
                                      style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(bottomSheetContext),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                foregroundColor: AppColors.primaryTeal,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                              ),
                              child: const Text("Close", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ] else if (isProcessing) ...[
                          const SizedBox(height: 50),
                          const Center(
                            child: CircularProgressIndicator(color: AppColors.astrolabeGold, strokeWidth: 3),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Securing your chair...",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.primaryTeal, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            "Processing ticket transaction through Astrolabe Pay...",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                          ),
                          const SizedBox(height: 50),
                        ] else if (isSuccess) ...[
                          const SizedBox(height: 40),
                          const Center(
                            child: Icon(Icons.verified, color: Colors.green, size: 70),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Transaction Verified!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.primaryTeal, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Your payment has cleared. View ticket in Circles.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
        );
      },
    );
  }
}