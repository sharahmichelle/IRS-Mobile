class News {
  final String id;
  final String title;
  final String content;
  final DateTime publishedAt;
  final String author;
  final String category;
  final bool isActive;
  final String? imageUrl;   // Optional header image (Supabase Storage URL or external)
  final String? sourceUrl; // Optional hyperlink to the original news outlet

  News({
    this.id = '',
    required this.title,
    required this.content,
    DateTime? publishedAt,
    required this.author,
    this.category = 'general',
    this.isActive = true,
    this.imageUrl,
    this.sourceUrl,
  }) : publishedAt = publishedAt ?? DateTime.now();

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'])
          : DateTime.now(),
      author: json['author'] ?? '',
      category: json['category'] ?? 'general',
      isActive: json['is_active'] ?? true,
      imageUrl: json['image_url'],
      sourceUrl: json['source_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'published_at': publishedAt.toIso8601String(),
      'author': author,
      'category': category,
      'is_active': isActive,
      'image_url': imageUrl,
      'source_url': sourceUrl,
    };
  }
}