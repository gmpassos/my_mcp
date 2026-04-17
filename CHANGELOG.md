## 1.0.34

- Added new `FxCurrencyTool`:
  - Fetches currency exchange rates from fxapi.app without requiring an API key.
  - Supports querying by base currency or direct currency pairs.
  - Supports optional amount conversion and historical date queries.
  - Implements structured input and output schemas for currency conversion parameters and results.
  - Handles HTTP requests and JSON parsing with error handling.
- Updated `tools.dart`:
  - Added import and registration of `FxCurrencyTool` in the tool list.

## 1.0.33

- Added `GoogleScholarTool`:
  - Implements Google Scholar search via HTML scraping without API key.
  - Supports input parameters `query` (required) and optional `limit` (default 5).
  - Returns results with fields: `title`, `authors`, `year`, `url`, and `snippet`.
  - Uses user-agent header to mimic a browser for HTTP requests.
- Updated `tools.dart`:
  - Added import and registration of `GoogleScholarTool` in the tool list.

## 1.0.32

- Added new `GoogleNewsTool`:
  - Fetches news articles from Google News RSS without requiring an API key.
  - Supports input parameters: `query`, `country` (default `US`), `language` (default `en-US`), and optional `freshness` filter (`1h`, `1d`, `7d`).
  - Parses RSS XML feed to extract article `title`, `source`, `url`, and `publishedAt`.
  - Returns structured output with a list of news articles.
- `tools.dart`:
  - Registered `GoogleNewsTool` in the list of available tools.
- `pubspec.yaml`:
  - Added dependency on `xml` package version `^6.6.1` for XML parsing.

## 1.0.31

- `WikipediaSearchTool`:
  - Updated `description` to include that results return URLs to pages with more information.

## 1.0.30

- `DateTimeTool`:
  - `outputSchema`: updated description of `iso` field to "ISO 8601 datetime string".
  - `outputSchema`: added new output fields:
    - `time`: string, time in HH:mm:ss format.
    - `weekday`: string, day of the week (e.g. Monday).
  - `execute` method: included `time` and `weekday` in the returned structured content.
  - Added private helper method `_weekday(int)` to convert weekday integer to weekday name string.

## 1.0.29

- `date_time_tool.dart`:
  - `getLocation` method:
    - Fixed handling of `tzName` for 'GMT' and 'UTC' to call `timeZone.getLocationGMT()`.
    - Added support for returning main location by `countryCode` and optional `stateCode` if `tzName` is null.
    - Simplified fallback to GMT location when no parameters provided.

- `timezone.dart`:
  - `TimeZone` class:
    - Updated `getLocationGMT` to return `tz.UTC` instead of `tz.getLocation('GMT')`.
    - Minor formatting fixes.

## 1.0.28

- `date_time_tool.dart`:
  - `execute`: replaced inline timezone location resolution with `resolveLocation` method.
  - Added `resolveLocation` method to centralize timezone location resolution logic.
    - Throws `tz.LocationNotFoundException` if location for given country and state codes is not found.
    - Handles special cases for 'GMT' and 'UTC' timezone names.

- `timezone.dart`:
  - `TimeZone`:
    - `getLocationsByCountryCode`: added handling for 'GMT' and 'UTC' country codes returning GMT location.
    - `getLocation`: added handling for 'GMT' and 'UTC' country codes returning GMT location.
    - Normalized `countryCode` to uppercase and trimmed in `getLocation`.

## 1.0.27

- Added new `DateTimeTool`:
  - Returns current or relative date/time for a given location.
  - Supports input parameters: `countryCode`, `stateCode`, `timezone`, `dayOffset`, and `date` keyword.
  - Outputs ISO8601 datetime string, resolved timezone, date, time, and timezone offset in minutes.
  - Resolves timezone by IANA name or country/state codes with fallback to GMT.
  - Handles day offsets and keywords like "now", "today", "tomorrow", "yesterday".

- `TimeZone` utility:
  - Added copyright header.
  - Fixed indentation in location lists.
  - Corrected method `getLocationUSNewYork` to use 'America/New_York' timezone.
  - Fixed `toIso8601StringNoNanoseconds` extension on `tz.TZDateTime`:
    - Corrected offset formatting to include colon between hours and minutes.
    - Used offset in milliseconds for accurate calculation.
    - Improved variable naming for clarity.

- `WikipediaSearchTool`:
  - Updated `lang` input description to specify it must match the language of the `query` parameter and default to "en".

- Added dependency on `timezone` package version `^0.11.0` in `pubspec.yaml`.

## 1.0.26

- `EvaluateDartCodeTool`:
  - Updated `inputSchema` for `code` property:
    - Expanded restrictions to disallow imports, external dependencies, exceptions, throw, try/catch, null-safety operators, and async/await.

## 1.0.25

- Dependency updates:
  - `apollovm`: updated from ^0.1.9 to ^0.1.10

## 1.0.24

- Dependency updates:
  - `apollovm`: updated from ^0.1.8 to ^0.1.9

## 1.0.23

- Dependency updates:
  - `apollovm`: updated from ^0.1.7 to ^0.1.8

## 1.0.22

- Dependency updates:
  - Updated `apollovm` from ^0.1.6 to ^0.1.7.

## 1.0.21

- Dependency updates:
  - `apollovm`: updated from ^0.1.5 to ^0.1.6

## 1.0.20

- Dependency updates:
  - `apollovm`: updated from ^0.1.4 to ^0.1.5

## 1.0.19

- `evaluate_dart_code.dart`:
  - `execute` method:
    - Added progress reporting via `extra?.sendProgress` at multiple stages:
      - Starting ApolloVM initialization.
      - Loading code.
      - Code successfully loaded.
      - Resolving function to invoke.
      - Preparing VM runtime.
      - Defining `print` function.
      - Executing function with parameters.
      - Function execution completed with returned value type.
      - Resolved value type.
      - Resolved JSON return value type.

## 1.0.18

- Dependency updates:
  - Updated `apollovm` from ^0.1.3 to ^0.1.4 in `pubspec.yaml`.

## 1.0.17

- Dependency updates:
  - `apollovm`: updated from ^0.1.2 to ^0.1.3

## 1.0.16

- `EvaluateDartCodeTool`:
  - Updated `inputSchema` for `code` property:
    - Expanded and clarified rules for Dart code input.
    - Added detailed instructions emphasizing:
      - No imports or external dependencies.
      - Code must only define functions/classes without direct execution.
      - The function to invoke is specified separately.
    - Added multi-line example demonstrating proper function definition without invocation.
  - Updated `inputSchema` for `function` property:
    - Clarified rules requiring exact match to a top-level function defined in `code`.
    - Specified default is `main`.
  - Updated `inputSchema` for `parameters` property:
    - Clarified rules requiring exact match to function signature with JSON-compatible values.
  - Added overall `inputSchema` description with example JSON call format.
  - Improved error logging in `call` method to include stack trace and detailed function call info.

## 1.0.15

- `EvaluateDartCodeTool`:
  - Simplified input schema to a single `ToolInputSchema` allowing full Dart code execution with variables, functions, and classes.
  - Added `invokedFunction` field to output schema to indicate which function was executed.
  - Enhanced `execute` method:
    - Automatically determines which function to invoke if `function` argument is null or empty:
      - Uses `'main'` if no functions are found.
      - Uses the single function if only one is found.
      - Uses the last function if multiple are found, logging the choice.
    - Improved logging for function selection and execution steps.

## 1.0.14

- `EvaluateDartCodeTool`:
  - Updated `inputSchema` to support two modes: expression mode and function mode.
  - Added `inputSchemaExpressionMode` for executing Dart expressions that return a value without defining external functions.
  - Added `inputSchemaFunctionMode` for executing Dart code that can define functions, classes, and variables, with optional invocation of a named function and parameters.

- `UrlFetchTool`:
  - Added `annotations` with title "URL fetcher" and `openWorldHint` set to true.

- `PubDevSearchTool`:
  - Added `annotations` with title "pub.dev search", `openWorldHint` and `readOnlyHint` set to true.

- `WikipediaSearchTool`:
  - Added `annotations` with title "wikipedia.org search", `openWorldHint` and `readOnlyHint` set to true.

## 1.0.13

- `evaluate_dart_code.dart`:
  - `execute` method:
    - Added capturing of `print()` output from executed Dart code by mapping `print` to a local list.
    - Included captured stdout lines in the returned structured content under the `output` field.
    - Added `output` field to the JSON schema describing the execution result.

## 1.0.12

- `BaseTool`:
  - `tryJsonDecode`: fixed to decode JSON string instead of encoding.
  - Added `tryJsonEncode` to safely encode objects to JSON string.
  - Added `toJsonType` to convert arbitrary objects to JSON-compatible types.
- Added new tool `EvaluateDartCodeTool`:
  - Executes Dart code dynamically using Apollo VM.
  - Supports specifying code, function name, and parameters.
  - Returns the evaluated result as JSON-compatible output.
- `tools.dart`:
  - Added `EvaluateDartCodeTool` to the list of available tools.
- `pubspec.yaml`:
  - Added dependency on `apollovm` package ^0.1.2.
  - Added `publish_to: none`.
  - Added `dependency_overrides` for `freezed_annotation` ^3.1.0.

## 1.0.11

- `BaseTool`:
  - `stripHtmlTags`:
    - Added extraction and temporary replacement of `<pre>` blocks to preserve them during tag stripping.
    - Updated regexes for `<br>` and `<p>` tags to allow attributes.
    - Improved `<a>` and `<img>` tag handling with consolidated regex formatting.
    - Restored `<pre>` blocks after cleaning other HTML tags.

## 1.0.10

- `UrlFetchTool`:
  - Disabled the `asMarkdown` option in the input schema and commented out related code that converts HTML content to Markdown.
- `run-llama-server.bat`:
  - Updated server launch commands:
    - Changed model from `gemma-4-E2B-it-Q4_K_M.gguf` to `gemma-4-E4B-it-Q4_K_M.gguf`.
    - Increased `--ctx-size` to 128000.
    - Added `--parallel 2` and `--tensor-split 1,0` options for multi-GPU usage.
    - Adjusted `-ngl` and `-b` parameters for performance tuning.

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

