import 'package:apollovm/apollovm.dart';
import 'package:mcp_dart/mcp_dart.dart';

import 'base_tool.dart';

/// Executes Dart code using ApolloVM.
class EvaluateDartCodeTool extends BaseTool {
  @override
  String get name => 'evaluate_dart_code';

  @override
  String get description =>
      'Executes Dart code dynamically using Apollo VM and returns the evaluated result of the code';

  @override
  ToolInputSchema get inputSchema => ToolInputSchema(
        properties: {
          'code': JsonSchema.string(
            description: r"""
Dart code to execute.

Rules:
- Must be valid Dart code
- No imports or external dependencies
- Can define functions and classes
- MUST NOT execute the function directly
- MUST only DEFINE the function to be invoked
- The function will be called separately using `function` and `parameters`

Important:
- Always structure the code so the desired entry point is a named function
- Do not include top-level execution (no direct calls)

Example (define only, do NOT call):

'''
int sum(int a, int b) {
  var r = a + b;
  print('r: $r');
  return r;
}
'''
""",
          ),
          'function': JsonSchema.string(
            description: """
Function name to invoke.

Rules:
- Must exactly match a function defined in `code`
- Must be a top-level function (not nested)
- Defaults to `main` if omitted

Example:
"sum"
""",
            defaultValue: 'main',
          ),
          'parameters': JsonSchema.array(
            description: r"""
Parameters to pass to the invoked function.

Rules:
- Must match the function signature exactly
- Order matters
- Use JSON-compatible values only

Example:
[5, 10]
""",
          ),
        },
        required: ['code'],
        description: r"""
Expected tool call format:

{
  "code": "<Dart code with function definitions only>",
  "function": "<function name>",
  "parameters": [<args>]
}

Example:

{
  "code": "int sum(int a, int b) {\n  var r = a + b;\n  print('r: $r');\n  return r;\n}",
  "function": "sum",
  "parameters": [5, 10]
}
""",
      );

  @override
  ToolOutputSchema? get outputSchema => ToolOutputSchema(
        properties: {
          'invokedFunction': JsonSchema.string(
            description: 'Name of the function that was invoked.',
          ),
          'result': JsonSchema.anyOf(
            [
              JsonSchema.string(),
              JsonSchema.number(),
              JsonSchema.integer(),
              JsonSchema.boolean(),
              JsonSchema.array(),
              JsonSchema.object(),
              JsonSchema.nullValue(),
            ],
            description: 'Execution result',
          ),
          'output': JsonSchema.array(
            items: JsonSchema.string(),
            description:
                'Captured stdout: one entry per print() call, in order',
          ),
        },
      );

  @override
  Future<CallToolResult> execute(
      Map<String, dynamic> args, RequestHandlerExtra? extra) async {
    logger.info("evaluate_dart_code> $args");

    final code = args['code'] as String;
    var function = (args['function'] as String?)?.trim();
    final parameters = args['parameters'] as List?;

    try {
      // Create VM
      final vm = ApolloVM();

      var codeUnit = SourceCodeUnit('dart', code);

      try {
        var loadOK = await vm.loadCodeUnit(codeUnit);

        if (!loadOK) {
          return CallToolResult(
            content: [
              TextContent(text: "Can't load code!"),
            ],
            isError: true,
          );
        }
      } catch (e) {
        return CallToolResult(
          content: [
            TextContent(text: 'Error loading code: $e'),
          ],
          isError: true,
        );
      }

      if (function == null || function.isEmpty) {
        var namespace = vm.getNamespace('dart', '');
        var loadedFunctions = namespace?.functions ?? [];

        logger.info(
            "evaluate_dart_code> Function variable was empty or null. Checking namespace loaded functions: $loadedFunctions");

        if (loadedFunctions.isEmpty) {
          function = 'main';
          logger.info(
              "evaluate_dart_code> No functions found in 'dart' namespace. Setting function to default 'main'.");
        } else if (loadedFunctions.length == 1) {
          function = loadedFunctions.first;
          logger.info(
              "evaluate_dart_code> Single function found in 'dart' namespace. Setting function to: $function");
        } else {
          // Log which function was chosen when multiple exist
          function = loadedFunctions.last;
          logger.info(
              "evaluate_dart_code> Multiple functions found (count: ${loadedFunctions.length}). Setting function to the last loaded: $function");
        }
      }

      final dartRunner = vm.createRunner('dart')!;

      final output = <String>[];

      // Map the `print` function in the VM:
      dartRunner.externalPrintFunction = (o) => output.add('$o');

      logger.info(
          "evaluate_dart_code> executing function: $function( ${parameters != null ? parameters.join(', ') : ''} )");

      final astValue = await dartRunner.executeFunction(
        '',
        function,
        positionalParameters: parameters,
      );

      final value = astValue.getValueNoContext();

      logger.info("evaluate_dart_code> result: $value");

      final result = toJsonType(value) ?? value;

      logger.info("evaluate_dart_code> result as json: $result");

      logger.info("evaluate_dart_code> output: <<<\n${output.join('\n')}\n>>>");

      return CallToolResult.fromStructuredContent({
        'invokedFunction': function,
        'result': result,
        'output': output,
      });
    } catch (e, s) {
      logger.severe(
          "evaluate_dart_code> ERROR calling function: $function( ${parameters != null ? parameters.join(', ') : ''} )",
          e,
          s);

      return CallToolResult(
        content: [
          TextContent(text: 'Failed to execute Dart code: $e\n$s'),
        ],
        isError: true,
      );
    }
  }
}
