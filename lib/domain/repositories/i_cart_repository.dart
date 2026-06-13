import '../entities/cart_item.dart';
import '../entities/menu_item.dart';

abstract class ICartRepository {
  Future<List<CartItem>> getCartItems();
  Future<void> addToCart(MenuItem item);
  Future<void> removeFromCart(MenuItem item);
  Future<void> clearCart();
}
