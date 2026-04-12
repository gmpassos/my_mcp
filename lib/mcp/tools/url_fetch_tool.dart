import 'package:http/http.dart' as http;
import 'package:mcp_dart/mcp_dart.dart';

import 'base_tool.dart';

/// Fetches a URL and returns its content.
class UrlFetchTool extends BaseTool {
  @override
  String get name => 'fetch_url';

  @override
  String get description => 'Fetches the content of a URL via HTTP GET';

  @override
  ToolInputSchema get inputSchema => ToolInputSchema(
        properties: {
          'url': JsonSchema.string(description: 'URL to fetch'),
          'timeoutMs': JsonSchema.number(
            description: 'Optional timeout in milliseconds',
          ),
          'stripHtml': JsonSchema.boolean(
            description: 'If true, removes HTML tags from response body',
          ),
        },
        required: ['url'],
      );

  @override
  ToolOutputSchema? get outputSchema => ToolOutputSchema(
        properties: {
          'statusCode': JsonSchema.number(description: 'HTTP status code'),
          'body': JsonSchema.string(description: 'Response body'),
          'contentType': JsonSchema.string(description: 'Content-Type header'),
          'finalUrl': JsonSchema.string(description: 'Final resolved URL'),
        },
      );

  String _stripHtmlTags(String input) {
    return input
        .replaceAll(
            RegExp(r'<script[^>]*>.*?</script>',
                caseSensitive: false, dotAll: true),
            '')
        .replaceAll(
            RegExp(r'<style[^>]*>.*?</style>',
                caseSensitive: false, dotAll: true),
            '')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll(RegExp(r'\s+\n'), '\n')
        .replaceAll(RegExp(r'\n\s+'), '\n')
        .trim();
  }

  @override
  Future<CallToolResult> execute(
    Map<String, dynamic> args,
    RequestHandlerExtra? extra,
  ) async {
    logger.info("fetch_url> $args");

    final url = Uri.parse(args['url'] as String);
    final timeoutMs = (args['timeoutMs'] as num?)?.toInt() ?? 10000;
    final stripHtml = args['stripHtml'] as bool? ?? false;

    final response =
        await http.get(url).timeout(Duration(milliseconds: timeoutMs));

    final contentType = response.headers['content-type'] ?? '';
    var body = response.body;

    final isHtml = contentType.contains('text/html');

    if (stripHtml && isHtml) {
      body = _stripHtmlTags(body);
    }

    logger.info("fetch_url.response[$contentType]> $body");

    return CallToolResult.fromStructuredContent({
      'statusCode': response.statusCode,
      'body': body,
      'contentType': contentType,
      'finalUrl': response.request?.url.toString() ?? url.toString(),
    });
  }
}
