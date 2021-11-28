class Recipe {
  final String id;
  final category;
  final String title;
  final String subtitle;

  final String steps;

  const Recipe({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.steps,
  });
}

class Category {
  final String category;
  final String title;
  final String image;
  final String description;

  const Category({
    required this.category,
    required this.title,
    required this.image,
    required this.description,
  });
}
