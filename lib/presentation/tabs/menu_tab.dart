import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/app_colors.dart';
import '../../domain/entities/menu_item.dart';
import '../cubit/menu/menu_cubit.dart';
import '../cubit/menu/menu_state.dart';
import '../cubit/cart/cart_cubit.dart';

class MenuTab extends StatefulWidget {
  const MenuTab({super.key});

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  // Current selected filter
  String selectedCategory = "Hot";

  // Categories based on your Astrolabe documents
  final List<String> categories = [
    "Hot",
    "Cold",
    "Bakery",
    "Pastries",
    "Salads",
    "Sandwiches"
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuCubit, MenuState>(
      builder: (context, state) {
        if (state is MenuLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MenuError) {
          return Center(child: Text(state.message));
        } else if (state is MenuLoaded) {
          final fullMenu = state.menuItems;
          // Filter logic with null-safety
          final filteredItems = fullMenu
              .where((item) => item.category == selectedCategory)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(25, 20, 25, 0),
                child: Text(
                  "Explore Menu",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ),

              // 1. CATEGORY SELECTOR
              Container(
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final String category = categories[index];
                    bool isSelected = selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() => selectedCategory = category);
                        },
                        selectedColor: AppColors.primaryTeal,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.primaryTeal,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 2. LIST OF ITEMS
              Expanded(
                child: filteredItems.isEmpty
                    ? const Center(
                  child: Text(
                    "No items available in this category.",
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    return _buildMenuListItem(filteredItems[index]);
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMenuListItem(MenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Icon based on category
          _getIconForCategory(item.category),
          const SizedBox(width: 15),

          // Name and Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name, // Non-nullable in model
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description, // Non-nullable in model
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Price column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${item.smallPrice.toStringAsFixed(2)} JOD",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTeal,
                ),
              ),
              if (item.regularPrice != null)
                Text(
                  "Reg: ${item.regularPrice!.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textGrey,
                  ),
                ),
              const SizedBox(height: 5),
              InkWell(
                onTap: () {
                  context.read<CartCubit>().addItem(item);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${item.name} added to cart!"), duration: const Duration(seconds: 1)));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.astrolabeGold.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Text("+ Add", style: TextStyle(color: AppColors.astrolabeGold, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getIconForCategory(String category) {
    IconData icon;
    switch (category) {
      case "Hot": icon = Icons.coffee; break;
      case "Cold": icon = Icons.icecream_outlined; break;
      case "Bakery": icon = Icons.bakery_dining; break;
      case "Pastries": icon = Icons.cake_outlined; break;
      case "Salads": icon = Icons.flatware_rounded; break;
      case "Sandwiches": icon = Icons.layers_outlined; break;
      default: icon = Icons.restaurant;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.astrolabeGold.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.astrolabeGold, size: 24),
    );
  }
}