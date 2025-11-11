import 'package:flutter/material.dart';
import '../models/article_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
        backgroundColor: const Color(0xFF2B2928),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null)
              Image.network(article.imageUrl!),
            const SizedBox(height: 12),
            Text(article.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Published at: ${article.publishedAt}'),
            const SizedBox(height: 12),
            Text(article.description),
            const Spacer(),
            ElevatedButton(
              onPressed: () => launchUrl(Uri.parse(article.url)),
              child: const Text('Read Full Article'),
            ),
          ],
        ),
      ),
    );
  }
}
