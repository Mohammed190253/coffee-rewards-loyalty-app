enum DiningOption { pickup, delivery, dineIn }

class OrderDetails {
  // Pickup fields
  final String? branchName;
  final String? pickupTime;

  // Delivery fields
  final String? address;
  final String? contactNumber;

  // Dine-in fields
  final String? tableNumber;

  const OrderDetails({
    this.branchName,
    this.pickupTime,
    this.address,
    this.contactNumber,
    this.tableNumber,
  });

  OrderDetails copyWith({
    String? branchName,
    String? pickupTime,
    String? address,
    String? contactNumber,
    String? tableNumber,
  }) {
    return OrderDetails(
      branchName: branchName ?? this.branchName,
      pickupTime: pickupTime ?? this.pickupTime,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      tableNumber: tableNumber ?? this.tableNumber,
    );
  }
}
