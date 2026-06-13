import '../../domain/entities/cart_item.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/repositories/i_cart_repository.dart';

class CartRepositoryImpl implements ICartRepository {
  final List<CartItem> _items = [];

  @override
  Future<List<CartItem>> getCartItems() async {
    return List.from(_items); // Return a copy
  }

  @override
  Future<void> addToCart(MenuItem item) async {
    final index = _items.indexWhere((element) => element.menuItem.name == item.name);
    if (index != -1) {
      _items[index].quantity += 1;
    } else {
      _items.add(CartItem(menuItem: item, quantity: 1));
    }
  }

  @override
  Future<void> removeFromCart(MenuItem item) async {
    final index = _items.indexWhere((element) => element.menuItem.name == item.name);
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity -= 1;
      } else {
        _items.removeAt(index);
      }
    }
  }

  @override
  Future<void> clearCart() async {
    _items.clear();
  }
}
