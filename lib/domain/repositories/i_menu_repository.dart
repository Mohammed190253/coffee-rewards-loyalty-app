import '../entities/menu_item.dart';

abstract class IMenuRepository {
  Future<List<MenuItem>> getAstrolabeMenu();
  Future<List<MenuItem>> getRecommendedItems();
}
