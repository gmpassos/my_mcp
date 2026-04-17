import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:mcp_dart/mcp_dart.dart';

import 'base_tool.dart';

/// Searches Google Scholar (scraped, no API key).
class GoogleScholarTool extends BaseTool {
  @override
  String get name => 'google_scholar';

  @override
  ToolAnnotations? get annotations => ToolAnnotations(
        title: 'Google Scholar search',
        openWorldHint: true,
        readOnlyHint: true,
      );

  @override
  String get description =>
      'Searches Google Scholar and returns academic articles with titles, authors, year, and links. '
      'No API key required (HTML scraping).';

  @override
  ToolInputSchema get inputSchema => ToolInputSchema(
        properties: {
          'query': JsonSchema.string(
            description: 'Search query (e.g. "transformer neural networks")',
          ),
          'limit': JsonSchema.number(
            description: 'Number of results (default: 5)',
          ),
        },
        required: ['query'],
      );

  @override
  ToolOutputSchema? get outputSchema => ToolOutputSchema(
        properties: {
          'results': JsonSchema.array(
            items: JsonSchema.object(
              properties: {
                'title': JsonSchema.string(),
                'authors': JsonSchema.string(),
                'year': JsonSchema.string(),
                'url': JsonSchema.string(),
                'snippet': JsonSchema.string(),
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
    logger.info("google_scholar> $args");

    final query = args['query'] as String;
    final limit = (args['limit'] as num?)?.toInt() ?? 5;

    final uri = Uri.https('scholar.google.com', '/scholar', {
      'q': query,
      'hl': 'en',
    });

    final response = await http.get(
      uri,
      headers: {
        // Important: mimic browser
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)',
      },
    );

    final document = html.parse(response.body);
    final entries = document.querySelectorAll('.gs_ri');

    final results = <Map<String, dynamic>>[];

    for (final entry in entries.take(limit)) {
      final titleEl = entry.querySelector('.gs_rt');
      final linkEl = titleEl?.querySelector('a');
      final metaEl = entry.querySelector('.gs_a');
      final snippetEl = entry.querySelector('.gs_rs');

      final title = titleEl?.text.trim() ?? '';
      final url = linkEl?.attributes['href'] ?? '';
      final meta = metaEl?.text ?? '';
      final snippet = snippetEl?.text.trim() ?? '';

      // Extract year (simple regex)
      final yearMatch = RegExp(r'\b(19|20)\d{2}\b').firstMatch(meta);
      final year = yearMatch?.group(0) ?? '';

      results.add({
        'title': title,
        'authors': meta,
        'year': year,
        'url': url,
        'snippet': snippet,
      });
    }

    logger.info("google_scholar.response> ${results.length} items");

    return CallToolResult.fromStructuredContent({
      'results': results,
    });
  }
}
