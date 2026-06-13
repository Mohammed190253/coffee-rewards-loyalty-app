import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/app_colors.dart';
import 'cubit/cart/cart_cubit.dart';
import 'cubit/cart/cart_state.dart';
import 'cubit/dashboard/dashboard_cubit.dart';
import 'cubit/dashboard/dashboard_state.dart';
import '../../../domain/entities/order_details.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Controllers for dynamic form inputs
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _tableController = TextEditingController();

  @override
  void dispose() {
    _branchController.dispose();
    _timeController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _tableController.dispose();
    super.dispose();
  }

  void _updateOrderDetails(BuildContext context, DiningOption option) {
    final details = OrderDetails(
      branchName: option == DiningOption.pickup ? _branchController.text : null,
      pickupTime: option == DiningOption.pickup ? _timeController.text : null,
      address: option == DiningOption.delivery ? _addressController.text : null,
      contactNumber: option == DiningOption.delivery ? _contactController.text : null,
      tableNumber: option == DiningOption.dineIn ? _tableController.text : null,
    );
    context.read<CartCubit>().updateOrderDetails(details);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, dashboardState) {
        final isScholar = dashboardState.isScholarMode;
        final bgColor = AppColors.getBackground(isScholar);
        final textColor = isScholar ? Colors.white : AppColors.primaryTeal;
        final cardColor = isScholar ? AppColors.scholarCard : AppColors.surfaceWhite;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text("Checkout", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: textColor),
          ),
          body: BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              if (cartState is CartLoaded) {
                if (cartState.items.isEmpty) {
                  return Center(child: Text("Your cart is empty.", style: TextStyle(color: AppColors.textGrey, fontSize: 16)));
                }
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. DINING OPTION SELECTOR
                            Text("Dining Option", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 15),
                            _buildOptionSelector(context, cartState.diningOption, isScholar),
                            const SizedBox(height: 25),

                            // 2. DYNAMIC INPUT FORM
                            _buildDynamicForm(context, cartState.diningOption, cardColor, textColor),
                            const SizedBox(height: 30),

                            // 3. CART ITEMS SUMMARY
                            Text("Order Summary", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 15),
                            ...cartState.items.map((cartItem) => Container(
                                  margin: const EdgeInsets.only(bottom: 15),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(cartItem.menuItem.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                                            const SizedBox(height: 5),
                                            Text("${cartItem.menuItem.smallPrice.toStringAsFixed(2)} JOD", style: const TextStyle(color: AppColors.textGrey)),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(icon: const Icon(Icons.remove_circle_outline, color: AppColors.astrolabeGold), onPressed: () => context.read<CartCubit>().removeItem(cartItem.menuItem)),
                                          Text("${cartItem.quantity}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                                          IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.astrolabeGold), onPressed: () => context.read<CartCubit>().addItem(cartItem.menuItem)),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),

                    // 4. CHECKOUT BAR
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total", style: TextStyle(fontSize: 18, color: AppColors.textGrey)),
                              Text("${cartState.totalPrice.toStringAsFixed(2)} JOD", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textColor)),
                            ],
                          ),
                          const SizedBox(height: 25),
                          AstrolabeButton(
                            label: "Place Order",
                            onPressed: () {
                              context.read<CartCubit>().checkout();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: const Text("Order placed successfully!"),
                                backgroundColor: AppColors.primaryTeal,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ));
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator(color: AppColors.astrolabeGold));
            },
          ),
        );
      },
    );
  }

  Widget _buildOptionSelector(BuildContext context, DiningOption selectedOption, bool isScholar) {
    return Row(
      children: [
        _buildOptionCard(context, DiningOption.pickup, "Pickup", Icons.storefront, selectedOption, isScholar),
        const SizedBox(width: 10),
        _buildOptionCard(context, DiningOption.delivery, "Delivery", Icons.pedal_bike, selectedOption, isScholar),
        const SizedBox(width: 10),
        _buildOptionCard(context, DiningOption.dineIn, "Dine-in", Icons.event_seat, selectedOption, isScholar),
      ],
    );
  }

  Widget _buildOptionCard(BuildContext context, DiningOption option, String title, IconData icon, DiningOption selectedOption, bool isScholar) {
    final isSelected = option == selectedOption;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<CartCubit>().selectDiningOption(option),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.astrolabeGold : (isScholar ? AppColors.scholarCard : AppColors.surfaceWhite),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? AppColors.astrolabeGold : Colors.transparent),
            boxShadow: isSelected ? [BoxShadow(color: AppColors.astrolabeGold.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))] : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primaryTeal : AppColors.textGrey, size: 24),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(
                color: isSelected ? AppColors.primaryTeal : AppColors.textGrey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicForm(BuildContext context, DiningOption option, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (option == DiningOption.pickup) ...[
            _buildTextField("Branch Name", Icons.store, _branchController, textColor, () => _updateOrderDetails(context, option)),
            const SizedBox(height: 15),
            _buildTextField("Estimated Pickup Time", Icons.access_time, _timeController, textColor, () => _updateOrderDetails(context, option)),
          ],
          if (option == DiningOption.delivery) ...[
            _buildTextField("Delivery Address", Icons.location_on, _addressController, textColor, () => _updateOrderDetails(context, option)),
            const SizedBox(height: 15),
            _buildTextField("Contact Number", Icons.phone, _contactController, textColor, () => _updateOrderDetails(context, option)),
          ],
          if (option == DiningOption.dineIn) ...[
            _buildTextField("Table Number", Icons.tag, _tableController, textColor, () => _updateOrderDetails(context, option)),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller, Color textColor, VoidCallback onChanged) {
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textGrey),
        prefixIcon: Icon(icon, color: AppColors.astrolabeGold),
        filled: true,
        fillColor: textColor.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
