/// MCP tools for the server.
library;

import 'base_tool.dart';
import 'date_time_tool.dart';
import 'evaluate_dart_code.dart';
import 'evaluate_expression.dart';
import 'fetch_url_tool.dart';
import 'pubdev_search_tool.dart';
import 'wikipedia_search_tool.dart';

export 'base_tool.dart';

/// Creates all available tools.
List<BaseTool> createAllTools() => [
      UrlFetchTool(),
      WikipediaSearchTool(),
      EvaluateExpressionTool(),
      EvaluateDartCodeTool(),
      PubDevSearchTool(),
      DateTimeTool(),
    ];
