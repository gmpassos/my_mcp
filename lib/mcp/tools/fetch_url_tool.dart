import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:mcp_dart/mcp_dart.dart';

import 'base_tool.dart';

/// Fetches a URL and returns its content.
class UrlFetchTool extends BaseTool {
  @override
  String get name => 'fetch_url';

  @override
  ToolAnnotations? get annotations =>
      ToolAnnotations(title: 'URL fetcher', openWorldHint: true);

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
            defaultValue: true,
          ),
          'stripWikipedia': JsonSchema.boolean(
            description:
                'If true and the URL is a Wikipedia page, extracts and cleans the main article content (removes sidebars, navboxes, references, etc.)',
            defaultValue: true,
          ),
          // 'asMarkdown': JsonSchema.boolean(
          //   description:
          //       'If true, converts HTML content to Markdown (preserving links and images)',
          //   defaultValue: false,
          // ),
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

  @override
  Future<CallToolResult> execute(
    Map<String, dynamic> args,
    RequestHandlerExtra? extra,
  ) async {
    logger.info("fetch_url> $args");

    final url = Uri.parse(args['url'] as String);
    final timeoutMs = (args['timeoutMs'] as num?)?.toInt() ?? 10000;
    final stripHtml = args['stripHtml'] as bool? ?? true;
    final stripWikipedia = args['stripWikipedia'] as bool? ?? true;
    // final asMarkdown = args['asMarkdown'] as bool? ?? false;

    final response =
        await http.get(url).timeout(Duration(milliseconds: timeoutMs));

    final contentType = response.headers['content-type'] ?? '';
    var body = response.body;

    final isHtml = contentType.contains('text/html');

    if (isHtml) {
      if (stripWikipedia && url.host.endsWith('.wikipedia.org')) {
        body = extractWikipediaMainContent(body);
      }

      if (stripHtml) {
        body = stripHtmlTags(body);
      }
    }

    // if (asMarkdown && body.trim().isNotEmpty) {
    //   logger.info("Converting to markdown...");
    //
    //   var markdown = await prompt(body, system: const [
    //     'Convert the input into clean, readable Markdown. '
    //         'Preserve structure such as headings, paragraphs, lists, tables, links, and images when present. '
    //         'If the input is HTML, remove tags and convert appropriately. '
    //         'If the input is plain text or another format, normalize it into well-structured Markdown. '
    //         'Do not add explanations. Output only Markdown.'
    //   ]);
    //
    //   if (markdown != null) {
    //     logger.info("Converted to markdown");
    //     body = markdown;
    //   }
    // }

    logger.info("fetch_url.response[$contentType]> $body");

    return CallToolResult.fromStructuredContent({
      'statusCode': response.statusCode,
      'body': body,
      'contentType': contentType,
      'finalUrl': response.request?.url.toString() ?? url.toString(),
    });
  }

  String extractWikipediaMainContent(String html) {
    final document = html_parser.parse(html);

    final content = document.querySelector('#bodyContent');
    if (content == null) return html;

    // Remove noisy elements
    content
        .querySelectorAll(
            // navigation / layout
            '.navbox, .vertical-navbox, .sidebar, .metadata, '

            // editing / UI
            '.mw-editsection, .mw-jump-link, '

            // references / citations
            '.reference, .reflist, '

            // media / thumbnails
            '.thumb, .gallery, '

            // tables that are not core text
            'table.infobox, table.navbox, '

            // citations
            '.mw-references-wrap, '

            // scripts/styles
            'style, script')
        .forEach((e) => e.remove());

    return content.innerHtml.trim();
  }
}
