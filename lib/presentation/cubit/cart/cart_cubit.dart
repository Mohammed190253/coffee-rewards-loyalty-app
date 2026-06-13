import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/menu_item.dart';
import '../../../domain/repositories/i_cart_repository.dart';
import '../../../domain/entities/order_details.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final ICartRepository _cartRepository;

  CartCubit(this._cartRepository) : super(CartInitial());

  Future<void> loadCart() async {
    final currentState = state;
    DiningOption currentOption = DiningOption.pickup;
    OrderDetails currentDetails = const OrderDetails();

    if (currentState is CartLoaded) {
      currentOption = currentState.diningOption;
      currentDetails = currentState.orderDetails;
    } else {
      emit(CartLoading());
    }

    try {
      final items = await _cartRepository.getCartItems();
      emit(CartLoaded(
        items,
        diningOption: currentOption,
        orderDetails: currentDetails,
      ));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  void selectDiningOption(DiningOption option) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(currentState.copyWith(diningOption: option));
    }
  }

  void updateOrderDetails(OrderDetails details) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(currentState.copyWith(orderDetails: details));
    }
  }

  Future<void> addItem(MenuItem item) async {
    await _cartRepository.addToCart(item);
    loadCart();
  }

  Future<void> removeItem(MenuItem item) async {
    await _cartRepository.removeFromCart(item);
    loadCart();
  }

  Future<void> checkout() async {
    // In a real app, this is where you'd send the CartItems AND OrderDetails to the backend
    await _cartRepository.clearCart();
    
    // Reset to initial state with empty cart and default options
    emit(const CartLoaded([], diningOption: DiningOption.pickup, orderDetails: OrderDetails()));
  }
}
