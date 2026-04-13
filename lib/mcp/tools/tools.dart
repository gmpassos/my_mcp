/// MCP tools for the server.
library;

import 'base_tool.dart';
import 'calculator_tool.dart';
import 'pubdev_tool.dart';
import 'url_fetch_tool.dart';
import 'wikipedia_tool.dart';

export 'base_tool.dart';
export 'calculator_tool.dart';

/// Creates all available tools.
List<BaseTool> createAllTools() => [
      CalculatorTool(),
      UrlFetchTool(),
      PubDevSearchTool(),
      WikipediaSearchTool(),
    ];
