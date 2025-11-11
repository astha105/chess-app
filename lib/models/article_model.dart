class Article {
  final String title;
  final String description;
  final String url;
  final String? imageUrl;
  final DateTime publishedAt;

  Article({
    required this.title,
    required this.description,
    required this.url,
    this.imageUrl,
    required this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'],
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
