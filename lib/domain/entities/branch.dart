class Branch {
  final String name;
  final String location;
  final String imagePath;
  final String busynessLevel; // e.g., "Quiet", "Moderate", "Busy"
  final bool hasQuietZone;

  Branch({
    required this.name,
    required this.location,
    required this.imagePath,
    required this.busynessLevel,
    required this.hasQuietZone,
  });
}
