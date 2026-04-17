import 'package:http/http.dart' as http;
import 'package:mcp_dart/mcp_dart.dart';
import 'package:xml/xml.dart';

import 'base_tool.dart';

/// Fetches news from Google News RSS (no API key required).
class GoogleNewsTool extends BaseTool {
  @override
  String get name => 'google_news';

  @override
  ToolAnnotations? get annotations => ToolAnnotations(
        title: 'Google News RSS',
        openWorldHint: true,
        readOnlyHint: true,
      );

  @override
  String get description =>
      'Fetches news articles from Google News RSS by query, country, and language. '
      'Supports time filtering and returns titles, sources, dates, and URLs.';

  @override
  ToolInputSchema get inputSchema => ToolInputSchema(
        properties: {
          'query': JsonSchema.string(
            description: 'Search query (e.g. "artificial intelligence")',
          ),
          'country': JsonSchema.string(
            description: 'Country code (e.g. US, BR, GB). Default: US',
          ),
          'language': JsonSchema.string(
            description: 'Language code (e.g. en, pt-BR). Default: en-US',
          ),
          'freshness': JsonSchema.string(
            description: 'Time filter: 1h, 1d, 7d (optional)',
          ),
        },
        required: [],
      );

  @override
  ToolOutputSchema? get outputSchema => ToolOutputSchema(
        properties: {
          'results': JsonSchema.array(
            description: 'List of news articles',
            items: JsonSchema.object(
              properties: {
                'title': JsonSchema.string(),
                'source': JsonSchema.string(),
                'url': JsonSchema.string(),
                'publishedAt': JsonSchema.string(),
              },
            ),
          ),
        },
      );

  @override
  Future<CallToolResult> execute(
    Map<String, dynamic> args,
    RequestHandlerExtra? extra,
  ) async {
    logger.info("google_news> $args");

    final query = args['query'] as String?;
    final country = (args['country'] as String?) ?? 'US';
    final language = (args['language'] as String?) ?? 'en-US';
    final freshness = args['freshness'] as String?;

    final ceidLang = language.split('-').first;
    final ceid = '$country:$ceidLang';

    String? q;
    if (query != null && query.isNotEmpty) {
      q = query;
      if (freshness != null) {
        q += ' when:$freshness';
      }
    }

    final uri = Uri.https(
      'news.google.com',
      query != null ? '/rss/search' : '/rss',
      {
        if (q != null) 'q': q,
        'hl': language,
        'gl': country,
        'ceid': ceid,
      },
    );

    final response = await http.get(uri);

    final xml = XmlDocument.parse(response.body);
    final items = xml.findAllElements('item');

    final results = items.map((item) {
      final title = item.getElement('title')?.innerText ?? '';
      final link = item.getElement('link')?.innerText ?? '';
      final pubDate = item.getElement('pubDate')?.innerText ?? '';

      // Google puts source inside title like: "Title - Source"
      String cleanTitle = title;
      String source = '';

      final parts = title.split(' - ');
      if (parts.length > 1) {
        cleanTitle = parts.first;
        source = parts.last;
      }

      return {
        'title': cleanTitle,
        'source': source,
        'url': link,
        'publishedAt': pubDate,
      };
    }).toList();

    logger.info("google_news.response> ${results.length} items");

    return CallToolResult.fromStructuredContent({
      'results': results,
    });
  }
}
