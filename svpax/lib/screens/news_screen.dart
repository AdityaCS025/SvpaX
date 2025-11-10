import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  Future<void> _launchUrl(String? url) async {
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final pastelColors = [
      Color(0xFFFFC7C7),
      Color(0xFFB5FFD9),
      Color(0xFFFFF6B7),
      Color(0xFF7C83FD).withOpacity(0.15),
    ];

    // Fetch news when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (newsProvider.articles.isEmpty && !newsProvider.isLoading) {
        newsProvider.getNewsHeadlines();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => newsProvider.getNewsHeadlines(),
          ),
          PopupMenuButton<String>(
            onSelected: (String category) {
              newsProvider.getNewsHeadlines(category: category);
            },
            itemBuilder: (BuildContext context) {
              return [
                'general',
                'business',
                'technology',
                'science',
                'health',
                'sports',
                'entertainment',
              ].map((String category) {
                return PopupMenuItem<String>(
                  value: category,
                  child: Text(category.toUpperCase()),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: newsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : newsProvider.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      'Error: ${newsProvider.error}',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => newsProvider.getNewsHeadlines(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C83FD),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : newsProvider.articles.isEmpty
          ? const Center(child: Text('No news articles available'))
          : ListView.builder(
              itemCount: newsProvider.articles.length,
              itemBuilder: (context, index) {
                final article = newsProvider.articles[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.grey.shade900, Colors.black],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade800, width: 1),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: article.urlToImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              article.urlToImage!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.article_rounded,
                                    color: Colors.white70,
                                    size: 40,
                                  ),
                            ),
                          )
                        : const Icon(
                            Icons.article_rounded,
                            color: Colors.white70,
                            size: 40,
                          ),
                    title: Text(
                      article.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article.description != null)
                          Text(
                            article.description!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 14,
                              height: 1.3,
                            ),
                          ),
                        const SizedBox(height: 6),
                        Text(
                          article.source ?? 'Unknown Source',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      if (article.url != null) {
                        final uri = Uri.parse(article.url!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
