import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mcp_dart/mcp_dart.dart';

import 'base_tool.dart';

/// Searches pub.dev and returns a list of Dart/Flutter packages.
class PubDevSearchTool extends BaseTool {
  @override
  String get name => 'pubdev_search';

  @override
  String get description =>
      'Searches pub.dev for Dart and Flutter packages. Returns matching packages with metadata including name, description, latest version, popularity, and score. '
      'Use this tool to find libraries, plugins, and dependencies for Dart or Flutter projects.';

  @override
  ToolInputSchema get inputSchema => ToolInputSchema(
        properties: {
          'query': JsonSchema.string(description: 'Search query'),
          'limit': JsonSchema.number(
            description: 'Number of results (default: 5)',
          ),
          'page': JsonSchema.number(
            description: 'Page number (default: 1)',
          ),
        },
        required: ['query'],
      );

  @override
  ToolOutputSchema? get outputSchema => ToolOutputSchema(
        properties: {
          'results': JsonSchema.array(
            description: 'List of package results',
            items: JsonSchema.object(
              properties: {
                'name': JsonSchema.string(),
                'description': JsonSchema.string(),
                'latest_version': JsonSchema.string(),
                'url': JsonSchema.string(),
              },
            ),
          ),
          'next': JsonSchema.string(
            description: 'Next page URL (if available)',
          ),
        },
      );

  @override
  Future<CallToolResult> execute(
    Map<String, dynamic> args,
    RequestHandlerExtra? extra,
  ) async {
    logger.info("pubdev_search> $args");

    final query = args['query'] as String;
    final limit = (args['limit'] as num?)?.toInt() ?? 5;
    final page = (args['page'] as num?)?.toInt() ?? 1;

    final uri = Uri.https('pub.dev', '/api/search', {
      'q': query,
      if (page > 1) 'page': '$page',
    });

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('pub.dev search failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final packages = (data['packages'] as List? ?? []).take(limit).toList();
    final next = data['next'];

    // 🔥 Parallel fetch of package details
    final futures = packages.map((item) async {
      final packageName = item['package'] as String;

      try {
        final pkgUri = Uri.https('pub.dev', '/api/packages/$packageName');
        final pkgResponse = await http.get(pkgUri);

        if (pkgResponse.statusCode != 200) {
          return {
            'name': packageName,
            'description': '',
            'latest_version': '',
            'url': 'https://pub.dev/packages/$packageName',
          };
        }

        final pkgData = jsonDecode(pkgResponse.body);
        final latest = pkgData['latest'];
        final pubspec = latest?['pubspec'];

        return {
          'name': packageName,
          'description': pubspec?['description'] ?? '',
          'latest_version': latest?['version'] ?? '',
          'url': 'https://pub.dev/packages/$packageName',
        };
      } catch (e) {
        return {
          'name': packageName,
          'description': '',
          'latest_version': '',
          'url': 'https://pub.dev/packages/$packageName',
        };
      }
    });

    final results = await Future.wait(futures);

    logger.info("pubdev_search.response> $results");

    return CallToolResult.fromStructuredContent({
      'results': results,
      if (next != null) 'next': next,
    });
  }
}
