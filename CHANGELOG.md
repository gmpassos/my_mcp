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

