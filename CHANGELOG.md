## 1.0.9

- `BaseTool`:
  - Added `tryJsonDecode` method to attempt JSON encoding of a string.
  - Added `prompt` method to send prompts to a ChatOpenAI model with configurable system messages, temperature, and server URL.
  - Imported `dart:convert`, `langchain`, and `langchain_openai` packages for JSON and LLM support.

- `UrlFetchTool`:
  - Added `asMarkdown` boolean input argument to optionally convert HTML content to Markdown.
  - Updated `execute` method to:
    - Convert fetched HTML content to Markdown using the `prompt` method if `asMarkdown` is true.
    - Preserve links, images, and structure in the Markdown conversion.
    - Log conversion steps.

## 1.0.8

- `bin/prompt_local.dart`:
  - Added timing measurement for prompt execution duration.
  - Added detailed logging including prompt input, messages sent, request status, and raw response.
  - Refactored prompt message construction into a `messages` list.
  - Improved error handling with stacktrace output.
  - Introduced `tryJsonDecode` helper to safely encode response output as JSON for debug logging.
  - Changed hardcoded base URL and API key to use a constant `llmServerURL` and removed unnecessary API key.
  - Added usage error message when no prompt argument is provided.

## 1.0.7

- Added new CLI tool `bin/prompt_local.dart`:
  - Uses `ChatOpenAI` from `langchain_openai` to send a prompt to a local LLM server.
  - Connects to local server at `http://localhost:8080/v1` with model `local-model`.
  - Handles input prompt from command line arguments and outputs the LLM response.
  - Includes error handling with appropriate exit codes.

- Dependencies:
  - Added `langchain` ^0.8.1.
  - Added `langchain_openai` ^0.8.1+1.

## 1.0.6

- `PubDevSearchTool`:
  - Updated `description` to provide more detailed information about the search capabilities and returned metadata, including name, description, latest version, popularity, and score.
  - Clarified usage for finding Dart and Flutter libraries, plugins, and dependencies.

## 1.0.5

- Added new `EvaluateExpressionTool`:
  - Evaluates mathematical expressions with support for variables and functions.
  - Supports operators (+, -, *, /, %, ^), parentheses, constants (pi, e), and standard math functions (sin, cos, tan, log, sqrt, etc.).
  - Accepts variables as a map for substitution in expressions.
  - Returns the numeric evaluation result or an error message on failure.

- `tools.dart`:
  - Removed `CalculatorTool`.
  - Added `EvaluateExpressionTool`.
  - Updated imports to reflect renamed and reordered tools (`fetch_url_tool.dart`, `pubdev_search_tool.dart`, `wikipedia_search_tool.dart`).

- Dependencies:
  - Added `math_expressions` package version ^3.1.0.

## 1.0.4

- `UrlFetchTool`:
  - `extractWikipediaMainContent`:
    - Changed main content selector from `.mw-parser-output` to `#bodyContent`.
    - Expanded removal of noisy elements to include:
      - Navigation/layout: `.navbox`, `.vertical-navbox`, `.sidebar`, `.metadata`.
      - Editing/UI: `.mw-editsection`, `.mw-jump-link`.
      - References/citations: `.reference`, `.reflist`, `.mw-references-wrap`.
      - Media/thumbnails: `.thumb`, `.gallery`.
      - Non-core text tables: `table.infobox`, `table.navbox`.
      - Scripts and styles: `style`, `script`.

## 1.0.3

- `UrlFetchTool`:
  - Added `stripWikipedia` input option to extract and clean main article content from Wikipedia pages.
  - Updated `execute` method to:
    - Detect Wikipedia URLs and extract main content by removing sidebars, navboxes, references, and other clutter.
    - Apply HTML stripping after Wikipedia content extraction if `stripHtml` is true.
  - Added private method `extractWikipediaMainContent` to parse and clean Wikipedia HTML content.
- Dependencies:
  - Added `html` package ^0.15.6 for HTML parsing.

## 1.0.2

- `BaseTool`:
  - `stripHtmlTags`: updated to clean blank lines after removing HTML tags.
  - Added new methods:
    - `cleanSnippet`: removes HTML tags and decodes common HTML entities, then cleans blank lines.
    - `cleanBlankLines`: normalizes and removes excessive blank lines and whitespace in strings.

- `WikipediaSearchTool`:
  - Replaced internal `_cleanSnippet` method with `BaseTool.cleanSnippet` for snippet cleaning in search results.

## 1.0.1

- `.gitignore`:
  - Added ignores for `.DS_Store` and `*.exe` files.

- `BaseTool` (`lib/mcp/tools/base_tool.dart`):
  - Added `stripHtmlTags` method to clean HTML content, converting links and images to markdown and removing scripts/styles.

- `PubDevSearchTool` (`lib/mcp/tools/pubdev_tool.dart`):
  - Added new tool to search pub.dev packages with metadata including name, description, latest version, and URL.
  - Supports pagination and limits results.
  - Fetches package details in parallel.

- `WikipediaSearchTool` (`lib/mcp/tools/wikipedia_tool.dart`):
  - Added new tool to search Wikipedia articles with summaries.
  - Supports language selection and result limits.
  - Cleans HTML snippets from Wikipedia search results.

- `UrlFetchTool` (`lib/mcp/tools/url_fetch_tool.dart`):
  - Updated default `stripHtml` parameter to `true`.
  - Replaced internal HTML stripping with `BaseTool.stripHtmlTags` method for consistent HTML cleanup.

- `tools.dart` (`lib/mcp/tools/tools.dart`):
  - Registered new tools: `PubDevSearchTool` and `WikipediaSearchTool`.

- `pubspec.yaml`:
  - Added dependency on `http` package version `^1.6.0`.

- `webui-config.json`:
  - Added configuration for MCP server connection to `http://localhost:3000/mcp` with proxy enabled.

