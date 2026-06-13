class MenuItem {
  final String name;
  final String description;
  final double smallPrice;
  final double? regularPrice;
  final String category;

  MenuItem({
    required this.name,
    required this.description,
    required this.smallPrice,
    this.regularPrice,
    required this.category,
  });
}
