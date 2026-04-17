import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mcp_dart/mcp_dart.dart';

import 'base_tool.dart';

/// Searches Wikipedia and returns summarized results.
class WikipediaSearchTool extends BaseTool {
  @override
  String get name => 'wikipedia_search';

  @override
  ToolAnnotations? get annotations => ToolAnnotations(
      title: 'wikipedia.org search', openWorldHint: true, readOnlyHint: true);

  @override
  String get description =>
      'Searches Wikipedia and returns a list of matching articles with summaries and URLs to pages with more information';

  @override
  ToolInputSchema get inputSchema => ToolInputSchema(
        properties: {
          'query': JsonSchema.string(description: 'Search query'),
          'limit': JsonSchema.number(
            description: 'Number of results (default: 5)',
          ),
          'lang': JsonSchema.string(
            description: 'Wikipedia language (ISO code, e.g. en, pt, fr, es). '
                'MUST match the language of the `query` parameter. Default: en',
          ),
        },
        required: ['query'],
      );

  @override
  ToolOutputSchema? get outputSchema => ToolOutputSchema(
        properties: {
          'results': JsonSchema.array(
            description: 'List of search results',
            items: JsonSchema.object(
              properties: {
                'title': JsonSchema.string(),
                'snippet': JsonSchema.string(),
                'url': JsonSchema.string(),
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
    logger.info("wikipedia_search> $args");

    final query = args['query'] as String;
    final limit = (args['limit'] as num?)?.toInt() ?? 5;
    final lang = (args['lang'] as String?) ?? 'en';

    final uri = Uri.https('$lang.wikipedia.org', '/w/api.php', {
      'action': 'query',
      'list': 'search',
      'srsearch': query,
      'format': 'json',
      'srlimit': '$limit',
    });

    final response = await http.get(uri);

    final data = jsonDecode(response.body);
    final search = data['query']?['search'] as List? ?? [];

    final results = search.map((item) {
      final title = item['title'] as String;
      final snippet = cleanSnippet(item['snippet'] as String);
      final url =
          'https://$lang.wikipedia.org/wiki/${Uri.encodeComponent(title)}';

      return {
        'title': title,
        'snippet': snippet,
        'url': url,
      };
    }).toList();

    logger.info("wikipedia_search.response> $results");

    return CallToolResult.fromStructuredContent({
      'results': results,
    });
  }
}
