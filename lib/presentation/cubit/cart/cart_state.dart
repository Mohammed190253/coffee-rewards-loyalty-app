import 'package:equatable/equatable.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/order_details.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;
  final DiningOption diningOption;
  final OrderDetails orderDetails;
  
  const CartLoaded(
    this.items, {
    this.diningOption = DiningOption.pickup,
    this.orderDetails = const OrderDetails(),
  });
  
  double get totalPrice => items.fold(0, (sum, item) => sum + item.totalPrice);
  
  CartLoaded copyWith({
    List<CartItem>? items,
    DiningOption? diningOption,
    OrderDetails? orderDetails,
  }) {
    return CartLoaded(
      items ?? this.items,
      diningOption: diningOption ?? this.diningOption,
      orderDetails: orderDetails ?? this.orderDetails,
    );
  }

  @override
  List<Object?> get props => [items, diningOption, orderDetails];
}

class CartError extends CartState {
  final String message;
  
  const CartError(this.message);
  
  @override
  List<Object> get props => [message];
}
