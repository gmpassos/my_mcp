/// Base class for MCP tools with dependency injection.
///
/// Each tool implementation should extend this class and provide:
/// - [name]: Unique tool identifier
/// - [description]: Human-readable description of what the tool does
/// - [inputSchema]: JSON schema for tool arguments
/// - [outputSchema]: Optional JSON schema for tool output
/// - [annotations]: Optional tool behavior hints (readOnly, destructive, etc.)
/// - [meta]: Optional metadata for the tool
/// - [execute]: Implementation of the tool logic
library;

import 'dart:convert';

import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:logging/logging.dart' as logging;
import 'package:mcp_dart/mcp_dart.dart';

/// Base class for all MCP tools.
abstract class BaseTool {
  /// Unique name for this tool.
  String get name;

  late final logger = logging.Logger('Tool[$name]');

  /// Human-readable description of what this tool does.
  String get description;

  /// JSON schema defining the input arguments.
  /// Use [JsonSchema.object()] to create an object schema.
  ToolInputSchema get inputSchema;

  /// Optional JSON schema defining the output format.
  /// Use [JsonSchema.object()] to create an object schema.
  ToolOutputSchema? get outputSchema => null;

  /// Optional tool annotations with hints about tool behavior.
  /// Includes readOnlyHint, destructiveHint, idempotentHint, etc.
  ToolAnnotations? get annotations => null;

  /// Optional metadata for the tool.
  Map<String, dynamic>? get meta => null;

  /// Execute the tool with the given arguments.
  ///
  /// Returns a [CallToolResult] with either success content or an error.
  Future<CallToolResult> execute(
      Map<String, dynamic> args, RequestHandlerExtra? extra);

  String stripHtmlTags(String input) {
    final preBlocks = <String>[];

    var mark = '___STRIP_PRE_BLOCK';
    while (input.contains(mark)) {
      mark += '-';
    }

    mark = '${mark}__';

    // 1. Extract <pre> blocks
    input = input.replaceAllMapped(
      RegExp(r'<pre[^>]*>.*?</pre>', caseSensitive: false, dotAll: true),
      (m) {
        final token = '$mark${preBlocks.length}___';
        preBlocks.add(m[0]!);
        return token;
      },
    );

    input = input
        .replaceAll(
            RegExp(r'<script[^>]*>.*?</script>',
                caseSensitive: false, dotAll: true),
            '')
        .replaceAll(
            RegExp(r'<style[^>]*>.*?</style>',
                caseSensitive: false, dotAll: true),
            '')
        .replaceAll(RegExp(r'<br[^>]*>'), '\n')
        .replaceAll(RegExp(r'<p[^>]*>'), '\n\n')
        // <a> → [text](url)
        .replaceAllMapped(
          RegExp(r'<a[^>]*href="([^"]+)"[^>]*>(.*?)</a>',
              caseSensitive: false, dotAll: true),
          (m) => '[${m[2]}](${m[1]})',
        )
        // <img> → ![alt](src)
        .replaceAllMapped(
          RegExp(r'<img[^>]*src="([^"]+)"[^>]*alt="([^"]*)"[^>]*>',
              caseSensitive: false),
          (m) => '![${m[2]}](${m[1]})',
        )
        .replaceAllMapped(
          RegExp(r'<img[^>]*src="([^"]+)"[^>]*>', caseSensitive: false),
          (m) => '![](${m[1]})',
        )
        // remove remaining tags
        .replaceAll(RegExp(r'<[^>]+>'), '');

    input = cleanBlankLines(input).trim();

    // 2. Restore <pre> blocks unchanged
    for (var i = 0; i < preBlocks.length; i++) {
      input = input.replaceAll(
        '$mark${i}___',
        preBlocks[i],
      );
    }

    return input;
  }

  String cleanSnippet(String html) {
    html = html
        .replaceAll(RegExp(r'<[^>]+>'), '') // remove HTML tags
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
    html = cleanBlankLines(html).trim();
    return html;
  }

  String cleanBlankLines(String html) {
    return html
        .replaceAll(RegExp(r'(?:\n[ \t]+)+\n'), '\n')
        .replaceAll(RegExp(r'\n[ \t]+'), '\n')
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .replaceAll(RegExp(r'\n+'), '\n');
  }

  Object? tryJsonDecode(String j) {
    try {
      return json.decode(j);
    } catch (_) {
      return null;
    }
  }

  String? tryJsonEncode(Object? o) {
    try {
      return json.encode(o);
    } catch (_) {
      return null;
    }
  }

  Object? toJsonType(Object? o) {
    try {
      var j = tryJsonEncode(o);
      if (j == null) return null;
      return tryJsonDecode(j);
    } catch (_) {
      return null;
    }
  }

  Future<String?> prompt(String prompt,
      {List<String> system = const ['You are a helpful assistant.'],
      double temperature = 0.7,
      String llmServerURL = 'http://localhost:8080/v1'}) async {
    final llm = ChatOpenAI(
      baseUrl: llmServerURL,
      defaultOptions: ChatOpenAIOptions(
        temperature: temperature,
      ),
    );

    final messages = [
      ...system.map((e) => ChatMessage.system(e)),
      ChatMessage.human(ChatMessageContent.text(prompt)),
    ];

    final response = await llm.invoke(PromptValue.chat(messages));

    var output = response.outputAsString;

    return output;
  }
}

/// Extension to register tools with an MCP server.
extension ToolRegistration on McpServer {
  /// Register a [BaseTool] with this server.
  void registerBaseTool(BaseTool tool) {
    registerTool(
      tool.name,
      description: tool.description,
      inputSchema: tool.inputSchema,
      outputSchema: tool.outputSchema,
      annotations: tool.annotations,
      meta: tool.meta,
      callback: (args, extra) => tool.execute(args, extra),
    );
  }
}
